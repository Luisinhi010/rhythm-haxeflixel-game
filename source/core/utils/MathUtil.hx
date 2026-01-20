package core.utils;

import core.utils.ArrayUtil;
import flixel.FlxG;
import flixel.math.FlxMath;

/**
 * Math utilities using native Haxe and HaxeFlixel functions where possible.
 * Following Single Responsibility Principle.
 * 
 * NOTE: Most functions delegate to native implementations (FlxMath, Math).
 * Only custom utilities not provided by the framework are implemented here.
 */
class MathUtil
{
	/**
	 * Clamps a value between a minimum and maximum.
	 * 
	 * @param value Value to clamp
	 * @param min Minimum value
	 * @param max Maximum value
	 * @return Clamped value
	 */
	public static function clamp(value:Float, min:Float, max:Float):Float
	{
		return FlxMath.bound(value, min, max);
	}
	
	/**
	 * Clamps an integer value between a minimum and maximum.
	 */
	public static function clampInt(value:Int, min:Int, max:Int):Int
	{
		return Std.int(FlxMath.bound(value, min, max));
	}
	
	/**
	 * Rounds a float to a specified number of decimal places.
	 * 
	 * @param value Value to round
	 * @param precision Number of decimal places
	 * @return Rounded value
	 */
	public static function roundTo(value:Float, precision:Int):Float
	{
		return FlxMath.roundDecimal(value, precision);
	}
	
	/**
	 * Linear interpolation between two values.
	 * 
	 * @param a Start value
	 * @param b End value
	 * @param t Interpolation factor (0.0 to 1.0)
	 * @return Interpolated value
	 */
	public static function lerp(a:Float, b:Float, t:Float):Float
	{
		return FlxMath.lerp(a, b, t);
	}
	
	/**
	 * Linear interpolation with automatic clamping of t.
	 */
	public static function lerpClamp(a:Float, b:Float, t:Float):Float
	{
		return FlxMath.lerp(a, b, FlxMath.bound(t, 0, 1));
	}
	
	/**
	 * Maps a value from one range to another.
	 * If inMax == inMin, returns outMin to avoid division by zero.
	 * 
	 * @param value Value to map
	 * @param inMin Input range minimum
	 * @param inMax Input range maximum
	 * @param outMin Output range minimum
	 * @param outMax Output range maximum
	 * @return Mapped value
	 */
	public static function mapRange(value:Float, inMin:Float, inMax:Float, outMin:Float, outMax:Float):Float
	{
		if (inMax == inMin)
			return outMin;
		return FlxMath.remapToRange(value, inMin, inMax, outMin, outMax);
	}
	
	/**
	 * Converts degrees to radians.
	 */
	public static inline function degToRad(deg:Float):Float
	{
		return deg * Math.PI / 180;
	}
	
	/**
	 * Converts radians to degrees.
	 */
	public static inline function radToDeg(rad:Float):Float
	{
		return rad * 180 / Math.PI;
	}
	
	/**
	 * Positive modulo (always returns positive value).
	 * Manual implementation for Float support.
	 */
	public static inline function positiveMod(x:Float, m:Float):Float
	{
		if (m == 0) return 0;
		var result = x % m;
		return result < 0 ? result + m : result;
	}
	
	/**
	 * Checks if two values are approximately equal.
	 * 
	 * @param a First value
	 * @param b Second value
	 * @param eps Epsilon (tolerance)
	 * @return true if approximately equal
	 */
	public static inline function approxEqual(a:Float, b:Float, eps:Float = 0.0001):Bool
	{
		return Math.abs(a - b) <= eps;
	}
	
	/**
	 * Returns the sign of a number.
	 * Preserves float semantics for small magnitudes.
	 * 
	 * @return 1 if positive, -1 if negative, 0 if zero
	 */
	public static inline function sign(x:Float):Int
	{
		if (x < 0)
			return -1;
		if (x > 0)
			return 1;
		return 0;
	}
	
