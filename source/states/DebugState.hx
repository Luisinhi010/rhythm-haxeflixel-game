package states;

import backend.BeatEvent;
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
	var music:Music;
	var debugCanvas:FlxSprite;

	override public function create():Void
	{
		FlxG.autoPause = false;
		cam = new FlxCamera();
		FlxG.cameras.reset(cam);
		cam.bgColor = FlxColor.GRAY;
		super.create();

		debugCanvas = new FlxSprite();
		debugCanvas.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
		add(debugCanvas);

		add(music = new Music("Test", true));
		music.debugMode = true;
		music.play();
		trace(music);
		trace(music.metaData);
	}
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		#if debug
		if (music != null && music.debugMode)
		{
			music.drawDebug(debugCanvas);
		}
		#end
	}
}
