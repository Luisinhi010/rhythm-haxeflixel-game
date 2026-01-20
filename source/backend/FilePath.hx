package backend;

import core.utils.ArrayUtil;
import core.utils.StringUtil;

#if (sys && !android && !ios)
import sys.FileSystem;
import sys.io.File;
#else
import lime.utils.Assets;
#end

enum FilePathType // compatible File Paths
{
	CONFIG;
	DATA;
	FONTS;
	IMAGES;
	MUSIC;
	METADATA;
	NONE;
	SAVES;
	SCRIPTS;
	SHADERS;
	SOUNDS;
	// VIDEOS; //Not Available yet
	TEXT;
}

enum FilePathExtension // compatible File Extensions
{
	/* Images */
	PNG;
	// JPG; //Not Available yet //TODO
	// WEBP; //Not Available yet
	/* Audios/Sounds */
	OGG;
	MP3;
	WAV;
	/* Videos */
	// AVI;
	// WEBM;
	// MP4;
	/* Shaders */
	GLSL;
	/* Fonts */
	TTF;
	/* Texts */
	JSON;
	TXT;
	XML;
	SOL;
	HX;
	// Add more extensions as needed
	/* None */
	NONE;
}

class FilePath
{
	// This class is used to manage file paths in the game.
	// It provides static methods to get paths for various resources.
	/**
	 * Validates that a file name is not null or empty.
	 * @param fileName The file name to validate
	 * @return true if valid, false otherwise
	 */
	private static function isValidFileName(fileName:String):Bool
	{
		if (StringUtil.isEmpty(fileName))
		{
			#if debug
			throw "File name cannot be null or empty.";
			#end
			return false;
		}
		return true;
	}

	/**
	 * Resolves a file path, checking mods folder first, then assets.
	 * @param absPath The absolute path (relative to assets/ or mods/)
	 * @param type The file type
	 * @param ignoreMod Whether to skip mod folder check
	 * @return The resolved path, or null if not found
	 */
	private static function resolveFilePath(absPath:String, type:FilePathType, ignoreMod:Bool):String
	{
		var modPath = getMod() + absPath;
		var filePath = get() + absPath;

		if (!ignoreMod && existsPath(modPath, type))
			return modPath;

		if (existsPath(filePath, type))
			return filePath;

		return null;
	}

	/**
	 * Gets the array of extensions for a given file type.
	 * @param type The file type
	 * @return Array of possible extensions for that type
	 */
	private static function getExtensionsForType(type:FilePathType):Array<FilePathExtension>
	{
		return switch (type)
		{
			case IMAGES: [PNG];
			case SOUNDS | MUSIC: [MP3, OGG, WAV];
			case SHADERS: [GLSL];
			case FONTS: [TTF];
			case METADATA: [JSON];
			case CONFIG | DATA | SAVES | TEXT | SCRIPTS: [JSON, TXT, XML, SOL, HX];
			default: [];
		};
	}
	
	public static function getExtension(ext:FilePathExtension):String
	{
		if (ext == NONE)
			return "";
		return "." + Type.enumConstructor(ext).toLowerCase();
	}

	public static function getType(type:FilePathType):String
		return Type.enumConstructor(type).toLowerCase();

	public static function get():String
		return "assets/";

	public static function getMod():String
		return "mods/";

	public static function getTypeFromExt(ext:FilePathExtension):String
	{
		switch (ext)
		{
			case PNG /*| JPG | WEBP*/:
				return Type.enumConstructor(IMAGES);
			case GLSL:
				return Type.enumConstructor(SHADERS);
			case TTF:
				return Type.enumConstructor(FONTS);
			default:
				return Type.enumConstructor(NONE);
		}
	}

	public static function getPath(type:FilePathType):String
		switch (type)
		{
			case IMAGES:
				return "images/";
			case SOUNDS:
				return "sounds/";
			case MUSIC | METADATA:
				return "music/";
			// case VIDEOS:
			// return "assets/videos/";
			case SHADERS:
				return "shaders/";
			case FONTS:
				return "fonts/";
			case CONFIG:
				return "config/";
			case DATA:
				return "data/";
			case SAVES:
				return "saves/";
			default:
				return "";
		}

	public static function existsPath(path:String, type:FilePathType):Bool
	{
		var exists:Bool;
		#if (sys && !android && !ios)
		exists = FileSystem.exists(path);
		#else
		exists = Assets.exists(path);
		#end
		#if debug trace('Checking for ${path}: ${exists ? "Found" : "Not Found"}'); #end
		return exists;
	}

