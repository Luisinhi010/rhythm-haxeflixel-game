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
import objects.Metronome;
import objects.Song;

class DebugState extends DefaultState
{

	var cam:FlxCamera;
	var bg:FlxSprite;
	var song:Song;
	var conductor:Conductor;
	var debugCanvas:FlxSprite;
	var debugTextLayer:FlxTypedGroup<FlxText>;
	var positionMarker:FlxSprite;
	var metronome:Metronome;

	// UI Elements
	var uiPanel:FlxSprite;
	var infoText:FlxText;
	var controlsText:FlxText;
	var statusText:FlxText;
	var cuePointsText:FlxText;

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

		debugCanvas = new FlxSprite();
		debugCanvas.makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
		add(debugCanvas);

		debugTextLayer = new FlxTypedGroup<FlxText>();
		add(debugTextLayer);

		positionMarker = new FlxSprite();
		add(positionMarker);

		createUI();

		song = new Song("Test", true);
		conductor = new Conductor(song);
		add(conductor);
		metronome = new Metronome();
		conductor.beatHit = (event:BeatEvent) ->
		{
			metronome.click(event.beat);
			if (event.beat % 2 == 0)
				FlxTween.color(bg, (60 / song.metaData.bpm), FlxColor.WHITE, FlxColor.GRAY);
		};
		conductor.play();
	}

	private function createUI():Void
	{
		// Main panel background
		uiPanel = new FlxSprite(10, 10);
		uiPanel.makeGraphic(Std.int(FlxG.width * 0.3), Std.int(FlxG.height * 0.85), FlxColor.BLACK);
		uiPanel.alpha = 0.8;
		add(uiPanel);

		// Info Text
		infoText = new FlxText(25, 25, 0, "MUSIC INFO", 14);
		infoText.color = FlxColor.YELLOW;
		infoText.bold = true;
		add(infoText);

		// Status Text
		statusText = new FlxText(25, 50, 0, "Status: ", 12);
		statusText.color = FlxColor.WHITE;
		add(statusText);

		// Controls Text
		controlsText = new FlxText(25, 150, 0, "", 11);
		controlsText.color = FlxColor.LIME;
		controlsText.text = "CONTROLES:\n" + "[SPACE] Play/Pause\n" + "[R] Restart\n" + "[Q] Jump to 'test' cue\n" + "[E] Add 'test' cue point\n"
			+ "[S] Remove 'test' cue\n" + "[A] -10s\n" + "[D] +10s\n" + "[P] Toggle Debug Draw\n";
		add(controlsText);

		// Cue Points Text
		cuePointsText = new FlxText(25, FlxG.height - 150, 0, "", 11);
		cuePointsText.color = FlxColor.CYAN;
		add(cuePointsText);
	}

	private function updateUI():Void
	{
		@:privateAccess
		if (conductor != null && song != null)
		{
			var minutes:Int = Std.int(conductor.music.time / 60000);
			var seconds:Int = Std.int((conductor.music.time % 60000) / 1000);
			var ms:Int = Std.int(conductor.music.time % 1000);
			var timeStr = '${minutes}:${seconds < 10 ? "0" : ""}${seconds}.${ms < 100 ? "0" : ""}${ms < 10 ? "0" : ""}${ms}';

			var duration = conductor.music.length;
			var durMinutes:Int = Std.int(duration / 60000);
			var durSeconds:Int = Std.int((duration % 60000) / 1000);
			var durationStr = '${durMinutes}:${durSeconds < 10 ? "0" : ""}${durSeconds}';

			statusText.text = "Status: " + (conductor.playing ? "PLAYING" : "PAUSED") + "\n" + "BPM: " + song.metaData.bpm + "\n" + "Beat: "
				+ conductor.currentBeat + "\n" + "Time: " + timeStr + " / " + durationStr + "\n" + "Debug Draw: " + (conductor.debugMode ? "ON" : "OFF");

			// Update cue points display
			var cueList = "CUE POINTS:\n";
			for (cueName in conductor.cuePoints.keys())
			{
				var cueTime = conductor.cuePoints.get(cueName);
				var cueMin = Std.int(cueTime / 60000);
				var cueSec = Std.int((cueTime % 60000) / 1000);
				cueList += '${cueName}: ${cueMin}:${cueSec < 10 ? "0" : ""}${cueSec}\n';
			}
			cuePointsText.text = cueList;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (conductor != null)
		{
			updateUI();

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
	}
}
