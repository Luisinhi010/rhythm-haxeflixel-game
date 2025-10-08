package backend;

import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.sound.FlxSound;
import flixel.util.typeLimit.OneOfFour;
import flixel.util.typeLimit.OneOfTwo;
import haxe.ds.Map;
import lime.app.Future;
import lime.app.Promise;
import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.utils.Assets as OpenFLAssets;
import openfl.utils.ByteArray;
#if (sys && !android && !ios)
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
		clearImageCache();
		clearSoundCache();
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

		#if (sys && !android && !ios)
		return File.getContent(path);
		#else
		return LimeAssets.getText(path);
		#end
	}

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
			imageCache.set(path, OpenFLAssets.getBitmapData(path, false)); // useCache = false, we handle it

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
			soundCache.set(path, OpenFLAssets.getSound(path, false)); // useCache = false, we handle it

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
			soundCache.set(path, OpenFLAssets.getSound(path, false)); // useCache = false, we handle it

		return soundCache.get(path);
	}
	/**
	 * Saves content to a file.
	 * @param filePath The full path to the file.
	 * @param content The content to save.
	 */
	public static function saveContent(filePath:String, content:String):Void
	{
		#if js
		// var parts = filePath.split('/');
		// var fileName = parts[parts.length - 1];
		// var bytes = Bytes.ofString(content);
		// WebFile.saveAs(bytes, fileName);
		#elseif (android || ios)
		var fullPath = System.applicationStorageDirectory + '/' + filePath;
		File.saveContent(fullPath, content);
		#elseif sys
		File.saveContent(filePath, content);
		#else
		// Saving is not supported on this platform
		#end
	}

	// --- Assyncronous loading---

	/**
	 * Loads an image asynchronously.
	 * @param imageName The name of the image file (without extension).
	 * @param ignoreMod Whether to ignore the mods folder.
	 * @return A Future that will be completed with the BitmapData.
	 */
	public static function loadImageAsync(imageName:String, ignoreMod:Bool = false):Future<BitmapData>
	{
		var promise = new Promise<BitmapData>();
		var path = FilePath.getImagePath(imageName, ignoreMod);

		if (path == null)
		{
			promise.complete(null);
			return promise.future;
		}

		if (imageCache.exists(path))
		{
			promise.complete(imageCache.get(path));
			return promise.future;
		}

		OpenFLAssets.loadBitmapData(path, false).onComplete(function(bitmapData)
		{
			imageCache.set(path, bitmapData);
			promise.complete(bitmapData);
		}).onError(function(error)
		{
				promise.error(error);
		});

		return promise.future;
	}

	/**
	 * Loads a sound asynchronously.
	 * @param soundName The name of the sound file (without extension).
	 * @param ignoreMod Whether to ignore the mods folder.
	 * @return A Future that will be completed with the Sound.
	 */
	public static function loadSoundAsync(soundName:String, ignoreMod:Bool = false):Future<Sound>
	{
		var promise = new Promise<Sound>();
		var path = FilePath.getSoundPath(soundName, ignoreMod);

		if (path == null)
		{
			promise.complete(null);
			return promise.future;
		}

		if (soundCache.exists(path))
		{
			promise.complete(soundCache.get(path));
			return promise.future;
		}

		OpenFLAssets.loadSound(path, false).onComplete(function(sound)
		{
			soundCache.set(path, sound);
			promise.complete(sound);
		}).onError(function(error)
		{
				promise.error(error);
		});

		return promise.future;
	}
}
