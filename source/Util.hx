import Math;
import Std;
import StringTools;
import flixel.FlxG;
import flixel.math.FlxMath;

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
		return str.charAt(0).toUpperCase() + str.substr(1).toLowerCase();
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
		return Std.int(Math.floor(Math.random() * (max - min + 1))) + min;
	}

	/**
	 * Clamps an integer between min and max (inclusive).
	 */
	public static inline function clampInt(value:Int, min:Int, max:Int):Int
	{
		if (value < min)
			return min;
		if (value > max)
			return max;
		return value;
	}

	/**
	 * Maps a value from one range to another. If inMax == inMin, returns outMin.
	 */
	public static inline function mapRange(value:Float, inMin:Float, inMax:Float, outMin:Float, outMax:Float):Float
	{
		if (inMax == inMin)
			return outMin;
		var t = (value - inMin) / (inMax - inMin);
		return outMin + t * (outMax - outMin);
	}

	/**
	 * Degrees <-> Radians helpers
	 */
	public static inline function degToRad(deg:Float):Float
	{
		return deg * Math.PI / 180;
	}

	public static inline function radToDeg(rad:Float):Float
	{
		return rad * 180 / Math.PI;
	}

	/**
	 * Positive modulo for floats (always returns value in [0, m)).
	 */
	public static inline function positiveMod(x:Float, m:Float):Float
	{
		var r = x % m;
		if (r < 0)
			r += m;
		return r;
	}

	/**
	 * Approximate equality for floats with epsilon.
	 */
	public static inline function approxEqual(a:Float, b:Float, eps:Float = 0.0001):Bool
	{
		return Math.abs(a - b) <= eps;
	}

	/**
	 * Return a random element from an array. Returns null if array empty.
	 */
	public static inline function pickRandom<T>(arr:Array<T>):T
	{
		if (arr == null || arr.length == 0)
			return null;
		return arr[randomInt(0, arr.length - 1)];
	}

	/**
	 * In-place Fisher-Yates shuffle. Returns the same array reference.
	 */
	public static inline function shuffle<T>(arr:Array<T>):Array<T>
	{
		if (arr == null)
			return arr;
		var i = arr.length;
		while (i > 1)
		{
			i -= 1;
			var j = randomInt(0, i);
			var tmp = arr[i];
			arr[i] = arr[j];
			arr[j] = tmp;
		}
		return arr;
	}

	/**
	 * Sign of a number: -1, 0 or 1.
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
	 * Lerp with t clamped to [0,1].
	 */
	public static inline function lerpClamp(a:Float, b:Float, t:Float):Float
	{
		return lerp(a, b, clamp(t, 0, 1));
	}

	/**
	 * Converts a relative file path into a platform-specific writable path.
	 * @param relativePath The relative path of the file.
	 * @return The full, writable path.
	 */
	public static function getWritablePath(relativePath:String):String
	{
		#if (android || ios)
		return lime.system.System.applicationStorageDirectory + '/' + relativePath;
		#else
		return relativePath;
		#end
	}
}
