package backend;

import flixel.FlxG;
import flixel.sound.FlxSound;

class Music
{
	public static var bpm:Float;
	public static var timeSignature:String;
	public static var song:FlxSound;

	public static function test()
	{
		song = new FlxSound();
		song.loadEmbedded("assets/100bpm.ogg", true, false);
		song.play();
	}
}
