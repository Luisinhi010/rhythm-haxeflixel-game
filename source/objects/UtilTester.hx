package objects;

import backend.FilePath.FilePathExtension;
import backend.FilePath.FilePathType;
import backend.FilePath;
import backend.FlxGroupContainer;
import backend.InputManager;
import backend.Paths;
import core.utils.ArrayUtil;
import core.utils.MathUtil;
import core.utils.StringUtil;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;

using StringTools;

/**
 * Visual tester for utility functions (MathUtil, StringUtil, ArrayUtil).
 * Shows animated demonstrations of each function.
 */
class UtilTester extends FlxGroupContainer
{
	// Section management
	private var currentSection:Int = 0; // 0=Math, 1=String, 2=Array, 3=FileSystem, 4=Input
	private var sectionNames:Array<String> = ["MathUtil", "StringUtil", "ArrayUtil", "FileSystem", "Input"];
	
	// Visual components
	private var background:FlxSprite;
	private var titleText:FlxText;
	private var instructionText:FlxText;
	
	// Section groups (only active section updates)
	private var mathSection:FlxTypedGroup<FlxSprite>;
	private var stringSection:FlxTypedGroup<FlxSprite>;
	private var arraySection:FlxTypedGroup<FlxSprite>;
	private var fileSystemSection:FlxTypedGroup<FlxSprite>;
	private var inputSection:FlxTypedGroup<FlxSprite>;
	
	// MathUtil test objects
	private var lerpSprite:FlxSprite;
	private var lerpProgress:Float = 0;
	private var lerpDirection:Int = 1;
	private var lerpStartX:Float = 100;
	private var lerpEndX:Float = 500;
	
	private var clampSprite:FlxSprite;
	private var clampArea:FlxSprite;
	
	private var mapRangeBar:FlxSprite;
	private var mapRangeValue:Float = 0;
	
	private var rotationSprite:FlxSprite;
	private var rotationDegrees:Float = 0;
	
	private var randomParticles:Array<FlxSprite> = [];
	
	// StringUtil test objects
	private var timeCounter:Float = 0;
	private var timeText:FlxText;
	
	private var capitalText:FlxText;
	private var paddingText:FlxText;
	
	// ArrayUtil test objects
	private var arrayElements:Array<FlxSprite> = [];
	private var arrayNumberTexts:Array<FlxText> = [];
	private var arrayNumbers:Array<Int> = [1, 2, 3, 4, 5, 6];
	private var selectedIndex:Int = -1;
	private var arrayColX:Float;
	private var arrayElementSpacing:Float;

	// MathUtil rotation text reference
	private var rotationText:FlxText;
	
	// FileSystem test objects
	private var fileStatusText:FlxText;
	private var pathInfoText:FlxText;

	// Input test objects
	private var inputStatusText:FlxText;
	private var keyPressVisuals:Map<String, FlxSprite> = new Map();
	private var lastKeyPressed:String = "None";
	
	// Layout system
	private var contentHeight:Float = 0; // Available height for content
	private var contentY:Float = 70; // Starting Y position after header
	private var padding:Float = 10; // Spacing between elements
	private var sectionPadding:Float = 20; // Spacing between major sections
	
	/**
	 * Helper to create a section label with consistent formatting.
	 * @param x X position
	 * @param y Y position
	 * @param width Label width
	 * @param text Label text
	 * @param section Which section to add to
	 * @return The created FlxText
	 */
	private function createSectionLabel(x:Float, y:Float, width:Float, text:String, section:FlxTypedGroup<FlxSprite>):FlxText
	{
		var label = new FlxText(x, y, width, text);
		label.setFormat(null, 14, FlxColor.CYAN, LEFT);
		section.add(label);
		return label;
	}

	/**
	 * Helper to set visibility and active state of a section.
	 * @param section The section group
	 * @param state Whether to show/activate or hide/deactivate
	 */
	private function setSectionVisibility(section:FlxTypedGroup<FlxSprite>, state:Bool):Void
	{
		section.visible = state;
		section.active = state;
	}

	/**
	 * Check if any section is currently active.
	 * @return True if at least one section is active
	 */
	private function isAnySectionActive():Bool
	{
		return mathSection.active || stringSection.active || arraySection.active || fileSystemSection.active || inputSection.active;
	}

