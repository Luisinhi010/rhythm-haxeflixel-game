package backend;

import core.utils.MathUtil;
import flixel.FlxG;
import states.ResponsiveState.DeviceType;

/**
 * Shared responsive layout system
 * Handles all layout calculations for both states and substates.
 */
class ResponsiveLayout
{
	// Responsive breakpoints (pixels)
	public static inline var BREAKPOINT_MOBILE:Int = 640;
	public static inline var BREAKPOINT_TABLET:Int = 1024;
	public static inline var BREAKPOINT_DESKTOP:Int = 1920;
	
	// Grid system (12-column grid like Bootstrap)
	public static inline var GRID_COLUMNS:Int = 12;
	
	// Layout properties
	public var padding:Float = 20;
	public var margin:Float = 10;
	public var columnGap:Float = 20;
	public var rowGap:Float = 20;
	
	// Safe areas (for notches, system bars)
	public var safeAreaTop:Float = 0;
	public var safeAreaBottom:Float = 0;
	public var safeAreaLeft:Float = 0;
	public var safeAreaRight:Float = 0;
	
	// Calculated dimensions
	private var _contentWidth:Float = 0;
	private var _contentHeight:Float = 0;
	private var _safeContentWidth:Float = 0;
	private var _safeContentHeight:Float = 0;
	
	// Screen dimensions
	public var screenWidth(get, never):Float;
	public var screenHeight(get, never):Float;
	
	/**
	 * Helper to clamp a value within a range.
	 * Delegates to MathUtil for consistent clamping behavior.
	 * @param value The value to clamp
	 * @param min Minimum value (optional)
	 * @param max Maximum value (optional)
	 * @return The clamped value
	 */
	private inline function clampValue(value:Float, ?min:Float, ?max:Float):Float
	{
		if (min != null && value < min) value = min;
		if (max != null && value > max) value = max;
		return value;
	}
	
	/**
	 * Helper to validate and clamp column/span values.
	 * Delegates to MathUtil for consistent integer clamping.
	 * @param value The value to validate
	 * @param min Minimum allowed value
	 * @param max Maximum allowed value
	 * @return The validated value
	 */
	private inline function validateColumnSpan(value:Int, min:Int, max:Int):Int
	{
		return MathUtil.clampInt(value, min, max);
	}
	
	/**
	 * Helper to calculate column width for a given number of columns.
	 * @param columns Number of columns
	 * @param totalWidth Total available width
	 * @param gap Gap between columns
	 * @return Width of each column
	 */
	private function calculateColumnWidth(columns:Int, totalWidth:Float, gap:Float):Float
	{
		if (columns <= 0) return 0;
		
		var totalGap = gap * (columns - 1);
		return (totalWidth - totalGap) / columns;
	}
	
	public function new()
	{
		validateSpacing();
		calculateLayout();
	}
	
	/**
	 * Validates that spacing values are not negative.
	 */
	private function validateSpacing():Void
	{
		if (padding < 0) padding = 0;
		if (margin < 0) margin = 0;
		if (columnGap < 0) columnGap = 0;
		if (rowGap < 0) rowGap = 0;
	}
	
	/**
	 * Called when screen size changes.
	 */
	public function onResize(width:Int, height:Int):Void
	{
		calculateLayout();
	}
	
	/**
	 * Recalculates layout dimensions.
	 */
	public function calculateLayout():Void
	{
		_contentWidth = screenWidth - (padding * 2);
		_contentHeight = screenHeight - (padding * 2);
		
		_safeContentWidth = screenWidth - (padding * 2) - safeAreaLeft - safeAreaRight;
		_safeContentHeight = screenHeight - (padding * 2) - safeAreaTop - safeAreaBottom;
		
		// Ensure safe content dimensions are not negative
		if (_safeContentWidth < 0) _safeContentWidth = 0;
		if (_safeContentHeight < 0) _safeContentHeight = 0;
		if (_contentWidth < 0) _contentWidth = 0;
		if (_contentHeight < 0) _contentHeight = 0;
	}
	
	// Screen size getters
	private function get_screenWidth():Float
	{
		return FlxG.width;
	}
	
	private function get_screenHeight():Float
	{
		return FlxG.height;
	}
	
