package states;

import backend.ResponsiveBackground;
import backend.ResponsiveLayout;
import backend.ScrollSystem;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;

/**
 * Base class for states with responsive UI layout system.
 * Uses composition to share functionality
 */
class ResponsiveState extends DefaultState
{
	// Shared systems
	public var background:ResponsiveBackground;
	public var layout:ResponsiveLayout;
	public var scroll:ScrollSystem;
	
	// Quick access properties (delegates to layout)
	public var padding(get, set):Float;
	public var margin(get, set):Float;
	public var columnGap(get, set):Float;
	public var rowGap(get, set):Float;
	public var screenWidth(get, never):Float;
	public var screenHeight(get, never):Float;
	public var scrollY(get, never):Float;
	
	override public function create():Void
	{
		super.create();
		
		// Initialize systems
		background = new ResponsiveBackground();
		add(background);
		
		layout = new ResponsiveLayout();
		scroll = new ScrollSystem();
		
		addScroll();
	}
	
	/**
	 * Called when the game window is resized.
	 * Automatically updates layout and scroll systems.
	 */
	override public function onResize(width:Int, height:Int):Void
	{
		super.onResize(width, height);
		layout.onResize(width, height);
		background.onResize(width, height);
		scroll.updateScreenSize();
		repositionScrollUI();
		onResizeContent();
	}
	
	/**
	 * Override this method to handle custom resize logic for your content.
	 * Called after the layout and scroll systems have been updated.
	 */
	public function onResizeContent():Void
	{
		// Override in subclasses to handle custom resize logic
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		scroll.update(elapsed);
		FlxG.camera.scroll.y = scroll.scrollY;
	}
	
	/**
	 * Repositions scroll UI elements without recreating them.
	 * More efficient than remove/add cycle.
	 */
	private function repositionScrollUI():Void
	{
		// Update positions based on new screen size
		scroll.repositionUI();
	}

