package core.utils;

import flixel.util.FlxStringUtil;

/**
 * String utilities using native Haxe and HaxeFlixel functions where possible.
 * Following Single Responsibility Principle.
 * 
 * NOTE: Most functions delegate to native implementations (FlxStringUtil, StringTools).
 * Only custom utilities not provided by the framework are implemented here.
 */
class StringUtil
{
	/**
	 * Capitalizes the first letter of a string.
	 * 
	 * @param str String to capitalize
	 * @return String with first letter uppercase
	 */
	public static inline function capitalization(str:String):String
	{
		if (str.length == 0) return str;
		return str.charAt(0).toUpperCase() + str.substr(1).toLowerCase();
	}
	
	/**
	 * Formats a time in seconds to "minutes:seconds".
	 * Uses FlxStringUtil for consistent formatting.
	 * 
	 * @param seconds Time in seconds
	 * @return Formatted string (ex: "3:45")
	 */
	public static inline function formatTime(seconds:Float):String
	{
		return FlxStringUtil.formatTime(seconds, false);
	}
	
	/**
	 * Formats milliseconds to "minutes:seconds".
	 * 
	 * @param milliseconds Time in milliseconds
	 * @return Formatted string
	 */
	public static inline function formatTimeMs(milliseconds:Float):String
	{
		return FlxStringUtil.formatTime(milliseconds / 1000, false);
	}
	
	/**
	 * Checks if a string is empty or null.
	 * Convenience wrapper for null-safe checking.
	 */
	public static inline function isEmpty(str:String):Bool
	{
		return str == null || str.length == 0;
	}
	
	/**
	 * Removes whitespace from the beginning and end.
	 * Direct delegation to StringTools.
	 */
	public static inline function trim(str:String):String
	{
		return StringTools.trim(str);
	}
	
	/**
	 * Pads a string on the left with a character until it reaches the desired length.
	 * 
	 * @param str Original string
	 * @param length Desired length
	 * @param char Padding character
	 * @return Padded string
	 */
	public static inline function padLeft(str:String, length:Int, char:String = " "):String
	{
		return StringTools.lpad(str, char, length);
	}
	
	/**
	 * Pads a string on the right with a character until it reaches the desired length.
	 */
	public static inline function padRight(str:String, length:Int, char:String = " "):String
	{
		return StringTools.rpad(str, char, length);
	}
}
