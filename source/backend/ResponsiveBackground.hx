package backend;

import core.utils.MathUtil;
import core.utils.SpriteUtil;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;

/**
 * Automatic responsive background management system.
 * Supports solid colors, gradients, images, and parallax scrolling.
 */
class ResponsiveBackground extends FlxTypedGroup<FlxSprite>
{
	// Background layers
	private var layers:Array<BackgroundLayer>;
	
	// Settings
	private var autoResize:Bool = true;
	
	// Cache of last screen size
	private var lastWidth:Int = 0;
	private var lastHeight:Int = 0;
	
	public function new()
	{
		super();
		layers = [];
		lastWidth = FlxG.width;
		lastHeight = FlxG.height;
	}
	
	/**
	 * Creates a solid color background.
	 * @param color Background color
	 * @param alpha Transparency (0-1)
	 */
	public function createSolid(color:FlxColor = FlxColor.WHITE, alpha:Float = 1.0):FlxSprite
	{
		clear();
		alpha = clampAlpha(alpha);
		
		var bg = createSprite(color, alpha);
		addLayer(bg, "solid", 0, 0, null, SOLID);
		
		return bg;
	}
	
	/**
	 * Creates a gradient background.
	 * Uses GPU shaders.
	 * @param color1 First color (top for vertical, left for horizontal)
	 * @param color2 Second color (bottom for vertical, right for horizontal)
	 * @param vertical True for vertical gradient, false for horizontal
	 * @param alpha Transparency (0-1)
	 */
	private function createGradient(color1:FlxColor, color2:FlxColor, vertical:Bool, alpha:Float):FlxSprite
	{
		clear();
		alpha = clampAlpha(alpha);

		var bg = new FlxSprite();
		updateGradient(bg, color1, color2, vertical);
		bg.alpha = alpha;

		addLayer(bg, "gradient", 0, 0, null, GRADIENT, vertical, color1, color2);

		return bg;
	}
	
	/**
	 * Creates a vertical gradient background.
	 * @param topColor Top color
	 * @param bottomColor Bottom color
	 * @param alpha Transparency (0-1)
	 */
	public function createVerticalGradient(topColor:FlxColor, bottomColor:FlxColor, alpha:Float = 1.0):FlxSprite
	{
		return createGradient(topColor, bottomColor, true, alpha);
	}
	
	/**
	 * Creates a horizontal gradient background.
	 * @param leftColor Left color
	 * @param rightColor Right color
	 * @param alpha Transparency (0-1)
	 */
	public function createHorizontalGradient(leftColor:FlxColor, rightColor:FlxColor, alpha:Float = 1.0):FlxSprite
	{
		return createGradient(leftColor, rightColor, false, alpha);
	}
	
	/**
	 * Creates an image background.
	 * @param imagePath Image name (without extension, uses Paths)
	 * @param scaleMode How to scale the image (FIT, FILL, STRETCH)
	 * @param alpha Transparency (0-1)
	 */
	public function createImage(imagePath:String, scaleMode:ScaleMode = FIT, alpha:Float = 1.0):FlxSprite
	{
		clear();
		alpha = clampAlpha(alpha);
		
		var bg = new FlxSprite();
		bg.loadGraphic(Paths.getImage(imagePath));
		bg.alpha = alpha;
		
		applyScaleMode(bg, scaleMode);
		addLayer(bg, "image", 0, 0, scaleMode, IMAGE);
		
		return bg;
	}
	
	/**
	 * Adds a vertical gradient layer without clearing previous layers.
	 * Use this for creating multiple gradient layers (e.g., animated gradients).
	 * Uses GPU shaders.
	 * @param topColor Top color
	 * @param bottomColor Bottom color
	 * @param alpha Transparency (0-1)
	 * @param scrollFactorX Optional horizontal scroll factor
	 * @param scrollFactorY Optional vertical scroll factor
	 */
	public function addVerticalGradientLayer(topColor:FlxColor, bottomColor:FlxColor, alpha:Float = 1.0, scrollFactorX:Float = 0, scrollFactorY:Float = 0):FlxSprite
	{
		alpha = clampAlpha(alpha);

		var bg = new FlxSprite();
		updateGradient(bg, topColor, bottomColor, true);
		bg.alpha = alpha;

		addLayer(bg, "gradient_layer_" + layers.length, scrollFactorX, scrollFactorY, null, GRADIENT, true, topColor, bottomColor);

		return bg;
	}
	
