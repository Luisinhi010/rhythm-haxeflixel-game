package backend;

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
	public static function getExtension(ext:FilePathExtension):String
		return "." + Type.enumConstructor(ext).toLowerCase();

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
		if (fileName == null || fileName == "")
		{
			#if DEBUG
			throw "File name cannot be null or empty.";
			#end
			return false;
		}
		var absPath = getPath(type) + fileName + getExtension(ext);
		var filePath = get() + absPath;
		var modPath = getMod() + absPath;

		if (!ignoreMod && existsPath(modPath, type))
			return true;

		return existsPath(filePath, type);
	}

	private static function findFirstExtension(fileName:String, extensions:Array<FilePathExtension>, type:FilePathType,
			ignoreMod:Bool = false):FilePathExtension
	{
		for (ext in extensions)
		{
			if (existsFile(fileName, ext, type, ignoreMod))
				return ext;
		}
		return NONE;
	}

	public static function existsImageExt(fileName:String, ignoreMod:Bool = false):FilePathExtension
	{
		return findFirstExtension(fileName, [PNG], IMAGES, ignoreMod);
	}

	public static function existsAudioExt(fileName:String, type:FilePathType, ignoreMod:Bool = false):FilePathExtension
	{
		return findFirstExtension(fileName, [MP3, OGG, WAV], type, ignoreMod);
	}

	public static function existsTextExt(fileName:String, type:FilePathType, ignoreMod:Bool = false):FilePathExtension // I hope i find a better way to do this
	{
		return findFirstExtension(fileName, [JSON, TXT, XML, SOL, HX], type, ignoreMod);
	}

	public static function getFile(fileName:String, ext:FilePathExtension, type:FilePathType, ignoreMod:Bool = false):String
	{
		if (fileName == null || fileName == "")
		{
			#if DEBUG
			throw "File name cannot be null or empty.";
			#end
			return null;
		}
		#if debug trace("Getting file: " + fileName + getExtension(ext)); #end
		var absPath = getPath(type) + fileName + getExtension(ext);
		var filePath = get() + absPath;
		var modPath = getMod() + absPath;

		if (existsPath(modPath, type) && !ignoreMod)
		{
			#if debug trace("Mod file found: " + modPath); #end
			return modPath;
		}

		if (existsPath(filePath, type))
		{
			#if debug trace("File found: " + filePath); #end
			return filePath;
		}
		#if debug trace("File not found: " + fileName + getExtension(ext)); #end
		return null;
	}

	public static function getImagePath(imageName:String, ignoreMod:Bool = false):String
	{
		#if debug trace("Getting image path for: " + imageName); #end
		var ext = existsImageExt(imageName, ignoreMod);
		if (ext == NONE)
			return null;

		return getFile(imageName, ext, IMAGES, ignoreMod);
	}

	public static function getSoundPath(soundName:String, ignoreMod:Bool = false):String
	{
		#if debug trace("Getting sound path for: " + soundName); #end
		var ext = existsAudioExt(soundName, SOUNDS, ignoreMod);
		if (ext == NONE)
			return null;

		return getFile(soundName, ext, SOUNDS, ignoreMod);
	}

	public static function getMusicPath(musicName:String, ignoreMod:Bool = false):String
	{
		#if debug trace("Getting music path for: " + musicName); #end
		var ext = existsAudioExt(musicName, MUSIC, ignoreMod);
		if (ext == NONE)
			return null;

		return getFile(musicName, ext, MUSIC, ignoreMod);
	}

	public static function getMusicDataPath(dataName:String, ignoreMod:Bool = false):String
	{
		#if debug trace("Getting data path for: " + dataName); #end
		var ext = existsTextExt(dataName, METADATA, ignoreMod);
		if (ext != JSON) // Only JSON is supported for music metadata
			return null;

		return getFile(dataName, ext, METADATA, ignoreMod);
	}
	public static function getShaderPath(shaderName:String, ignoreMod:Bool = false):String
	{
		#if debug trace("Getting shader path for: " + shaderName); #end
		var ext = findFirstExtension(shaderName, [GLSL], SHADERS, ignoreMod);
		if (ext == NONE)
			return null;

		return getFile(shaderName, ext, SHADERS, ignoreMod);
	}

	public static function getFontPath(fontName:String, ignoreMod:Bool = false):String
	{
		#if debug trace("Getting font path for: " + fontName); #end
		var ext = findFirstExtension(fontName, [TTF], FONTS, ignoreMod);
		if (ext == NONE)
			return null;

		return getFile(fontName, ext, FONTS, ignoreMod);
	}

	public static function getTextPath(textName:String, type:FilePathType, ignoreMod:Bool = false):String
	{
		#if debug trace("Getting text path for: " + textName); #end
		var ext = existsTextExt(textName, type, ignoreMod);
		if (ext == NONE)
			return null;

		return getFile(textName, ext, type, ignoreMod);
	}

	public static function getConfigPath(configName:String, ignoreMod:Bool = false):String
	{
		#if debug trace("Getting config path for: " + configName); #end
		var ext = existsTextExt(configName, CONFIG, ignoreMod);
		if (ext == NONE)
			return null;

		return getFile(configName, ext, CONFIG, ignoreMod);
	}

	public static function getDataPath(dataName:String, ignoreMod:Bool = false):String
	{
		#if debug trace("Getting data path for: " + dataName); #end
		var ext = existsTextExt(dataName, DATA, ignoreMod);
		if (ext == NONE)
			return null;

		return getFile(dataName, ext, DATA, ignoreMod);
	}

	public static function getSavesPath(savesName:String, ignoreMod:Bool = false):String
	{
		#if debug trace("Getting saves path for: " + savesName); #end
		var ext = existsTextExt(savesName, SAVES, ignoreMod);
		if (ext == NONE)
			return null;

		return getFile(savesName, ext, SAVES, ignoreMod);
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
	public static function resourceExists(fileName:String, type:FilePathType, ignoreMod:Bool = false):Bool
	{
		var ext = existsTextExt(fileName, type, ignoreMod);
		if (ext != NONE)
			return true;

		ext = existsAudioExt(fileName, type, ignoreMod);
		if (ext != NONE)
			return true;

		ext = existsImageExt(fileName, ignoreMod);
		return ext != NONE;
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
	 * Checks if a font file exists.
	 * @param fontName The font file name (without extension).
	 * @param ignoreMod Whether to ignore the mods folder.
	 * @return true if the font exists, false otherwise.
	 */
	public static function fontExists(fontName:String, ignoreMod:Bool = false):Bool
	{
		var ext = findFirstExtension(fontName, [TTF], FONTS, ignoreMod);
		return ext != NONE;
	}

	/**
	 * Checks if a shader file exists.
	 * @param shaderName The shader file name (without extension).
	 * @param ignoreMod Whether to ignore the mods folder.
	 * @return true if the shader exists, false otherwise.
	 */
	public static function shaderExists(shaderName:String, ignoreMod:Bool = false):Bool
	{
		var ext = findFirstExtension(shaderName, [GLSL], SHADERS, ignoreMod);
		return ext != NONE;
	}

	/**
	 * Checks if an image file exists.
	 * @param imageName The image file name (without extension).
	 * @param ignoreMod Whether to ignore the mods folder.
	 * @return true if the image exists, false otherwise.
	 */
	public static function imageExists(imageName:String, ignoreMod:Bool = false):Bool
	{
		var ext = existsImageExt(imageName, ignoreMod);
		return ext != NONE;
	}

	/**
	 * Checks if a sound file exists.
	 * @param soundName The sound file name (without extension).
	 * @param ignoreMod Whether to ignore the mods folder.
	 * @return true if the sound exists, false otherwise.
	 */
	public static function soundExists(soundName:String, ignoreMod:Bool = false):Bool
	{
		var ext = existsAudioExt(soundName, SOUNDS, ignoreMod);
		return ext != NONE;
	}

	/**
	 * Checks if a music file exists.
	 * @param musicName The music file name (without extension).
	 * @param ignoreMod Whether to ignore the mods folder.
	 * @return true if the music exists, false otherwise.
	 */
	public static function musicExists(musicName:String, ignoreMod:Bool = false):Bool
	{
		var ext = existsAudioExt(musicName, MUSIC, ignoreMod);
		return ext != NONE;
	}
}
