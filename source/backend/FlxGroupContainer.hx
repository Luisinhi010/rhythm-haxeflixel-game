package backend;

import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.group.FlxGroup;

/**
 * A FlxGroup that supports positioning with x and y coordinates.
 * Useful for grouping mixed types of FlxBasic objects and moving them together.
 * Children are positioned relative to the container using preAdd transformation.
 */
class FlxGroupContainer extends FlxGroup
{
	private var _x:Float = 0;
	private var _y:Float = 0;

	public var x(get, set):Float;
	public var y(get, set):Float;

	public function new()
	{
		super();
	}

	override public function add(basic:FlxBasic):FlxBasic
	{
		if (basic == null)
			return null;

		// Transform child before adding (like FlxTypedSpriteGroup.preAdd)
		transformChild(basic);
		
		return super.add(basic);
	}

	override public function insert(position:Int, basic:FlxBasic):FlxBasic
	{
		if (basic == null)
			return null;

		// Transform child before inserting
		transformChild(basic);
		
		return super.insert(position, basic);
	}

	/**
	 * Adjusts the position of a child relative to the container's position.
	 * Similar to FlxTypedSpriteGroup.preAdd()
	 */
	private function transformChild(child:FlxBasic):Void
	{
		if (child == null)
			return;

		// Only adjust position if the child is a FlxObject
		if (Std.isOfType(child, FlxObject))
		{
			var sprite = cast(child, FlxObject);
			sprite.x += _x;
			sprite.y += _y;
		}
	}

	private function get_x():Float
	{
		return _x;
	}

	private function set_x(value:Float):Float
	{
		if (_x != value)
		{
			var offset = value - _x;
			_x = value;
			// Move all children by the offset
			for (member in members)
			{
				if (member != null && member.exists && Std.isOfType(member, FlxObject))
				{
					var sprite = cast(member, FlxObject);
					sprite.x += offset;
				}
			}
		}
		return _x;
	}

	private function get_y():Float
	{
		return _y;
	}

	private function set_y(value:Float):Float
	{
		if (_y != value)
		{
			var offset = value - _y;
			_y = value;
			// Move all children by the offset
			for (member in members)
			{
				if (member != null && member.exists && Std.isOfType(member, FlxObject))
				{
					var sprite = cast(member, FlxObject);
					sprite.y += offset;
				}
			}
		}
		return _y;
	}
}
