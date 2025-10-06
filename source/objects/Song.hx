package objects;

import Reflect;
import backend.MusicMetaData;
import backend.Paths;
import haxe.Json;

/**
 * A data container for a song. It holds all metadata, cue points, tempo changes,
 * and eventually, the note chart. It is responsible for loading this data from
 * a JSON file.
 */
class Song
{
	public var metaData:MusicMetaData;
	public var name:String;

	public function new(fileName:String)
	{
		this.name = fileName;
		load();
	}

	private function load():Void
	{
		var jsonString = Paths.getMusicData(name);
		if (jsonString == null)
		{
			#if debug
			throw 'Music metadata not found for "$name"';
			#else
			trace('Music metadata not found for "$name"');
			return;
			#end
		}

		metaData = Json.parse(jsonString);

		// The JSON parser creates an anonymous object for cuePoints,
		// so we need to manually convert it to a real Map.
		var cuePointsObj:Dynamic = metaData.cuespoints;
		metaData.cuespoints = new Map<String, Float>();
		if (cuePointsObj != null)
		{
			for (fieldName in Reflect.fields(cuePointsObj))
			{
				metaData.cuespoints.set(fieldName, Reflect.field(cuePointsObj, fieldName));
			}
		}
	}
}
