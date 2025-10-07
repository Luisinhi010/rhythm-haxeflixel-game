package backend;

typedef MusicMetaData =
{
	title:String,
	artist:String,
	bpm:Float,
	?offset:Float, // in milliseconds, If not provided, defaults to 0
	?timeSignature:String, // e.g., "4/4", "3/4". If not provided, defaults to "4/4"
	?cuePoints:Map<String, Float>, // Map of cue point names to their time in milliseconds
	?tempoChanges:Array<{time:Float, bpm:Float}>, // Array of tempo changes with time in milliseconds and new bpm
	?looped:Bool // Whether the music should loop
}