	public function addScroll():Void
	{
		// Add scroll UI elements (removing first to avoid duplicates)
		remove(scroll.topIndicator, true);
		remove(scroll.bottomIndicator, true);
		remove(scroll.scrollbarTrack, true);
		remove(scroll.scrollbar, true);
		
		add(scroll.topIndicator);
		add(scroll.bottomIndicator);
		add(scroll.scrollbarTrack);
		add(scroll.scrollbar);
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
	private function get_scrollY():Float return scroll.scrollY;
	
	// Layout delegates
	public inline function getDeviceType():DeviceType
		return layout.getDeviceType();

	public inline function isMobile():Bool
		return layout.isMobile();

	public inline function isTablet():Bool
		return layout.isTablet();

	public inline function isDesktop():Bool
		return layout.isDesktop();

	public inline function isPortrait():Bool
		return layout.isPortrait();

	public inline function isLandscape():Bool
		return layout.isLandscape();

	public inline function getColumnWidth(columns:Int):Float
		return layout.getColumnWidth(columns);

	public inline function getColumnX(columns:Int, index:Int):Float
		return layout.getColumnX(columns, index);

	public inline function getRowY(rowIndex:Int, rowHeight:Float):Float
		return layout.getRowY(rowIndex, rowHeight);

	public inline function getGridWidth(span:Int):Float
		return layout.getGridWidth(span);

	public inline function getGridX(column:Int):Float
		return layout.getGridX(column);

	public inline function getCenterX(elementWidth:Float):Float
		return layout.getCenterX(elementWidth);

	public inline function getCenterY(elementHeight:Float):Float
		return layout.getCenterY(elementHeight);

	public inline function getResponsiveFontSize(baseSize:Int):Int
		return layout.getResponsiveFontSize(baseSize);

	public inline function getResponsiveSpacing(baseSpacing:Float):Float
		return layout.getResponsiveSpacing(baseSpacing);

	public inline function getResponsiveScale():Float
		return layout.getResponsiveScale();

	public inline function getContentWidth():Float
		return layout.getContentWidth();

	public inline function getContentHeight():Float
		return layout.getContentHeight();

	public inline function getSafeContentWidth():Float
		return layout.getSafeContentWidth();

	public inline function getSafeContentHeight():Float
		return layout.getSafeContentHeight();

	public inline function getContentX():Float
		return layout.getContentX();

	public inline function getContentY():Float
		return layout.getContentY();

	public inline function getSafeContentX():Float
		return layout.getSafeContentX();

	public inline function getSafeContentY():Float
		return layout.getSafeContentY();

	public inline function maintainAspectRatio(targetWidth:Float, targetHeight:Float, maxWidth:Float, maxHeight:Float)
		return layout.maintainAspectRatio(targetWidth, targetHeight, maxWidth, maxHeight);

	public inline function clampWidth(width:Float, ?min:Float, ?max:Float):Float
		return layout.clampWidth(width, min, max);

	public inline function clampHeight(height:Float, ?min:Float, ?max:Float):Float
		return layout.clampHeight(height, min, max);
	
	// Scroll delegates - inline for zero runtime overhead
	public inline function setMaxScroll(contentHeight:Float):Void
		scroll.setMaxScroll(contentHeight);

	public inline function resetScroll():Void
		scroll.resetScroll();

	public inline function scrollTo(position:Float, animated:Bool = true, ?onComplete:Void->Void):Void
		scroll.scrollTo(position, animated, onComplete);

	public inline function scrollToElement(elementY:Float, elementHeight:Float, ?margin:Float = 20):Void
		scroll.scrollToElement(elementY, elementHeight, margin);

	public inline function isElementVisible(elementY:Float, elementHeight:Float):Bool
		return scroll.isElementVisible(elementY, elementHeight);

	public inline function getElementVisibility(elementY:Float, elementHeight:Float):Float
		return scroll.getElementVisibility(elementY, elementHeight);
	
	// Background convenience methods
	
	/**
	 * Creates a solid color background.
	 * @param color Background color
	 * @param alpha Transparency (0-1)
	 */
	public inline function setBackgroundColor(color:FlxColor = FlxColor.WHITE, alpha:Float = 1.0):FlxSprite
	{
		return background.createSolid(color, alpha);
	}
	
	/**
	 * Creates a vertical gradient background.
	 * @param topColor Top color
	 * @param bottomColor Bottom color
	 * @param alpha Transparency (0-1)
	 */
	public inline function setBackgroundGradient(topColor:FlxColor, bottomColor:FlxColor, alpha:Float = 1.0):FlxSprite
	{
		return background.createVerticalGradient(topColor, bottomColor, alpha);
	}
	
	/**
	 * Creates a horizontal gradient background.
	 * @param leftColor Left color
	 * @param rightColor Right color
	 * @param alpha Transparency (0-1)
	 */
	public inline function setBackgroundHorizontalGradient(leftColor:FlxColor, rightColor:FlxColor, alpha:Float = 1.0):FlxSprite
	{
		return background.createHorizontalGradient(leftColor, rightColor, alpha);
	}
	
	/**
	 * Creates an image background.
	 * @param imagePath Image name (without extension)
	 * @param scaleMode How to scale the image (FIT, FILL, STRETCH, NONE)
	 * @param alpha Transparency (0-1)
	 */
	public inline function setBackgroundImage(imagePath:String, scaleMode:ScaleMode = FIT, alpha:Float = 1.0):FlxSprite
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
	public inline function addBackgroundLayer(imagePath:String, scrollFactor:Float = 0.5, scaleMode:ScaleMode = FIT, alpha:Float = 1.0):FlxSprite
	{
		return background.addParallaxLayer(imagePath, scrollFactor, scaleMode, alpha);
	}
	
	override private function printStateSpecificInfo():Void
	{
		super.printStateSpecificInfo();
		
		// Layout info
		trace("--- Responsive Layout ---");
		trace("Device Type: " + getDeviceType());
		trace("Orientation: " + (isPortrait() ? "Portrait" : "Landscape"));
		trace("Content Area: " + Std.int(getContentWidth()) + "x" + Std.int(getContentHeight()));
		trace("Padding: " + padding + ", Margin: " + margin);
		trace("Gaps: Column=" + columnGap + ", Row=" + rowGap);
		
		// Background info
		if (background != null)
		{
			trace("--- Background ---");
			trace("Layers: " + background.getLayerCount());
			trace("Members: " + background.length);
		}
		
		// Scroll info
		if (scroll != null)
		{
			trace("--- Scroll System ---");
			trace("Scroll Y: " + Std.int(scroll.scrollY) + " / " + Std.int(scroll.maxScrollY));
			trace("Progress: " + Std.int(scroll.getScrollProgress() * 100) + "%");
			trace("At Top: " + scroll.isAtTop() + ", At Bottom: " + scroll.isAtBottom());
			trace("Scrollbar Visible: " + scroll.showScrollbar);
		}
	}
	
	override public function destroy():Void
	{
		if (scroll != null)
		{
			scroll.destroy();
			scroll = null;
		}
		
		if (background != null)
		{
			background.destroy();
			background = null;
		}
		
		layout = null;
		
		super.destroy();
	}
}

/**
 * Device type enum for responsive design.
 */
enum DeviceType
{
	MOBILE;
	TABLET;
	DESKTOP;
}
