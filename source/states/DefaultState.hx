package states;

import flixel.FlxG;
import flixel.FlxState;

class DefaultState extends FlxState
{
	override public function create():Void
	{
		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.F5)
		{
			trace("Reloading state...");
			FlxG.resetState();
		}
		if (FlxG.keys.justPressed.F6)
		{
			printDebugInfo();
		}
	}

	/**
	 * Prints debug information to the terminal.
	 * Press F6 to display current state info, memory usage, FPS, etc.
	 */
	private function printDebugInfo():Void
	{
		trace("========================================");
		trace("DEBUG INFO - " + Type.getClassName(Type.getClass(this)));
		trace("========================================");

		// Screen info
		trace("Screen: " + FlxG.width + "x" + FlxG.height);
		trace("Camera: " + FlxG.camera.width + "x" + FlxG.camera.height);
		trace("Scale: " + FlxG.scaleMode);

		// Performance info
		trace("FPS: " + FlxG.drawFramerate + " (target: " + FlxG.updateFramerate + ")");
		trace("Elapsed: " + FlxG.elapsed + "s");

		// Object counts
		trace("Active objects: " + length);
		trace("Visible objects: " + countVisible());
		trace("Alive objects: " + countAlive());

		// Memory info (platform-specific)
		#if sys
		try
		{
			var memUsage = Sys.cpuTime();
			trace("CPU Time: " + memUsage + "s");
		}
		catch (e:Dynamic)
		{
			trace("Memory info not available on this platform");
		}
		#end

		// State-specific info (can be overridden in subclasses)
		printStateSpecificInfo();

		trace("========================================");
	}

	/**
	 * Override this method in subclasses to print state-specific debug info.
	 */
	private function printStateSpecificInfo():Void
	{
		// Override in subclasses for specific info
	}

	/**
	 * Counts visible objects in the state.
	 */
	private function countVisible():Int
	{
		var count = 0;
		forEachExists(function(obj)
		{
			if (obj.visible)
				count++;
		});
		return count;
	}

	/**
	 * Counts alive objects in the state.
	 */
	private function countAlive():Int
	{
		var count = 0;
		forEachAlive(function(obj)
		{
			count++;
		});
		return count;
	}
}
