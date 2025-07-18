package states;

import backend.Music;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import objects.DefaultBar;
import objects.DefaultSprite;

class PlayState extends DefaultState
{
	var middlebar:DefaultBar;

	override public function create():Void
	{
		middlebar = new DefaultBar(0, 0);
		middlebar.screenCenter();
		add(middlebar);

		backend.Music.test();
		super.create();

		var count:Int = 0;
		new FlxTimer().start(1.666666666666667, function(t:FlxTimer):Void
		{
			trace("Timer tick: " + count);
			count++;
		}, 0);

		trace(backend.FilePath.getExtension(backend.FilePath.FilePathExtension.MP3));
	}
}