	/**
	 * Helper to list files in a directory with a specific extension.
	 * @param dirPath The directory path
	 * @param extension The file extension to filter (e.g., ".ogg")
	 * @param status Array to append status messages to
	 */
	private function listDirectoryFiles(dirPath:String, extension:String, status:Array<String>):Void
	{
		#if (sys && !android && !ios)
		if (sys.FileSystem.exists(dirPath) && sys.FileSystem.isDirectory(dirPath))
		{
			var files = sys.FileSystem.readDirectory(dirPath);
			var filteredFiles = files.filter(f -> f.toLowerCase().endsWith(extension));
			if (!ArrayUtil.isEmpty(filteredFiles))
			{
				for (file in filteredFiles)
					status.push('  ✓ ${file}');
			}
			else
			{
				status.push('  (No ${extension} files found)');
			}
		}
		else
		{
			status.push('  ✗ Directory not found: ${dirPath}');
		}
		#else
		status.push('  (File listing not available on this platform)');
		#end
	}

	public function new()
	{
		super();
		
		// Calculate available content height (screen height - header - some bottom padding)
		contentHeight = FlxG.height - contentY - 20;
		
		// Create background (dynamic height)
		background = new FlxSprite();
		background.makeGraphic(FlxG.width, Std.int(contentY + contentHeight + 20), FlxColor.fromRGB(30, 30, 30));
		add(background);
		
		// Create title
		titleText = new FlxText(10, 10, FlxG.width - 20, "");
		titleText.setFormat(null, 24, FlxColor.WHITE, LEFT);
		add(titleText);
		
		// Create instructions
		instructionText = new FlxText(10, 40, FlxG.width - 20, 
		"[1][2][3][4][5] Switch Section | [SPACE] Execute | [T] Toggle Tester");
		instructionText.setFormat(null, 12, FlxColor.GRAY, LEFT);
		add(instructionText);
		
		// Initialize sections
		mathSection = new FlxTypedGroup<FlxSprite>();
		stringSection = new FlxTypedGroup<FlxSprite>();
		arraySection = new FlxTypedGroup<FlxSprite>();
		fileSystemSection = new FlxTypedGroup<FlxSprite>();
		inputSection = new FlxTypedGroup<FlxSprite>();
		
		add(mathSection);
		add(stringSection);
		add(arraySection);
		add(fileSystemSection);
		add(inputSection);
		
		// Setup each section
		setupMathSection();
		setupStringSection();
		setupArraySection();
		setupFileSystemSection();
		setupInputSection();
		
		// Show initial section
		switchSection(0);
	}
	
	private function setupMathSection():Void
	{
		var yOffset:Float = contentY;
		var col1X:Float = 20; // Left column
		var col2X:Float = FlxG.width / 2 + 10; // Right column
		var colWidth:Float = FlxG.width / 2 - 30;
		
		// LEFT COLUMN
		// Lerp demonstration
		createSectionLabel(col1X, yOffset, colWidth, "lerp(a, b, t):", mathSection);
		
		lerpStartX = col1X + 50;
		lerpEndX = col1X + colWidth - 70;
		
		lerpSprite = new FlxSprite(lerpStartX, yOffset + 25);
		lerpSprite.makeGraphic(20, 20, FlxColor.GREEN);
		mathSection.add(lerpSprite);
		
		// Start and end markers
		var startMarker = new FlxSprite(lerpStartX, yOffset + 25);
		startMarker.makeGraphic(4, 20, FlxColor.GRAY);
		mathSection.add(startMarker);
		
		var endMarker = new FlxSprite(lerpEndX, yOffset + 25);
		endMarker.makeGraphic(4, 20, FlxColor.GRAY);
		mathSection.add(endMarker);
		
		yOffset += 60;
		
		// Clamp demonstration
		createSectionLabel(col1X, yOffset, colWidth, "clamp(value, min, max):", mathSection);
		
		var clampWidth = Std.int(colWidth - 50);
		clampArea = new FlxSprite(col1X, yOffset + 25);
		clampArea.makeGraphic(clampWidth, 30, FlxColor.fromRGB(50, 50, 80));
		mathSection.add(clampArea);
		
		clampSprite = new FlxSprite(col1X + clampWidth/2, yOffset + 30);
		clampSprite.makeGraphic(20, 20, FlxColor.YELLOW);
		mathSection.add(clampSprite);
		
		yOffset += 70;
		
		// MapRange demonstration
		createSectionLabel(col1X, yOffset, colWidth, "mapRange(0-100 → RGB):", mathSection);
		
		mapRangeBar = new FlxSprite(col1X, yOffset + 25);
		mapRangeBar.makeGraphic(Std.int(colWidth - 10), 30, FlxColor.RED);
		mathSection.add(mapRangeBar);
		
		// RIGHT COLUMN
		yOffset = contentY;
		
		// Rotation demonstration
		createSectionLabel(col2X, yOffset, colWidth, "degToRad/radToDeg:", mathSection);
		
		rotationSprite = new FlxSprite(col2X + 100, yOffset + 40);
		rotationSprite.makeGraphic(40, 4, FlxColor.MAGENTA);
		rotationSprite.offset.set(0, 2);
		mathSection.add(rotationSprite);
		
		rotationText = new FlxText(col2X + 150, yOffset + 35, colWidth - 150, "");
		rotationText.setFormat(null, 12, FlxColor.WHITE, LEFT);
		mathSection.add(rotationText);
		
		yOffset += 90;
		
		// Random particles demonstration
		createSectionLabel(col2X, yOffset, colWidth, "randomRange/randomInt:\n[SPACE] Spawn particles", mathSection);
		
		for (i in 0...10)
		{
			var particle = new FlxSprite(0, 0);
			particle.makeGraphic(6, 6, FlxColor.WHITE);
			particle.visible = false;
			mathSection.add(particle);
			randomParticles.push(particle);
		}
	}
	
