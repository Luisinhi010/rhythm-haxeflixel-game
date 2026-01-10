package backend;

import backend.FilePath.FilePathType;
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
	private static var textCache:Map<String, String> = new Map();

	// Cache control
	public static function clearCache():Void
	{
		clearImageCache();
		clearSoundCache();
		clearTextCache();
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

	public static function clearTextCache():Void
	{
		textCache.clear();
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

		if (!textCache.exists(path))
		{
			#if (sys && !android && !ios)
			textCache.set(path, File.getContent(path));
			#else
			textCache.set(path, OpenFLAssets.getText(path));
			#end
		}

		return textCache.get(path);
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
	 * Loads config file content as a string.
	 * @param configName The config file name (without extension).
	 * @param ignoreMod Whether to ignore the mods folder.
	 * @return The config file contents as a string, or null if not found.
	 */
	public static function getConfig(configName:String, ignoreMod:Bool = false):String
	{
		var path = FilePath.getConfigPath(configName, ignoreMod);
		if (path == null)
			return null;

		if (!textCache.exists(path))
		{
			#if (sys && !android && !ios)
			textCache.set(path, File.getContent(path));
			#else
			textCache.set(path, OpenFLAssets.getText(path));
			#end
		}

		return textCache.get(path);
	}

	/**
	 * Loads data file content as a string.
	 * @param dataName The data file name (without extension).
	 * @param ignoreMod Whether to ignore the mods folder.
	 * @return The data file contents as a string, or null if not found.
	 */
	public static function getData(dataName:String, ignoreMod:Bool = false):String
	{
		var path = FilePath.getDataPath(dataName, ignoreMod);
		if (path == null)
			return null;

		if (!textCache.exists(path))
		{
			#if (sys && !android && !ios)
			textCache.set(path, File.getContent(path));
			#else
			textCache.set(path, OpenFLAssets.getText(path));
			#end
		}

		return textCache.get(path);
	}

	/**
	 * Loads saves file content as a string.
	 * @param savesName The saves file name (without extension).
	 * @param ignoreMod Whether to ignore the mods folder.
	 * @return The saves file contents as a string, or null if not found.
	 */
	public static function getSaves(savesName:String, ignoreMod:Bool = false):String
	{
		var path = FilePath.getSavesPath(savesName, ignoreMod);
		if (path == null)
			return null;

		if (!textCache.exists(path))
		{
			#if (sys && !android && !ios)
			textCache.set(path, File.getContent(path));
			#else
			textCache.set(path, OpenFLAssets.getText(path));
			#end
		}

		return textCache.get(path);
	}

	/**
	 * Loads text file content as a string.
	 * @param textName The text file name (without extension).
	 * @param type The type of text file (CONFIG, DATA, SAVES, etc).
	 * @param ignoreMod Whether to ignore the mods folder.
	 * @return The text file contents as a string, or null if not found.
	 */
	public static function getText(textName:String, type:FilePathType, ignoreMod:Bool = false):String
	{
		var path = FilePath.getTextPath(textName, type, ignoreMod);
		if (path == null)
			return null;

		if (!textCache.exists(path))
		{
			#if (sys && !android && !ios)
			textCache.set(path, File.getContent(path));
			#else
			textCache.set(path, OpenFLAssets.getText(path));
			#end
		}

		return textCache.get(path);
	}

	/**
	 * Loads a FlxSprite from an image asset.
	 * @param imageName The image file name (without extension).
	 * @param ignoreMod Whether to ignore the mods folder.
	 * @return A FlxSprite with the image, or null if not found.
	 */
	public static function getSprite(imageName:String, ignoreMod:Bool = false):FlxSprite
	{
		var bitmap = getImage(imageName, ignoreMod);
		if (bitmap == null)
			return null;

		var sprite = new FlxSprite();
		sprite.loadGraphic(bitmap);
		return sprite;
	}

	/**
	 * Loads a FlxSound from a sound asset.
	 * @param soundName The sound file name (without extension).
	 * @param ignoreMod Whether to ignore the mods folder.
	 * @return A FlxSound, or null if not found.
	 */
	public static function getFlxSound(soundName:String, ignoreMod:Bool = false):FlxSound
	{
		var sound = getSound(soundName, ignoreMod);
		if (sound == null)
			return null;

		var flxSound = new FlxSound();
		flxSound.loadEmbedded(sound);
		return flxSound;
	}

	/**
	 * Loads a FlxSound from a music asset.
	 * @param musicName The music file name (without extension).
	 * @param ignoreMod Whether to ignore the mods folder.
	 * @return A FlxSound, or null if not found.
	 */
	public static function getFlxMusic(musicName:String, ignoreMod:Bool = false):FlxSound
	{
		var sound = getMusic(musicName, ignoreMod);
		if (sound == null)
			return null;

		var flxSound = new FlxSound();
		flxSound.loadEmbedded(sound);
		return flxSound;
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

	/**
	 * Loads music data asynchronously.
	 * @param dataName The data file name (without extension).
	 * @param ignoreMod Whether to ignore the mods folder.
	 * @return A Future that will be completed with the JSON string.
	 */
	public static function loadMusicDataAsync(dataName:String, ignoreMod:Bool = false):Future<String>
	{
		var promise = new Promise<String>();
		var path = FilePath.getMusicDataPath(dataName, ignoreMod);

		if (path == null)
		{
			promise.complete(null);
			return promise.future;
		}

		OpenFLAssets.loadText(path).onComplete(function(text)
		{
			promise.complete(text);
		}).onError(function(error)
		{
				promise.error(error);
		});

		return promise.future;
	}

	/**
	 * Loads config file asynchronously.
	 * @param configName The config file name (without extension).
	 * @param ignoreMod Whether to ignore the mods folder.
	 * @return A Future that will be completed with the config string.
	 */
	public static function loadConfigAsync(configName:String, ignoreMod:Bool = false):Future<String>
	{
		var promise = new Promise<String>();
		var path = FilePath.getConfigPath(configName, ignoreMod);

		if (path == null)
		{
			promise.complete(null);
			return promise.future;
		}

		OpenFLAssets.loadText(path).onComplete(function(text)
		{
			promise.complete(text);
		}).onError(function(error)
		{
				promise.error(error);
		});

		return promise.future;
	}

	/**
	 * Loads data file asynchronously.
	 * @param dataName The data file name (without extension).
	 * @param ignoreMod Whether to ignore the mods folder.
	 * @return A Future that will be completed with the data string.
	 */
	public static function loadDataAsync(dataName:String, ignoreMod:Bool = false):Future<String>
	{
		var promise = new Promise<String>();
		var path = FilePath.getDataPath(dataName, ignoreMod);

		if (path == null)
		{
			promise.complete(null);
			return promise.future;
		}

		OpenFLAssets.loadText(path).onComplete(function(text)
		{
			promise.complete(text);
		}).onError(function(error)
		{
				promise.error(error);
		});

		return promise.future;
	}

	/**
	 * Loads music asynchronously.
	 * @param musicName The name of the music file (without extension).
	 * @param ignoreMod Whether to ignore the mods folder.
	 * @return A Future that will be completed with the Sound.
	 */
	public static function loadMusicAsync(musicName:String, ignoreMod:Bool = false):Future<Sound>
	{
		var promise = new Promise<Sound>();
		var path = FilePath.getMusicPath(musicName, ignoreMod);

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

	/**
	 * Checks if a resource is cached.
	 * @param path The resource path.
	 * @return true if the resource is in cache, false otherwise.
	 */
	public static function isCached(path:String):Bool
	{
		return imageCache.exists(path) || soundCache.exists(path) || textCache.exists(path);
	}

	/**
	 * Removes a specific cached resource.
	 * @param path The resource path to remove from cache.
	 */
	public static function uncache(path:String):Void
	{
		if (imageCache.exists(path))
		{
			var bitmap = imageCache.get(path);
			if (bitmap != null)
				bitmap.dispose();
			imageCache.remove(path);
		}
		else if (soundCache.exists(path))
		{
			soundCache.remove(path);
		}
		else if (textCache.exists(path))
		{
			textCache.remove(path);
		}
	}

	/**
	 * Gets the size of the image cache.
	 * @return The number of cached images.
	 */
	public static function getImageCacheSize():Int
	{
		var count = 0;
		for (_ in imageCache)
			count++;
		return count;
	}

	/**
	 * Gets the size of the sound cache.
	 * @return The number of cached sounds.
	 */
	public static function getSoundCacheSize():Int
	{
		var count = 0;
		for (_ in soundCache)
			count++;
		return count;
	}

	/**
	 * Gets the size of the text cache.
	 * @return The number of cached text files.
	 */
	public static function getTextCacheSize():Int
	{
		var count = 0;
		for (_ in textCache)
			count++;
		return count;
	}

	/**
	 * Preloads multiple resources at once.
	 * @param resourceList Array of resource names to preload (without extensions).
	 * @param type The type of resources (IMAGES, SOUNDS, MUSIC, etc).
	 */
	public static function preload(resourceList:Array<String>, type:FilePathType):Void
	{
		for (resource in resourceList)
		{
			switch (type)
			{
				case IMAGES:
					getImage(resource);
				case SOUNDS:
					getSound(resource);
				case MUSIC:
					getMusic(resource);
				case CONFIG:
					getConfig(resource);
				case DATA:
					getData(resource);
				case METADATA:
					getMusicData(resource);
				default:
					getText(resource, type);
			}
		}
	}

	/**
	 * Checks if a resource exists and is available.
	 * @param resourceName The resource name (without extension).
	 * @param type The resource type.
	 * @param ignoreMod Whether to ignore the mods folder.
	 * @return true if the resource exists, false otherwise.
	 */
	public static function exists(resourceName:String, type:FilePathType, ignoreMod:Bool = false):Bool
	{
		switch (type)
		{
			case IMAGES:
				return FilePath.imageExists(resourceName, ignoreMod);
			case SOUNDS:
				return FilePath.soundExists(resourceName, ignoreMod);
			case MUSIC:
				return FilePath.musicExists(resourceName, ignoreMod);
			case FONTS:
				return FilePath.fontExists(resourceName, ignoreMod);
			case SHADERS:
				return FilePath.shaderExists(resourceName, ignoreMod);
			default:
				return FilePath.resourceExists(resourceName, type, ignoreMod);
		}
	}

	/**
	 * Gets a font path.
	 * @param fontName The font file name (without extension).
	 * @param ignoreMod Whether to ignore the mods folder.
	 * @return The font path as a string, or null if not found.
	 */
	public static function getFont(fontName:String, ignoreMod:Bool = false):String
	{
		#if debug trace("Getting font path for: " + fontName); #end
		var path = FilePath.getFontPath(fontName, ignoreMod);
		if (path == null)
			return null;

		if (!textCache.exists(path))
			textCache.set(path, path); // Store path in cache

		return textCache.get(path);
	}

	/**
	 * Gets a shader path.
	 * @param shaderName The shader file name (without extension).
	 * @param ignoreMod Whether to ignore the mods folder.
	 * @return The shader path as a string, or null if not found.
	 */
	public static function getShader(shaderName:String, ignoreMod:Bool = false):String
	{
		#if debug trace("Getting shader path for: " + shaderName); #end
		var path = FilePath.getShaderPath(shaderName, ignoreMod);
		if (path == null)
			return null;

		if (!textCache.exists(path))
			textCache.set(path, path); // Store path in cache

		return textCache.get(path);
	}

	/**
	 * Loads a font file asynchronously.
	 * @param fontName The font file name (without extension).
	 * @param ignoreMod Whether to ignore the mods folder.
	 * @return A Future that will be completed with the font path as a string.
	 */
	public static function loadFontAsync(fontName:String, ignoreMod:Bool = false):Future<String>
	{
		var promise = new Promise<String>();
		var path = FilePath.getFontPath(fontName, ignoreMod);

		if (path == null)
		{
			promise.complete(null);
			return promise.future;
		}

		if (textCache.exists(path))
		{
			promise.complete(textCache.get(path));
			return promise.future;
		}

		// Font paths are just strings, so we can complete immediately
		promise.complete(path);
		return promise.future;
	}

	/**
	 * Loads a shader asynchronously.
	 * @param shaderName The shader file name (without extension).
	 * @param ignoreMod Whether to ignore the mods folder.
	 * @return A Future that will be completed with the shader path as a string.
	 */
	public static function loadShaderAsync(shaderName:String, ignoreMod:Bool = false):Future<String>
	{
		var promise = new Promise<String>();
		var path = FilePath.getShaderPath(shaderName, ignoreMod);

		if (path == null)
		{
			promise.complete(null);
			return promise.future;
		}

		if (textCache.exists(path))
		{
			promise.complete(textCache.get(path));
			return promise.future;
		}

		// Shader paths are just strings, so we can complete immediately
		promise.complete(path);
		return promise.future;
	}
}
