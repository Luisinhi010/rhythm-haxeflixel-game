package objects;

import Reflect;
import backend.MusicMetaData;
import backend.MusicMetaDataBuilder;
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

		var parsedData:Dynamic = Json.parse(jsonString);
		if (parsedData == null)
		{
			trace('Error parsing music metadata for "$name"');
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
			title: parsedData.title == null ? name : parsedData.title,
			artist: parsedData.artist == null ? "Unknown" : parsedData.artist,
			bpm: parsedData.bpm,
			offset: parsedData.offset == null ? 0 : parsedData.offset,
			timeSignature: parsedData.timeSignature == null ? "4/4" : parsedData.timeSignature,
			cuePoints: cuePointsMap,
			tempoChanges: parsedData.tempoChanges == null ? [] : parsedData.tempoChanges,
			looped: parsedData.looped == null ? false : parsedData.looped
		};

		#if debug
		trace('Successfully parsed metadata for "$name".');
		trace('  - Title: ${metaData.title}, Artist: ${metaData.artist}');
		trace('  - Initial BPM: ${metaData.bpm}, Offset: ${metaData.offset}ms');
		trace('  - Cue Points: ' + (metaData.cuePoints.iterator().hasNext() ? '${metaData.cuePoints}' : '(none)'));
		trace('  - Tempo Changes: ' + (metaData.tempoChanges.length > 0 ? '${metaData.tempoChanges}' : '(none)'));
		#end
	}

	/**
	 * Static helper to create a Song with metadata from a MusicMetaDataBuilder.
	 * Useful when programmatically generating song metadata.
	 * @param fileName The name of the music file (without extension).
	 * @param builder The MusicMetaDataBuilder containing the metadata.
	 * @param saveJson Whether to save the metadata to a JSON file. Default is true.
	 * @return A new Song instance with the provided metadata.
	 */
	public static function fromBuilder(fileName:String, builder:MusicMetaDataBuilder, saveJson:Bool = true):Song
	{
		#if sys
		if (saveJson)
		{
			var json = builder.toJson();
			var outputPath = 'assets/music/$fileName.json';
			
			try
			{
				File.saveContent(outputPath, json);
				#if debug
				trace('Saved metadata to: $outputPath');
				#end
			}
			catch (e:Dynamic)
			{
				trace('Warning: Could not save metadata file: $e');
			}
		}
		#end
		
		// Create the song normally, which will load the JSON we just saved
		// (or the existing JSON if saveJson was false)
		return new Song(fileName);
	}
}
