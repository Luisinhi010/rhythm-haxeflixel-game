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
	/**
	 * Repeats a string n times.
	 * @param str String to repeat
	 * @param times Number of repetitions
	 * @return Repeated string
	 */
	public static function repeat(str:String, times:Int):String
	{
		if (isEmpty(str) || times <= 0)
			return "";
		if (times == 1)
			return str;

		var result = new StringBuf();
		for (i in 0...times)
			result.add(str);
		return result.toString();
	}

	/**
	 * Truncates a string to specified length, adding ellipsis if needed.
	 * @param str String to truncate
	 * @param maxLength Maximum length (including ellipsis)
	 * @param ellipsis Ellipsis string (default "...")
	 * @return Truncated string
	 */
	public static function truncate(str:String, maxLength:Int, ellipsis:String = "..."):String
	{
		if (isEmpty(str) || str.length <= maxLength)
			return str;

		var cutLength = maxLength - ellipsis.length;
		if (cutLength <= 0)
			return ellipsis.substr(0, maxLength);

		return str.substr(0, cutLength) + ellipsis;
	}

	/**
	 * Removes all whitespace from a string.
	 * @param str String to process
	 * @return String without whitespace
	 */
	public static function removeWhitespace(str:String):String
	{
		if (isEmpty(str))
			return "";
		return StringTools.replace(StringTools.replace(str, " ", ""), "\t", "");
	}

	/**
	 * Checks if string contains substring (case insensitive).
	 * @param str String to search in
	 * @param substr Substring to find
	 * @return true if contains
	 */
	public static inline function containsIgnoreCase(str:String, substr:String):Bool
	{
		if (isEmpty(str) || isEmpty(substr))
			return false;
		return str.toLowerCase().indexOf(substr.toLowerCase()) >= 0;
	}

	/**
	 * Checks if string starts with prefix (case sensitive).
	 * Direct delegation to StringTools.
	 */
	public static inline function startsWith(str:String, prefix:String):Bool
	{
		if (isEmpty(str))
			return isEmpty(prefix);
		return StringTools.startsWith(str, prefix);
	}

	/**
	 * Checks if string ends with suffix (case sensitive).
	 * Direct delegation to StringTools.
	 */
	public static inline function endsWith(str:String, suffix:String):Bool
	{
		if (isEmpty(str))
			return isEmpty(suffix);
		return StringTools.endsWith(str, suffix);
	}

	/**
	 * Reverses a string.
	 * @param str String to reverse
	 * @return Reversed string
	 */
	public static function reverse(str:String):String
	{
		if (isEmpty(str))
			return "";
		var chars = str.split("");
		chars.reverse();
		return chars.join("");
	}

	/**
	 * Counts occurrences of a substring.
	 * @param str String to search in
	 * @param substr Substring to count
	 * @return Number of occurrences
	 */
	public static function countOccurrences(str:String, substr:String):Int
	{
		if (isEmpty(str) || isEmpty(substr))
			return 0;

		var count = 0;
		var pos = 0;

		while ((pos = str.indexOf(substr, pos)) >= 0)
		{
			count++;
			pos += substr.length;
		}

		return count;
	}

	/**
	 * Wraps text to specified line width.
	 * @param str Text to wrap
	 * @param width Maximum line width
	 * @return Wrapped text with newlines
	 */
	public static function wordWrap(str:String, width:Int):String
	{
		if (isEmpty(str) || width <= 0)
			return str;

		var words = str.split(" ");
		var lines:Array<String> = [];
		var currentLine = "";

		for (word in words)
		{
			if (currentLine.length + word.length + 1 > width)
			{
				if (currentLine.length > 0)
				{
					lines.push(currentLine);
					currentLine = word;
				}
				else
				{
					lines.push(word);
				}
			}
			else
			{
				if (currentLine.length > 0)
					currentLine += " ";
				currentLine += word;
			}
		}

		if (currentLine.length > 0)
			lines.push(currentLine);

		return lines.join("\n");
	}
}
