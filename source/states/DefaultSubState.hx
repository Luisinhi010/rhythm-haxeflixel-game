package states;

import flixel.FlxG;
import flixel.FlxSubState;

class DefaultSubState extends FlxSubState
{
	override public function create():Void
	{
		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.F5)
		{
			trace("Reloading parent state...");
			close();
			FlxG.resetState();
		}
	}
}
