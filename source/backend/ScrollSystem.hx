package backend;

import backend.LayoutConstants;
import core.utils.MathUtil;
import core.utils.SpriteUtil;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

/**
 * Complete scroll system with smooth scrolling, drag, keyboard, and scrollbar
 */
class ScrollSystem
{
	// Scroll state
	public var scrollY:Float = 0;
	public var targetScrollY:Float = 0;
	public var maxScrollY:Float = 0;
	
	// Configuration
	public var scrollSpeed:Float = LayoutConstants.SCROLL_SPEED_BASE;
	public var smoothScrollSpeed:Float = LayoutConstants.SMOOTH_SCROLL_SPEED;
	public var dragScrollEnabled:Bool = true;
	public var keyboardScrollEnabled:Bool = true;
	public var mouseWheelEnabled:Bool = true;
	public var showScrollbar:Bool = true;
	
	// Scrollbar
	public var scrollbar:FlxSprite;
	public var scrollbarTrack:FlxSprite;
	private var scrollbarWidth:Float = LayoutConstants.SCROLLBAR_WIDTH;
	private var scrollbarPadding:Float = LayoutConstants.SCROLLBAR_PADDING;
	
	// Drag state
	private var isDragging:Bool = false;
	private var dragStartY:Float = 0;
	private var dragStartScrollY:Float = 0;
	
	// Bounds indicators
	public var topIndicator:FlxSprite;
	public var bottomIndicator:FlxSprite;
	public var showBoundsIndicators:Bool = true;
	
	// Active tween for cleanup
	private var activeTween:FlxTween;
	
	// Screen bounds
	private var screenHeight:Float;
	
	public function new()
	{
		screenHeight = validateScreenHeight(FlxG.height);
		createScrollUI();
	}
	
	/**
	 * Validates and returns a safe screen height value.
	 */
	private inline function validateScreenHeight(height:Float):Float
	{
		if (height <= 0)
		{
			#if debug
			trace('Invalid screen height: $height, using fallback: ${LayoutConstants.MIN_SCREEN_HEIGHT}');
			#end
			return LayoutConstants.MIN_SCREEN_HEIGHT;
		}
		return height;
	}
	
	/**
	 * Helper to create a colored sprite with scroll factor set to 0.
	 * Delegates to SpriteUtil for consistent sprite creation behavior.
	 */
	private inline function createColoredSprite(width:Int, height:Int, color:FlxColor, alpha:Float = 1.0):FlxSprite
	{
		var sprite = SpriteUtil.createColoredSprite(width, height, color, alpha);
		sprite.scrollFactor.set(0, 0);
		return sprite;
	}
	
	/**
	 * Helper to update indicator alpha based on distance.
	 */
	private inline function calculateIndicatorAlpha(distance:Float):Float
	{
		if (distance <= 0) return 0;
		return MathUtil.clamp(distance / LayoutConstants.BOUNDS_INDICATOR_FADE_DISTANCE, 0, LayoutConstants.BOUNDS_INDICATOR_MAX_ALPHA);
	}
	
	/**
	 * Helper to validate and clamp scroll position.
	 */
	private inline function clampScroll(value:Float):Float
	{
		return MathUtil.clamp(value, 0, maxScrollY);
	}
	
	/**
	 * Helper to calculate scrollbar height based on content.
	 */
	private inline function calculateScrollbarHeight():Float
	{
		if (maxScrollY <= 0) return screenHeight;
		var contentHeight = maxScrollY + screenHeight;
		return Math.max(LayoutConstants.SCROLLBAR_MIN_HEIGHT, (screenHeight / contentHeight) * screenHeight);
	}
	
	/**
	 * Helper to calculate scrollbar Y position.
	 */
	private inline function calculateScrollbarY(scrollbarHeight:Float):Float
	{
		if (maxScrollY <= 0) return 0;
		return (scrollY / maxScrollY) * (screenHeight - scrollbarHeight);
	}
	
	/**
	 * Helper to position scrollbar track at the right edge.
	 */
	private inline function positionScrollbarTrack():Void
	{
		if (scrollbarTrack == null) return;
		scrollbarTrack.x = FlxG.width - scrollbarWidth - scrollbarPadding;
		scrollbarTrack.y = 0;
	}
	
	/**
	 * Helper to resize a sprite (avoids recreating graphics unnecessarily).
	 */
	private inline function resizeSprite(sprite:FlxSprite, width:Int, height:Int):Void
	{
		if (sprite == null) return;
		sprite.setGraphicSize(width, height);
		sprite.updateHitbox();
	}
	
