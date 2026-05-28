package objects;

import backend.Paths;
import flixel.FlxG;
import flixel.sound.FlxSound;

/**
 * A simple metronome that plays sounds at regular intervals.
 * Supports pitch variation based on beat position.
 */
class Metronome
{
	private var soundName:String = "Metronome";
	private var _flxSound:FlxSound;
	private var defaultPitch:Float = 1.0;
	private var accentPitch:Float = 1.12246;
	private var accentInterval:Int = 4; // Accent every N beats

	public function new() 
	{
		_flxSound = Paths.getFlxSound(soundName);
		if (_flxSound == null)
		{
			#if debug
			trace('Warning: Metronome sound "$soundName" not found');
			#end
		}
	}

	/**
	 * Plays the metronome click at a specific beat.
	 * @param beat The current beat number.
	 */
	public function click(beat:Int = 0):Void
	{
		if (_flxSound == null)
			return;

		// Update pitch and play from start without re-loading assets
		_flxSound.pitch = (beat % accentInterval == 0) ? accentPitch : defaultPitch;
		_flxSound.play(true);
	}
}
