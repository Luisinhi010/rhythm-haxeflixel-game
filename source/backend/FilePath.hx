package backend;

#if sys
import sys.FileSystem;
import sys.io.File;
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
		trace("Checking path: " + path + " of type: " + getType(type));
		#if sys
		if (FileSystem.exists(path))
		{
			trace("Path found: " + path);
			return true;
		}
		#else
		if (Assets.exists(path))
		{
			trace("Path found: " + path);
			return true;
		}
		#end
		trace("Path not found: " + path);
		return false;
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

		return existsPath(filePath, type) || existsPath(modPath, type);
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
		return findFirstExtension(fileName, [MP3, OGG], type, ignoreMod);
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
		trace("Getting file: " + fileName + getExtension(ext));
		var absPath = getPath(type) + fileName + getExtension(ext);
		var filePath = get() + absPath;
		var modPath = getMod() + absPath;

		if (existsPath(modPath, type) && !ignoreMod)
		{
			trace("Mod file found: " + modPath);
			return modPath;
		}

		if (existsPath(filePath, type))
		{
			trace("File found: " + filePath);
			return filePath;
		}
		trace("File not found: " + fileName + getExtension(ext));
		return null;
	}

	public static function getImagePath(imageName:String, ignoreMod:Bool = false):String
	{
		trace("Getting image path for: " + imageName);
		var ext = existsImageExt(imageName, ignoreMod);
		if (ext == NONE)
			return null;

		return getFile(imageName, ext, IMAGES, ignoreMod);
	}

	public static function getSoundPath(soundName:String, ignoreMod:Bool = false):String
	{
		trace("Getting sound path for: " + soundName);
		var ext = existsAudioExt(soundName, SOUNDS, ignoreMod);
		if (ext == NONE)
			return null;

		return getFile(soundName, ext, SOUNDS, ignoreMod);
	}

	public static function getMusicPath(musicName:String, ignoreMod:Bool = false):String
	{
		trace("Getting music path for: " + musicName);
		var ext = existsAudioExt(musicName, MUSIC, ignoreMod);
		if (ext == NONE)
			return null;

		return getFile(musicName, ext, MUSIC, ignoreMod);
	}

	public static function getMusicDataPath(dataName:String, ignoreMod:Bool = false):String
	{
		trace("Getting data path for: " + dataName);
		var ext = existsTextExt(dataName, METADATA, ignoreMod);
		if (ext != JSON)
			return null;

		return getFile(dataName, ext, METADATA, ignoreMod);
	}
}
