package states;

import backend.ResponsiveBackground.ScaleMode;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;

/**
 * Example state demonstrating ResponsiveBackground usage.
 * Press numbers to switch between different background types.
 */
class BackgroundExampleState extends ResponsiveState
{
	private var infoText:FlxText;
	private var currentMode:Int = 0;
	
	override public function create():Void
	{
		super.create();
		
		// Create initial background (solid color)
		setBackgroundColor(FlxColor.fromRGB(40, 44, 52));
		
		// Create info text
		infoText = new FlxText(0, 0, FlxG.width - 40);
		infoText.setFormat(null, 20, FlxColor.WHITE, CENTER);
		infoText.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		updateInfo();
		infoText.fieldWidth = FlxG.width - 40;
		infoText.screenCenter();
		add(infoText);
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		// Switch modes with number keys
		if (FlxG.keys.justPressed.ONE)
		{
			currentMode = 0;
			setBackgroundColor(FlxColor.fromRGB(40, 44, 52));
			updateInfo();
		}
		
		if (FlxG.keys.justPressed.TWO)
		{
			currentMode = 1;
			setBackgroundGradient(FlxColor.BLUE, FlxColor.PURPLE);
			updateInfo();
		}
		
		if (FlxG.keys.justPressed.THREE)
		{
			currentMode = 2;
			setBackgroundHorizontalGradient(FlxColor.RED, FlxColor.ORANGE);
			updateInfo();
		}
		
		if (FlxG.keys.justPressed.FOUR)
		{
			currentMode = 3;
			// Clear previous background
			background.clear();
			// Add multiple parallax layers
			addBackgroundLayer("bg_far", 0.2, FILL, 1.0);
			addBackgroundLayer("bg_mid", 0.5, FILL, 0.8);
			addBackgroundLayer("bg_close", 0.8, FILL, 0.6);
			updateInfo();
		}
		
		if (FlxG.keys.justPressed.FIVE)
		{
			currentMode = 4;
			// Create animated gradient effect
			createAnimatedGradient();
			updateInfo();
		}
		
		// ESC to go back
		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.switchState(DebugState.new);
		}
	}
	
	private function updateInfo():Void
	{
		var modeText = switch (currentMode)
		{
			case 0: "Mode 1: Solid Color";
			case 1: "Mode 2: Vertical Gradient";
			case 2: "Mode 3: Horizontal Gradient";
			case 3: "Mode 4: Parallax (multiple layers)";
			case 4: "Mode 5: Animated Gradient";
			default: "Unknown mode";
		}
		
		infoText.text = modeText + "\n\n" +
			"Press 1-5 to switch modes\n" +
			"ESC to go back\n" +
			"F5 to reload state\n\n" +
			"Device: " + getDeviceType() + "\n" +
			"Orientation: " + (isPortrait() ? "Portrait" : "Landscape");
	}
	
	private function createAnimatedGradient():Void
	{
		// Clear previous background first
		background.clear();
		
		var colors = [
			{top: FlxColor.CYAN, bottom: FlxColor.BLUE},
			{top: FlxColor.PURPLE, bottom: FlxColor.PINK},
			{top: FlxColor.ORANGE, bottom: FlxColor.RED}
		];
		
		// Use addVerticalGradientLayer instead of createVerticalGradient
		// to avoid clearing on each iteration (which was causing memory leaks)
		for (i in 0...colors.length)
		{
			var scrollFactor = 0.1 * (i + 1);
			background.addVerticalGradientLayer(colors[i].top, colors[i].bottom, 0.3, scrollFactor, scrollFactor);
		}
	}
	
	override public function onResizeContent():Void
	{
		// Reposition text on resize
		if (infoText != null)
		{
			infoText.fieldWidth = FlxG.width - 40;
			infoText.screenCenter();
			updateInfo();
		}
	}
	override private function printStateSpecificInfo():Void
	{
		trace("=== Background Example State Info ===");
		trace("Current Mode: " + currentMode + " (" + (switch (currentMode)
		{
			case 0: "Solid Color";
			case 1: "Vertical Gradient";
			case 2: "Horizontal Gradient";
			case 3: "Parallax Layers";
			case 4: "Animated Gradient";
			default: "Unknown";
		}) + ")");
		trace("Background Layers: " + background.getLayerCount());
		trace("Auto Resize: enabled");
		trace("---");
		trace("Controls:");
		trace("  1-5: Switch background modes");
		trace("  ESC: Return to Debug State");
		trace("  F5: Reload state");
	}
}
