package states;

import backend.LayoutConstants;
import core.utils.SpriteUtil;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;

/**
 * Example substate demonstrating responsive UI in overlays/popups.
 * Shows how to use ResponsiveSubState for modal dialogs and popups.
 */
class ResponsiveExampleSubState extends ResponsiveSubState
{
	private static inline var MODAL_GRID_HEIGHT:Float = 120;
	private static inline var MODAL_GRID_LABEL_OFFSET:Float = 25;
	private static inline var MODAL_GRID_BOX_HEIGHT:Float = 40;
	
	private var bgDim:FlxSprite;
	private var modalBox:FlxSprite;
	
	override public function create():Void
	{
		super.create();
		
		// Semi-transparent dimmed background
		bgDim = SpriteUtil.createColoredSprite(FlxG.width, FlxG.height, FlxColor.BLACK, 0.7);
		add(bgDim);
		
		// Modal box - centered and responsive size
		var modalWidth = isMobile() ? getContentWidth() : (isTablet() ? getContentWidth() * 0.8 : getContentWidth() * 0.6);
		var modalHeight = isMobile() ? getContentHeight() * 0.7 : getContentHeight() * 0.5;
		
		modalBox = SpriteUtil.createColoredSprite(Std.int(modalWidth), Std.int(modalHeight), FlxColor.fromRGB(50, 50, 80));
		SpriteUtil.setPosition(modalBox, getCenterX(modalWidth), getCenterY(modalHeight));
		add(modalBox);
		
		// Modal title
		var titleSize = getResponsiveFontSize(24);
		var titleText = new FlxText(modalBox.x + LayoutConstants.MODAL_PADDING, modalBox.y + LayoutConstants.MODAL_TITLE_OFFSET, modalWidth - LayoutConstants.MODAL_PADDING * 2, "Responsive SubState");
		titleText.setFormat(null, titleSize, FlxColor.WHITE, CENTER);
		add(titleText);
		
		// Content text
		var contentSize = getResponsiveFontSize(14);
		var contentText = new FlxText(modalBox.x + LayoutConstants.MODAL_PADDING, modalBox.y + LayoutConstants.MODAL_CONTENT_OFFSET, modalWidth - LayoutConstants.MODAL_PADDING * 2, 
			"This is a responsive SubState overlay.\n\n" +
			"• The modal size adapts to screen size\n" +
			"• Font sizes scale appropriately\n" +
			"• Padding adjusts for mobile/tablet/desktop\n\n" +
			"Device: " + getDeviceType() + "\n" +
			"Screen: " + Std.int(screenWidth) + "x" + Std.int(screenHeight));
		contentText.setFormat(null, contentSize, FlxColor.CYAN, LEFT);
		add(contentText);
		
		// Grid example in modal
		var gridY = modalBox.y + modalBox.height - MODAL_GRID_HEIGHT;
		var gridLabel = new FlxText(modalBox.x + LayoutConstants.MODAL_PADDING, gridY - MODAL_GRID_LABEL_OFFSET, modalWidth - LayoutConstants.MODAL_PADDING * 2, "Grid in Modal:");
		gridLabel.setFormat(null, getResponsiveFontSize(12), FlxColor.LIME, LEFT);
		add(gridLabel);
		
		// Temporarily adjust layout for modal context
		var oldPadding = padding;
		padding = LayoutConstants.MODAL_PADDING;
		
		var numBoxes = isMobile() ? 2 : 4;
		for (i in 0...numBoxes)
		{
			var totalGap = numBoxes > 1 ? columnGap * (numBoxes - 1) : 0;
			var boxWidth = (modalWidth - LayoutConstants.MODAL_PADDING * 2 - totalGap) / numBoxes;
			var boxX = modalBox.x + LayoutConstants.MODAL_PADDING + (boxWidth + columnGap) * i;
			var box = SpriteUtil.createColoredSprite(Std.int(boxWidth), Std.int(MODAL_GRID_BOX_HEIGHT), FlxColor.fromRGB(100 + i * 20, 100, 150));
			SpriteUtil.setPosition(box, boxX, gridY);
			add(box);
		}
		
		// Restore padding
		padding = oldPadding;
		
		// Close button
		var buttonWidth = isMobile() ? modalWidth - LayoutConstants.MODAL_PADDING * 2 : 200;
		var closeButton = SpriteUtil.createColoredSprite(Std.int(buttonWidth), Std.int(LayoutConstants.MODAL_BUTTON_HEIGHT), FlxColor.fromRGB(150, 50, 50));
		SpriteUtil.setPosition(closeButton, getCenterX(buttonWidth), modalBox.y + modalBox.height - LayoutConstants.MODAL_BUTTON_MARGIN);
		add(closeButton);
		
		var closeText = new FlxText(closeButton.x, closeButton.y + 10, buttonWidth, "[SPACE] or [ESC] to Close");
		closeText.setFormat(null, getResponsiveFontSize(12), FlxColor.WHITE, CENTER);
		add(closeText);
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		if (FlxG.keys.justPressed.SPACE || FlxG.keys.justPressed.ESCAPE)
		{
			close();
		}
	}
	override private function printSubStateSpecificInfo():Void
	{
		trace("=== Responsive Example SubState Info ===");
		trace("Modal Width: " + Std.int(modalBox.width));
		trace("Modal Height: " + Std.int(modalBox.height));
		trace("Device Type: " + getDeviceType());
		trace("Orientation: " + (isPortrait() ? "Portrait" : "Landscape"));
		trace("Content Size: " + Std.int(getContentWidth()) + "x" + Std.int(getContentHeight()));
		trace("Background Layers: " + background.getLayerCount());
		trace("---");
		trace("Controls:");
		trace("  SPACE/ESC: Close modal");
		trace("  F6: Show debug info");
	}
}