	/**
	 * Adds a horizontal gradient layer without clearing previous layers.
	 * Use this for creating multiple gradient layers (e.g., animated gradients).
	 * Uses GPU shaders.
	 * @param leftColor Left color
	 * @param rightColor Right color
	 * @param alpha Transparency (0-1)
	 * @param scrollFactorX Optional horizontal scroll factor
	 * @param scrollFactorY Optional vertical scroll factor
	 */
	public function addHorizontalGradientLayer(leftColor:FlxColor, rightColor:FlxColor, alpha:Float = 1.0, scrollFactorX:Float = 0, scrollFactorY:Float = 0):FlxSprite
	{
		alpha = clampAlpha(alpha);

		var bg = new FlxSprite();
		updateGradient(bg, leftColor, rightColor, false);
		bg.alpha = alpha;

		addLayer(bg, "gradient_layer_" + layers.length, scrollFactorX, scrollFactorY, null, GRADIENT, false, leftColor, rightColor);

		return bg;
	}
	
	/**
	 * Adds a parallax layer to the background.
	 * @param imagePath Image name
	 * @param scrollFactor Movement factor (0-1, where 0 = fixed, 1 = moves with camera)
	 * @param scaleMode How to scale the image
	 * @param alpha Transparency
	 */
	public function addParallaxLayer(imagePath:String, scrollFactor:Float = 0.5, scaleMode:ScaleMode = FIT, alpha:Float = 1.0):FlxSprite
	{
		scrollFactor = clampScrollFactor(scrollFactor);
		alpha = clampAlpha(alpha);
		
		var layer = new FlxSprite();
		layer.loadGraphic(Paths.getImage(imagePath));
		layer.alpha = alpha;
		
		applyScaleMode(layer, scaleMode);
		addLayer(layer, "parallax_" + imagePath, scrollFactor, scrollFactor, scaleMode, PARALLAX);
		
		return layer;
	}
	
	/**
	 * Adds a solid color layer with parallax.
	 * @param color Layer color
	 * @param scrollFactor Movement factor
	 * @param alpha Transparency
	 */
	public function addParallaxColor(color:FlxColor, scrollFactor:Float = 0.5, alpha:Float = 0.5):FlxSprite
	{
		scrollFactor = clampScrollFactor(scrollFactor);
		alpha = clampAlpha(alpha);
		
		var layer = createSprite(color, alpha);
		addLayer(layer, "parallax_color", scrollFactor, scrollFactor, null, PARALLAX);
		
		return layer;
	}
	
	/**
	 * Removes all background layers.
	 */
	override public function clear():Void
	{
		while (layers.length > 0)
		{
			var layer = layers.pop();
			if (layer.sprite != null)
			{
				remove(layer.sprite, true);
				layer.sprite.destroy();
			}
			if (layer.scrollFactor != null)
			{
				layer.scrollFactor.put();
			}
		}
		super.clear();
	}
	
	/**
	 * Updates background size when screen is resized.
	 * Called automatically if autoResize = true.
	 */
	public function onResize(width:Int, height:Int):Void
	{
		if (!autoResize) return;
		
		lastWidth = width;
		lastHeight = height;
		
		for (layer in layers)
		{
			if (layer.sprite == null) continue;
			
			switch (layer.type)
			{
				case SOLID:
					updateSolidSize(layer.sprite, width, height);
					
				case GRADIENT:
					resizeGradient(layer);
					
				case IMAGE | PARALLAX:
					// Reapply scale mode
					if (layer.scaleMode != null)
					{
						applyScaleMode(layer.sprite, layer.scaleMode);
					}
			}
		}
	}
	
