package objects;

import backend.FilePath;
import backend.MusicMetaData;
import backend.Paths;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.sound.FlxSound;
import flixel.util.FlxStringUtil;
import haxe.Json;
import openfl.Memory;

using Util;

class Music extends FlxBasic
{
	// An instance of the music currently playing. Holds the sound and its metadata.
	// Also contains the algorithm for the conductor to follow the music's rhythm.
	// Can be expanded with methods to control playback, volume, etc.
	public var name:String;
	public var metaData:MusicMetaData;
	public var music:FlxSound;

	private var bpm:Float;
	private var beatDuration:Float;
	private var offset:Float;
	private var timeSignature:String;
	private var beatsPerBar:Int; // Number of beats per bar
	private var beatValue:Int; // The note value that represents one beat

	public var currentBeat:Float;
	public var currentStep:Float;
	public var currentSection:Float;
	public var currentBar:Float;

	private var _lastBeat:Int;
	private var _lastStep:Int;
	private var _lastSection:Int;
	private var _lastBar:Int;

	public var beatHit:Int->Void;
	public var stepHit:Int->Void;
	public var sectionHit:Int->Void;
	public var barHit:Int->Void;

	/**
	 * Create a new Music instance.
	 * @param fileName The music file name (without extension).
	 * @param looped Whether the music should loop when it reaches the end.
	 */
	@:noCompletion
	public function new(fileName:String, looped:Bool = false)
	{
		super();
		name = fileName; // the name is different than the song title
		// because the name is used to load identify the file
		// think of it as an id, but using the file name instead of a number.
		// the title is just for display purposes.
		// example: fileName = "song1", title = "My First Song"
		
		music = FlxG.sound.load(Paths.getMusic(fileName), 1, looped);
		metaData = Json.parse(Paths.getMusicData(fileName));
		if (metaData == null)
		{
			#if DEBUG
			throw "Music metadata not found for " + fileName;
			#end
			return;
		}
		exists = true;
		active = true;

		bpm = metaData.bpm;
		beatDuration = 60 / bpm;
		offset = metaData.offset;
		timeSignature = metaData.timeSignature;

		// Parse time signature (format: "numerator/denominator")
		var timeSigParts = timeSignature.split("/");
		if (timeSigParts.length == 2)
		{
			beatsPerBar = Std.parseInt(timeSigParts[0]);
			beatValue = Std.parseInt(timeSigParts[1]);
		}
		else
		{
			// Default to 4/4 if time signature is invalid
			beatsPerBar = 4;
			beatValue = 4;
		}

		reset(0, 0);
	}

	public function play():Void
		if (music != null)
		{
			active = true;
			music.play();
		}

	public function stop():Void
		if (music != null)
		{
			active = false;
			music.stop();
		}

	public function pause():Void
		if (music != null)
		{
			active = false;
			music.pause();
		}

	public function resume()
		if (music != null)
		{
			active = true;
			music.resume();
		}

	override public function update(elapsed:Float):Void
	{
		if (music != null && music.playing)
		{
			// Calculate current beat position
			currentBeat = (music.time - offset) / (beatDuration * 1000);

			// Calculate subdivisions
			currentStep = currentBeat * (beatValue / 4); // steps per beat based on time signature
			currentSection = Math.floor(currentBeat / beatsPerBar); // beats per section based on time signature
			currentBar = Math.floor(currentBeat / beatsPerBar); // beats per bar based on time signature

			// Check for beat hits (pass beat index to handler)
			var beatIndex = Std.int(Math.floor(currentBeat));
			if (beatIndex > _lastBeat)
			{
				_lastBeat = beatIndex;
				if (beatHit != null)
					beatHit(beatIndex);
			}

			// Check for step hits (pass step index to handler)
			var stepIndex = Std.int(Math.floor(currentStep));
			if (stepIndex > _lastStep)
			{
				_lastStep = stepIndex;
				if (stepHit != null)
					stepHit(stepIndex);
			}

			// Check for section hits (pass section index)
			var sectionIndex = Std.int(Math.floor(currentSection));
			if (sectionIndex > _lastSection)
			{
				_lastSection = sectionIndex;
				if (sectionHit != null)
					sectionHit(sectionIndex);
			}

			// Check for bar hits (pass bar index)
			var barIndex = Std.int(Math.floor(currentBar));
			if (barIndex > _lastBar)
			{
				_lastBar = barIndex;
				if (barHit != null)
					barHit(barIndex);
			}
		}

		super.update(elapsed);
	}

	public function reset(x:Float, y:Float):Void
	{
		currentBeat = 0;
		currentStep = 0;
		currentSection = 0;
		currentBar = 0;
	_lastBeat = -1;
	_lastStep = -1;
	_lastSection = -1;
	_lastBar = -1;
		visible = false;
		active = false;

		beatHit = null;
		stepHit = null;
		sectionHit = null;
		barHit = null;
	}

	override public function toString():String
	{
		return FlxStringUtil.getDebugString([
			LabelValuePair.weak("name", name),
			LabelValuePair.weak("bpm", bpm),
			LabelValuePair.weak("beatDuration", beatDuration),
			LabelValuePair.weak("offset", offset),
			LabelValuePair.weak("timeSignature", timeSignature),
			LabelValuePair.weak("currentBeat", currentBeat),
			LabelValuePair.weak("currentStep", currentStep),
			LabelValuePair.weak("currentSection", currentSection),
			LabelValuePair.weak("currentBar", currentBar)
		]);
	}
}
