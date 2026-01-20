package states;

import core.events.BeatEvent;
import core.utils.SpriteUtil;
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
import objects.UtilTester;

class DebugState extends DefaultState
{

	var cam:FlxCamera;
	var bg:FlxSprite;
	var song:Song;
	var conductor:Conductor;
	var debugger:ConductorDebugger;
	var metronome:Metronome;
	var lastplaying:Bool = false;
	var utilTester:UtilTester;
	var showTester:Bool = false;

	/**
	 * Helper to handle conductor input controls.
	 */
	private function handleConductorInput():Void
	{
		if (conductor == null)
			return;
		
		if (FlxG.keys.justPressed.SPACE && !showTester)
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
			if (debugger != null)
				debugger.markDirty();
		}

		if (FlxG.keys.justPressed.S)
		{
			conductor.removeCuePoint("test");
			if (debugger != null)
				debugger.markDirty();
		}

		if (FlxG.keys.justPressed.A)
			conductor.time -= 10000;

		if (FlxG.keys.justPressed.D)
			conductor.time += 10000;

		if (FlxG.keys.justPressed.P)
		{
			if (debugger != null)
			{
				debugger.toggleDebugMode();
				debugger.markDirty();
			}
		}
	}

	/**
	 * Helper to handle utility tester input controls.
	 */
	private function handleUtilTesterInput():Void
	{
		if (!showTester || utilTester == null)
			return;

		// Number keys for section switching
		var sectionKeys = [
			FlxG.keys.justPressed.ONE,
			FlxG.keys.justPressed.TWO,
			FlxG.keys.justPressed.THREE,
			FlxG.keys.justPressed.FOUR,
			FlxG.keys.justPressed.FIVE
		];

		for (i in 0...sectionKeys.length)
		{
			if (sectionKeys[i])
			{
				utilTester.switchSection(i);
				break;
			}
		}

		if (FlxG.keys.justPressed.SPACE)
			utilTester.executeTest();
	}

	/**
	 * Toggles the utility tester display.
	 */
	private function toggleUtilTester():Void
	{
		if (utilTester == null || conductor == null)
			return;
		
		if (!showTester)
		{
			lastplaying = conductor.playing;
			conductor.pause();
		}
		else
		{
			if (lastplaying)
				conductor.resume();
		}

		showTester = !showTester;
		utilTester.visible = showTester;
		utilTester.active = showTester;
	}

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
		// Create and add debugger
		debugger = new ConductorDebugger(conductor);
		debugger.y = FlxG.height - 100;
		add(debugger);

		// Create utility tester
		utilTester = new UtilTester();
		utilTester.y = 0;
		utilTester.visible = false;
		add(utilTester);

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

		handleConductorInput();

		// Toggle utility tester
		if (FlxG.keys.justPressed.T)
			toggleUtilTester();

		handleUtilTesterInput();
	}
}
