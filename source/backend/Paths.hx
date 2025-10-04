package backend;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.sound.FlxSound;
import flixel.util.typeLimit.OneOfFour;
import flixel.util.typeLimit.OneOfTwo;
import haxe.Json;
import haxe.ds.Map;
import haxe.io.Bytes;
import haxe.xml.Access;
import lime.app.Promise;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;
import lime.utils.Assets as LimeAssets;
import openfl.display.BitmapData;
import openfl.display.Graphics;
import openfl.media.Sound;
import openfl.utils.Assets as OpenFLAssets;
import openfl.utils.ByteArray;
#if sys
import sys.io.File;
#end

/**
 * Typedefs for loaded assets.
 */
typedef GraphicAsset = OneOfFour<FlxSprite, FlxGraphic, BitmapData, String>;

typedef SoundAsset = OneOfFour<FlxSound, String, Sound, Class<Sound>>;
typedef ByteArrayAsset = OneOfTwo<ByteArray, String>;

/**
 * A class to load game assets from the paths provided by FilePath.hx.
 * This class handles converting file paths into game-ready data
 * such as BitmapData, FlxSound, etc.
 */
class Paths
{
	// Cache maps
	private static var imageCache:Map<String, BitmapData> = new Map();
	private static var soundCache:Map<String, Sound> = new Map();

	// Cache control
	public static function clearCache():Void
	{
		for (bitmap in imageCache)
			if (bitmap != null)
				bitmap.dispose();
		imageCache.clear();

		soundCache.clear();
	}

	public static function clearImageCache():Void
	{
		for (bitmap in imageCache)
			if (bitmap != null)
				bitmap.dispose();
		imageCache.clear();
	}

	public static function clearSoundCache():Void
	{
		soundCache.clear();
	}

	/**
	 * Loads the contents of a music metadata JSON file.
	 * @param dataName The data file name (without extension).
	 * @param ignoreMod Whether to ignore the mods folder.
	 * @return The JSON file contents as a string, or null if not found.
	 */
	public static function getMusicData(dataName:String, ignoreMod:Bool = false):String
	{
		var path = FilePath.getMusicDataPath(dataName, ignoreMod);
		if (path == null)
			return null;

		#if sys
		return File.getContent(path);
		#else
		return LimeAssets.getText(path);
		#end
	}

	// Synchronous cached versions

	/**
	 * Loads an image asset as BitmapData.
	 * @param imageName The image file name (without extension).
	 * @param ignoreMod Whether to ignore the mods folder.
	 * @return The loaded BitmapData, or null if not found.
	 */
	public static function getImage(imageName:String, ignoreMod:Bool = false):BitmapData
	{
		var path = FilePath.getImagePath(imageName, ignoreMod);
		if (path == null)
			return null;

		if (!imageCache.exists(path))
			imageCache.set(path, OpenFLAssets.getBitmapData(path));

		return imageCache.get(path);
	}

	/**
	 * Loads a sound asset as an OpenFL Sound.
	 * @param soundName The sound file name (without extension).
	 * @param ignoreMod Whether to ignore the mods folder.
	 * @return An OpenFL Sound, or null if not found.
	 */
	public static function getSound(soundName:String, ignoreMod:Bool = false):Sound
	{
		var path = FilePath.getSoundPath(soundName, ignoreMod);
		if (path == null)
			return null;

		if (!soundCache.exists(path))
			soundCache.set(path, OpenFLAssets.getSound(path));

		return soundCache.get(path);
	}

	/**
	 * Loads a music asset as OpenFL Sound.
	 * @param musicName The name of the music file (without extension).
	 * @param ignoreMod Whether to ignore the mods folder.
	 * @return A Sound from OpenFL, or null if not found.
	 */
	public static function getMusic(musicName:String, ignoreMod:Bool = false):Sound
	{
		var path = FilePath.getMusicPath(musicName, ignoreMod);
		if (path == null)
			return null;

		if (!soundCache.exists(path))
			soundCache.set(path, OpenFLAssets.getSound(path));

		return soundCache.get(path);
	}
}
