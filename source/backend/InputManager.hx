package backend;

import core.utils.MathUtil;
import core.utils.StringUtil;
import flixel.FlxG;
import flixel.input.FlxInput.FlxInputState;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;
import flixel.input.mouse.FlxMouseButton.FlxMouseButtonID;

enum InputDevice
{
	Keyboard;
	Mouse;
	GamepadButton;
	GamepadAxis;
}

enum GamepadAxisKind
{
	Axis;
	XAxis;
	YAxis;
}

class InputBinding
{
	public var device:InputDevice;
	public var code:Int;
	public var gamepadId:Int;
	public var axisKind:GamepadAxisKind;
	public var axisSign:Int;
	public var axisThreshold:Float;

	public function new(device:InputDevice, code:Int, ?gamepadId:Int = -1, ?axisKind:GamepadAxisKind = Axis, ?axisSign:Int = 1, ?axisThreshold:Float = 0.5)
	{
		this.device = device;
		this.code = code;
		this.gamepadId = gamepadId;
		this.axisKind = axisKind;
		this.axisSign = axisSign >= 0 ? 1 : -1; // Clamp threshold to valid range [0, 1]
		this.axisThreshold = MathUtil.clamp(axisThreshold, 0, 1);
	}

	/**
	 * Checks if this binding is equal to another binding.
	 * Used to prevent duplicate bindings.
	 */
	public function equals(other:InputBinding):Bool
	{
		if (other == null)
			return false;

		return device == other.device && code == other.code && gamepadId == other.gamepadId && axisKind == other.axisKind && axisSign == other.axisSign;
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
	private var lastActivation:Map<String, Int> = new Map<String, Int>();
	private var axisPrevPressed:Map<String, Bool> = new Map<String, Bool>();
	private var activationCounter:Int = 0;

	private function new() {}
	/**
	 * Validates that an action name is not empty.
	 * @param action The action name to validate
	 * @return true if valid
	 */
	private inline function isValidAction(action:String):Bool
	{
		return !StringUtil.isEmpty(action);
	}

	/**
	 * Checks if a binding already exists in the list.
	 * @param bindingList List of bindings to check
	 * @param binding Binding to look for
	 * @return true if binding exists
	 */
	private function hasDuplicateBinding(bindingList:Array<InputBinding>, binding:InputBinding):Bool
	{
		for (b in bindingList)
		{
			if (b.equals(binding))
				return true;
		}
		return false;
	}

	/**
	 * Binds a key to an action.
	 * @param action The name of the action.
	 * @param key The key to bind to the action.
	 * @return true if binding was added, false if action is invalid or duplicate
	 */
	public function bindKey(action:String, key:FlxKey):Bool
	{
		return addBinding(action, new InputBinding(Keyboard, key));
	}

	/**
	 * Bind a mouse button to an action.
	 * @param action The name of the action.
	 * @param button The mouse button to bind.
	 * @return true if binding was added, false if action is invalid or duplicate
	 */
	public function bindMouseButton(action:String, button:FlxMouseButtonID):Bool
	{
		return addBinding(action, new InputBinding(Mouse, button));
	}

	/**
	 * Bind a gamepad button to an action.
	 * @param action The name of the action.
	 * @param button The gamepad button to bind.
	 * @param gamepadId The gamepad ID (-1 for any gamepad).
	 * @return true if binding was added, false if action is invalid or duplicate
	 */
	public function bindGamepadButton(action:String, button:FlxGamepadInputID, ?gamepadId:Int = -1):Bool
	{
		return addBinding(action, new InputBinding(GamepadButton, button, gamepadId));
	}

	/**
	 * Bind a gamepad axis (trigger or analog stick) to an action.
	 * @param action The name of the action.
	 * @param axis The gamepad axis to bind.
	 * @param axisKind Whether to read simple axis (Axis) or X/Y component of a stick.
	 * @param sign 1 for positive values, -1 for negative values.
	 * @param threshold Activation threshold (0-1, automatically clamped).
	 * @param gamepadId The gamepad ID (-1 for any gamepad).
	 * @return true if binding was added, false if action is invalid or duplicate
	 */
	public function bindGamepadAxis(action:String, axis:FlxGamepadInputID, ?axisKind:GamepadAxisKind = Axis, ?sign:Int = 1, ?threshold:Float = 0.5,
			?gamepadId:Int = -1):Bool
	{
		return addBinding(action, new InputBinding(GamepadAxis, axis, gamepadId, axisKind, sign, threshold));
	}

	/**
	 * Removes a specific binding from an action.
	 * @param action The name of the action.
	 * @param binding The binding to remove.
	 * @return true if binding was removed, false if not found
	 */
	public function unbind(action:String, binding:InputBinding):Bool
	{
		if (!isValidAction(action) || !bindings.exists(action))
			return false;

		var bindingList = bindings.get(action);
		for (i in 0...bindingList.length)
		{
			if (bindingList[i].equals(binding))
			{
				bindingList.splice(i, 1);
				// Clean up empty action
				if (bindingList.length == 0)
					bindings.remove(action);
				return true;
			}
		}
		return false;
	}

	/**
	 * Removes all bindings for an action.
	 * @param action The name of the action.
	 * @return true if action existed and was removed
	 */
	public function unbindAction(action:String):Bool
	{
		if (!isValidAction(action) || !bindings.exists(action))
			return false;

		bindings.remove(action);
		return true;
	}

	/**
	 * Clears all bindings and resets internal state.
	 * Useful when changing control schemes or resetting input configuration.
	 */
	public function clear():Void
	{
		bindings.clear();
		lastActivation.clear();
		axisPrevPressed.clear();
		activationCounter = 0;
	}

	/**
	 * Gets all actions that have bindings.
	 * @return Array of action names
	 */
	public function getActions():Array<String>
	{
		var actions = new Array<String>();
		for (action in bindings.keys())
		{
			actions.push(action);
		}
		return actions;
	}

	/**
	 * Gets all bindings for a specific action.
	 * @param action The action name
	 * @return Array of bindings (empty if action doesn't exist)
	 */
	public function getBindings(action:String):Array<InputBinding>
	{
		if (!isValidAction(action) || !bindings.exists(action))
			return [];

		return bindings.get(action).copy();
	}

	/**
	 * Checks if an action has any bindings.
	 * @param action The action name
	 * @return true if action has bindings
	 */
	public function hasAction(action:String):Bool
	{
		return isValidAction(action) && bindings.exists(action);
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

	/**
	 * Internal method to check input state for an action.
	 * @param action The action name
	 * @param status The input state to check
	 * @return true if action is active in the given state
	 */
	private function check(action:String, status:FlxInputState):Bool
	{
		if (!isValidAction(action) || !bindings.exists(action))
			return false;

		var bindingList = bindings.get(action);
		var preferred = getPreferredBinding(bindingList);
		if (preferred != null && isBindingActive(preferred, status))
		{
			if (status == FlxInputState.JUST_PRESSED)
				markActivation(preferred);
			return true;
		}

		for (binding in bindingList)
		{
			if (preferred != null && binding == preferred)
				continue;
			if (isBindingActive(binding, status))
			{
				if (status == FlxInputState.JUST_PRESSED)
					markActivation(binding);
				return true;
			}
		}

		return false;
	}

	/**
	 * Adds a binding to an action, preventing duplicates.
	 * @param action The action name
	 * @param binding The binding to add
	 * @return true if added, false if invalid or duplicate
	 */
	private function addBinding(action:String, binding:InputBinding):Bool
	{
		if (!isValidAction(action))
			return false;

		if (!bindings.exists(action))
			bindings.set(action, []);

		var bindingList = bindings.get(action);

		// Prevent duplicate bindings
		if (hasDuplicateBinding(bindingList, binding))
			return false;

		bindingList.push(binding);
		return true;
	}

	/**
	 * Checks if a binding is currently active in the given state.
	 * @param binding The binding to check
	 * @param status The input state to check
	 * @return true if active
	 */
	private function isBindingActive(binding:InputBinding, status:FlxInputState):Bool
	{
		switch (binding.device)
		{
			case Keyboard:
				return FlxG.keys.checkStatus(binding.code, status);
			case Mouse:
				return checkMouse(binding.code, status);
			case GamepadButton:
				return checkGamepadButton(binding, status);
			case GamepadAxis:
				return checkGamepadAxis(binding, status);
		}
		return false;
	}

	/**
	 * Checks mouse button state.
	 * @param button The mouse button ID
	 * @param status The input state to check
	 * @return true if mouse button matches state
	 */
	private function checkMouse(button:Int, status:FlxInputState):Bool
	{
		switch (status)
		{
			case FlxInputState.JUST_PRESSED:
				return (button == FlxMouseButtonID.LEFT && FlxG.mouse.justPressed)
					|| (button == FlxMouseButtonID.MIDDLE && FlxG.mouse.justPressedMiddle)
					|| (button == FlxMouseButtonID.RIGHT && FlxG.mouse.justPressedRight);
			case FlxInputState.PRESSED:
				return (button == FlxMouseButtonID.LEFT && FlxG.mouse.pressed)
					|| (button == FlxMouseButtonID.MIDDLE && FlxG.mouse.pressedMiddle)
					|| (button == FlxMouseButtonID.RIGHT && FlxG.mouse.pressedRight);
			case FlxInputState.JUST_RELEASED:
				return (button == FlxMouseButtonID.LEFT && FlxG.mouse.justReleased)
					|| (button == FlxMouseButtonID.MIDDLE && FlxG.mouse.justReleasedMiddle)
					|| (button == FlxMouseButtonID.RIGHT && FlxG.mouse.justReleasedRight);
			default:
				return false;
		}
	}

	/**
	 * Checks gamepad button state.
	 * @param binding The binding to check
	 * @param status The input state to check
	 * @return true if gamepad button matches state
	 */
	private function checkGamepadButton(binding:InputBinding, status:FlxInputState):Bool
	{
		if (binding.gamepadId == -1)
		{
			switch (status)
			{
				case FlxInputState.JUST_PRESSED:
					return FlxG.gamepads.anyJustPressed(cast binding.code);
				case FlxInputState.PRESSED:
					return FlxG.gamepads.anyPressed(cast binding.code);
				case FlxInputState.JUST_RELEASED:
					return FlxG.gamepads.anyJustReleased(cast binding.code);
				default:
					return false;
			}
		}

		var gamepad = FlxG.gamepads.getByID(binding.gamepadId);
		if (gamepad == null)
			return false;
		return gamepad.checkStatus(cast binding.code, status);
	}

	/**
	 * Checks gamepad axis state with threshold detection.
	 * Tracks previous state to properly detect JUST_PRESSED and JUST_RELEASED.
	 * @param binding The binding to check
	 * @param status The input state to check
	 * @return true if gamepad axis matches state
	 */
	private function checkGamepadAxis(binding:InputBinding, status:FlxInputState):Bool
	{
		var gamepads = new Array<FlxGamepad>();
		if (binding.gamepadId == -1)
			FlxG.gamepads.getActiveGamepads(gamepads);
		else
		{
			var gp = FlxG.gamepads.getByID(binding.gamepadId);
			if (gp != null)
				gamepads.push(gp);
		}

		for (gp in gamepads)
		{
			var value = getAxisValue(gp, binding);
			var pressedNow = binding.axisSign > 0 ? value >= binding.axisThreshold : value <= -binding.axisThreshold;
			var axisKey = bindingKey(binding) + ":" + gp.id;
			var wasPressed = axisPrevPressed.exists(axisKey) ? axisPrevPressed.get(axisKey) : false;
			axisPrevPressed.set(axisKey, pressedNow);

			switch (status)
			{
				case FlxInputState.PRESSED:
					if (pressedNow)
						return true;
				case FlxInputState.JUST_PRESSED:
					if (pressedNow && !wasPressed)
						return true;
				case FlxInputState.JUST_RELEASED:
					if (!pressedNow && wasPressed)
						return true;
				default:
			}
		}
		return false;
	}
	/**
	 * Gets the current value of a gamepad axis.
	 * @param gamepad The gamepad to read from
	 * @param binding The binding containing axis information
	 * @return The axis value
	 */
	private function getAxisValue(gamepad:FlxGamepad, binding:InputBinding):Float
	{
		switch (binding.axisKind)
		{
			case Axis:
				return gamepad.getAxis(cast binding.code);
			case XAxis:
				return gamepad.getXAxis(cast binding.code);
			case YAxis:
				return gamepad.getYAxis(cast binding.code);
		}
		return 0;
	}

	/**
	 * Gets the most recently used binding from a list.
	 * Used to prioritize the last input method used.
	 * @param bindingList List of bindings
	 * @return The preferred binding, or null if none
	 */
	private function getPreferredBinding(bindingList:Array<InputBinding>):InputBinding
	{
		var best:InputBinding = null;
		var bestScore = -1;
		for (b in bindingList)
		{
			var id = bindingKey(b);
			var score = lastActivation.exists(id) ? lastActivation.get(id) : -1;
			if (score > bestScore)
			{
				bestScore = score;
				best = b;
			}
		}
		return best;
	}

	/**
	 * Marks a binding as activated, updating its priority.
	 * @param binding The binding that was activated
	 */
	private function markActivation(binding:InputBinding):Void
	{
		activationCounter++;
		lastActivation.set(bindingKey(binding), activationCounter);
	}

	/**
	 * Generates a unique key for a binding.
	 * Used for tracking activation history and axis state.
	 * @param binding The binding to generate a key for
	 * @return Unique string key
	 */
	private function bindingKey(binding:InputBinding):String
	{
		return Std.string(binding.device)
			+ ":"
			+ binding.code
			+ ":"
			+ binding.gamepadId
			+ ":"
			+ Std.string(binding.axisKind)
			+ ":"
			+ binding.axisSign;
	}
}
