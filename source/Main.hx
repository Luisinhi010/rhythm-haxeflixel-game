package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	var options = {
		gameWidth: 1280,
		gameHeight: 720,
		initialState: #if debug states.DebugState #else states.PlayState #end,
		framerate: 60,
		skipSplash: true,
		startFullscreen: false,
	};

	public function new()
	{
		super();
		addChild(new FlxGame(options.gameWidth, options.gameHeight, options.initialState, options.framerate, options.framerate, options.skipSplash,
			options.startFullscreen));
	}
}
