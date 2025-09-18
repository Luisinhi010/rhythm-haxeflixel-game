package states;

import backend.FilePath;
import backend.Music;
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

		trace(FilePath.getImagePath("example_image", false));
		add(new FlxSprite(0, 0).loadGraphic(FilePath.getImagePath("example_image", false)));
		FlxG.sound.playMusic(FilePath.getMusicPath("Legion", false));
		var metadata:MusicMetaData;
		metadata = Json.parse(FilePath.getMusicDataPath("Legion", false));
		trace(metadata);
	}
}