	/**
	 * Generates a random float between min and max.
	 */
	public static inline function randomRange(min:Float, max:Float):Float
	{
		return FlxG.random.float(min, max);
	}
	
	/**
	 * Generates a random integer between min and max (inclusive).
	 */
	public static inline function randomInt(min:Int, max:Int):Int
	{
		return FlxG.random.int(min, max);
	}
	
	/**
	 * Calculates percentage of a relative to b.
	 */
	public static inline function percent(a:Float, b:Float):Float
	{
		if (b == 0) return 0;
		return a / b;
	}
	/**
	 * Calculates distance between two points.
	 * @param x1 First point X
	 * @param y1 First point Y
	 * @param x2 Second point X
	 * @param y2 Second point Y
	 * @return Distance between points
	 */
	public static inline function distance(x1:Float, y1:Float, x2:Float, y2:Float):Float
	{
		return FlxMath.distanceBetween(x1, y1, x2, y2);
	}

	/**
	 * Calculates squared distance (faster, no sqrt).
	 * Useful for distance comparisons where exact distance isn't needed.
	 */
	public static inline function distanceSquared(x1:Float, y1:Float, x2:Float, y2:Float):Float
	{
		var dx = x2 - x1;
		var dy = y2 - y1;
		return dx * dx + dy * dy;
	}

	/**
	 * Calculates angle in radians between two points.
	 * @param x1 Start point X
	 * @param y1 Start point Y
	 * @param x2 End point X
	 * @param y2 End point Y
	 * @return Angle in radians
	 */
	public static inline function angleBetween(x1:Float, y1:Float, x2:Float, y2:Float):Float
	{
		return FlxMath.angleBetween(x1, y1, x2, y2);
	}

	/**
	 * Calculates angle in degrees between two points.
	 */
	public static inline function angleBetweenDegrees(x1:Float, y1:Float, x2:Float, y2:Float):Float
	{
		return radToDeg(angleBetween(x1, y1, x2, y2));
	}

	/**
	 * Wraps an angle to the range [0, 360) degrees.
	 * @param angle Angle in degrees
	 * @return Wrapped angle
	 */
	public static inline function wrapAngle(angle:Float):Float
	{
		return FlxMath.wrapAngle(angle);
	}

	/**
	 * Returns the minimum of multiple values.
	 * More convenient than Math.min for 3+ values.
	 */
	public static function min(values:Array<Float>):Float
	{
		if (ArrayUtil.isEmpty(values))
			return 0;
		var result = values[0];
		for (i in 1...values.length)
		{
			if (values[i] < result)
				result = values[i];
		}
		return result;
	}

	/**
	 * Returns the maximum of multiple values.
	 * More convenient than Math.max for 3+ values.
	 */
	public static function max(values:Array<Float>):Float
	{
		if (ArrayUtil.isEmpty(values))
			return 0;
		var result = values[0];
		for (i in 1...values.length)
		{
			if (values[i] > result)
				result = values[i];
		}
		return result;
	}

	/**
	 * Calculates average of array values.
	 * @param values Array of numbers
	 * @return Average value, or 0 if empty
	 */
	public static function average(values:Array<Float>):Float
	{
		if (ArrayUtil.isEmpty(values))
			return 0;
		var sum:Float = 0;
		for (value in values)
			sum += value;
		return sum / values.length;
	}

	/**
	 * Smooth step interpolation (ease in/out).
	 * Returns smooth curve between 0 and 1 for t in [0, 1].
	 */
	public static function smoothStep(t:Float):Float
	{
		t = clamp(t, 0, 1);
		return t * t * (3 - 2 * t);
	}

	/**
	 * Smoother step interpolation (better ease in/out).
	 * Ken Perlin's improved smoothstep.
	 */
	public static function smootherStep(t:Float):Float
	{
		t = clamp(t, 0, 1);
		return t * t * t * (t * (t * 6 - 15) + 10);
	}

	/**
	 * Checks if value is within range (inclusive).
	 */
	public static inline function inRange(value:Float, min:Float, max:Float):Bool
	{
		return value >= min && value <= max;
	}
}
