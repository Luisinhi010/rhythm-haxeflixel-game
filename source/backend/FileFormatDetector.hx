package backend;

import backend.FilePath.FilePathExtension;
import haxe.io.Bytes;
import haxe.io.Eof;
import WhatFormat;

#if (sys && !android && !ios)
import sys.FileSystem;
import sys.io.File;
#else
import lime.utils.Assets;
#end

/**
 * Detects the real format of supported binary assets from their file header.
 *
 * File extensions are treated as hints only. WhatFormat performs the magic
 * number/header check, while this class maps its string result back to the
 * game's type-safe FilePathExtension enum.
 */
class FileFormatDetector
{
	private static var supportedFormats:Array<String> = ["png", "ogg", "mp3", "wav"];

	/**
	 * Returns whether this detector can validate the given extension by header.
	 * @param extension The extension to check.
	 * @return true when WhatFormat has a matching detector used by this project.
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
	 * Detects a supported file format from bytes.
	 * @param bytes File bytes. WhatFormat stops once the header is decisive.
	 * @return The detected FilePathExtension, or NONE when it cannot be identified.
	 */
	public static function detectBytes(bytes:Bytes):FilePathExtension
	{
		if (bytes == null || bytes.length == 0)
			return NONE;

		var detector = new WhatFormat(supportedFormats);
		var result = detector.checkHeaderBytes(bytes);
		return result.found ? fromWhatFormat(result.format) : NONE;
	}

	/**
	 * Detects a supported file format from a path.
	 *
	 * Desktop targets stream only the small header needed by WhatFormat instead
	 * of reading the whole asset. Packaged/mobile/web targets use Lime's asset
	 * byte API because a normal filesystem path is not guaranteed there.
	 *
	 * @param path The resolved asset path.
	 * @return The detected FilePathExtension, or NONE when unavailable/unknown.
	 */
	public static function detectPath(path:String):FilePathExtension
	{
		if (path == null || path.length == 0)
			return NONE;

		#if (sys && !android && !ios)
		if (!FileSystem.exists(path) || FileSystem.isDirectory(path))
			return NONE;

		var detector = new WhatFormat(supportedFormats);
		var input = File.read(path, true);

		try
		{
			while (detector.proceed)
				detector.checkNextByte(input.readByte());
		}
		catch (error:Eof)
		{
			// A short/empty file simply remains unidentified.
		}

		input.close();
		return detector.byHeader.found ? fromWhatFormat(detector.byHeader.format) : NONE;
		#else
		try
		{
			return detectBytes(Assets.getBytes(path));
		}
		catch (error:Dynamic)
		{
			#if debug
			trace('Could not read bytes for format detection: $path ($error)');
			#end
			return NONE;
		}
		#end
	}

	/**
	 * Resolves an extension using file contents when possible.
	 * @param path The resolved asset path.
	 * @param declaredExtension The extension implied by the filename.
	 * @return Header-detected extension when available, otherwise the declared one.
	 */
	public static function resolveExtension(path:String, declaredExtension:FilePathExtension):FilePathExtension
	{
		if (!supportsExtension(declaredExtension))
			return declaredExtension;

		var detected = detectPath(path);
		return detected != NONE ? detected : declaredExtension;
	}

	private static function fromWhatFormat(format:String):FilePathExtension
	{
		return switch (format)
		{
			case "png": PNG;
			case "ogg": OGG;
			case "mp3": MP3;
			case "wav": WAV;
			default: NONE;
		};
	}
}
