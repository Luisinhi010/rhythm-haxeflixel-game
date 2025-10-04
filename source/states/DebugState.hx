package states;

import backend.FilePath;
import backend.MusicMetaData;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.sound.FlxSound;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.Json;
import objects.DefaultBar;
import objects.Music;

class DebugState extends DefaultState
{
	var cam:FlxCamera;

	override public function create():Void
	{
		FlxG.autoPause = false;
		cam = new FlxCamera();
		FlxG.cameras.reset(cam);
		cam.bgColor = FlxColor.WHITE;
		super.create();

		var music:Music = new Music("Legion", true);
		add(music);
		music.play();
		music.beatHit = function(beat:Int)
		{
			trace("Beat hit: " + beat);
		};
		trace(music);
		trace(music.metaData);
	}
}
