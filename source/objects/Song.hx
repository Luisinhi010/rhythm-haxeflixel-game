package objects;

import Reflect;
import backend.MusicMetaData;
import backend.Paths;
import flixel.FlxG;
import flixel.sound.FlxSound;
import haxe.Json;
#if sys
import sys.io.File;
#end

/**
 * A data container for a song. It holds all metadata, cue points, tempo changes,
 * and eventually, the note chart. It is responsible for loading this data from
 * a JSON file.
 */
class Song
{
	public var metaData:MusicMetaData;
	public var name:String;
	public var music:FlxSound;

	public function new(fileName:String, ?looped:Bool = null)
	{
		#if debug
		trace('new Song: "$fileName"');
		#end
		this.name = fileName;
		load();
		// If looped parameter is provided, it overrides the metadata setting
		var shouldLoop = looped != null ? looped : (metaData != null && metaData.looped);

		var musicPath = Paths.getMusic(name);
		if (musicPath == null)
		{
			#if debug
			trace('Music file not found for "$name"');
			#end
			return;
		}
		music = FlxG.sound.load(musicPath, 1, shouldLoop);
	}

	private function getDefaultMetadata():MusicMetaData
	{
		return {
			title: name,
			artist: "Unknown",
			bpm: 120,
			offset: 0,
			timeSignature: "4/4",
			cuePoints: new Map<String, Float>(),
			tempoChanges: [],
			looped: false
		};
	}

	/**
	 * Helper to handle loading errors and fall back to defaults.
	 * @param reason The reason for the fallback
	 */
	private function fallbackToDefaults(reason:String):Void
	{
		#if debug
		trace('$reason for "$name", using defaults');
		#end
		metaData = getDefaultMetadata();
	}

	/**
	 * Get a field value from parsed data with a default fallback.
	 * @param data The parsed data object
	 * @param field The field name
	 * @param defaultValue The default value if field is null
	 * @return The field value or default
	 */
	private function getFieldOrDefault<T>(data:Dynamic, field:String, defaultValue:T):T
	{
		var value = Reflect.field(data, field);
		return value != null ? value : defaultValue;
	}

	private function load():Void
	{
		#if debug
		trace('Loading metadata for "$name"...');
		#end
		var jsonString = Paths.getMusicData(name);
		if (jsonString == null)
		{
			fallbackToDefaults('Music metadata not found');
			return;
		}

		var parsedData:Dynamic = null;
		try
		{
			parsedData = Json.parse(jsonString);
		}
		catch (e:Dynamic)
		{
			fallbackToDefaults('Error parsing music metadata: $e');
			return;
		}

		if (parsedData == null || parsedData.bpm == null)
		{
			fallbackToDefaults('Invalid or missing BPM in metadata');
			return;
		}

		// The JSON parser creates an anonymous object for cuePoints,
		// so we need to manually convert it to a real Map.
		var cuePointsMap = new Map<String, Float>();
		var cuePointsObj:Dynamic = parsedData.cuePoints;
		if (cuePointsObj != null)
		{
			for (fieldName in Reflect.fields(cuePointsObj))
			{
				cuePointsMap.set(fieldName, Reflect.field(cuePointsObj, fieldName));
			}
		}
		// Construct the metaData object with defaults and the converted map
		// Plus, this fixes "Uncaught exception: Can't cast dynobj to haxe.ds.StringMap" when compiling to hashlink
		metaData = {
			title: getFieldOrDefault(parsedData, "title", name),
			artist: getFieldOrDefault(parsedData, "artist", "Unknown"),
			bpm: parsedData.bpm,
			offset: getFieldOrDefault(parsedData, "offset", 0),
			timeSignature: getFieldOrDefault(parsedData, "timeSignature", "4/4"),
			cuePoints: cuePointsMap,
			tempoChanges: getFieldOrDefault(parsedData, "tempoChanges", []),
			looped: getFieldOrDefault(parsedData, "looped", false)
		};

		#if debug
		trace('Successfully parsed metadata for "$name".');
		trace('  - Title: ${metaData.title}, Artist: ${metaData.artist}');
		trace('  - Initial BPM: ${metaData.bpm}, Offset: ${metaData.offset}ms');
		trace('  - Cue Points: ' + (metaData.cuePoints.iterator().hasNext() ? '${metaData.cuePoints}' : '(none)'));
		trace('  - Tempo Changes: ' + (metaData.tempoChanges.length > 0 ? '${metaData.tempoChanges}' : '(none)'));
		#end
	}
}
