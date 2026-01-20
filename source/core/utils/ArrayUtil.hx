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
	/**
	 * Checks if array is null or empty.
	 * Convenience method for quick validation.
	 */
	public static inline function isEmpty<T>(arr:Array<T>):Bool
	{
		return arr == null || arr.length == 0;
	}

	/**
	 * Returns a random subset of elements from an array.
	 * @param arr Source array
	 * @param count Number of elements to return
	 * @return New array with random elements (no duplicates)
	 */
	public static function randomSubset<T>(arr:Array<T>, count:Int):Array<T>
	{
		if (isEmpty(arr) || count <= 0)
			return [];
		if (count >= arr.length)
			return arr.copy();

		var shuffled = shuffle(arr);
		return shuffled.slice(0, count);
	}

	/**
	 * Creates an array with unique elements (removes duplicates).
	 * Uses native array operations for best performance.
	 * @param arr Source array
	 * @return New array without duplicates
	 */
	public static function unique<T>(arr:Array<T>):Array<T>
	{
		if (isEmpty(arr))
			return [];

		var result:Array<T> = [];
		for (item in arr)
		{
			if (!result.contains(item))
				result.push(item);
		}
		return result;
	}

	/**
	 * Splits array into chunks of specified size.
	 * @param arr Source array
	 * @param size Chunk size
	 * @return Array of arrays (chunks)
	 */
	public static function chunk<T>(arr:Array<T>, size:Int):Array<Array<T>>
	{
		if (isEmpty(arr) || size <= 0)
			return [];

		var result:Array<Array<T>> = [];
		var i = 0;

		while (i < arr.length)
		{
			result.push(arr.slice(i, i + size));
			i += size;
		}

		return result;
	}

	/**
	 * Finds the index of the minimum value in a numeric array.
	 * @param arr Source array of numbers
	 * @return Index of minimum value, or -1 if array empty
	 */
	public static function indexOfMin(arr:Array<Float>):Int
	{
		if (isEmpty(arr))
			return -1;

		var minIndex = 0;
		var minValue = arr[0];

		for (i in 1...arr.length)
		{
			if (arr[i] < minValue)
			{
				minValue = arr[i];
				minIndex = i;
			}
		}

		return minIndex;
	}

	/**
	 * Finds the index of the maximum value in a numeric array.
	 * @param arr Source array of numbers
	 * @return Index of maximum value, or -1 if array empty
	 */
	public static function indexOfMax(arr:Array<Float>):Int
	{
		if (isEmpty(arr))
			return -1;

		var maxIndex = 0;
		var maxValue = arr[0];

		for (i in 1...arr.length)
		{
			if (arr[i] > maxValue)
			{
				maxValue = arr[i];
				maxIndex = i;
			}
		}

		return maxIndex;
	}
}
