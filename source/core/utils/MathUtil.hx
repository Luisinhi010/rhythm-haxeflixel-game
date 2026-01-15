package core.utils;

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
	public static inline function clamp(value:Float, min:Float, max:Float):Float
	{
		return FlxMath.bound(value, min, max);
	}
	
	/**
	 * Clamps an integer value between a minimum and maximum.
	 */
	public static inline function clampInt(value:Int, min:Int, max:Int):Int
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
	public static inline function roundTo(value:Float, precision:Int):Float
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
	public static inline function lerp(a:Float, b:Float, t:Float):Float
	{
		return FlxMath.lerp(a, b, t);
	}
	
	/**
	 * Linear interpolation with automatic clamping of t.
	 */
	public static inline function lerpClamp(a:Float, b:Float, t:Float):Float
	{
		return FlxMath.lerp(a, b, FlxMath.bound(t, 0, 1));
	}
	
	/**
	 * Maps a value from one range to another.
	 * 
	 * @param value Value to map
	 * @param inMin Input range minimum
	 * @param inMax Input range maximum
	 * @param outMin Output range minimum
	 * @param outMax Output range maximum
	 * @return Mapped value
	 */
	public static inline function mapRange(value:Float, inMin:Float, inMax:Float, outMin:Float, outMax:Float):Float
	{
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
		return Math.abs(a - b) < eps;
	}
	
	/**
	 * Returns the sign of a number.
	 * 
	 * @return 1 if positive, -1 if negative, 0 if zero
	 */
	public static inline function sign(x:Float):Int
	{
		return FlxMath.signOf(Std.int(x));
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
}
