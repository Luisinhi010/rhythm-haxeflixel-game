package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.system.scaleModes.StageSizeScaleMode;
import openfl.display.Sprite;
import openfl.events.Event;

class Main extends Sprite
{
	var options = {
		gameWidth: 1920,
		gameHeight: 1080,
		initialState: #if debug states.DebugState #else states.PlayState #end,
		framerate: 60,
		skipSplash: true,
		startFullscreen: false,
	};

	public function new()
	{
		super();
		var game = new FlxGame(options.gameWidth, options.gameHeight, options.initialState, options.framerate, options.framerate, options.skipSplash,
			options.startFullscreen);
		addChild(game);

		addEventListener(Event.ADDED_TO_STAGE, function(_)
		{
			FlxG.scaleMode = new StageSizeScaleMode();
		});
	}
}
