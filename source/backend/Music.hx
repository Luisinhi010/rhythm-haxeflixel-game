package backend;

import flixel.FlxG;
import flixel.sound.FlxSound;
import haxe.Json;

class Music
{
	// An instance of the currently playing music. it contains the music and its metadata.
	// also contains the algorithm for the conductor to follow the music's beat.
	// it can be expanded with methods to control playback, volume, etc.
	public var metaData:MusicMetaData;
	public var music:FlxSound;
	private var bpm:Float;
	private var beatDuration:Float;
	private var offset:Float;
	private var timeSignature:String;

	public var currentBeat:Float;
	public var currentStep:Float;
	public var currentSection:Float;
	public var currentBar:Float;
	private var lastBeat:Float;
	private var lastStep:Float;
	private var lastSection:Float;
	private var lastBar:Float;

	public var beatHit:Void->Void;
	public var stepHit:Void->Void;
	public var sectionHit:Void->Void;
	public var barHit:Void->Void;

	public function new(musicName:String)
	{
		music = FlxG.sound.load(FilePath.getMusicPath(musicName), 1, false, true);
		metaData = Json.parse(FilePath.getMusicDataPath(musicName));

		bpm = metaData.bpm;
		beatDuration = 60 / bpm;
		offset = metaData.offset;
		timeSignature = metaData.timeSignature;

		currentBeat = 0;
		currentStep = 0;
		currentSection = 0;
		currentBar = 0;
		lastBeat = -1;
		lastStep = -1;
		lastSection = -1;
		lastBar = -1;

		beatHit = null;
		stepHit = null;
		sectionHit = null;
		barHit = null;
	}
}


