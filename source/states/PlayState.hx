package states;

import backend.FilePath;
import backend.Music;
import backend.MusicMetaData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.sound.FlxSound;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.Json;
import objects.DefaultBar;

class PlayState extends DefaultState
{
	var hitbar:DefaultBar;

	override public function create():Void
	{
		FlxG.autoPause = false;

		hitbar = new DefaultBar(0, 0);
		hitbar.screenCenter();
		add(hitbar);

		super.create();

		trace(FilePath.getImagePath("example_image", false));
		add(new FlxSprite(0, 0).loadGraphic(FilePath.getImagePath("example_image", false)));
		FlxG.sound.playMusic(FilePath.getMusicPath("Legion", false));
		var metadata:MusicMetaData;
		metadata = Json.parse(FilePath.getMusicDataPath("Legion", false));
		trace(metadata);
	}
}
