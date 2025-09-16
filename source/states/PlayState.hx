package states;

import backend.FilePath;
import backend.Music;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.sound.FlxSound;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import objects.DefaultBar;
import objects.DefaultSprite;

class PlayState extends DefaultState
{
	var hitbar:DefaultBar;

	override public function create():Void
	{
		hitbar = new DefaultBar(0, 0);
		hitbar.screenCenter();
		add(hitbar);

		super.create();

		trace(FilePath.getImagePath("example_image", false));
		add(new DefaultSprite(0, 0).loadGraphic(FilePath.getImagePath("example_image", false)));
		FlxG.sound.playMusic(FilePath.getMusicPath("Legion", false));
	}
}
