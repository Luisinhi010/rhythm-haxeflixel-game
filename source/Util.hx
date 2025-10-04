import Math;
import Std;
import StringTools;
import flixel.FlxG;

class Util
{
	/**
	 * Capitalizes the first letter of a string.
	 * @param str 
	 * @return String
	 */
	public static inline function capitalization(str:String):String
	{
		if (str.length == 0)
			return str;
		return str.charAt(0).toUpperCase() + str.substr(1);
	}

	/**
	 * Clamps a value between a minimum and maximum range.
	 * @param value 
	 * @param min 
	 * @param max 
	 * @return Float
	 */
	public static inline function clamp(value:Float, min:Float, max:Float):Float
	{
		return Math.max(min, Math.min(max, value));
	}

	/**
	 * Rounds a float to a specified number of decimal places.
	 * @param value 
	 * @param precision 
	 * @return Float
	 */
	public static inline function roundTo(value:Float, precision:Int):Float
	{
		var factor = Math.pow(10, precision);
		return Math.round(value * factor) / factor;
	}

	/**
	 * Linearly interpolates between two values by a given factor.
	 * @param a 
	 * @param b 
	 * @param t 
	 * @return Float
	 */
	public static inline function lerp(a:Float, b:Float, t:Float):Float
	{
		return a + (b - a) * t;
	}

	/**
	 * Calculates the percentage of a value relative to another.
	 * @param a 
	 * @param b 
	 * @return Float
	 */
	public static inline function percent(a:Float, b:Float):Float
	{
		if (b == 0)
			return 0;
		return a / b;
	}

	/**
	 * Formats a time in seconds to a "minutes:seconds" string.
	 * @param seconds 
	 * @return String
	 */
	public static inline function formatTime(seconds:Float):String
	{
		var totalSeconds = Math.floor(seconds);
		var minutes = Math.floor(totalSeconds / 60);
		var secs = totalSeconds % 60;
		return minutes + ":" + StringTools.lpad(Std.string(secs), "0", 2);
	}

	/**
	 * Generates a random float within a specified range.
	 * @param min 
	 * @param max 
	 * @return Float
	 */
	public static inline function randomRange(min:Float, max:Float):Float
	{
		return Math.random() * (max - min) + min;
	}

	/**
	 * Generates a random integer within a specified range (inclusive).
	 * @param min 
	 * @param max 
	 * @return Int
	 */
	public static inline function randomInt(min:Int, max:Int):Int
	{
		return Math.floor(Math.random() * (max - min + 1)) + min;
	}
}
