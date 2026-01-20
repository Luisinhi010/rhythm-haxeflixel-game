package core.utils;

import core.utils.MathUtil;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;

/**
 * Sprite utilities for common operations.
 * Following Single Responsibility Principle.
 */
class SpriteUtil
{
	/**
	 * Validates that a sprite is not null.
	 * Helper to eliminate code duplication in null checks.
	 * @param sprite The sprite to validate
	 * @return True if sprite is valid (not null), false otherwise
	 */
	private static inline function isValid(sprite:FlxSprite):Bool
	{
		return sprite != null;
	}
	
	/**
	 * Validates dimensions to ensure they are positive.
	 * @param width The width to validate
	 * @param height The height to validate
	 * @return Object with validated width and height
	 */
	private static inline function validateDimensions(width:Int, height:Int):{width:Int, height:Int}
	{
		var validWidth = width;
		var validHeight = height;
		
		if (validWidth < 1) validWidth = 1;
		if (validHeight < 1) validHeight = 1;
		
		return {width: validWidth, height: validHeight};
	}
	
	/**
	 * Creates a solid-color sprite using GPU-efficient technique.
	 * Uses a 1x1 texture with scaling and shader-based coloring.
	 * This technique uses minimal memory (only 1 pixel) and lets the GPU
	 * handle scaling and coloring via shaders.
	 * 
	 * @param width The desired width of the sprite (minimum 1)
	 * @param height The desired height of the sprite (minimum 1)
	 * @param color The color of the sprite
	 * @param alpha The alpha transparency (0.0 - 1.0)
	 * @return A new FlxSprite with the specified dimensions and color
	 */
	public static function createColoredSprite(width:Int, height:Int, color:FlxColor = FlxColor.WHITE, alpha:Float = 1.0):FlxSprite
	{
		var dims = validateDimensions(width, height);
		
		var sprite = new FlxSprite();
		sprite.makeGraphic(1, 1, FlxColor.WHITE); // Only 1 pixel - GPU efficient
		sprite.setGraphicSize(dims.width, dims.height);
		sprite.updateHitbox();
		sprite.color = color; // GPU shader handles the color
		sprite.alpha = alpha;
		return sprite;
	}
	
	/**
	 * Shorthand alias for createColoredSprite.
	 * @param width The desired width of the sprite (minimum 1)
	 * @param height The desired height of the sprite (minimum 1)
	 * @param color The color of the sprite
	 * @param alpha The alpha transparency (0.0 - 1.0)
	 * @return A new FlxSprite with the specified dimensions and color
	 */
	public static inline function createColored(width:Int, height:Int, color:FlxColor = FlxColor.WHITE, alpha:Float = 1.0):FlxSprite
	{
		return createColoredSprite(width, height, color, alpha);
	}
	
	/**
	 * Resizes an existing sprite efficiently without recreating graphics.
	 * @param sprite The sprite to resize
	 * @param width The new width (minimum 1)
	 * @param height The new height (minimum 1)
	 */
	public static function resize(sprite:FlxSprite, width:Int, height:Int):Void
	{
		if (!isValid(sprite))
			return;
		
		// Validate dimensions
		var dims = validateDimensions(width, height);
		
		sprite.setGraphicSize(dims.width, dims.height);
		sprite.updateHitbox();
	}
	
	/**
	 * Sets the position of a sprite (convenience method).
	 * @param sprite The sprite to position
	 * @param x The X coordinate
	 * @param y The Y coordinate
	 */
	public static inline function setPosition(sprite:FlxSprite, x:Float, y:Float):Void
	{
		if (!isValid(sprite))
			return;
		
		sprite.x = x;
		sprite.y = y;
	}
	
	/**
	 * Centers a sprite on the screen.
	 * Delegates to FlxSprite's built-in screenCenter method.
	 * @param sprite The sprite to center
	 * @param axes Which axes to center on (default: both X and Y)
	 */
	public static inline function screenCenter(sprite:FlxSprite, ?axes:FlxAxes):Void
	{
		if (!isValid(sprite))
			return;
		
		sprite.screenCenter(axes);
	}
	
	/**
	 * Sets the alpha (transparency) of a sprite.
	 * @param sprite The sprite to modify
	 * @param alpha The alpha value (0.0 - 1.0, clamped automatically)
	 */
	public static inline function setAlpha(sprite:FlxSprite, alpha:Float):Void
	{
		if (!isValid(sprite))
			return;
		
		sprite.alpha = alpha;
	}
	