	// Device type detection
	public function getDeviceType():DeviceType
	{
		if (screenWidth < BREAKPOINT_MOBILE)
			return MOBILE;
		else if (screenWidth < BREAKPOINT_TABLET)
			return TABLET;
		else
			return DESKTOP;
	}
	
	public function isMobile():Bool
	{
		return screenWidth < BREAKPOINT_MOBILE;
	}
	
	public function isTablet():Bool
	{
		return screenWidth >= BREAKPOINT_MOBILE && screenWidth < BREAKPOINT_TABLET;
	}
	
	public function isDesktop():Bool
	{
		return screenWidth >= BREAKPOINT_TABLET;
	}
	
	public function isPortrait():Bool
	{
		return screenHeight > screenWidth;
	}
	
	public function isLandscape():Bool
	{
		return screenWidth > screenHeight;
	}
	
	// Column layout helpers
	public function getColumnWidth(columns:Int):Float
	{
		columns = validateColumnSpan(columns, 1, 12);
		return calculateColumnWidth(columns, _contentWidth, columnGap);
	}
	
	public function getColumnX(columns:Int, index:Int):Float
	{
		var colWidth = getColumnWidth(columns);
		return padding + (colWidth + columnGap) * index;
	}
	
	public function getRowY(rowIndex:Int, rowHeight:Float):Float
	{
		return padding + (rowHeight + rowGap) * rowIndex;
	}
	
	// Grid system (12-column)
	public function getGridWidth(span:Int):Float
	{
		span = validateColumnSpan(span, 1, GRID_COLUMNS);
		
		var colWidth = calculateColumnWidth(GRID_COLUMNS, _contentWidth, columnGap);
		var spanGap = columnGap * (span - 1);
		
		var result = colWidth * span + spanGap;
		return result < 0 ? 0 : result;
	}
	
	public function getGridX(column:Int):Float
	{
		column = validateColumnSpan(column, 0, GRID_COLUMNS - 1);
		
		var colWidth = calculateColumnWidth(GRID_COLUMNS, _contentWidth, columnGap);
		
		var result = padding + (colWidth + columnGap) * column;
		return result < 0 ? 0 : result;
	}
	
	// Centering helpers
	public function getCenterX(elementWidth:Float):Float
	{
		return (screenWidth - elementWidth) / 2;
	}
	
	public function getCenterY(elementHeight:Float):Float
	{
		return (screenHeight - elementHeight) / 2;
	}
	
	// Responsive scaling
	public function getResponsiveFontSize(baseSize:Int):Int
	{
		if (isMobile())
			return Std.int(baseSize * 0.75);
		else if (isTablet())
			return Std.int(baseSize * 0.9);
		else
			return baseSize;
	}
	
	public function getResponsiveSpacing(baseSpacing:Float):Float
	{
		if (isMobile())
			return baseSpacing * 0.5;
		else if (isTablet())
			return baseSpacing * 0.75;
		else
			return baseSpacing;
	}
	
	public function getResponsiveScale():Float
	{
		if (isMobile())
			return 0.75;
		else if (isTablet())
			return 0.9;
		else
			return 1.0;
	}
	
	// Content dimensions
	public function getContentWidth():Float
	{
		return _contentWidth;
	}
	
	public function getContentHeight():Float
	{
		return _contentHeight;
	}
	
	public function getSafeContentWidth():Float
	{
		return _safeContentWidth;
	}
	
	public function getSafeContentHeight():Float
	{
		return _safeContentHeight;
	}
	
	public function getContentX():Float
	{
		return padding;
	}
	
	public function getContentY():Float
	{
		return padding;
	}
	
	public function getSafeContentX():Float
	{
		return padding + safeAreaLeft;
	}
	
	public function getSafeContentY():Float
	{
		return padding + safeAreaTop;
	}
	
	// Aspect ratio helpers
	public function maintainAspectRatio(targetWidth:Float, targetHeight:Float, maxWidth:Float, maxHeight:Float):{width:Float, height:Float}
	{
		// Validate inputs to prevent division by zero or invalid values
		if (targetHeight <= 0 || targetWidth <= 0 || maxWidth <= 0 || maxHeight <= 0)
			return {width: maxWidth > 0 ? maxWidth : 0, height: maxHeight > 0 ? maxHeight : 0};
		
		var ratio = targetWidth / targetHeight;
		var width = maxWidth;
		var height = width / ratio;
		
		// Adjust if height exceeds maximum (single limit check, no clamp needed)
		if (height > maxHeight)
		{
			height = maxHeight;
			width = height * ratio;
		}
		
		return {width: width, height: height};
	}
	
