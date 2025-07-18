package backend;

import openfl.utils.ByteArray;
import sys.FileSystem;
import sys.io.File;

enum FilePathType
{
	IMAGES;
	SOUNDS;
	MUSIC;
	METADATA;
	// VIDEOS; //Not Available yet
	SHADERS;
	FONTS;
	CONFIG;
	DATA;
	SAVES;
}

enum FilePathExtension
{
	// Images
	PNG;
	JPG;
	WEBP;
	// Audios/Sounds
	OGG;
	MP3;
	// Videos
	// AVI;
	// WEBM;
	// MP4;
	// Shaders
	GLSL;
	// Fonts
	TTF;
	// Texts
	JSON;
	TXT;
	XML;
	HX;
	// Add more extensions as needed
}

class FilePath
{
	// This class is used to manage file paths in the game.
	// It provides static methods to get paths for various resources.
	public static function getExtension(ext:FilePathExtension):String
	{
		return "." + Type.enumConstructor(ext).toLowerCase();
	}

	public static function getPath(type:FilePathType):String
		switch (type)
		{
			case IMAGES:
				return "images/";
			case SOUNDS:
				return "sounds/";
			case MUSIC:
				return "music/";
			case METADATA:
				return "music/"; //strange, I know, just let me be!
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
		}

	public static function get():String
		return "assets/";

	public static function getMod():String
		return "mods/";

	public static function exists(path:String, ignoreMod:Bool = false):Bool // Returns true if the file exists
	{
		if (ignoreMod)
			return FileSystem.exists(get() + path);

		if (FileSystem.exists(getMod() + path))
			return true;
		return FileSystem.exists(get() + path);
	}

	public static function existsWithExtension(path:String, ext:FilePathExtension, ignoreMod:Bool = false):Bool
	{
		var fullPath = path + getExtension(ext);
		return exists(fullPath, ignoreMod);
	}

	public static function getImagePath(imageName:String, ext:FilePathExtension = FilePathExtension.PNG):String
	{
		var filename = imageName + getExtension(ext);
		var modPath = getMod() + "images/" + filename;
		if (FileSystem.exists(modPath))
			return modPath;
		return getPath(FilePathType.IMAGES) + filename;
	}

	public static function getSongPath(songName:String, ext:FilePathExtension = FilePathExtension.MP3):String
	{
		var filename = songName + getExtension(ext);
		var modPath = getMod() + "music/" + filename;
		if (FileSystem.exists(modPath))
			return modPath;
		return getPath(FilePathType.MUSIC) + filename;
	}
}