	private function createScrollUI():Void
	{
		var scrollbarHeight = calculateScrollbarHeight();

		scrollbarTrack = createColoredSprite(Std.int(scrollbarWidth), Std.int(screenHeight), FlxColor.fromRGB(40, 40, 40), LayoutConstants.SCROLL_TRACK_ALPHA);
		scrollbar = createColoredSprite(Std.int(scrollbarWidth), Std.int(scrollbarHeight), FlxColor.fromRGB(150, 150, 150), 0.6);
		
		topIndicator = createColoredSprite(FlxG.width, Std.int(LayoutConstants.SCROLL_INDICATOR_HEIGHT), FlxColor.fromRGB(100, 100, 255), 0);
		topIndicator.y = 0;
		
		bottomIndicator = createColoredSprite(FlxG.width, Std.int(LayoutConstants.SCROLL_INDICATOR_HEIGHT), FlxColor.fromRGB(100, 100, 255), 0);
		bottomIndicator.y = screenHeight - LayoutConstants.SCROLL_INDICATOR_HEIGHT;
		
		updateScrollbarPosition();
	}
	
	/**
	 * Updates scroll system.
	 */
	public function update(elapsed:Float):Void
	{
		if (mouseWheelEnabled)
		{
			var wheel = FlxG.mouse.wheel;
			if (wheel != 0)
			{
				targetScrollY -= wheel * scrollSpeed;
				clampTargetScroll();
			}
		}
		
		if (keyboardScrollEnabled)
		{
			if (FlxG.keys.pressed.PAGEDOWN)
				targetScrollY += scrollSpeed * LayoutConstants.SCROLL_SPEED_PAGE_MULTIPLIER;
			if (FlxG.keys.pressed.PAGEUP)
				targetScrollY -= scrollSpeed * LayoutConstants.SCROLL_SPEED_PAGE_MULTIPLIER;
			if (FlxG.keys.justPressed.HOME)
				targetScrollY = 0;
			if (FlxG.keys.justPressed.END)
				targetScrollY = maxScrollY;
			
			if (FlxG.keys.pressed.DOWN)
				targetScrollY += scrollSpeed * LayoutConstants.SCROLL_SPEED_ARROW_MULTIPLIER;
			if (FlxG.keys.pressed.UP)
				targetScrollY -= scrollSpeed * LayoutConstants.SCROLL_SPEED_ARROW_MULTIPLIER;
			
			clampTargetScroll();
		}
		
		if (dragScrollEnabled)
		{
			if (FlxG.mouse.justPressed)
			{
				isDragging = true;
				dragStartY = FlxG.mouse.viewY;
				dragStartScrollY = scrollY;
			}
			else if (FlxG.mouse.justReleased)
			{
				isDragging = false;
			}
			
			if (isDragging && FlxG.mouse.pressed)
			{
				var deltaY = FlxG.mouse.viewY - dragStartY;
				targetScrollY = dragStartScrollY - deltaY;
				clampTargetScroll();
			}
		}
		
		scrollY = FlxMath.lerp(scrollY, targetScrollY, smoothScrollSpeed);
		
		if (Math.abs(scrollY - targetScrollY) < LayoutConstants.SCROLL_SNAP_THRESHOLD)
			scrollY = targetScrollY;
		
		updateScrollbarPosition();
		updateBoundsIndicators();
	}
	
	/**
	 * Scrolls to a specific position with optional animation.
	 */
	public function scrollTo(position:Float, animated:Bool = true, ?onComplete:Void->Void):Void
	{
		position = clampScroll(position);
		
		// Cancel any active tween
		if (activeTween != null)
		{
			activeTween.cancel();
			activeTween = null;
		}
		
		if (animated)
		{
			activeTween = FlxTween.tween(this, {targetScrollY: position}, 0.5, {
				ease: FlxEase.quadOut,
				onComplete: function(_) {
					activeTween = null;
					if (onComplete != null) onComplete();
				}
			});
		}
		else
		{
			scrollY = position;
			targetScrollY = position;
			if (onComplete != null) onComplete();
		}
	}
	
	/**
	 * Scrolls to make an element visible.
	 */
	public function scrollToElement(elementY:Float, elementHeight:Float, ?margin:Float = 20):Void
	{
		var topY = elementY - margin;
		var bottomY = elementY + elementHeight + margin;
		
		if (bottomY > scrollY + screenHeight)
		{
			// Element is below viewport
			scrollTo(bottomY - screenHeight);
		}
		else if (topY < scrollY)
		{
			// Element is above viewport
			scrollTo(topY);
		}
	}
	
