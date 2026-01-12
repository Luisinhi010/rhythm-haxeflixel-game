package objects;

import backend.Paths;
import flixel.FlxG;
import flixel.sound.FlxSound;
import openfl.media.Sound;

/**
 * A simple metronome that plays sounds at regular intervals.
 * Supports pitch variation based on beat position.
 */
class Metronome
{
	private var soundName:String = "Metronome";
	private var sound:Sound;
	private var defaultPitch:Float = 1.0;
	private var accentPitch:Float = 1.12246;
	private var accentInterval:Int = 4; // Accent every N beats

	public function new() 
	{
		sound = Paths.getSound(soundName);
	}

	/**
	 * Plays the metronome click at a specific beat.
	 * @param beat The current beat number.
	 */
	public function click(beat:Int = 0):Void
	{
		FlxG.sound.play(sound).pitch = (beat % accentInterval == 0) ? accentPitch : defaultPitch;
	}
}
