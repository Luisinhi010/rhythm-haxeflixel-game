package states;

import backend.FilePath;
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
	}
}