	/**
	 * Sets maximum scroll distance.
	 */
	public function setMaxScroll(contentHeight:Float):Void
	{
		maxScrollY = Math.max(0, contentHeight - screenHeight);
		clampTargetScroll();
	}
	
	/**
	 * Resets scroll to top.
	 */
	public function resetScroll():Void
	{
		scrollY = 0;
		targetScrollY = 0;
	}
	
	public function updateScreenSize():Void
	{
		var oldScreenHeight = screenHeight;
		var newHeight = validateScreenHeight(FlxG.height);
		var newWidth = FlxG.width;

		// Validate dimensions before using
		if (newWidth <= 0 || newHeight <= 0)
		{
			#if debug
			trace("[ScrollSystem] Invalid screen dimensions: " + newWidth + "x" + newHeight);
			#end
			return;
		}

		screenHeight = newHeight;
		
		if (oldScreenHeight > 0 && maxScrollY > 0)
		{
			var scrollRatio = scrollY / maxScrollY;
			var newMaxScrollY = Math.max(0, maxScrollY + (screenHeight - oldScreenHeight));
			setMaxScroll(newMaxScrollY);
			scrollY = scrollRatio * maxScrollY;
			targetScrollY = scrollY;
		}
		
		if (scrollbar != null && scrollbarTrack != null && topIndicator != null && bottomIndicator != null)
		{
			repositionUI();
		}
		updateScrollbarPosition();
	}
	
	public function repositionUI():Void
	{
		if (showScrollbar && scrollbarTrack != null)
		{
			resizeSprite(scrollbarTrack, Std.int(scrollbarWidth), Std.int(screenHeight));
			positionScrollbarTrack();
		}
		
		if (showBoundsIndicators)
		{
			if (topIndicator != null)
			{
				resizeSprite(topIndicator, FlxG.width, Std.int(LayoutConstants.SCROLL_INDICATOR_HEIGHT));
				topIndicator.y = 0;
			}
			
			if (bottomIndicator != null)
			{
				resizeSprite(bottomIndicator, FlxG.width, Std.int(LayoutConstants.SCROLL_INDICATOR_HEIGHT));
				bottomIndicator.y = screenHeight - LayoutConstants.SCROLL_INDICATOR_HEIGHT;
			}
		}
	}
	
	/**
	 * Checks if an element is visible in viewport.
	 */
	public function isElementVisible(elementY:Float, elementHeight:Float):Bool
	{
		var topY = elementY;
		var bottomY = elementY + elementHeight;
		
		return bottomY >= scrollY && topY <= scrollY + screenHeight;
	}
	
	/**
	 * Gets visibility percentage (0-1) of an element.
	 */
	public function getElementVisibility(elementY:Float, elementHeight:Float):Float
	{
		var topY = elementY;
		var bottomY = elementY + elementHeight;
		
		// Calculate visible portion
		var visibleTop = Math.max(topY, scrollY);
		var visibleBottom = Math.min(bottomY, scrollY + screenHeight);
		var visibleHeight = Math.max(0, visibleBottom - visibleTop);
		
		return visibleHeight / elementHeight;
	}
	
	private inline function clampTargetScroll():Void
	{
		targetScrollY = clampScroll(targetScrollY);
	}
	
	private function updateScrollbarPosition():Void
	{
		if (!showScrollbar) return;
		
		positionScrollbarTrack();
		
		// Calculate scrollbar size and position
		if (maxScrollY > 0)
		{
			var scrollbarHeight = calculateScrollbarHeight();
			var scrollbarY = calculateScrollbarY(scrollbarHeight);
			
			resizeSprite(scrollbar, Std.int(scrollbarWidth), Std.int(scrollbarHeight));
			scrollbar.x = FlxG.width - scrollbarWidth - scrollbarPadding;
			scrollbar.y = scrollbarY;
			
			scrollbar.alpha = 0.6;
			scrollbarTrack.alpha = LayoutConstants.SCROLL_TRACK_ALPHA;
		}
		else
		{
			scrollbar.alpha = 0;
			scrollbarTrack.alpha = 0;
		}
	}
	
	private function updateBoundsIndicators():Void
	{
		if (!showBoundsIndicators) return;
		
		topIndicator.alpha = calculateIndicatorAlpha(scrollY);
		bottomIndicator.alpha = calculateIndicatorAlpha(maxScrollY - scrollY);
	}
	
