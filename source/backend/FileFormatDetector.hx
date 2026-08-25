package backend;

import backend.FilePath.FilePathExtension;
import haxe.io.Bytes;
import lime.graphics.Image;
import lime.media.AudioBuffer;

#if (sys && !android && !ios)
import sys.FileSystem;
import sys.io.File;
#end

#if !(sys && !android && !ios)
import lime.utils.Assets;
#end

/**
 * Detects supported binary asset formats using Lime's own format sniffing.
 *
 * This intentionally treats the filename extension as a discovery hint only.
 * Lime already contains internal header checks used by its image/audio loading
 * paths, so this class reuses those checks instead of maintaining another list
 * of magic numbers in the game.
 *
 * NOTE: `Image.__isPNG` and `AudioBuffer.__getCodec` are internal Lime APIs.
 * `@:access` is used deliberately on this experimental branch so the project
 * can compare this approach against a third-party detector such as whatformat.
 */
@:access(lime.graphics.Image)
@:access(lime.media.AudioBuffer)
class FileFormatDetector
{
	private static inline var HEADER_LENGTH:Int = 16;

	/**
	 * Returns whether this detector knows how to classify the extension using
	 * the formats currently supported by the game.
	 * @param extension Extension to check.
	 * @return true for PNG, OGG, MP3 and WAV.
	 */
	public static function supportsExtension(extension:FilePathExtension):Bool
	{
		return switch (extension)
		{
			case PNG | OGG | MP3 | WAV: true;
			default: false;
		};
	}

	/**
	 * Detects the real supported format from file bytes.
	 *
	 * Image classification uses the same private checks Lime uses before
	 * decoding image bytes on HTML5. Audio classification uses Lime's own
	 * `AudioBuffer.__getCodec`, which recognizes Ogg, WAV and multiple MP3
	 * frame/header variants.
	 *
	 * @param bytes File bytes or at least the initial header bytes.
	 * @return Detected extension, or NONE if unsupported/unknown.
	 */
	public static function detectBytes(bytes:Bytes):FilePathExtension
	{
		if (bytes == null || bytes.length == 0)
			return NONE;

		try
		{
			if (Image.__isPNG(bytes))
				return PNG;

			// Do not reinterpret other image formats as audio just because the
			// current game only exposes PNG in FilePathExtension.
			if (Image.__isJPG(bytes) || Image.__isGIF(bytes) || Image.__isWebP(bytes))
				return NONE;
		}
		catch (error:Dynamic)
		{
			// A short or malformed header is simply not identified as an image.
		}

		try
		{
			return switch (AudioBuffer.__getCodec(bytes))
			{
				case "audio/ogg": OGG;
				case "audio/mp3": MP3;
				case "audio/wav": WAV;
				default: NONE;
			};
		}
		catch (error:Dynamic)
		{
			#if debug
			trace('Lime could not classify binary header: $error');
			#end
			return NONE;
		}
	}

	/**
	 * Detects a supported format from a resolved path.
	 *
	 * Desktop targets read only a small prefix because Lime's current image and
	 * audio header sniffers need no more than the beginning of the file. Packed
	 * targets obtain bytes through Lime Assets, then pass only the same prefix to
	 * the detector.
	 *
	 * @param path Resolved resource path.
	 * @return Detected extension, or NONE when the resource cannot be read.
	 */
	public static function detectPath(path:String):FilePathExtension
	{
		if (path == null || path.length == 0)
			return NONE;

		#if (sys && !android && !ios)
		if (!FileSystem.exists(path) || FileSystem.isDirectory(path))
			return NONE;

		var input = File.read(path, true);
		var header = Bytes.alloc(HEADER_LENGTH);
		var bytesRead:Int = 0;

		try
		{
			bytesRead = input.readBytes(header, 0, HEADER_LENGTH);
		}
		catch (error:haxe.io.Eof)
		{
			// `readBytes` may throw after reading a short file. Re-open below with
			// the safe whole-file path for tiny inputs.
		}

		input.close();

		if (bytesRead > 0)
			return detectBytes(header.sub(0, bytesRead));

		try
		{
			var bytes = File.getBytes(path);
			return detectBytes(bytes.length > HEADER_LENGTH ? bytes.sub(0, HEADER_LENGTH) : bytes);
		}
		catch (error:Dynamic)
		{
			return NONE;
		}
		#else
		try
		{
			var bytes = Assets.getBytes(path);
			if (bytes == null)
				return NONE;
			return detectBytes(bytes.length > HEADER_LENGTH ? bytes.sub(0, HEADER_LENGTH) : bytes);
		}
		catch (error:Dynamic)
		{
			#if debug
			trace('Could not read asset bytes for Lime format detection: $path ($error)');
			#end
			return NONE;
		}
		#end
	}

	/**
	 * Resolves an extension using the actual file header when possible.
	 * @param path Resolved resource path.
	 * @param declaredExtension Extension implied by the filename.
	 * @return Header-detected extension, or declared extension as fallback.
	 */
	public static function resolveExtension(path:String, declaredExtension:FilePathExtension):FilePathExtension
	{
		if (!supportsExtension(declaredExtension))
			return declaredExtension;

		var detected = detectPath(path);
		return detected != NONE ? detected : declaredExtension;
	}
}
