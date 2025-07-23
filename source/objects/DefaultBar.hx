package objects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;

class DefaultBar extends FlxSprite
{
	public function new(x:Float, y:Float)
	{
		super(x, y);
		makeGraphic(50, FlxG.height, FlxColor.WHITE);
		scrollFactor.set(0, 0);
	}
}