	/**
	 * Sets the color of a sprite.
	 * @param sprite The sprite to modify
	 * @param color The new color
	 */
	public static inline function setColor(sprite:FlxSprite, color:FlxColor):Void
	{
		if (!isValid(sprite))
			return;
		
		sprite.color = color;
	}
	
	/**
	 * Makes a sprite visible.
	 * @param sprite The sprite to show
	 */
	public static inline function show(sprite:FlxSprite):Void
	{
		if (!isValid(sprite))
			return;
		
		sprite.visible = true;
	}
	
	/**
	 * Makes a sprite invisible.
	 * @param sprite The sprite to hide
	 */
	public static inline function hide(sprite:FlxSprite):Void
	{
		if (!isValid(sprite))
			return;
		
		sprite.visible = false;
	}
	
	/**
	 * Toggles sprite visibility.
	 * @param sprite The sprite to toggle
	 * @return The new visibility state
	 */
	public static inline function toggleVisibility(sprite:FlxSprite):Bool
	{
		if (!isValid(sprite))
			return false;
		
		sprite.visible = !sprite.visible;
		return sprite.visible;
	}
	
	/**
	 * Gets the bounds of a sprite as a rectangle object.
	 * @param sprite The sprite to get bounds from
	 * @return Object with x, y, width, height properties, or null if sprite is invalid
	 */
	public static function getBounds(sprite:FlxSprite):Null<{x:Float, y:Float, width:Float, height:Float}>
	{
		if (!isValid(sprite))
			return null;
		
		return {
			x: sprite.x,
			y: sprite.y,
			width: sprite.width,
			height: sprite.height
		};
	}
	
	/**
	 * Sets the size of a sprite (width and height).
	 * More efficient than calling setGraphicSize when you know exact pixel dimensions.
	 * @param sprite The sprite to resize
	 * @param width The new width
	 * @param height The new height
	 */
	public static inline function setSize(sprite:FlxSprite, width:Float, height:Float):Void
	{
		if (!isValid(sprite))
			return;
		
		sprite.width = width;
		sprite.height = height;
	}
	
	/**
	 * Offsets a sprite's position by the given amounts.
	 * @param sprite The sprite to offset
	 * @param offsetX The X offset to apply
	 * @param offsetY The Y offset to apply
	 */
	public static inline function offset(sprite:FlxSprite, offsetX:Float, offsetY:Float):Void
	{
		if (!isValid(sprite))
			return;
		
		sprite.x += offsetX;
		sprite.y += offsetY;
	}
	
	/**
	 * Checks if a sprite is on screen (visible area).
	 * Delegates to FlxSprite's built-in isOnScreen method.
	 * @param sprite The sprite to check
	 * @return True if sprite is on screen, false otherwise
	 */
	public static inline function isOnScreen(sprite:FlxSprite):Bool
	{
		if (!isValid(sprite))
			return false;
		
		return sprite.isOnScreen();
	}
	
	/**
	 * Resets a sprite to its default state.
	 * Sets position to (0, 0), alpha to 1, visibility to true, and color to white.
	 * @param sprite The sprite to reset
	 */
	public static function reset(sprite:FlxSprite):Void
	{
		if (!isValid(sprite))
			return;
		
		sprite.x = 0;
		sprite.y = 0;
		sprite.alpha = 1;
		sprite.visible = true;
		sprite.color = FlxColor.WHITE;
	}
	// ==================== SHADER METHODS ====================

	/**
	 * Creates a sprite with a gradient shader applied.
	 * Uses GPU shader for smooth gradients without bitmap memory overhead.
	 * Falls back to solid color if shader loading fails.
	 * 
	 * @param width The desired width of the sprite (minimum 1)
	 * @param height The desired height of the sprite (minimum 1)
	 * @param color1 Start color (top for vertical, left for horizontal)
	 * @param color2 End color (bottom for vertical, right for horizontal)
	 * @param vertical True for vertical gradient (default), false for horizontal
	 * @param alpha The alpha transparency (0.0 - 1.0)
	 * @return A new FlxSprite with gradient shader applied
	 */
	public static function createGradientSprite(width:Int, height:Int, color1:FlxColor, color2:FlxColor, vertical:Bool = true, alpha:Float = 1.0):FlxSprite
	{
		// Create base sprite with white color (shader will apply gradient)
		var sprite = createColoredSprite(width, height, FlxColor.WHITE, alpha);

		// Try to apply gradient shader
		if (!applyGradientShader(sprite, color1, color2, vertical))
		{
			// Fallback: use the first color as solid color
			#if debug
			trace("[SpriteUtil] Gradient shader failed, using solid color fallback");
			#end
			sprite.color = color1;
		}

		return sprite;
	}

