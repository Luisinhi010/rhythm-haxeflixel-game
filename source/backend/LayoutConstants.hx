package backend;

/**
 * Centralized constants for responsive layout system.
 * All magic numbers should be defined here for easy configuration.
 */
class LayoutConstants
{
	// Screen size fallbacks
	public static inline var DEFAULT_SCREEN_WIDTH:Int = 1280;
	public static inline var DEFAULT_SCREEN_HEIGHT:Int = 720;
	public static inline var MIN_SCREEN_HEIGHT:Int = 600;
	
	// UI positioning
	public static inline var DEBUGGER_BOTTOM_OFFSET:Int = 100;
	public static inline var MODAL_PADDING:Float = 20;
	public static inline var MODAL_BUTTON_HEIGHT:Float = 40;
	public static inline var MODAL_BUTTON_MARGIN:Float = 60;
	public static inline var MODAL_TITLE_OFFSET:Float = 20;
	public static inline var MODAL_CONTENT_OFFSET:Float = 70;
	public static inline var GRID_BOX_HEIGHT:Float = 30;
	public static inline var GRID_BOX_SPACING:Float = 40;
	public static inline var GRID_LABEL_SIZE:Int = 10;
	public static inline var GRID_LABEL_Y_OFFSET:Float = 8;
	
	// Visibility thresholds
	public static inline var SCROLL_SNAP_THRESHOLD:Float = 0.5;
	public static inline var BOUNDS_INDICATOR_FADE_DISTANCE:Float = 100;
	public static inline var BOUNDS_INDICATOR_MAX_ALPHA:Float = 0.3;
	
	// Scroll speeds
	public static inline var SCROLL_SPEED_BASE:Float = 30;
	public static inline var SCROLL_SPEED_PAGE_MULTIPLIER:Float = 3;
	public static inline var SCROLL_SPEED_ARROW_MULTIPLIER:Float = 0.5;
	public static inline var SMOOTH_SCROLL_SPEED:Float = 0.2; // Lerp factor (0-1)
	
	// Scrollbar configuration
	public static inline var SCROLL_TRACK_ALPHA:Float = 0.3;
	public static inline var SCROLLBAR_WIDTH:Float = 8;
	public static inline var SCROLLBAR_PADDING:Float = 4;
	public static inline var SCROLLBAR_MIN_HEIGHT:Float = 30;
	public static inline var SCROLL_INDICATOR_HEIGHT:Float = 20;
}
