package states;

import flixel.FlxG;
import flixel.FlxSubState;

class DefaultSubState extends FlxSubState
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
			trace("Reloading parent state...");
			close();
			FlxG.resetState();
		}
		if (FlxG.keys.justPressed.F6)
		{
			printDebugInfo();
		}
	}

	/**
	 * Prints debug information to the terminal.
	 * Press F6 to display current substate info.
	 */
	private function printDebugInfo():Void
	{
		trace("========================================");
		trace("DEBUG INFO (SubState) - " + Type.getClassName(Type.getClass(this)));
		trace("========================================");

		// Screen info
		trace("Screen: " + FlxG.width + "x" + FlxG.height);

		// Performance info
		trace("FPS: " + FlxG.drawFramerate);

		// Object counts
		trace("Active objects: " + length);
		trace("Visible objects: " + countVisible());

		// SubState-specific info
		printSubStateSpecificInfo();

		trace("========================================");
	}

	/**
	 * Override this method in subclasses to print substate-specific debug info.
	 */
	private function printSubStateSpecificInfo():Void
	{
		// Override in subclasses for specific info
	}

	/**
	 * Counts visible objects in the substate.
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
}
