package objects;

import backend.FlxGroupContainer;
import backend.Paths;
import core.utils.ArrayUtil;
import core.utils.MathUtil;
import core.utils.StringUtil;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;

/**
 * Visual tester for utility functions (MathUtil, StringUtil, ArrayUtil).
 * Shows animated demonstrations of each function.
 */
class UtilTester extends FlxGroupContainer
{
	// Section management
	private var currentSection:Int = 0; // 0=Math, 1=String, 2=Array
	private var sectionNames:Array<String> = ["MathUtil", "StringUtil", "ArrayUtil"];
	
	// Visual components
	private var background:FlxSprite;
	private var titleText:FlxText;
	private var instructionText:FlxText;
	
	// Section groups (only active section updates)
	private var mathSection:FlxTypedGroup<FlxSprite>;
	private var stringSection:FlxTypedGroup<FlxSprite>;
	private var arraySection:FlxTypedGroup<FlxSprite>;
	
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
	
	// Layout system
	private var contentHeight:Float = 0; // Available height for content
	private var contentY:Float = 70; // Starting Y position after header
	private var padding:Float = 10; // Spacing between elements
	private var sectionPadding:Float = 20; // Spacing between major sections
	
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
			"[1][2][3] Switch Section | [SPACE] Execute | [T] Toggle Tester");
		instructionText.setFormat(null, 12, FlxColor.GRAY, LEFT);
		add(instructionText);
		
		// Initialize sections
		mathSection = new FlxTypedGroup<FlxSprite>();
		stringSection = new FlxTypedGroup<FlxSprite>();
		arraySection = new FlxTypedGroup<FlxSprite>();
		
		add(mathSection);
		add(stringSection);
		add(arraySection);
		
		// Setup each section
		setupMathSection();
		setupStringSection();
		setupArraySection();
		
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
		var lerpLabel = new FlxText(col1X, yOffset, colWidth, "lerp(a, b, t):");
		lerpLabel.setFormat(null, 14, FlxColor.CYAN, LEFT);
		mathSection.add(lerpLabel);
		
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
		var clampLabel = new FlxText(col1X, yOffset, colWidth, "clamp(value, min, max):");
		clampLabel.setFormat(null, 14, FlxColor.CYAN, LEFT);
		mathSection.add(clampLabel);
		
		var clampWidth = Std.int(colWidth - 50);
		clampArea = new FlxSprite(col1X, yOffset + 25);
		clampArea.makeGraphic(clampWidth, 30, FlxColor.fromRGB(50, 50, 80));
		mathSection.add(clampArea);
		
		clampSprite = new FlxSprite(col1X + clampWidth/2, yOffset + 30);
		clampSprite.makeGraphic(20, 20, FlxColor.YELLOW);
		mathSection.add(clampSprite);
		
		yOffset += 70;
		
		// MapRange demonstration
		var mapLabel = new FlxText(col1X, yOffset, colWidth, "mapRange(0-100 → RGB):");
		mapLabel.setFormat(null, 14, FlxColor.CYAN, LEFT);
		mathSection.add(mapLabel);
		
		mapRangeBar = new FlxSprite(col1X, yOffset + 25);
		mapRangeBar.makeGraphic(Std.int(colWidth - 10), 30, FlxColor.RED);
		mathSection.add(mapRangeBar);
		
		// RIGHT COLUMN
		yOffset = contentY;
		
		// Rotation demonstration
		var rotLabel = new FlxText(col2X, yOffset, colWidth, "degToRad/radToDeg:");
		rotLabel.setFormat(null, 14, FlxColor.CYAN, LEFT);
		mathSection.add(rotLabel);
		
		rotationSprite = new FlxSprite(col2X + 100, yOffset + 40);
		rotationSprite.makeGraphic(40, 4, FlxColor.MAGENTA);
		rotationSprite.offset.set(0, 2);
		mathSection.add(rotationSprite);
		
		rotationText = new FlxText(col2X + 150, yOffset + 35, colWidth - 150, "");
		rotationText.setFormat(null, 12, FlxColor.WHITE, LEFT);
		mathSection.add(rotationText);
		
		yOffset += 90;
		
		// Random particles demonstration
		var randomLabel = new FlxText(col2X, yOffset, colWidth, "randomRange/randomInt:\n[SPACE] Spawn particles");
		randomLabel.setFormat(null, 14, FlxColor.CYAN, LEFT);
		mathSection.add(randomLabel);
		
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
		var timeLabel = new FlxText(col1X, yOffset, colWidth, "formatTime(seconds):");
		timeLabel.setFormat(null, 14, FlxColor.CYAN, LEFT);
		stringSection.add(timeLabel);
		
		timeText = new FlxText(col1X, yOffset + 25, colWidth, "00:00");
		timeText.setFormat(null, 32, FlxColor.GREEN, LEFT);
		stringSection.add(timeText);
		
		yOffset += 80;
		
		// Capitalization demonstration
		var capLabel = new FlxText(col1X, yOffset, colWidth, "capitalization(str):");
		capLabel.setFormat(null, 14, FlxColor.CYAN, LEFT);
		stringSection.add(capLabel);
		
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
		var padLabel = new FlxText(col2X, yOffset, colWidth, "padLeft/padRight:");
		padLabel.setFormat(null, 14, FlxColor.CYAN, LEFT);
		stringSection.add(padLabel);
		
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
		var shuffleLabel = new FlxText(col1X, yOffset, colWidth, "shuffle(array)\n[SPACE] to shuffle:");
		shuffleLabel.setFormat(null, 14, FlxColor.CYAN, LEFT);
		arraySection.add(shuffleLabel);
		
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
		var firstLastLabel = new FlxText(col1X, yOffset, colWidth, "first() / last():");
		firstLastLabel.setFormat(null, 14, FlxColor.CYAN, LEFT);
		arraySection.add(firstLastLabel);
		
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
		var pickLabel = new FlxText(col2X, yOffset, colWidth, "pickRandom(array)\nRandom highlighted:");
		pickLabel.setFormat(null, 14, FlxColor.CYAN, LEFT);
		arraySection.add(pickLabel);
		
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

	public function switchSection(section:Int):Void
	{
		if (section < 0 || section >= sectionNames.length)
			return;
		
		currentSection = section;
		titleText.text = "Testing: " + sectionNames[currentSection];
		
		// Pause all sections (hide and stop updating)
		mathSection.visible = false;
		mathSection.active = false;
		stringSection.visible = false;
		stringSection.active = false;
		arraySection.visible = false;
		arraySection.active = false;
		
		// Activate current section
		switch (currentSection)
		{
			case 0:
				mathSection.visible = true;
				mathSection.active = true;
			case 1:
				stringSection.visible = true;
				stringSection.active = true;
			case 2:
				arraySection.visible = true;
				arraySection.active = true;
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
		}
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		// Update only active section
		if (!mathSection.active && !stringSection.active && !arraySection.active)
			return;
		
		// Update timer unconditionally for all sections
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
	}
}