	private function setupStringSection():Void
	{
		var yOffset:Float = contentY;
		var col1X:Float = 20;
		var col2X:Float = FlxG.width / 2 + 10;
		var colWidth:Float = FlxG.width / 2 - 30;
		
		// LEFT COLUMN
		// FormatTime demonstration
		createSectionLabel(col1X, yOffset, colWidth, "formatTime(seconds):", stringSection);
		
		timeText = new FlxText(col1X, yOffset + 25, colWidth, "00:00");
		timeText.setFormat(null, 32, FlxColor.GREEN, LEFT);
		stringSection.add(timeText);
		
		yOffset += 80;
		
		// Capitalization demonstration
		createSectionLabel(col1X, yOffset, colWidth, "capitalization(str):", stringSection);
		
		capitalText = new FlxText(col1X, yOffset + 25, colWidth, "");
		capitalText.setFormat(null, 16, FlxColor.WHITE, LEFT);
		stringSection.add(capitalText);
		
		var examples = ["hello world", "TESTING CAPS", "mIxEd CaSe"];
		var results = [];
		for (ex in examples)
		{
			results.push(ex + " → " + StringUtil.capitalization(ex));
		}
		capitalText.text = results.join("\n");
		
		// RIGHT COLUMN
		yOffset = contentY;
		
		// Padding demonstration
		createSectionLabel(col2X, yOffset, colWidth, "padLeft/padRight:", stringSection);
		
		paddingText = new FlxText(col2X, yOffset + 25, colWidth, "");
		paddingText.setFormat(null, 14, FlxColor.ORANGE, LEFT);
		stringSection.add(paddingText);
		
		var padExamples = [
			"|" + StringUtil.padLeft("42", 5, "0") + "| (padLeft)",
			"|" + StringUtil.padRight("42", 5, "0") + "| (padRight)",
			"|" + StringUtil.padLeft("Test", 10, ".") + "| (dots)"
		];
		paddingText.text = padExamples.join("\n");
	}
	
