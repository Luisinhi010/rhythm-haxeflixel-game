package states;

import backend.BeatEvent;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import objects.Conductor;
import objects.ConductorDebugger;
import objects.Metronome;
import objects.Song;

class DebugState extends DefaultState
{

	var cam:FlxCamera;
	var bg:FlxSprite;
	var song:Song;
	var conductor:Conductor;
	var debugger:ConductorDebugger;
	var metronome:Metronome;

	override public function create():Void
	{
		FlxG.autoPause = false;
		cam = new FlxCamera();
		FlxG.cameras.reset(cam);
		cam.bgColor = FlxColor.TRANSPARENT;
		super.create();

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		bg.color = FlxColor.GRAY;
		add(bg);

		song = new Song("Test", true);
		conductor = new Conductor(song);
		add(conductor);
		// Create and add debugger as a FlxTypedGroup
		debugger = new ConductorDebugger(conductor);
		debugger.y = FlxG.height - 100;
		add(debugger);
		
		metronome = new Metronome();
		conductor.beatHit = (event:BeatEvent) ->
		{
			// metronome.click(event.beat);
			// if (event.beat % 2 == 0)		FlxTween.color(bg, (60 / song.metaData.bpm), FlxColor.WHITE, FlxColor.GRAY);
		};
		conductor.play();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (conductor != null)
		{
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
			{
				conductor.addCuePoint("test", conductor.music.time);
				debugger.markDirty();
			}
			if (FlxG.keys.justPressed.S)
			{
				conductor.removeCuePoint("test");
				debugger.markDirty();
			}
			if (FlxG.keys.justPressed.A)
				conductor.time -= 10000;
			if (FlxG.keys.justPressed.D)
				conductor.time += 10000;
			if (FlxG.keys.justPressed.P)
			{
				debugger.toggleDebugMode();
				debugger.markDirty();
			}
		}
	}
}
