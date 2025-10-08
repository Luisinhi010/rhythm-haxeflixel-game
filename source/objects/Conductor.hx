package objects;

import backend.BeatEvent;
import backend.MusicMetaData;
import backend.Paths;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
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
		_debugDraw = true;
		return value;
	}

	private var bpm:Float;
	private var beatDuration:Float;
	private var offset:Float;
	private var timeSignature:String;
	private var beatsPerBar:Int; // Number of beats per bar
	private var beatValue:Int; // The note value that represents one beat

	public var time(get, set):Float;

	function get_time():Float
		return if (music != null) music.time else 0;

	function set_time(value:Float):Float
	{
		if (music != null)
		{
			if (debugMode)
				trace('Conductor.time set to: $value');

			music.time = value;
			resetCounters();
			updateBeatAndSubdivisions();
		}
		return value;
	}
	
	// Timing and sync
	private var beatOffset:Float = 0; // Fine offset adjustment for beats
	private var syncThreshold:Float = 0.02; // Sync tolerance (20ms)
	private var lastResyncTime:Float = 0;
	private var resyncInterval:Float = 1.0; // Resync every second

	// Debug
	public var debugMode:Bool = #if debug true #else false #end;

	private var _debugDraw:Bool = true;
	// Cue points and sections
	/* Cue points are named timestamps in the music that can be jumped to.
		*Tempo changes are points in time where the BPM changes, allowing for dynamic tempo adjustments.
	 */
	private var cuePoints:Map<String, Float>; // <Name, Time (in miliseconds)>
	private var tempoChanges:Array<{time:Float, bpm:Float}>; 

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
		if (debugMode)
			trace('Cue point "$name" added');
		_debugDraw = true;
	}

	public function removeCuePoint(name:String):Void
	{
		if (cuePoints != null && cuePoints.exists(name))
		{
			cuePoints.remove(name);
			if (debugMode)
				trace('Cue point "$name" removed');
			_debugDraw = true;
		}
	}

	public function jumpToCue(name:String):Void
	{
		if (cuePoints != null)
		{
			if (!cuePoints.exists(name))
			{
				if (debugMode)
					trace('$name does not exists');
				return;
			}
			var time = cuePoints.get(name);
			if (debugMode)
				trace('Jumping to cue "$name" at time $time');
			music.time = time;
			resetCounters();
			updateBeatAndSubdivisions();
		}
	}

	public function addTempoChange(time:Float, newBpm:Float):Void
	{
		if (tempoChanges == null)
			tempoChanges = [];
		if (debugMode)
			trace('Adding tempo change: ${newBpm} BPM at time $time');
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

	private function updateBeatAndSubdivisions():Void
	{
		currentBeat = (time - offset) / (beatDuration * 1000);
		updateSubdivisions();
	}

	private function updateSubdivisions():Void
	{
		currentStep = currentBeat * (beatValue / 4);
		currentSection = Math.floor(currentBeat / beatsPerBar);
		currentBar = Math.floor(currentBeat / beatsPerBar);
	}

	public function drawDebug(canvas:FlxSprite, positionMarker:FlxSprite, textLayer:FlxTypedGroup<FlxText>):Void
	{
		if (canvas == null || positionMarker == null || textLayer == null || music == null || !debugMode)
			return;

		if (!_debugDraw)
		{
			// Only update the position marker
			if (music.length > 0)
				positionMarker.x = (music.time / music.length) * canvas.width;
			return;
		}

		var y = canvas.height / 2;

		FlxSpriteUtil.fill(canvas, FlxColor.TRANSPARENT); // Clean the canvas before drawing
		textLayer.forEach(function(text) text.kill());
		textLayer.clear(); // Clear the group for reuse

		// Draw base line
		FlxSpriteUtil.drawLine(canvas, 0, y, canvas.width, y, {color: FlxColor.WHITE});

		// Helper to draw a marker line and its label
		function drawMarker(time:Float, color:FlxColor, size:Float, ?labelText:String)
		{
			if (music.length == 0)
				return;
			var x = (time / music.length) * canvas.width;
			FlxSpriteUtil.drawLine(canvas, x, y - size, x, y + size, {color: color, thickness: 2});

			if (labelText != null)
			{
				var label = textLayer.recycle(FlxText);
				label.setFormat(null, 8, color);
				label.text = labelText;
				label.setPosition(x + 2, y - size - 10);
				textLayer.add(label);
			}
		}

		// Draw beat and bar markers
		if (beatDuration > 0)
		{
			var msPerBeat = beatDuration * 1000;
			var totalBeats = Std.int(music.length / msPerBeat);
			for (beat in 1...totalBeats + 1)
			{
				var isBarLine = (beat % beatsPerBar == 1);
				drawMarker(beat * msPerBeat, isBarLine ? FlxColor.CYAN : FlxColor.RED, isBarLine ? 10 : 5);
			}
		}

		// Draw cue points
		if (cuePoints != null)
		{
			for (name in cuePoints.keys())
			{
				var time = cuePoints.get(name);
				drawMarker(time, FlxColor.YELLOW, 15, name);
			}
		}
		// Draw tempo changes
		if (tempoChanges != null)
			for (change in tempoChanges)
				drawMarker(change.time, FlxColor.MAGENTA, 20, '${change.bpm} BPM');

		// Setup current position marker
		positionMarker.makeGraphic(2, 50, FlxColor.LIME);
		if (music.length > 0)
			positionMarker.x = (music.time / music.length) * canvas.width;
		positionMarker.y = y - 25;
		_debugDraw = false;
	}

	/**
	 * Create a new Music instance.
	 * @param song The Song object to play.
	 */
	public function new(song:Song)
	{
		super();
		#if debug
		if (debugMode)
			trace('new Conductor for song: ${song.name}');
		#end
		exists = true;

		this.song = song;
		this.name = song.name;
		this.music = song.music;
		cuePoints = song.metaData.cuePoints;
		tempoChanges = song.metaData.tempoChanges;
		bpm = song.metaData.bpm;
		beatDuration = 60 / bpm;
		offset = song.metaData.offset;
		timeSignature = song.metaData.timeSignature;

		#if debug
		if (debugMode)
			trace('  - Initial BPM: $bpm, Offset: $offset, Time Signature: $timeSignature');
		#end
		// Parse time signature (format: "numerator/denominator")
		var timeSigParts = timeSignature.split("/");
		if (timeSigParts.length == 2)
		{
			beatsPerBar = Std.parseInt(timeSigParts[0]);
			beatValue = Std.parseInt(timeSigParts[1]);
		}
		else
		{
			beatsPerBar = 4;
			beatValue = 4;
		}

		reset();
		if (tempoChanges != null)
			tempoChanges.sort((a, b) -> Std.int(a.time - b.time));
		if (music != null)
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
		_nextTempoChangeIndex = 0;
	}

	public function play():Void
		if (music != null)
		{
			if (debugMode)
				trace('Conductor.play() called.');
			music.play();
			active = music.playing;
		}

	public function stop():Void
		if (music != null)
		{
			if (debugMode)
				trace('Conductor.stop() called.');
			music.stop();
			active = false;
		}

	public function pause():Void
		if (music != null)
		{
			if (debugMode)
				trace('Conductor.pause() called.');
			music.pause();
			active = false;
		}

	public function resume()
		if (music != null)
		{
			if (debugMode)
				trace('Conductor.resume() called.');
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

			_lastBeat = checkEvent(currentBeat, _lastBeat, beatHit, 'Beat: ${Math.floor(currentBeat)} Time: ${music.time}');
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

				bpm = nextChange.bpm;
				beatDuration = 60 / bpm;
				_nextTempoChangeIndex++;
				tempoHasChanged = true;
				if (debugMode)
					trace('Tempo changed to ${bpm} BPM at time ${music.time}');
			}
			if (tempoHasChanged)
				_debugDraw = true;
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
			if (debugMode && debugTrace != null)
				trace(debugTrace);
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
		_debugDraw = true;
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
			bpm = song.metaData.bpm;
			beatDuration = 60 / bpm;

			music.time = 0;
			resetCounters();
			if (debugMode)
				trace('Music restarted');
		}
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