	// Constraints helpers
	public function clampWidth(width:Float, ?min:Float, ?max:Float):Float
	{
		return clampValue(width, min, max);
	}
	
	public function clampHeight(height:Float, ?min:Float, ?max:Float):Float
	{
		return clampValue(height, min, max);
	}
	
	// Additional utility methods
	
	/**
	 * Updates spacing values and recalculates layout.
	 * @param newPadding New padding value (optional)
	 * @param newMargin New margin value (optional)
	 * @param newColumnGap New column gap value (optional)
	 * @param newRowGap New row gap value (optional)
	 */
	public function updateSpacing(?newPadding:Float, ?newMargin:Float, ?newColumnGap:Float, ?newRowGap:Float):Void
	{
		if (newPadding != null) padding = newPadding;
		if (newMargin != null) margin = newMargin;
		if (newColumnGap != null) columnGap = newColumnGap;
		if (newRowGap != null) rowGap = newRowGap;
		
		validateSpacing();
		calculateLayout();
	}
	
	/**
	 * Resets safe area values to zero.
	 */
	public function resetSafeAreas():Void
	{
		safeAreaTop = 0;
		safeAreaBottom = 0;
		safeAreaLeft = 0;
		safeAreaRight = 0;
		calculateLayout();
	}
	
	/**
	 * Sets safe area values and recalculates layout.
	 * @param top Top safe area
	 * @param bottom Bottom safe area
	 * @param left Left safe area
	 * @param right Right safe area
	 */
	public function setSafeAreas(top:Float, bottom:Float, left:Float, right:Float):Void
	{
		safeAreaTop = top >= 0 ? top : 0;
		safeAreaBottom = bottom >= 0 ? bottom : 0;
		safeAreaLeft = left >= 0 ? left : 0;
		safeAreaRight = right >= 0 ? right : 0;
		calculateLayout();
	}
	
	/**
	 * Gets responsive dimensions for an element based on device type.
	 * @param baseWidth Base width for desktop
	 * @param baseHeight Base height for desktop
	 * @return Object with width and height scaled for current device
	 */
	public function getResponsiveDimensions(baseWidth:Float, baseHeight:Float):{width:Float, height:Float}
	{
		var scale = getResponsiveScale();
		return {width: baseWidth * scale, height: baseHeight * scale};
	}
	
	/**
	 * Calculates total spacing needed for a number of items.
	 * @param itemCount Number of items
	 * @param gap Gap between items
	 * @return Total spacing (gaps only, not including items)
	 */
	public function calculateTotalSpacing(itemCount:Int, gap:Float):Float
	{
		if (itemCount <= 1) return 0;
		return gap * (itemCount - 1);
	}
	
	/**
	 * Positions an element in a grid cell.
	 * @param column Grid column (0-11)
	 * @param row Row index
	 * @param span Column span (1-12)
	 * @param rowHeight Height of each row
	 * @return Object with x, y, width, height for the element
	 */
	public function getGridCellBounds(column:Int, row:Int, span:Int, rowHeight:Float):{x:Float, y:Float, width:Float, height:Float}
	{
		return {
			x: getGridX(column),
			y: getRowY(row, rowHeight),
			width: getGridWidth(span),
			height: rowHeight
		};
	}
	
	/**
	 * Gets the maximum number of columns that can fit in the available width.
	 * @param minColumnWidth Minimum width for each column
	 * @return Maximum number of columns
	 */
	public function getMaxColumns(minColumnWidth:Float):Int
	{
		if (minColumnWidth <= 0) return 1;
		
		var availableWidth = _contentWidth;
		var columns = 1;
		
		while (columns < GRID_COLUMNS)
		{
			var width = calculateColumnWidth(columns + 1, availableWidth, columnGap);
			if (width < minColumnWidth) break;
			columns++;
		}
		
		return columns;
	}
}
