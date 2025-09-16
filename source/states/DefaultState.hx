package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;

class DefaultState extends FlxState
{
	var transition:FlxSprite;
	var depthpass:Bool = true;

	override public function create():Void
	{
		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.F5)
		{
			trace("Reloading state...");
			FlxG.resetState();
		}
	}
}
