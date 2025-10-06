package backend;

typedef MusicMetaData =
{
	title:String,
	artist:String,
	bpm:Float,
	offset:Float,
	timeSignature:String,
	cuespoints:Map<String, Float>,
	tempoChanges:Array<{time:Float, bpm:Float}>
}
