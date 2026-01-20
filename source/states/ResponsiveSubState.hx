package states;

import backend.ResponsiveBackground;
import backend.ResponsiveLayout;
import backend.ScrollSystem;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import states.ResponsiveState.DeviceType;

/**
 * Base class for substates with responsive UI layout system.
 * Uses composition to share functionality
 */
class ResponsiveSubState extends DefaultSubState
{
	// Shared systems
	public var background:ResponsiveBackground;
	public var layout:ResponsiveLayout;
	
	// Quick access properties (delegates to layout)
	public var padding(get, set):Float;
	public var margin(get, set):Float;
	public var columnGap(get, set):Float;
	public var rowGap(get, set):Float;
	public var screenWidth(get, never):Float;
	public var screenHeight(get, never):Float;
	
	override public function create():Void
	{
		super.create();
		
		// Initialize systems
		background = new ResponsiveBackground();
		add(background);
		
		layout = new ResponsiveLayout();
	}
	
	override function onResize(width:Int, height:Int):Void
	{
		super.onResize(width, height);
		layout.onResize(width, height);
		background.onResize(width, height);
		onResizeContent();
	}
	
	/**
	 * Override this method to handle custom resize logic for your content.
	 * Called after the layout system has been updated.
	 */
	public function onResizeContent():Void
	{
		// Override in subclasses
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}

	// Property delegates
	private function get_padding():Float return layout.padding;
	private function set_padding(value:Float):Float return layout.padding = value;
	
	private function get_margin():Float return layout.margin;
	private function set_margin(value:Float):Float return layout.margin = value;
	
	private function get_columnGap():Float return layout.columnGap;
	private function set_columnGap(value:Float):Float return layout.columnGap = value;
	
	private function get_rowGap():Float return layout.rowGap;
	private function set_rowGap(value:Float):Float return layout.rowGap = value;
	
	private function get_screenWidth():Float return layout.screenWidth;
	private function get_screenHeight():Float return layout.screenHeight;
	
	// Layout delegates
	public function getDeviceType():DeviceType return layout.getDeviceType();
	public function isMobile():Bool return layout.isMobile();
	public function isTablet():Bool return layout.isTablet();
	public function isDesktop():Bool return layout.isDesktop();
	public function isPortrait():Bool return layout.isPortrait();
	public function isLandscape():Bool return layout.isLandscape();
	
	public function getColumnWidth(columns:Int):Float return layout.getColumnWidth(columns);
	public function getColumnX(columns:Int, index:Int):Float return layout.getColumnX(columns, index);
	public function getRowY(rowIndex:Int, rowHeight:Float):Float return layout.getRowY(rowIndex, rowHeight);
	
	public function getGridWidth(span:Int):Float return layout.getGridWidth(span);
	public function getGridX(column:Int):Float return layout.getGridX(column);
	
	public function getCenterX(elementWidth:Float):Float return layout.getCenterX(elementWidth);
	public function getCenterY(elementHeight:Float):Float return layout.getCenterY(elementHeight);
	
	public function getResponsiveFontSize(baseSize:Int):Int return layout.getResponsiveFontSize(baseSize);
	public function getResponsiveSpacing(baseSpacing:Float):Float return layout.getResponsiveSpacing(baseSpacing);
	public function getResponsiveScale():Float return layout.getResponsiveScale();
	
	public function getContentWidth():Float return layout.getContentWidth();
	public function getContentHeight():Float return layout.getContentHeight();
	public function getSafeContentWidth():Float return layout.getSafeContentWidth();
	public function getSafeContentHeight():Float return layout.getSafeContentHeight();
	
	public function getContentX():Float return layout.getContentX();
	public function getContentY():Float return layout.getContentY();
	public function getSafeContentX():Float return layout.getSafeContentX();
	public function getSafeContentY():Float return layout.getSafeContentY();
	
	public function maintainAspectRatio(targetWidth:Float, targetHeight:Float, maxWidth:Float, maxHeight:Float) return layout.maintainAspectRatio(targetWidth, targetHeight, maxWidth, maxHeight);
	public function clampWidth(width:Float, ?min:Float, ?max:Float):Float return layout.clampWidth(width, min, max);
	public function clampHeight(height:Float, ?min:Float, ?max:Float):Float return layout.clampHeight(height, min, max);
	
	// Background convenience methods
	
	/**
	 * Creates a solid color background.
	 * @param color Background color
	 * @param alpha Transparency (0-1)
	 */
	public function setBackgroundColor(color:FlxColor = FlxColor.WHITE, alpha:Float = 1.0):FlxSprite
	{
		return background.createSolid(color, alpha);
	}
	
	/**
	 * Creates a vertical gradient background.
	 * @param topColor Top color
	 * @param bottomColor Bottom color
	 * @param alpha Transparency (0-1)
	 */
	public function setBackgroundGradient(topColor:FlxColor, bottomColor:FlxColor, alpha:Float = 1.0):FlxSprite
	{
		return background.createVerticalGradient(topColor, bottomColor, alpha);
	}
	
	/**
	 * Creates a horizontal gradient background.
	 * @param leftColor Left color
	 * @param rightColor Right color
	 * @param alpha Transparency (0-1)
	 */
	public function setBackgroundHorizontalGradient(leftColor:FlxColor, rightColor:FlxColor, alpha:Float = 1.0):FlxSprite
	{
		return background.createHorizontalGradient(leftColor, rightColor, alpha);
	}
	
	/**
	 * Creates an image background.
	 * @param imagePath Image name (without extension)
	 * @param scaleMode How to scale the image (FIT, FILL, STRETCH, NONE)
	 * @param alpha Transparency (0-1)
	 */
	public function setBackgroundImage(imagePath:String, scaleMode:ScaleMode = FIT, alpha:Float = 1.0):FlxSprite
	{
		return background.createImage(imagePath, scaleMode, alpha);
	}
	
	/**
	 * Adds a parallax layer to the background.
	 * @param imagePath Image name
	 * @param scrollFactor Movement factor (0 = fixed, 1 = moves with camera)
	 * @param scaleMode How to scale the image
	 * @param alpha Transparency
	 */
	public function addBackgroundLayer(imagePath:String, scrollFactor:Float = 0.5, scaleMode:ScaleMode = FIT, alpha:Float = 1.0):FlxSprite
	{
		return background.addParallaxLayer(imagePath, scrollFactor, scaleMode, alpha);
	}
	
	override public function destroy():Void
	{
		if (background != null)
		{
			background.destroy();
			background = null;
		}
		
		layout = null;
		
		super.destroy();
	}
}
