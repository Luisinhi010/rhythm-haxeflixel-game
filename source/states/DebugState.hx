package states;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import objects.Conductor;
import objects.Song;

class DebugState extends DefaultState
{
	var cam:FlxCamera;
	var song:Song;
	var conductor:Conductor;
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

		song = new Song("Legion");
		conductor = new Conductor(song, true);
		add(conductor);

		conductor.debugMode = true;
		conductor.play();
		trace(conductor);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		#if debug
		if (conductor != null && conductor.debugMode)
		{
			conductor.drawDebug(debugCanvas);
			if (FlxG.keys.justPressed.SPACE)
			{
				if (conductor.music.playing)
					conductor.music.pause();
				else
					conductor.music.resume();
			}
			if (FlxG.keys.justPressed.R)
				conductor.restart();
			if (FlxG.keys.justPressed.T)
				conductor.jumpToCue("test");
			if (FlxG.keys.justPressed.Y)
				conductor.addCuePoint("test", conductor.music.time);
		}
		#end
	}
}