	private function setupArraySection():Void
	{
		var yOffset:Float = contentY;
		var col1X:Float = 20;
		var col2X:Float = FlxG.width / 2 + 10;
		var colWidth:Float = FlxG.width / 2 - 30;
		
		// LEFT COLUMN
		// Array shuffle demonstration
		createSectionLabel(col1X, yOffset, colWidth, "shuffle(array)\n[SPACE] to shuffle:", arraySection);
		
		yOffset += 45;
		
		// Create visual array elements (adjust for column width)
		var elementSize = Std.int(Math.min(50, (colWidth - 30) / arrayNumbers.length));
		arrayColX = col1X;
		arrayElementSpacing = elementSize + 10;
		
		for (i in 0...arrayNumbers.length)
		{
			var element = new FlxSprite(arrayColX + i * arrayElementSpacing, yOffset);
			element.makeGraphic(elementSize, elementSize, FlxColor.fromRGB(100, 150, 200));
			arraySection.add(element);
			
			var numText = new FlxText(arrayColX + i * arrayElementSpacing, yOffset + (elementSize / 2) - 10, elementSize, Std.string(arrayNumbers[i]));
			numText.setFormat(null, 20, FlxColor.WHITE, CENTER);
			arraySection.add(numText);
			
			arrayElements.push(element);
			arrayNumberTexts.push(numText);
		}
		
		yOffset += elementSize + 20;
		
		// First/Last demonstration
		createSectionLabel(col1X, yOffset, colWidth, "first() / last():", arraySection);
		
		yOffset += 25;
		
		var firstArrow = new FlxText(col1X + 5, yOffset, elementSize, "↑\nFIRST");
		firstArrow.setFormat(null, 9, FlxColor.LIME, CENTER);
		arraySection.add(firstArrow);
		
		var lastArrow = new FlxText(col1X + (arrayNumbers.length - 1) * arrayElementSpacing + 5, yOffset, elementSize, "↑\nLAST");
		lastArrow.setFormat(null, 9, FlxColor.ORANGE, CENTER);
		arraySection.add(lastArrow);
		
		// RIGHT COLUMN
		yOffset = contentY;
		
		// PickRandom demonstration
		createSectionLabel(col2X, yOffset, colWidth, "pickRandom(array)\nRandom highlighted:", arraySection);
		
		yOffset += 45;
		
		// Create pickRandom visual elements (colors) - compact for column
		var colors = [FlxColor.RED, FlxColor.GREEN, FlxColor.BLUE, FlxColor.YELLOW, FlxColor.MAGENTA, FlxColor.CYAN];
		var colorSize = Std.int(Math.min(50, (colWidth - 30) / colors.length));
		var colorSpacing = colorSize + 10;
		
		for (i in 0...colors.length)
		{
			var colorBox = new FlxSprite(col2X + i * colorSpacing, yOffset);
			colorBox.makeGraphic(colorSize, colorSize, colors[i]);
			arraySection.add(colorBox);
		}
	}

	private function setupFileSystemSection():Void
	{
		var yOffset:Float = contentY;
		var col1X:Float = 20;
		var col2X:Float = FlxG.width / 2 + 10;
		var colWidth:Float = FlxG.width / 2 - 30;

		// LEFT COLUMN
		// FilePath tests
		createSectionLabel(col1X, yOffset, colWidth, "FilePath.hx - Path Resolution:", fileSystemSection);

		yOffset += 25;

		pathInfoText = new FlxText(col1X, yOffset, colWidth, "");
		pathInfoText.setFormat(null, 11, FlxColor.WHITE, LEFT);
		fileSystemSection.add(pathInfoText);

		// Build path info display
		var pathInfo = [];
		pathInfo.push("Base: " + FilePath.get());
		pathInfo.push("Mod: " + FilePath.getMod());
		pathInfo.push("Music: " + FilePath.getPath(MUSIC));
		pathInfo.push("Images: " + FilePath.getPath(IMAGES));
		pathInfo.push("Sounds: " + FilePath.getPath(SOUNDS));
		pathInfo.push("Data: " + FilePath.getPath(DATA));

		pathInfoText.text = pathInfo.join("\n");

		// RIGHT COLUMN
		yOffset = contentY;

		// Paths.hx tests
		createSectionLabel(col2X, yOffset, colWidth, "Paths.hx - File Checking:\n[SPACE] Refresh", fileSystemSection);

		yOffset += 45;

		fileStatusText = new FlxText(col2X, yOffset, colWidth, "");
		fileStatusText.setFormat(null, 11, FlxColor.LIME, LEFT);
		fileSystemSection.add(fileStatusText);

		// Check for test files
		updateFileStatus();
	}

