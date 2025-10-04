package objects;

import backend.BeatEvent;
import backend.FilePath;
import backend.MusicMetaData;
import backend.Paths;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.sound.FlxSound;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
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

	// Timing and sync
	private var beatOffset:Float = 0; // Fine offset adjustment for beats
	private var syncThreshold:Float = 0.02; // Sync tolerance (20ms)
	private var lastResyncTime:Float = 0;
	private var resyncInterval:Float = 1.0; // Resync every second

	// Debug
	public var debugMode:Bool = #if debug true #else false #end;

	// Cue points and sections
	private var cuePoints:Map<String, Float>;
	private var tempoChanges:Array<{time:Float, bpm:Float}>;

	public var currentBeat:Float;
	public var currentStep:Float;
	public var currentSection:Float;
	public var currentBar:Float;

	private var _lastBeat:Int;
	private var _lastStep:Int;
	private var _lastSection:Int;
	private var _lastBar:Int;

	public var beatHit:BeatEvent->Void;
	public var stepHit:BeatEvent->Void;
	public var sectionHit:BeatEvent->Void;
	public var barHit:BeatEvent->Void;

	// Utility functions
	public function quantize(time:Float, step:Float = 0.25):Float
	{
		return Math.round(time / (beatDuration * step)) * (beatDuration * step);
	}

	public function addCuePoint(name:String, time:Float):Void
	{
		if (cuePoints == null)
			cuePoints = new Map();
		cuePoints.set(name, time);
	}

	public function jumpToCue(name:String):Void
	{
		if (cuePoints != null && cuePoints.exists(name))
		{
			var time = cuePoints.get(name);
			music.time = time;
			resetCounters();
			// Recalculate beats based on new time
			currentBeat = (time - offset) / (beatDuration * 1000);
			updateSubdivisions();
		}
	}

	public function addTempoChange(time:Float, newBpm:Float):Void
	{
		if (tempoChanges == null)
			tempoChanges = [];
		tempoChanges.push({time: time, bpm: newBpm});
		tempoChanges.sort((a, b) -> Std.int(a.time - b.time));
	}

	private function checkResync():Void
	{
		if (music.time - lastResyncTime >= resyncInterval)
		{
			var expectedBeat = (music.time - offset) / (beatDuration * 1000);
			var drift = expectedBeat - currentBeat;

			if (Math.abs(drift) > syncThreshold)
			{
				currentBeat = expectedBeat;
				updateSubdivisions();
				if (debugMode)
					trace('Resynced at time ${music.time}. Drift was: $drift');
			}

			lastResyncTime = music.time;
		}
	}

	private function updateSubdivisions():Void
	{
		currentStep = currentBeat * (beatValue / 4);
		currentSection = Math.floor(currentBeat / beatsPerBar);
		currentBar = Math.floor(currentBeat / beatsPerBar);
	}

	#if debug
	public function drawDebug(canvas:FlxSprite):Void
	{
		var y = canvas.height - 40;

		// Limpar o canvas antes de desenhar
		FlxSpriteUtil.fill(canvas, FlxColor.TRANSPARENT);

		// Linha base horizontal
		FlxSpriteUtil.drawLine(canvas, 0, y, canvas.width, y, {color: FlxColor.WHITE});

		// Draw beats
		for (i in 0...Std.int(music.length / (beatDuration * 1000)))
		{
			var x = (i * beatDuration * 1000) / music.length * canvas.width;
			FlxSpriteUtil.drawLine(canvas, x, y - 5, x, y + 5, {color: FlxColor.RED});
		}

		// Mark current position
		var currentX = (music.time / music.length) * canvas.width;
		FlxSpriteUtil.drawLine(canvas, currentX, y - 10, currentX, y + 10, {color: FlxColor.LIME});

		// Draw cue points if any
		if (cuePoints != null)
		{
			for (time in cuePoints)
			{
				var x = (time / music.length) * canvas.width;
				FlxSpriteUtil.drawLine(canvas, x, y - 15, x, y + 15, {color: FlxColor.YELLOW});
			}
		}
	}
	#end

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

		// Initialize maps
		cuePoints = new Map<String, Float>();
		tempoChanges = [];

		// Add loop completion handler if looped
		if (looped && music != null)
		{
			music.onComplete = function()
			{
				resetCounters();
				if (debugMode)
					trace('Loop point reached at ${music.time}');
			};
			// Set loop point to start
			music.loopTime = 0;
		}

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

			checkResync();

			// Check for beat hits
			var beatIndex = Math.floor(currentBeat);
			if (beatIndex > _lastBeat)
			{
				_lastBeat = beatIndex;
				if (beatHit != null)
				{
					var event = new BeatEvent(beatIndex, music.time, Std.int(currentBar));
					beatHit(event);
				}
				if (debugMode)
					trace('Beat: $beatIndex Time: ${music.time}');
			}

			// Check for step hits
			var stepIndex = Math.floor(currentStep);
			if (stepIndex > _lastStep)
			{
				_lastStep = stepIndex;
				if (stepHit != null)
				{
					var event = new BeatEvent(stepIndex, music.time, Std.int(currentBar));
					stepHit(event);
				}
			}

			// Check for section hits
			var sectionIndex = Math.floor(currentSection);
			if (sectionIndex > _lastSection)
			{
				_lastSection = sectionIndex;
				if (sectionHit != null)
				{
					var event = new BeatEvent(sectionIndex, music.time, Std.int(currentBar));
					sectionHit(event);
				}
			}

			// Check for bar hits
			var barIndex = Math.floor(currentBar);
			if (barIndex > _lastBar)
			{
				_lastBar = barIndex;
				if (barHit != null)
				{
					var event = new BeatEvent(barIndex, music.time, barIndex);
					barHit(event);
				}
			}
		}

		super.update(elapsed);
	}

	/**
	 * Reset only the beat/step/section/bar counters without affecting other state
	 */
	private function resetCounters():Void
	{
		currentBeat = 0;
		currentStep = 0;
		currentSection = 0;
		currentBar = 0;
		_lastBeat = -1;
		_lastStep = -1;
		_lastSection = -1;
		_lastBar = -1;
	}

	public function reset(x:Float, y:Float):Void
	{
		resetCounters();
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