	/**
	 * Gets the current scroll progress as a percentage (0-1).
	 * @return Scroll progress from 0 (top) to 1 (bottom)
	 */
	public function getScrollProgress():Float
	{
		if (maxScrollY <= 0) return 0;
		return scrollY / maxScrollY;
	}
	
	/**
	 * Sets scroll position by percentage (0-1).
	 * @param progress Percentage from 0 (top) to 1 (bottom)
	 * @param animated Whether to animate the scroll
	 */
	public function setScrollProgress(progress:Float, animated:Bool = true):Void
	{
		progress = MathUtil.clamp(progress, 0, 1);
		scrollTo(progress * maxScrollY, animated);
	}
	
	/**
	 * Scrolls by a delta amount.
	 * @param deltaY Amount to scroll (positive = down, negative = up)
	 * @param animated Whether to animate the scroll
	 */
	public function scrollBy(deltaY:Float, animated:Bool = false):Void
	{
		var newPosition = targetScrollY + deltaY;
		scrollTo(newPosition, animated);
	}
	
	/**
	 * Checks if currently at the top of scrollable content.
	 */
	public function isAtTop():Bool
	{
		return scrollY <= LayoutConstants.SCROLL_SNAP_THRESHOLD;
	}
	
	/**
	 * Checks if currently at the bottom of scrollable content.
	 */
	public function isAtBottom():Bool
	{
		return scrollY >= maxScrollY - LayoutConstants.SCROLL_SNAP_THRESHOLD;
	}
	
	/**
	 * Checks if content is scrollable (has content beyond viewport).
	 */
	public function isScrollable():Bool
	{
		return maxScrollY > 0;
	}
	
	/**
	 * Gets the viewport bounds (current visible area).
	 * @return Object with top and bottom Y positions
	 */
	public function getViewportBounds():{top:Float, bottom:Float}
	{
		return {top: scrollY, bottom: scrollY + screenHeight};
	}
	
	/**
	 * Enables or disables all input methods at once.
	 */
	public function setInputEnabled(enabled:Bool):Void
	{
		dragScrollEnabled = enabled;
		keyboardScrollEnabled = enabled;
		mouseWheelEnabled = enabled;
	}
	
	/**
	 * Updates visibility of scrollbar and indicators.
	 */
	public function setUIVisibility(scrollbarVisible:Bool, indicatorsVisible:Bool):Void
	{
		showScrollbar = scrollbarVisible;
		showBoundsIndicators = indicatorsVisible;
		updateScrollbarPosition();
		updateBoundsIndicators();
	}
	
	/**
	 * Gets the current content height (viewport + scrollable area).
	 * @return Total content height
	 */
	public function getContentHeight():Float
	{
		return screenHeight + maxScrollY;
	}
	
	/**
	 * Gets the screen (viewport) height.
	 * @return Viewport height
	 */
	public function getScreenHeight():Float
	{
		return screenHeight;
	}
	
	/**
	 * Checks if element is partially or fully visible.
	 * @param elementY Element Y position
	 * @param elementHeight Element height
	 * @return True if any part of element is in viewport
	 */
	public function isElementPartiallyVisible(elementY:Float, elementHeight:Float):Bool
	{
		return isElementVisible(elementY, elementHeight);
	}
	
	/**
	 * Checks if element is fully visible in viewport.
	 * @param elementY Element Y position
	 * @param elementHeight Element height
	 * @return True if entire element is in viewport
	 */
	public function isElementFullyVisible(elementY:Float, elementHeight:Float):Bool
	{
		var topY = elementY;
		var bottomY = elementY + elementHeight;
		
		return topY >= scrollY && bottomY <= scrollY + screenHeight;
	}
	
	/**
	 * Cleans up resources to prevent memory leaks.
	 */
	public function destroy():Void
	{
		if (activeTween != null)
		{
			activeTween.cancel();
			activeTween = null;
		}
		
		if (scrollbar != null)
		{
			scrollbar.destroy();
			scrollbar = null;
		}
		
		if (scrollbarTrack != null)
		{
			scrollbarTrack.destroy();
			scrollbarTrack = null;
		}
		
		if (topIndicator != null)
		{
			topIndicator.destroy();
			topIndicator = null;
		}
		
		if (bottomIndicator != null)
		{
			bottomIndicator.destroy();
			bottomIndicator = null;
		}
	}
}
