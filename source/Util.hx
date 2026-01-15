import Math;
import Std;
import StringTools;
import flixel.FlxG;
import flixel.math.FlxMath;

class Util
{
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
