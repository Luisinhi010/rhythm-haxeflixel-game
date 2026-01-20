package states;

import backend.LayoutConstants;
import core.utils.SpriteUtil;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;

/**
 * Example state demonstrating responsive UI layout system.
 * Shows how to use ResponsiveState for adaptive layouts.
 */
class ResponsiveExampleState extends ResponsiveState
{
	private static inline var TITLE_Y_OFFSET:Float = 50;
	private static inline var COLOR_BOX_HEIGHT:Int = 80;
	private static inline var COLOR_BOX_START_Y:Float = 120;
	private static inline var GRID_Y_OFFSET:Float = 200;
	private static inline var GRID_LABEL_OFFSET:Float = 30;
	private static inline var EXTRA_SCROLL_SPACE:Float = 200;
	
	private var titleText:FlxText;
	private var infoText:FlxText;
	private var boxes:Array<FlxSprite> = [];
	
	override public function create():Void
	{
		super.create();
		
		// Background
		setBackgroundColor(FlxColor.fromRGB(40, 40, 40));
		
		// Title - responsive font size
		var titleSize = getResponsiveFontSize(32);
		titleText = new FlxText(getContentX(), getContentY(), getContentWidth(), "Responsive Layout Demo");
		titleText.setFormat(null, titleSize, FlxColor.WHITE, CENTER);
		add(titleText);
		
		// Device info
		var deviceType = switch (getDeviceType())
		{
			case MOBILE: "Mobile";
			case TABLET: "Tablet";
			case DESKTOP: "Desktop";
		}
		
		var infoSize = getResponsiveFontSize(16);
		infoText = new FlxText(getContentX(), getContentY() + TITLE_Y_OFFSET, getContentWidth(), 
			'Screen: ${Std.int(screenWidth)}x${Std.int(screenHeight)}\nDevice: $deviceType\nPress [SPACE] to show SubState example');
		infoText.setFormat(null, infoSize, FlxColor.CYAN, CENTER);
		add(infoText);
		
		// Responsive columns - changes based on screen size
		var columns = isMobile() ? 1 : (isTablet() ? 2 : 3);
		createColorBoxes(columns);
		
		// Grid system example
		createGridExample();
		
		// Configure scroll to accommodate all content
		scroll.showScrollbar = true;
		setMaxScroll(screenHeight + EXTRA_SCROLL_SPACE);
		addScroll();
	}
	
	private function createColorBoxes(columns:Int):Void
	{
		var colors = [FlxColor.RED, FlxColor.GREEN, FlxColor.BLUE, FlxColor.YELLOW, FlxColor.MAGENTA, FlxColor.CYAN];
		var colWidth = getColumnWidth(columns);
		var boxHeight = COLOR_BOX_HEIGHT;
		var startY = getContentY() + COLOR_BOX_START_Y;
		
		for (i in 0...colors.length)
		{
			var col = i % columns;
			var row = Std.int(i / columns);
			
			var box = SpriteUtil.createColoredSprite(Std.int(colWidth), boxHeight, colors[i]);
			SpriteUtil.setPosition(box, getColumnX(columns, col), startY + (boxHeight + rowGap) * row);
			add(box);
			boxes.push(box);
			
			var label = new FlxText(box.x, box.y + 30, colWidth, 'Box ${i + 1}');
			label.setFormat(null, getResponsiveFontSize(14), FlxColor.WHITE, CENTER);
			add(label);
		}
	}
	
	private function createGridExample():Void
	{
		var startY = screenHeight - GRID_Y_OFFSET;
		
		var gridLabel = new FlxText(getContentX(), startY - GRID_LABEL_OFFSET, getContentWidth(), "12-Column Grid System:");
		gridLabel.setFormat(null, getResponsiveFontSize(14), FlxColor.LIME, LEFT);
		add(gridLabel);
		
		var fullBox = SpriteUtil.createColoredSprite(Std.int(getGridWidth(12)), Std.int(LayoutConstants.GRID_BOX_HEIGHT), FlxColor.fromRGB(80, 80, 150));
		SpriteUtil.setPosition(fullBox, getGridX(0), startY);
		add(fullBox);
		
		var fullLabel = new FlxText(fullBox.x, fullBox.y + LayoutConstants.GRID_LABEL_Y_OFFSET, getGridWidth(12), "Span 12 (Full Width)");
		fullLabel.setFormat(null, LayoutConstants.GRID_LABEL_SIZE, FlxColor.WHITE, CENTER);
		add(fullLabel);
		
		startY += LayoutConstants.GRID_BOX_SPACING;
		
		for (i in 0...2)
		{
			var halfBox = SpriteUtil.createColoredSprite(Std.int(getGridWidth(6)), Std.int(LayoutConstants.GRID_BOX_HEIGHT), FlxColor.fromRGB(100, 150, 100));
			SpriteUtil.setPosition(halfBox, getGridX(i * 6), startY);
			add(halfBox);
			
			var halfLabel = new FlxText(halfBox.x, halfBox.y + LayoutConstants.GRID_LABEL_Y_OFFSET, getGridWidth(6), "Span 6");
			halfLabel.setFormat(null, LayoutConstants.GRID_LABEL_SIZE, FlxColor.WHITE, CENTER);
			add(halfLabel);
		}
		
		startY += LayoutConstants.GRID_BOX_SPACING;
		
		for (i in 0...3)
		{
			var thirdBox = SpriteUtil.createColoredSprite(Std.int(getGridWidth(4)), Std.int(LayoutConstants.GRID_BOX_HEIGHT), FlxColor.fromRGB(150, 100, 100));
			SpriteUtil.setPosition(thirdBox, getGridX(i * 4), startY);
			add(thirdBox);
			
			var thirdLabel = new FlxText(thirdBox.x, thirdBox.y + LayoutConstants.GRID_LABEL_Y_OFFSET, getGridWidth(4), "Span 4");
			thirdLabel.setFormat(null, LayoutConstants.GRID_LABEL_SIZE, FlxColor.WHITE, CENTER);
			add(thirdLabel);
		}
	}
	override public function onResizeContent():Void
	{
		setMaxScroll(screenHeight + EXTRA_SCROLL_SPACE);
		if (infoText != null)
		{
			var deviceType = switch (getDeviceType())
			{
				case MOBILE: "Mobile";
				case TABLET: "Tablet";
				case DESKTOP: "Desktop";
			}
			
			infoText.text = 'Screen: ${Std.int(screenWidth)}x${Std.int(screenHeight)}\nDevice: $deviceType\nPress [SPACE] to show SubState example';
			infoText.size = getResponsiveFontSize(16);
		}
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		// Reload state to see responsive changes
		if (FlxG.keys.justPressed.F5)
		{
			FlxG.resetState();
		}
		
		// Show substate example
		if (FlxG.keys.justPressed.SPACE)
		{
			openSubState(new ResponsiveExampleSubState());
		}
		
		// Back to debug state
		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.switchState(DebugState.new);
		}
	}
}