	/**
	 * Applies a gradient shader to an existing sprite.
	 * @param sprite The sprite to apply gradient to
	 * @param color1 Start color (top for vertical, left for horizontal)
	 * @param color2 End color (bottom for vertical, right for horizontal)
	 * @param vertical True for vertical gradient, false for horizontal
	 * @return True if shader was applied successfully, false otherwise
	 */
	public static function applyGradientShader(sprite:FlxSprite, color1:FlxColor, color2:FlxColor, vertical:Bool = true):Bool
	{
		if (!isValid(sprite))
			return false;

		// Load gradient shader source
		var shaderSource = backend.Paths.getShaderSource("gradient");
		if (shaderSource == null)
		{
			#if debug
			trace("[SpriteUtil] Failed to load gradient shader source");
			#end
			return false;
		}

		try
		{
			// Create runtime shader
			var shader = new flixel.addons.display.FlxRuntimeShader(shaderSource);

			// Set uniform values
			shader.setFloatArray("color1", [color1.redFloat, color1.greenFloat, color1.blueFloat, color1.alphaFloat]);
			shader.setFloatArray("color2", [color2.redFloat, color2.greenFloat, color2.blueFloat, color2.alphaFloat]);
			shader.setFloat("vertical", vertical ? 1.0 : 0.0);

			// Apply shader to sprite
			sprite.shader = shader;
			return true;
		}
		catch (e:Dynamic)
		{
			#if debug
			trace("[SpriteUtil] Failed to apply gradient shader: " + Std.string(e));
			#end
			return false;
		}
	}

	/**
	 * Updates the colors of an existing gradient shader on a sprite.
	 * More efficient than recreating the shader - just updates uniforms.
	 * @param sprite The sprite with gradient shader
	 * @param color1 New start color
	 * @param color2 New end color
	 * @param vertical New direction (optional, pass null to keep current)
	 * @return True if uniforms were updated, false if no shader exists
	 */
	public static function updateGradientColors(sprite:FlxSprite, color1:FlxColor, color2:FlxColor, ?vertical:Null<Bool>):Bool
	{
		if (!isValid(sprite) || sprite.shader == null)
			return false;

		try
		{
			// Validate that shader is the correct type before casting
			if (!Std.isOfType(sprite.shader, flixel.addons.display.FlxRuntimeShader))
			{
				#if debug
				trace("[SpriteUtil] Shader is not FlxRuntimeShader type");
				#end
				return false;
			}

			var shader = cast(sprite.shader, flixel.addons.display.FlxRuntimeShader);
			if (shader == null)
				return false;

			shader.setFloatArray("color1", [color1.redFloat, color1.greenFloat, color1.blueFloat, color1.alphaFloat]);
			shader.setFloatArray("color2", [color2.redFloat, color2.greenFloat, color2.blueFloat, color2.alphaFloat]);

			if (vertical != null)
				shader.setFloat("vertical", vertical ? 1.0 : 0.0);

			return true;
		}
		catch (e:Dynamic)
		{
			#if debug
			trace("[SpriteUtil] Failed to update gradient colors: " + Std.string(e));
			#end
			return false;
		}
	}

	/**
	 * Applies a shader to a sprite by name.
	 * @param sprite The sprite to apply shader to
	 * @param shaderName The name of the shader file (without .glsl extension)
	 * @return True if shader was applied successfully, false otherwise
	 */
	public static function applyShader(sprite:FlxSprite, shaderName:String):Bool
	{
		if (!isValid(sprite))
			return false;

		var shaderSource = backend.Paths.getShaderSource(shaderName);
		if (shaderSource == null)
		{
			#if debug
			trace("[SpriteUtil] Failed to load shader: " + shaderName);
			#end
			return false;
		}

		try
		{
			var shader = new flixel.addons.display.FlxRuntimeShader(shaderSource);
			sprite.shader = shader;
			return true;
		}
		catch (e:Dynamic)
		{
			#if debug
			trace("[SpriteUtil] Failed to apply shader " + shaderName + ": " + Std.string(e));
			#end
			return false;
		}
	}

	/**
	 * Removes shader from a sprite.
	 * @param sprite The sprite to remove shader from
	 */
	public static inline function removeShader(sprite:FlxSprite):Void
	{
		if (!isValid(sprite))
			return;

		sprite.shader = null;
	}

	/**
	 * Checks if a sprite has a shader applied.
	 * @param sprite The sprite to check
	 * @return True if sprite has a shader, false otherwise
	 */
	public static inline function hasShader(sprite:FlxSprite):Bool
	{
		return isValid(sprite) && sprite.shader != null;
	}
}
