package backend;

import backend.FilePath.FilePathExtension;
import backend.FilePath.FilePathType;

/**
 * Result of resolving a binary resource.
 *
 * `declaredExtension` is what the filename claims to be.
 * `extension` is the format Lime detected from the file bytes.
 */
typedef ResolvedBinaryResource =
{
	var path:String;
	var declaredExtension:FilePathExtension;
	var extension:FilePathExtension;
}

/**
 * Resolves supported binary resources without trusting their file extension.
 *
 * Discovery still uses the extensions the game knows how to encounter, but
 * classification is delegated to FileFormatDetector, which reuses Lime's own
 * image/audio header checks.
 */
class FileResourceResolver
{
	private static var binaryExtensions:Array<FilePathExtension> = [PNG, OGG, MP3, WAV];

	/**
	 * Finds a binary resource and classifies its real format from its bytes.
	 *
	 * Every supported binary filename extension is checked intentionally. This
	 * allows cases such as `texture.mp3` containing PNG bytes or `music.wav`
	 * containing Ogg bytes while still keeping discovery bounded to formats the
	 * project currently knows about.
	 *
	 * @param fileName File name without extension.
	 * @param type Directory/category to search.
	 * @param ignoreMod Whether to skip the mods directory.
	 * @return Resolved path and declared/real extension, or null if none validate.
	 */
	public static function resolveBinary(fileName:String, type:FilePathType, ignoreMod:Bool = false):ResolvedBinaryResource
	{
		for (declaredExtension in binaryExtensions)
		{
			var path = FilePath.getFile(fileName, declaredExtension, type, ignoreMod);
			if (path == null)
				continue;

			var detectedExtension = FileFormatDetector.detectPath(path);
			if (detectedExtension == NONE)
			{
				#if debug
				trace('Lime could not identify binary resource: $path');
				#end
				continue;
			}

			#if debug
			if (detectedExtension != declaredExtension)
			{
				trace('File extension mismatch: $path claims ${FilePath.getExtension(declaredExtension)}, Lime detects ${FilePath.getExtension(detectedExtension)}');
			}
			#end

			return {
				path: path,
				declaredExtension: declaredExtension,
				extension: detectedExtension
			};
		}

		return null;
	}

	/**
	 * Resolves one already-found resource's effective extension.
	 * @param path Resolved resource path.
	 * @param declaredExtension Filename extension.
	 * @return Lime-detected extension when available, otherwise declared value.
	 */
	public static function resolveExtension(path:String, declaredExtension:FilePathExtension):FilePathExtension
	{
		return FileFormatDetector.resolveExtension(path, declaredExtension);
	}
}
