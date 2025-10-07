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
		var shouldLoop = (looped == null ? (metaData != null && metaData.looped) : looped);
		music = FlxG.sound.load(Paths.getMusic(name), 1, shouldLoop);
	}

	private function load():Void
	{
		#if debug
		trace('Loading metadata for "$name"...');
		#end
		var jsonString = Paths.getMusicData(name);
		if (jsonString == null)
		{
			trace('Music metadata not found for "$name"');
			return;
		}

		metaData = Json.parse(jsonString);
		if (metaData == null)
		{
			trace('Error parsing music metadata for "$name"');
			return;
		}
		#if debug
		trace('Successfully parsed metadata for "$name".');
		#end
		// Set default values if optional fields are missing
		if (metaData.offset == null)
			metaData.offset = 0; // in milliseconds
		if (metaData.timeSignature == null) // Default to 4/4 if not specified
			metaData.timeSignature = "4/4";

		// The JSON parser creates an anonymous object for cuePoints,
		// so we need to manually convert it to a real Map.
		var cuePointsObj:Dynamic = metaData.cuePoints;
		metaData.cuePoints = new Map<String, Float>(); // Initialize with a new, empty map
		if (cuePointsObj != null)
		{
			// Iterate over the fields of the anonymous object and add them to the real Map
			for (fieldName in Reflect.fields(cuePointsObj))
			{
				metaData.cuePoints.set(fieldName, Reflect.field(cuePointsObj, fieldName));
			}
		}
		if (metaData.tempoChanges == null)
			metaData.tempoChanges = [];
		if (metaData.looped == null)
			metaData.looped = false;
		#if debug
		trace('  - Title: ${metaData.title}, Artist: ${metaData.artist}');
		trace('  - Initial BPM: ${metaData.bpm}, Offset: ${metaData.offset}ms');
		trace('  - Cue Points: ' + (metaData.cuePoints.iterator().hasNext() ? '${metaData.cuePoints}' : '(none)'));
		trace('  - Tempo Changes: ' + (metaData.tempoChanges.length > 0 ? '${metaData.tempoChanges}' : '(none)'));
		#end
	}
}