	private function updateFileStatus():Void
	{
		if (fileStatusText == null)
			return;

		var status = [];
		status.push("[SPACE] to refresh file checks\n");

		// List actual music files
		status.push("Music Files (.ogg):");
		var musicPath = "assets/" + FilePath.getPath(MUSIC);
		listDirectoryFiles(musicPath, ".ogg", status);

		// List actual metadata files
		status.push("\nMusic Metadata (.json):");
		var metadataPath = "assets/" + FilePath.getPath(METADATA);
		listDirectoryFiles(metadataPath, ".json", status);

		// List actual sound files
		status.push("\nSound Files (.ogg):");
		var soundsPath = "assets/" + FilePath.getPath(SOUNDS);
		listDirectoryFiles(soundsPath, ".ogg", status);

		fileStatusText.text = status.join("\n");
	}

	private function setupInputSection():Void
	{
		var yOffset:Float = contentY;
		var col1X:Float = 20;
		var col2X:Float = FlxG.width / 2 + 10;
		var colWidth:Float = FlxG.width / 2 - 30;

		// LEFT COLUMN
		// Input Manager tests
		createSectionLabel(col1X, yOffset, colWidth, "InputManager.hx\nKey & Gamepad Binding:", inputSection);

		yOffset += 45;

		inputStatusText = new FlxText(col1X, yOffset, colWidth, "");
		inputStatusText.setFormat(null, 11, FlxColor.WHITE, LEFT);
		inputSection.add(inputStatusText);

		// Setup InputManager bindings (Keyboard + Gamepad)
		var manager = InputManager.instance;

		// Keyboard bindings
		manager.bindKey("moveUp", FlxKey.W);
		manager.bindKey("moveUp", FlxKey.UP);
		manager.bindKey("moveDown", FlxKey.S);
		manager.bindKey("moveDown", FlxKey.DOWN);
		manager.bindKey("moveLeft", FlxKey.A);
		manager.bindKey("moveLeft", FlxKey.LEFT);
		manager.bindKey("moveRight", FlxKey.D);
		manager.bindKey("moveRight", FlxKey.RIGHT);
		manager.bindKey("jump", FlxKey.SPACE);

		// Gamepad bindings (D-Pad + Left Stick + Face Buttons)
		manager.bindGamepadButton("moveUp", FlxGamepadInputID.DPAD_UP);
		manager.bindGamepadButton("moveDown", FlxGamepadInputID.DPAD_DOWN);
		manager.bindGamepadButton("moveLeft", FlxGamepadInputID.DPAD_LEFT);
		manager.bindGamepadButton("moveRight", FlxGamepadInputID.DPAD_RIGHT);
		manager.bindGamepadButton("jump", FlxGamepadInputID.A);

		// Left analog stick
		manager.bindGamepadAxis("moveUp", FlxGamepadInputID.LEFT_STICK_DIGITAL_UP);
		manager.bindGamepadAxis("moveDown", FlxGamepadInputID.LEFT_STICK_DIGITAL_DOWN);
		manager.bindGamepadAxis("moveLeft", FlxGamepadInputID.LEFT_STICK_DIGITAL_LEFT);
		manager.bindGamepadAxis("moveRight", FlxGamepadInputID.LEFT_STICK_DIGITAL_RIGHT);

		// Check if gamepad is connected
		var gamepadConnected = FlxG.gamepads.lastActive != null;
		var statusText = gamepadConnected ? "Gamepad: CONNECTED ✓" : "Gamepad: Not connected";
		var statusColor = gamepadConnected ? FlxColor.LIME : FlxColor.ORANGE;

		inputStatusText.text = 'Press keys/buttons to test:\n[W/↑] [S/↓] [A/←] [D/→]\n[SPACE] - Jump';
		inputStatusText.color = FlxColor.WHITE;

		yOffset += 120;

		// Visual action indicators (compact layout for column)
		var actions = [
			{name: "moveUp", label: "↑"},
			{name: "moveLeft", label: "←"},
			{name: "moveDown", label: "↓"},
			{name: "moveRight", label: "→"},
			{name: "jump", label: "JUMP"}
		];

		// Compact keyboard layout - relative to column
		var actionPositions = [
			{x: col1X + 60, y: yOffset}, // moveUp
			{x: col1X + 20, y: yOffset + 40}, // moveLeft
			{x: col1X + 60, y: yOffset + 40}, // moveDown
			{x: col1X + 100, y: yOffset + 40}, // moveRight
			{x: col1X + 160, y: yOffset + 40} // jump
		];

		for (i in 0...actions.length)
		{
			var action = actions[i];
			var pos = actionPositions[i];

			var actionBox = new FlxSprite(pos.x, pos.y);
			var width = (action.name == "jump") ? 60 : 35;
			actionBox.makeGraphic(width, 35, FlxColor.fromRGB(60, 60, 60));
			inputSection.add(actionBox);

			var actionLabel = new FlxText(pos.x, pos.y + 10, width, action.label);
			actionLabel.setFormat(null, 10, FlxColor.GRAY, CENTER);
			inputSection.add(actionLabel);

			keyPressVisuals.set(action.name, actionBox);
		}

		// RIGHT COLUMN - Bindings info
		yOffset = contentY;

		createSectionLabel(col2X, yOffset, colWidth, "Input Bindings:", inputSection);

		yOffset += 30;

		var bindingsInfo = new FlxText(col2X, yOffset, colWidth,
			"Keyboard:\n  W/UP → moveUp\n  S/DOWN → moveDown\n  A/LEFT → moveLeft\n  D/RIGHT → moveRight\n  SPACE → jump\n\nGamepad:\n  D-Pad/L-Stick → Movement\n  A Button → jump\n\nMultiple inputs can\ntrigger the same action!");
		bindingsInfo.setFormat(null, 11, FlxColor.YELLOW, LEFT);
		inputSection.add(bindingsInfo);

		yOffset += 200;

		// Gamepad status indicator
		var gamepadStatusLabel = createSectionLabel(col2X, yOffset, colWidth, "Gamepad Status:", inputSection);
		gamepadStatusLabel.size = 12;

		yOffset += 25;

		var gamepadIndicator = new FlxSprite(col2X, yOffset);
		gamepadIndicator.makeGraphic(15, 15, gamepadConnected ? FlxColor.LIME : FlxColor.RED);
		inputSection.add(gamepadIndicator);
		keyPressVisuals.set("gamepadIndicator", gamepadIndicator);

		var gamepadText = new FlxText(col2X + 20, yOffset - 2, colWidth - 20, statusText);
		gamepadText.setFormat(null, 11, statusColor, LEFT);
		inputSection.add(gamepadText);
		keyPressVisuals.set("gamepadText", gamepadText);
	}
	
