package objects;

import backend.MusicMetaData;
import backend.Paths;
import core.events.BeatEvent;
import core.utils.MathUtil;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.sound.FlxSound;
import flixel.util.FlxStringUtil;

using Util;

/**
 * The Conductor is responsible for playing a song and keeping track of the rhythm.
 * It calculates the current beat, step, and other subdivisions, and dispatches
 * events accordingly. It is the "live" part of the music system.
 */
class Conductor extends FlxBasic
{
	// An instance of the music currently playing. Holds the sound and its metadata.
	// Also contains the algorithm for the conductor to follow the music's rhythm.
	// Can be expanded with methods to control playback, volume, etc.
	public var name:String;
	public var music:FlxSound;
	public var song:Song;
	public var playing(get, set):Bool;

	function get_playing():Bool
		return if (music != null) music.playing else false;

	function set_playing(value:Bool):Bool
	{
		if (music == null)
			return false;

		if (value)
			resume();
		else
			pause();
		return value;
	}

	private var bpm:Float;
	private var offset:Float;
	private var timeSignature:String;
	public var beatDuration:Float;
	public var beatsPerBar:Int; // Number of beats per bar
	public var beatValue:Int; // The note value that represents one beat

	public var time(get, set):Float;

	function get_time():Float
		return if (music != null) music.time else 0;

	function set_time(value:Float):Float
	{
		if (music != null && music.length > 0)
		{
			// Clamp time to valid range [0, music.length]
			var clampedValue = Math.max(0, Math.min(value, music.length));
			music.time = clampedValue;
			resetCounters();
			updateBeatAndSubdivisions();
			return clampedValue;
		}
		return value;
	}
	
	// Timing and sync
	private var beatOffset:Float = 0; // Fine offset adjustment for beats
	private var syncThreshold:Float = 0.02; // Sync tolerance (20ms)
	private var lastResyncTime:Float = 0;
	private var resyncInterval:Float = 1.0; // Resync every second

	// Cue points and sections
	/* Cue points are named timestamps in the music that can be jumped to.
		*Tempo changes are points in time where the BPM changes, allowing for dynamic tempo adjustments.
	 */
	public var cuePoints:Map<String, Float>; // <Name, Time (in miliseconds)>
	public var tempoChanges:Array<{time:Float, bpm:Float}>;

	public var currentBeat:Float;
	public var currentStep:Float;
	public var currentSection:Float;
	public var currentBar:Float;

	private var _lastBeat:Int;
	private var _lastStep:Int;
	private var _lastSection:Int;
	private var _lastBar:Int;
	private var _nextTempoChangeIndex:Int = 0;

	public var beatHit:BeatEvent->Void;
	public var stepHit:BeatEvent->Void;
	public var sectionHit:BeatEvent->Void;
	public var barHit:BeatEvent->Void;

	/**
	 * Set the BPM value with validation.
	 * Automatically updates beatDuration.
	 * @param value The new BPM value
	 */
	private function setBpm(value:Float):Void
	{
		if (value <= 0)
		{
			#if debug
			trace('Invalid BPM: $value, defaulting to 120');
			#end
			value = 120;
		}
		bpm = value;
		beatDuration = 60 / bpm;
	}

	/**
	 * Parse time signature string (format: "numerator/denominator").
	 * Sets beatsPerBar and beatValue.
	 * @param signature The time signature string
	 */
	private function parseTimeSignature(signature:String):Void
	{
		var timeSigParts = signature.split("/");
		if (timeSigParts.length == 2)
		{
			var parsedBeats = Std.parseInt(timeSigParts[0]);
			var parsedValue = Std.parseInt(timeSigParts[1]);
			beatsPerBar = (parsedBeats != null && parsedBeats > 0) ? parsedBeats : 4;
			beatValue = (parsedValue != null && parsedValue > 0) ? parsedValue : 4;
		}
		else
		{
			beatsPerBar = 4;
			beatValue = 4;
		}
	}

	// Utility functions
	public function quantize(time:Float, step:Float = 0.25):Float
	{
		if (beatDuration <= 0 || step <= 0)
			return time;
		return Math.round(time / (beatDuration * step)) * (beatDuration * step);
	}

	public function addCuePoint(name:String, time:Float):Void
	{
		if (cuePoints == null)
			cuePoints = new Map();
		cuePoints.set(name, time);
	}

	public function removeCuePoint(name:String):Void
	{
		if (cuePoints != null && cuePoints.exists(name))
		{
			cuePoints.remove(name);
		}
	}

	public function jumpToCue(name:String):Void
	{
		if (music == null || cuePoints == null)
			return;

		if (!cuePoints.exists(name))
		{
			#if debug
			trace('Cue point "$name" not found');
			#end
			return;
		}

		var time = cuePoints.get(name);
		music.time = time;
		resetCounters();
		updateBeatAndSubdivisions();
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
		if (music == null || !music.playing)
			return;

		var currentTime = time;
		if (currentTime - lastResyncTime >= resyncInterval * 1000)
		{
			var expectedBeat = (currentTime - offset) / (beatDuration * 1000);
			var drift = expectedBeat - currentBeat;

			if (Math.abs(drift) > syncThreshold)
			{
				currentBeat = expectedBeat;
				updateSubdivisions();
			}

			lastResyncTime = currentTime;
		}
	}

