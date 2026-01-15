package core.utils;

import flixel.FlxG;

/**
 * Array utilities using native Haxe and HaxeFlixel functions where possible.
 * Following Single Responsibility Principle.
 * 
 * NOTE: Most functions delegate to native implementations (FlxG.random, Array methods).
 * Only custom null-safe wrappers are implemented here.
 */
class ArrayUtil
{
	/**
	 * Selects a random element from an array.
	 * Uses FlxG.random for consistent randomization.
	 * 
	 * @param arr Source array
	 * @return Random element or null if array empty
	 */
	public static inline function pickRandom<T>(arr:Array<T>):Null<T>
	{
		if (arr == null || arr.length == 0) return null;
		return FlxG.random.getObject(arr);
	}
	
	/**
	 * Shuffles an array.
	 * Uses FlxG.random for consistent randomization.
	 * 
	 * @param arr Array to shuffle
	 * @param howManyTimes Number of shuffle iterations (default 1)
	 * @return New shuffled array (does not modify original)
	 */
	public static function shuffle<T>(arr:Array<T>, howManyTimes:Int = 1):Array<T>
	{
		if (arr == null) return null;
		var copy = arr.copy();
		for (i in 0...howManyTimes)
			FlxG.random.shuffle(copy);
		return copy;
	}
	
	/**
	 * Removes an element from the array.
	 * Direct wrapper of native Array.remove for consistency.
	 * 
	 * @param arr Source array
	 * @param element Element to remove
	 * @return true if removed, false if not found
	 * @deprecated Use arr.remove(element) directly
	 */
	public static inline function remove<T>(arr:Array<T>, element:T):Bool
	{
		return arr.remove(element);
	}
	
	/**
	 * Checks if an array contains an element.
	 * 
	 * @deprecated Use arr.contains(element) directly (Haxe 4+)
	 */
	public static inline function contains<T>(arr:Array<T>, element:T):Bool
	{
		return arr.contains(element);
	}
	
	/**
	 * Returns the last element of an array.
	 * Null-safe convenience wrapper.
	 */
	public static function last<T>(arr:Array<T>):Null<T>
	{
		if (arr == null || arr.length == 0) return null;
		return arr[arr.length - 1];
	}
	
	/**
	 * Returns the first element of an array.
	 * Null-safe convenience wrapper.
	 */
	public static function first<T>(arr:Array<T>):Null<T>
	{
		if (arr == null || arr.length == 0) return null;
		return arr[0];
	}
}