	public static function existsFile(fileName:String, ext:FilePathExtension, type:FilePathType, ignoreMod:Bool = false):Bool
	{
		if (!isValidFileName(fileName))
			return false;

		var absPath = getPath(type) + fileName + getExtension(ext);
		return resolveFilePath(absPath, type, ignoreMod) != null;
	}

	private static function findFirstExtension(fileName:String, extensions:Array<FilePathExtension>, type:FilePathType,
			ignoreMod:Bool = false):FilePathExtension
	{
		if (ArrayUtil.isEmpty(extensions))
			return NONE;
		for (ext in extensions)
		{
			if (existsFile(fileName, ext, type, ignoreMod))
				return ext;
		}
		return NONE;
	}

	public static function getFile(fileName:String, ext:FilePathExtension, type:FilePathType, ignoreMod:Bool = false):String
	{
		if (!isValidFileName(fileName))
			return null;

		#if debug trace("Getting file: " + fileName + getExtension(ext)); #end

		var absPath = getPath(type) + fileName + getExtension(ext);
		var result = resolveFilePath(absPath, type, ignoreMod);
		
		if (result == null)
		{
			#if debug trace("File not found: " + fileName + getExtension(ext)); #end
		}

		return result;
	}

	private static function getResourcePath(fileName:String, type:FilePathType, extensions:Array<FilePathExtension>, ignoreMod:Bool = false):String
	{
		if (!isValidFileName(fileName))
			return null;

		if (ArrayUtil.isEmpty(extensions))
		{
			#if debug
			trace('No extensions provided for type: ${Type.enumConstructor(type)}');
			#end
			return null;
		}

		#if debug trace("Getting path for: " + fileName + " (type: " + Type.enumConstructor(type) + ")"); #end

		var ext = findFirstExtension(fileName, extensions, type, ignoreMod);
		if (ext == NONE)
			return null;

		return getFile(fileName, ext, type, ignoreMod);
	}

	public static function getImagePath(imageName:String, ignoreMod:Bool = false):String
	{
		return getResourcePath(imageName, IMAGES, [PNG], ignoreMod);
	}

	public static function getSoundPath(soundName:String, ignoreMod:Bool = false):String
	{
		return getResourcePath(soundName, SOUNDS, [MP3, OGG, WAV], ignoreMod);
	}

	public static function getMusicPath(musicName:String, ignoreMod:Bool = false):String
	{
		return getResourcePath(musicName, MUSIC, [MP3, OGG, WAV], ignoreMod);
	}

	public static function getMusicDataPath(dataName:String, ignoreMod:Bool = false):String
	{
		var path = getResourcePath(dataName, METADATA, [JSON], ignoreMod);
		return path; // Only JSON is supported for music metadata, fow now...
	}

	public static function getShaderPath(shaderName:String, ignoreMod:Bool = false):String
	{
		return getResourcePath(shaderName, SHADERS, [GLSL], ignoreMod);
	}

	public static function getFontPath(fontName:String, ignoreMod:Bool = false):String
	{
		return getResourcePath(fontName, FONTS, [TTF], ignoreMod);
	}

	public static function getTextPath(textName:String, type:FilePathType, ignoreMod:Bool = false):String
	{
		return getResourcePath(textName, type, [JSON, TXT, XML, SOL, HX], ignoreMod);
	}

	public static function getConfigPath(configName:String, ignoreMod:Bool = false):String
	{
		return getResourcePath(configName, CONFIG, [JSON, TXT, XML], ignoreMod);
	}

	public static function getDataPath(dataName:String, ignoreMod:Bool = false):String
	{
		return getResourcePath(dataName, DATA, [JSON, TXT, XML], ignoreMod);
	}

	public static function getSavesPath(savesName:String, ignoreMod:Bool = false):String
	{
		return getResourcePath(savesName, SAVES, [JSON, TXT, XML], ignoreMod);
	}

	/**
	 * Checks if a specific file exists with the given extension and type.
	 * @param fileName The file name (without extension).
	 * @param ext The file extension to check.
	 * @param type The file type.
	 * @param ignoreMod Whether to ignore the mods folder.
	 * @return true if the file exists, false otherwise.
	 */
	public static function fileExists(fileName:String, ext:FilePathExtension, type:FilePathType, ignoreMod:Bool = false):Bool
	{
		return existsFile(fileName, ext, type, ignoreMod);
	}

