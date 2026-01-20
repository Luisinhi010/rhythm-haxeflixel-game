package backend;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxGroup;

/**
 * A FlxGroup that supports positioning with x and y coordinates.
 * Useful for grouping mixed types of FlxBasic objects and moving them together.
 * Children are positioned relative to the container using preAdd transformation.
 * 
 * Note: Only FlxObject children (sprites, etc.) are affected by positioning.
 * FlxBasic objects without position are ignored.
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

	/**
	 * Helper to check if a basic is a valid FlxObject that can be positioned.
	 * @param basic The basic to check
	 * @return true if it's a valid FlxObject
	 */
	private inline function isPositionable(basic:FlxBasic):Bool
	{
		return basic != null && basic.exists && Std.isOfType(basic, FlxObject);
	}

	/**
	 * Helper to apply an offset to all positionable children.
	 * @param offsetX X offset to apply
	 * @param offsetY Y offset to apply
	 */
	private function applyOffsetToChildren(offsetX:Float, offsetY:Float):Void
	{
		if (offsetX == 0 && offsetY == 0)
			return;

		for (member in members)
		{
			if (isPositionable(member))
			{
				var sprite = cast(member, FlxObject);
				sprite.x += offsetX;
				sprite.y += offsetY;
			}
		}
	}

	/**
	 * Iterates over all FlxObject children and applies a callback.
	 * @param callback Function to call for each FlxObject child
	 */
	public function forEachObject(callback:FlxObject->Void):Void
	{
		if (callback == null)
			return;

		for (member in members)
		{
			if (isPositionable(member))
			{
				callback(cast(member, FlxObject));
			}
		}
	}

	override public function add(basic:FlxBasic):FlxBasic
	{
		if (basic == null)
			return null;

		// Transform child before adding (like FlxTypedSpriteGroup.preAdd)
		transformChild(basic);
		
		return super.add(basic);
	}

	/**
	 * Adds a child without applying container transformation.
	 * Useful when the child is already positioned in absolute/screen coordinates.
	 * @param basic The object to add
	 * @return The added object
	 */
	public function addAbsolute(basic:FlxBasic):FlxBasic
	{
		if (basic == null)
			return null;

		// Add without transformation
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

	override public function remove(basic:FlxBasic, splice:Bool = false):FlxBasic
	{
		if (basic == null)
			return null;

		// Check if this object was added with transformation
		// Only reverse if it was transformed (has the offset applied)
		if (isPositionable(basic) && !isAbsoluteChild(basic))
		{
			var sprite = cast(basic, FlxObject);
			sprite.x -= _x;
			sprite.y -= _y;
		}

		return super.remove(basic, splice);
	}

	/**
	 * Checks if a child was added with addAbsolute (no transformation).
	 * This is a simple heuristic: if removing would put it at negative coords, it's probably absolute.
	 */
	private function isAbsoluteChild(basic:FlxBasic):Bool
	{
		if (!isPositionable(basic))
			return false;

		var sprite = cast(basic, FlxObject);
		// If removing offset would make position negative, it's likely absolute
		return (sprite.x - _x < 0) || (sprite.y - _y < 0);
	}

	/**
	 * Adjusts the position of a child relative to the container's position.
	 * Similar to FlxTypedSpriteGroup.preAdd()
	 */
	private function transformChild(child:FlxBasic):Void
	{
		if (isPositionable(child))
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
			applyOffsetToChildren(value - _x, 0);
			_x = value;
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
			applyOffsetToChildren(0, value - _y);
			_y = value;
		}
		return _y;
	}

	/**
	 * Sets both x and y position at once.
	 * More efficient than setting them separately when moving to a specific position.
	 * @param x The new x position
	 * @param y The new y position
	 */
	public function setPosition(x:Float, y:Float):Void
	{
		if (_x != x || _y != y)
		{
			applyOffsetToChildren(x - _x, y - _y);
			_x = x;
			_y = y;
		}
	}

	/**
	 * Centers the container on the screen.
	 * Note: This only sets the container's x/y, not the bounds of children.
	 * @param axes X, Y, or XY to center on those axes
	 */
	public function screenCenter(?axes:flixel.util.FlxAxes):Void
	{
		if (axes == null)
			axes = XY;

		var newX = _x;
		var newY = _y;

		if (axes.x)
			newX = (FlxG.width - 0) / 2; // Container doesn't have width, just position

		if (axes.y)
			newY = (FlxG.height - 0) / 2;

		setPosition(newX, newY);
	}

	/**
	 * Gets the number of FlxObject children in this container.
	 * @return The count of positionable objects
	 */
	public function getObjectCount():Int
	{
		var count = 0;
		for (member in members)
		{
			if (isPositionable(member))
				count++;
		}
		return count;
	}
	/**
	 * Resets the container position to (0, 0) and moves all children accordingly.
	 */
	public function resetPosition():Void
	{
		setPosition(0, 0);
	}
	/**
	 * Checks if a specific object is in this container.
	 * @param obj The object to check
	 * @return true if the object is in this container
	 */
	public function contains(obj:FlxBasic):Bool
	{
		return members.indexOf(obj) != -1;
	}
}
