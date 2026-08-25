package backend;

import backend.FilePath.FilePathExtension;
import backend.FilePath.FilePathType;

/**
 * Result of resolving a binary resource.
 *
 * `declaredExtension` is what the filename claims to be.
 * `extension` is what the file header says it actually is.
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
 * The resolver first searches filenames using extensions the project knows how
 * to encounter, then lets FileFormatDetector/WhatFormat classify the contents.
 * This keeps discovery cheap while making magic/header bytes authoritative.
 */
class FileResourceResolver
{
	private static var binaryExtensions:Array<FilePathExtension> = [PNG, OGG, MP3, WAV];

	/**
	 * Finds a binary resource and classifies its real format from its header.
	 *
	 * This intentionally checks every supported binary filename extension, not
	 * only the extensions normally associated with `type`. A file named
	 * `example.mp3` can therefore still resolve as PNG if its bytes are PNG.
	 *
	 * @param fileName File name without extension.
	 * @param type Directory/category to search (IMAGES, MUSIC, SOUNDS, etc.).
	 * @param ignoreMod Whether to skip the mods directory.
	 * @return Path plus declared/real extension, or null when nothing valid is found.
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
				trace('Could not verify file header: $path');
				#end
				continue;
			}

			#if debug
			if (detectedExtension != declaredExtension)
				trace('File extension mismatch: $path claims ${FilePath.getExtension(declaredExtension)}, header is ${FilePath.getExtension(detectedExtension)}');
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
	 * Verifies one already-resolved file while preserving its declared extension
	 * as a fallback when WhatFormat has no signature for it.
	 * @param path Resolved file path.
	 * @param declaredExtension Filename extension.
	 * @return The header-detected extension when known; otherwise the declared one.
	 */
	public static function resolveExtension(path:String, declaredExtension:FilePathExtension):FilePathExtension
	{
		return FileFormatDetector.resolveExtension(path, declaredExtension);
	}
}
