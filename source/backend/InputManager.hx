package backend;

import flixel.FlxG;
import flixel.input.FlxInput;
import flixel.input.keyboard.FlxKey;

enum InputDevice
{
	Keyboard;
}

class InputBinding
{
	public var device:InputDevice;
	public var code:Int;

	public function new(device:InputDevice, code:Int)
	{
		this.device = device;
		this.code = code;
	}
}

/**
 * A simple input manager that allows binding keys, mouse buttons, and gamepad buttons to actions.
 */
class InputManager
{
	/**
	 * The singleton instance of the InputManager.
	 */
	public static var instance(default, null):InputManager = new InputManager();

	private var bindings:Map<String, Array<InputBinding>> = new Map<String, Array<InputBinding>>();

	private function new() {}

	/**
	 * Binds a key to an action.
	 * @param action The name of the action.
	 * @param key The key to bind to the action.
	 */
	public function bindKey(action:String, key:FlxKey):Void
	{
		if (!bindings.exists(action))
			bindings.set(action, []);
		bindings.get(action).push(new InputBinding(Keyboard, key));
	}

	/**
	 * Checks if the input for the given action is currently pressed.
	 * @param action The name of the action.
	 * @return True if any of the inputs for the action are pressed, false otherwise.
	 */
	public function pressed(action:String):Bool
	{
		return check(action, FlxInputState.PRESSED);
	}

	/**
	 * Checks if the input for the given action was just pressed.
	 * @param action The name of the action.
	 * @return True if any of the inputs for the action were just pressed, false otherwise.
	 */
	public function justPressed(action:String):Bool
	{
		return check(action, FlxInputState.JUST_PRESSED);
	}

	/**
	 * Checks if the input for the given action was just released.
	 * @param action The name of the action.
	 * @return True if any of the inputs for the action were just released, false otherwise.
	 */
	public function justReleased(action:String):Bool
	{
		return check(action, FlxInputState.JUST_RELEASED);
	}

	private function check(action:String, status:FlxInputState):Bool
	{
		if (bindings.exists(action))
		{
			for (binding in bindings.get(action))
			{
				if (FlxG.keys.checkStatus(binding.code, status))
					return true;
			}
		}
		return false;
	}
}