	private function updateBeatAndSubdivisions():Void
	{
		if (beatDuration <= 0)
		{
			#if debug
			trace('Invalid beatDuration: $beatDuration');
			#end
			return;
		}
		
		currentBeat = (time - offset) / (beatDuration * 1000);
		updateSubdivisions();
	}

	private function updateSubdivisions():Void
	{
		currentStep = currentBeat * (beatValue / 4);
		currentBar = Math.floor(currentBeat / beatsPerBar);
		// Section is every 16 beats (not the same as bar)
		currentSection = Math.floor(currentBeat / 16);
	}



	/**
	 * Create a new Music instance.
	 * @param song The Song object to play.
	 */
	public function new(song:Song)
	{
		super();
		#if debug
		trace('new Conductor for song: ${song.name}');
		#end
		exists = true;

		this.song = song;
		this.name = song.name;
		this.music = song.music;
		// Initialize with null-safe defaults
		cuePoints = song.metaData != null && song.metaData.cuePoints != null ? song.metaData.cuePoints : new Map<String, Float>();
		tempoChanges = song.metaData != null && song.metaData.tempoChanges != null ? song.metaData.tempoChanges : [];

		// Set BPM with validation
		setBpm(song.metaData.bpm);

		offset = song.metaData.offset;
		timeSignature = song.metaData.timeSignature;

		#if debug
		trace('  - Initial BPM: $bpm, Offset: $offset, Time Signature: $timeSignature');
		#end
		// Parse time signature
		parseTimeSignature(timeSignature);

		reset();
		if (tempoChanges != null)
			tempoChanges.sort((a, b) -> Std.int(a.time - b.time));
		if (music != null)
		{
			music.onComplete = function()
			{
				resetCounters();
			};
			// Set loop point to start
			music.loopTime = 0;
		}
		_nextTempoChangeIndex = 0;
		lastResyncTime = 0; // Initialize resync timer
	}

	public function play():Void
		if (music != null)
		{
			music.play();
			active = music.playing;
		}

	public function stop():Void
		if (music != null)
		{
			music.stop();
			active = false;
		}

	public function pause():Void
		if (music != null)
		{
			music.pause();
			active = false;
		}

	public function resume()
		if (music != null)
		{
			music.resume();
			active = music.playing;
		}

	override public function update(elapsed:Float):Void // update is called once per frame when active is true
	{
		if (music != null && music.playing)
		{
			checkTempoChanges();

			updateBeatAndSubdivisions();

			checkResync();

			_lastBeat = checkEvent(currentBeat, _lastBeat, beatHit);
			_lastStep = checkEvent(currentStep, _lastStep, stepHit);
			_lastSection = checkEvent(currentSection, _lastSection, sectionHit);
			_lastBar = checkEvent(currentBar, _lastBar, barHit);
		}

		super.update(elapsed);
	}

	private function checkTempoChanges():Void
	{
		if (tempoChanges != null && _nextTempoChangeIndex < tempoChanges.length)
		{
			var tempoHasChanged:Bool = false;
			while (_nextTempoChangeIndex < tempoChanges.length)
			{
				var nextChange = tempoChanges[_nextTempoChangeIndex];
				if (music.time < nextChange.time)
					break;

				setBpm(nextChange.bpm);
				_nextTempoChangeIndex++;
				tempoHasChanged = true;
			}
		}
	}

	private function checkEvent(value:Float, lastValue:Int, eventHandler:BeatEvent->Void, ?debugTrace:String):Int
	{
		var index = Math.floor(value);
		if (index > lastValue)
		{
			if (eventHandler != null)
			{
				var event = new BeatEvent(index, music.time, Math.floor(currentBar));
				eventHandler(event);
			}
			return index;
		}
		return lastValue;
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
		_nextTempoChangeIndex = 0;
	}

	public function reset():Void
	{
		resetCounters();
		visible = false;
		active = false;

		beatHit = null;
		stepHit = null;
		sectionHit = null;
		barHit = null;
	}

	public function restart():Void
	{
		if (music != null)
		{
			// Reset BPM to the initial one from metadata
			setBpm(song.metaData.bpm);

			music.time = 0;
			resetCounters();
		}
	}
	/**
	 * Clean up resources to prevent memory leaks
	 */
	override public function destroy():Void
	{
		super.destroy();

		beatHit = null;
		stepHit = null;
		sectionHit = null;
		barHit = null;

		if (cuePoints != null)
		{
			cuePoints.clear();
			cuePoints = null;
		}

		tempoChanges = null;

		if (music != null)
		{
			music.stop();
			music.destroy();
			music = null;
		}

		song = null;
	}

	override public function toString():String
	{
		return FlxStringUtil.getDebugString([
			LabelValuePair.weak("song", song.metaData.title),
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
