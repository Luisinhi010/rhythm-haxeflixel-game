package objects;

import flixel.FlxSprite;

class DefaultSprite extends FlxSprite
{
	public var depth:Float = 0;

	public function new(x:Float, y:Float, depth:Float = 0)
	{
		super(x, y);
		this.depth = depth;
	}

	public function setDepth(value:Float):DefaultSprite
	{
		this.depth = value;
		return this;
	}
}