	/**
	 * Checks if any version of a file exists with the given type.
	 * @param fileName The file name (without extension).
	 * @param type The file type.
	 * @param ignoreMod Whether to ignore the mods folder.
	 * @return true if any file with that name exists, false otherwise.
	 */
	public static function resourceExistsOfType(fileName:String, type:FilePathType, ignoreMod:Bool = false):Bool
	{
		var extensions = getExtensionsForType(type);
		return resourceExists(fileName, type, extensions, ignoreMod);
	}

	/**
	 * Gets the full absolute path for a file.
	 * @param fileName The file name (without extension).
	 * @param ext The file extension.
	 * @param type The file type.
	 * @param ignoreMod Whether to ignore the mods folder.
	 * @return The full path including the assets/ prefix, or null if not found.
	 */
	public static function getAbsolutePath(fileName:String, ext:FilePathExtension, type:FilePathType, ignoreMod:Bool = false):String
	{
		var path = getFile(fileName, ext, type, ignoreMod);
		if (path != null)
			return path; // Already returns relative path from assets/
		return null;
	}

	/**
	 * Gets the directory path for a specific type.
	 * @param type The file type.
	 * @return The directory path (without assets/ prefix).
	 */
	public static function getDirectory(type:FilePathType):String
	{
		var path = getPath(type);
		return path.length > 0 ? path : "";
	}

	/**
	 * Checks if a specific resource file exists by verifying if any of the provided extensions
	 * match an existing file in the specified type path.
	 * 
	 * @param fileName The file name without extension to search for.
	 * @param type The category/type of file path to search within.
	 * @param extensions Array of possible file extensions to check for the given file name.
	 * @param ignoreMod If true, excludes the mods folder from the search. Defaults to false.
	 * @return true if a file matching the fileName and one of the extensions exists, false otherwise.
	 */
	private static function resourceExists(fileName:String, type:FilePathType, extensions:Array<FilePathExtension>, ignoreMod:Bool = false):Bool
	{
		if (!isValidFileName(fileName) || ArrayUtil.isEmpty(extensions))
			return false;
		
		var ext = findFirstExtension(fileName, extensions, type, ignoreMod);
		return ext != NONE;
	}

	/**
	 * Checks if a font file exists.
	 * @param fontName The font file name (without extension).
	 * @param ignoreMod Whether to ignore the mods folder.
	 * @return true if the font exists, false otherwise.
	 */
	public static function fontExists(fontName:String, ignoreMod:Bool = false):Bool
	{
		return resourceExists(fontName, FONTS, [TTF], ignoreMod);
	}

	/**
	 * Checks if a shader file exists.
	 * @param shaderName The shader file name (without extension).
	 * @param ignoreMod Whether to ignore the mods folder.
	 * @return true if the shader exists, false otherwise.
	 */
	public static function shaderExists(shaderName:String, ignoreMod:Bool = false):Bool
	{
		return resourceExists(shaderName, SHADERS, [GLSL], ignoreMod);
	}

	/**
	 * Checks if an image file exists.
	 * @param imageName The image file name (without extension).
	 * @param ignoreMod Whether to ignore the mods folder.
	 * @return true if the image exists, false otherwise.
	 */
	public static function imageExists(imageName:String, ignoreMod:Bool = false):Bool
	{
		return resourceExists(imageName, IMAGES, [PNG], ignoreMod);
	}

	/**
	 * Checks if a sound file exists.
	 * @param soundName The sound file name (without extension).
	 * @param ignoreMod Whether to ignore the mods folder.
	 * @return true if the sound exists, false otherwise.
	 */
	public static function soundExists(soundName:String, ignoreMod:Bool = false):Bool
	{
		return resourceExists(soundName, SOUNDS, [MP3, OGG, WAV], ignoreMod);
	}

	/**
	 * Checks if a music file exists.
	 * @param musicName The music file name (without extension).
	 * @param ignoreMod Whether to ignore the mods folder.
	 * @return true if the music exists, false otherwise.
	 */
	public static function musicExists(musicName:String, ignoreMod:Bool = false):Bool
	{
		return resourceExists(musicName, MUSIC, [MP3, OGG, WAV], ignoreMod);
	}
}