	/**
	 * Updates layers with parallax.
	 */
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		// Check if screen size changed
		if (autoResize && (FlxG.width != lastWidth || FlxG.height != lastHeight))
		{
			onResize(FlxG.width, FlxG.height);
		}
	}
	
	/**
	 * Gets a specific layer by name.
	 * @param name Layer name
	 * @return The layer sprite, or null if not found
	 */
	public function getLayer(name:String):FlxSprite
	{
		for (layer in layers)
		{
			if (layer.name == name)
				return layer.sprite;
		}
		return null;
	}
	
	/**
	 * Removes a specific layer by name.
	 * @param name Layer name
	 * @return True if layer was found and removed
	 */
	public function removeLayer(name:String):Bool
	{
		for (i in 0...layers.length)
		{
			if (layers[i].name == name)
			{
				var layer = layers[i];
				if (layer.sprite != null)
				{
					remove(layer.sprite, true);
					layer.sprite.destroy();
				}
				if (layer.scrollFactor != null)
				{
					layer.scrollFactor.put();
				}
				layers.splice(i, 1);
				return true;
			}
		}
		return false;
	}
	
	/**
	 * Sets the alpha of a specific layer.
	 * @param name Layer name
	 * @param alpha New alpha value (0-1)
	 * @return True if layer was found
	 */
	public function setLayerAlpha(name:String, alpha:Float):Bool
	{
		var sprite = getLayer(name);
		if (sprite != null)
		{
			sprite.alpha = clampAlpha(alpha);
			return true;
		}
		return false;
	}
	
	/**
	 * Sets whether the background should resize automatically.
	 */
	public function setAutoResize(value:Bool):Void
	{
		autoResize = value;
	}
	
	/**
	 * Gets the number of layers.
	 */
	public function getLayerCount():Int
	{
		return layers.length;
	}
	
	/**
	 * Checks if a layer exists.
	 * @param name Layer name
	 * @return True if layer exists
	 */
	public function hasLayer(name:String):Bool
	{
		return getLayer(name) != null;
	}
	
	// Private helper methods
	
	/**
	 * Clamps alpha value to valid range (0-1).
	 * Delegates to MathUtil for consistent clamping behavior.
	 */
	private inline function clampAlpha(alpha:Float):Float
	{
		return MathUtil.clamp(alpha, 0, 1);
	}
	
	/**
	 * Clamps scroll factor to valid range (0-1).
	 * Delegates to MathUtil for consistent clamping behavior.
	 */
	private inline function clampScrollFactor(factor:Float):Float
	{
		return MathUtil.clamp(factor, 0, 1);
	}
	
	/**
	 * Resizes a gradient layer preserving its colors and orientation.
	 * If using shader gradients, this is nearly instantaneous (just resize sprite).
	 * If using fallback bitmap gradients, recreates the gradient.
	 */
	private function resizeGradient(layer:BackgroundLayer):Void
	{
		if (layer.sprite == null)
			return;

		var oldAlpha = layer.sprite.alpha;
		var vertical = layer.gradientVertical != null ? layer.gradientVertical : true;
		var width = FlxG.width;
		var height = FlxG.height;

		// If using shader gradient, just resize the sprite - shader handles the rest
		if (SpriteUtil.hasShader(layer.sprite))
		{
			// Shader gradient: just resize, shader recalculates gradient automatically
			layer.sprite.setGraphicSize(width, height);
			layer.sprite.updateHitbox();
			layer.sprite.alpha = oldAlpha;
			return;
		}

		// If no stored colors and no shader, can't recreate gradient reliably
		if (layer.gradientColor1 == null || layer.gradientColor2 == null)
		{
			if (layer.sprite.pixels == null)
			{
				#if debug
				trace("[ResponsiveBackground] Cannot resize gradient without colors or pixels");
				#end
				return;
			}
		}

		// Fallback: bitmap gradient - need to get colors and recreate
		if (layer.sprite.pixels == null)
			return;

		var color1:FlxColor;
		var color2:FlxColor;

		// Try to get stored colors first (more reliable)
		if (layer.gradientColor1 != null && layer.gradientColor2 != null)
		{
			color1 = layer.gradientColor1;
			color2 = layer.gradientColor2;
		}
		else
		{
			// Extract colors from pixels as fallback
			if (vertical)
			{
				color1 = layer.sprite.pixels.getPixel32(0, 0);
				color2 = layer.sprite.pixels.getPixel32(0, layer.sprite.pixels.height - 1);
			}
			else
			{
				color1 = layer.sprite.pixels.getPixel32(0, 0);
				color2 = layer.sprite.pixels.getPixel32(layer.sprite.pixels.width - 1, 0);
			}
		}

		updateGradient(layer.sprite, color1, color2, vertical);
		layer.sprite.alpha = oldAlpha;
	}
	
	private function createSprite(color:FlxColor, alpha:Float):FlxSprite
	{
		return SpriteUtil.createColoredSprite(FlxG.width, FlxG.height, color, alpha);
	}
	
	private function updateSolidSize(sprite:FlxSprite, width:Int, height:Int):Void
	{
		SpriteUtil.resize(sprite, width, height);
	}
	
	private function updateGradient(sprite:FlxSprite, color1:FlxColor, color2:FlxColor, vertical:Bool):Void
	{
		var width = FlxG.width;
		var height = FlxG.height;

		// Try GPU shader-based gradient first (much faster)
		if (sprite.pixels == null || sprite.width != width || sprite.height != height)
		{
			// Create base sprite if needed
			sprite.makeGraphic(1, 1, FlxColor.WHITE);
			sprite.setGraphicSize(width, height);
			sprite.updateHitbox();
		}

		// Apply shader gradient
		if (SpriteUtil.applyGradientShader(sprite, color1, color2, vertical))
		{
			// Shader applied successfully - GPU handles the gradient
			return;
		}

		// Fallback: Use FlxGradient bitmap (slower)
		#if debug
		trace("[ResponsiveBackground] Shader gradient failed, using FlxGradient fallback");
		#end
		useFlxGradientFallback(sprite, color1, color2, vertical, width, height);
	}

	/**
	 * Helper method to apply FlxGradient bitmap fallback.
	 * Extracted for reusability and to avoid code duplication.
	 */
	private function useFlxGradientFallback(sprite:FlxSprite, color1:FlxColor, color2:FlxColor, vertical:Bool, width:Int, height:Int):Void
	{
		var tempSprite:FlxSprite;
		if (vertical)
		{
			tempSprite = FlxGradient.createGradientFlxSprite(width, height, [color1, color2]);
		}
		else
		{
			tempSprite = FlxGradient.createGradientFlxSprite(width, height, [color1, color2], 1, 0, true);
		}
		sprite.loadGraphic(tempSprite.graphic);
		tempSprite.destroy();
	}
	
	private function applyScaleMode(sprite:FlxSprite, mode:ScaleMode):Void
	{
		if (sprite.graphic == null) return;
		
		var screenWidth = FlxG.width;
		var screenHeight = FlxG.height;
		var imageWidth = sprite.graphic.width;
		var imageHeight = sprite.graphic.height;
		
		switch (mode)
		{
			case FIT:
				// Fit maintaining aspect ratio (fits on screen)
				var scaleX = screenWidth / imageWidth;
				var scaleY = screenHeight / imageHeight;
				var scale = Math.min(scaleX, scaleY);
				sprite.scale.set(scale, scale);
				sprite.updateHitbox();
				sprite.screenCenter();
				
			case FILL:
				// Fill screen maintaining aspect ratio (may crop)
				var scaleX = screenWidth / imageWidth;
				var scaleY = screenHeight / imageHeight;
				var scale = Math.max(scaleX, scaleY);
				sprite.scale.set(scale, scale);
				sprite.updateHitbox();
				sprite.screenCenter();
				
			case STRETCH:
				// Stretch to fill screen (ignores aspect ratio)
				sprite.setGraphicSize(screenWidth, screenHeight);
				sprite.updateHitbox();
				
			case NONE:
				// Keep original size
				sprite.scale.set(1, 1);
				sprite.updateHitbox();
		}
	}
	
	private function addLayer(sprite:FlxSprite, name:String, scrollFactorX:Float, scrollFactorY:Float, ?scaleMode:ScaleMode, type:BackgroundType,
			?gradientVertical:Bool, ?gradientColor1:FlxColor, ?gradientColor2:FlxColor):Void
	{
		if (sprite == null)
		{
			#if debug
			trace("[ResponsiveBackground] Attempted to add null sprite layer: " + name);
			#end
			return;
		}

		sprite.scrollFactor.set(scrollFactorX, scrollFactorY);

		var layer:BackgroundLayer = {
			sprite: sprite,
			name: name,
			scrollFactor: FlxPoint.get(scrollFactorX, scrollFactorY),
			scaleMode: scaleMode,
			type: type,
			gradientVertical: gradientVertical,
			gradientColor1: gradientColor1,
			gradientColor2: gradientColor2
		};

		layers.push(layer);
		add(sprite);
	}
	
	override public function destroy():Void
	{
		if (layers != null)
		{
			clear();
			layers = null;
		}
		super.destroy();
	}
}

/**
 * Data structure for a background layer.
 */
typedef BackgroundLayer =
{
	sprite:FlxSprite,
	name:String,
	scrollFactor:FlxPoint,
	?scaleMode:ScaleMode,
	type:BackgroundType,
	?gradientVertical:Bool,
	?gradientColor1:FlxColor,
	?gradientColor2:FlxColor
}

/**
 * Background type.
 */
enum BackgroundType
{
	SOLID;
	GRADIENT;
	IMAGE;
	PARALLAX;
}

/**
 * Image scaling mode.
 */
enum ScaleMode
{
	FIT;      // Fit maintaining aspect ratio (may have borders)
	FILL;     // Fill maintaining aspect ratio (may crop)
	STRETCH;  // Stretch to fill (ignores aspect ratio)
	NONE;     // Keep original size
}
