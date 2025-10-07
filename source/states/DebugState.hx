package states;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import objects.Conductor;
import objects.Song;

class DebugState extends DefaultState
{
	var cam:FlxCamera;
	var song:Song;
	var conductor:Conductor;
	var debugCanvas:FlxSprite;
	var debugTextLayer:FlxTypedGroup<FlxText>;
	var positionMarker:FlxSprite;

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

		debugTextLayer = new FlxTypedGroup<FlxText>();
		add(debugTextLayer);

		positionMarker = new FlxSprite();
		add(positionMarker);

		song = new Song("Singularity", true);
		conductor = new Conductor(song);
		add(conductor);
		conductor.play();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		#if debug
		if (conductor != null)
		{
			if (conductor.debugMode)
				conductor.drawDebug(debugCanvas, positionMarker, debugTextLayer);
			if (FlxG.keys.justPressed.SPACE)
			{
				if (conductor.playing)
					conductor.pause();
				else
					conductor.resume();
			}
			if (FlxG.keys.justPressed.R)
				conductor.restart();
			if (FlxG.keys.justPressed.Q)
				conductor.jumpToCue("test");
			if (FlxG.keys.justPressed.E)
				conductor.addCuePoint("test", conductor.music.time);
			if (FlxG.keys.justPressed.S)
				conductor.removeCuePoint("test");
			if (FlxG.keys.justPressed.A)
				conductor.time -= 10000;
			if (FlxG.keys.justPressed.D)
				conductor.time += 10000;
			if (FlxG.keys.justPressed.P)
				conductor.debugMode = !conductor.debugMode;
		}
		#end
	}
}