	public function switchSection(section:Int):Void
	{
		if (section < 0 || section >= sectionNames.length)
			return;
		
		currentSection = section;
		titleText.text = "Testing: " + sectionNames[currentSection];
		
		// Pause all sections (hide and stop updating)
		setSectionVisibility(mathSection, false);
		setSectionVisibility(stringSection, false);
		setSectionVisibility(arraySection, false);
		setSectionVisibility(fileSystemSection, false);
		setSectionVisibility(inputSection, false);
		
		// Activate current section
		switch (currentSection)
		{
			case 0:
				setSectionVisibility(mathSection, true);
			case 1:
				setSectionVisibility(stringSection, true);
			case 2:
				setSectionVisibility(arraySection, true);
			case 3:
				setSectionVisibility(fileSystemSection, true);
			case 4:
				setSectionVisibility(inputSection, true);
		}
	}
	
	public function executeTest():Void
	{
		switch (currentSection)
		{
			case 0: // MathUtil
				// Spawn random particles
				for (particle in randomParticles)
				{
					FlxTween.cancelTweensOf(particle);
					particle.x = MathUtil.randomRange(450, FlxG.width - 50);
					particle.y = MathUtil.randomRange(150, 220);
					particle.visible = true;
					particle.alpha = 1;
					
					// Fade out after appearing
					FlxTween.tween(particle, {alpha: 0}, 0.5, {
						onComplete: function(t:FlxTween) {
							particle.visible = false;
						}
					});
				}
				
			case 1: // StringUtil - Reset timer
				timeCounter = 0;
				
			case 2: // ArrayUtil - Shuffle array
				arrayNumbers = ArrayUtil.shuffle(arrayNumbers, 1);
				
				// Update visual positions with animation
				for (i in 0...arrayNumbers.length)
				{
					var element = arrayElements[i];
					var targetX = arrayColX + i * arrayElementSpacing;
					
					// Animate to new position
					FlxTween.tween(element, {x: targetX}, 0.3);
					
					// Update number text
					if (i < arrayNumberTexts.length)
					{
						arrayNumberTexts[i].text = Std.string(arrayNumbers[i]);
					}
				}
				
				// Highlight random element
				selectedIndex = MathUtil.randomInt(0, arrayElements.length - 1);
				for (i in 0...arrayElements.length)
				{
					var brightness = (i == selectedIndex) ? 1.5 : 0.7;
					var clampedBrightness = Math.min(brightness, 1.0);
					arrayElements[i].color = FlxColor.fromRGBFloat(
					clampedBrightness * 100 / 255, clampedBrightness * 150 / 255, clampedBrightness * 200 / 255
					);
				}
			case 3: // FileSystem - Refresh file status
				updateFileStatus();

			case 4: // Input

		}
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		// Update only active section
		if (!isAnySectionActive())
			return;


		timeCounter += elapsed;
		
		// MathUtil updates
		if (mathSection.active)
		{
			// Lerp animation
			lerpProgress += elapsed * lerpDirection * 0.5;
			if (lerpProgress >= 1.0)
			{
				lerpProgress = 1.0;
				lerpDirection = -1;
			}
			else if (lerpProgress <= 0.0)
			{
				lerpProgress = 0.0;
				lerpDirection = 1;
			}
			
			lerpSprite.x = MathUtil.lerp(lerpStartX, lerpEndX, lerpProgress);
			
			// Clamp demonstration - follow mouse but clamped
			var clampedX = MathUtil.clamp(FlxG.mouse.x, clampArea.x, clampArea.x + clampArea.width - clampSprite.width);
			clampSprite.x = clampedX;
			
			// MapRange demonstration - cycle through colors
			mapRangeValue += elapsed * 20;
			if (mapRangeValue > 100) mapRangeValue = 0;
			
			var r = Std.int(MathUtil.mapRange(mapRangeValue, 0, 100, 0, 255));
			var g = Std.int(MathUtil.mapRange(mapRangeValue, 0, 100, 255, 0));
			var b = 128;
			mapRangeBar.color = FlxColor.fromRGB(r, g, b);
			
			// Rotation demonstration
			rotationDegrees += elapsed * 60;
			if (rotationDegrees >= 360) rotationDegrees -= 360;
			
			rotationSprite.angle = rotationDegrees;
			
			// Update rotation text
			var radians = MathUtil.degToRad(rotationDegrees);
			if (rotationText != null)
			{
				rotationText.text = '${MathUtil.roundTo(rotationDegrees, 1)}° = ${MathUtil.roundTo(radians, 3)} rad';
			}
		}
		
		// StringUtil updates
		if (stringSection.active)
		{
			// Update timer display
			timeText.text = StringUtil.formatTime(timeCounter);
		}
		
		// ArrayUtil updates
		if (arraySection.active)
		{
			// Pulse selected element
			if (selectedIndex >= 0 && selectedIndex < arrayElements.length)
			{
				var pulse = 1.0 + Math.sin(timeCounter * 5) * 0.2;
				arrayElements[selectedIndex].scale.set(pulse, pulse);
			}
		}
		// FileSystem updates (static, no animation needed)
		if (fileSystemSection.active)
		{
			// Nothing to update in real-time
		}

		// Input updates
		if (inputSection.active)
		{
			// Update action press visuals using InputManager
			var manager = InputManager.instance;
			var actions = ["moveUp", "moveLeft", "moveDown", "moveRight", "jump"];

			for (action in actions)
			{
				var visual = keyPressVisuals.get(action);
				if (visual != null)
				{
					// Use InputManager to check if action is pressed
					if (manager.pressed(action))
					{
						visual.color = FlxColor.LIME;
						lastKeyPressed = action;
					}
					else
					{
						visual.color = FlxColor.fromRGB(60, 60, 60);
					}
				}
			}

			// Update gamepad connection status
			var gamepadConnected = FlxG.gamepads.lastActive != null;
			var indicator = keyPressVisuals.get("gamepadIndicator");
			var text = cast(keyPressVisuals.get("gamepadText"), FlxText);

			if (indicator != null)
			{
				indicator.color = gamepadConnected ? FlxColor.LIME : FlxColor.RED;
			}

			if (text != null)
			{
				var statusText = gamepadConnected ? "Gamepad: CONNECTED ✓" : "Gamepad: Not connected";
				var statusColor = gamepadConnected ? FlxColor.LIME : FlxColor.ORANGE;
				text.text = statusText;
				text.color = statusColor;
			}
		}
	}
}
