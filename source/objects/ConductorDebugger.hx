package objects;

import backend.FlxGroupContainer;
import core.utils.SpriteUtil;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;

/**
 * Handles all debug visualization and tracing for the Conductor.
 * This class is responsible for drawing debug information about beats,
 * cue points, and tempo changes on a canvas. Extends FlxGroupContainer to allow
 * positioning with x and y coordinates while supporting any FlxBasic objects.
 */
class ConductorDebugger extends FlxGroupContainer
{
	private var debugMode:Bool = #if debug true #else false #end;
	private var _debugDraw:Bool = true;
	private var _conductor:Conductor;
	
	// Components
	private var canvas:FlxSprite;
	private var positionMarker:FlxSprite;
	private var textLayer:FlxTypedGroup<FlxText>;

	public function new(conductor:Conductor)
	{
		super();
		
		_conductor = conductor;
		
		// Create background
		var bg = SpriteUtil.createColored(FlxG.width, 120, 0xFF1a1a1a);
		add(bg);
		
		// Create canvas - dynamic size based on screen
		canvas = new FlxSprite(0, 10);
		canvas.makeGraphic(FlxG.width, 100, FlxColor.TRANSPARENT, false);
		add(canvas);
		
		// Create position marker - initialize once
		positionMarker = SpriteUtil.createColored(2, 50, FlxColor.LIME);
		add(positionMarker);
		
		// Create text layer for labels
		textLayer = new FlxTypedGroup<FlxText>();
		addAbsolute(textLayer);
		
		visible = debugMode;
	}

	/**
	 * Marks that debug drawing needs to be refreshed.
	 */
	public function markDirty():Void
	{
		_debugDraw = true;
	}

	/**
	 * Updates the debug visualization.
	 */
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (debugMode && _conductor != null)
		{
			updateDebugDraw();
		}
	}

	/**
	 * Draws debug information on the canvas.
	 */
	private function updateDebugDraw():Void
	{
		if (canvas == null || positionMarker == null || textLayer == null || _conductor == null || _conductor.music == null)
			return;

		// Handle window resizing - only recreate graphic if dimensions changed
		if (canvas.pixels.width != FlxG.width)
		{
			canvas.makeGraphic(FlxG.width, 100, FlxColor.TRANSPARENT, true);
			_debugDraw = true;
		}

		if (!_debugDraw)
		{
			// Only update the position marker
			if (_conductor.music.length > 0)
			{
				positionMarker.x = canvas.x + (_conductor.music.time / _conductor.music.length) * canvas.width;
				positionMarker.y = canvas.y + (canvas.height / 2) - (positionMarker.height / 2);
			}
			return;
		}

		var y = canvas.height / 2;

		SpriteUtil.fill(canvas, FlxColor.TRANSPARENT); // High-performance clear using fillRect

		// Kill all existing labels to mark them for recycling.
		// We do NOT call clear() here; staying in the group allows recycle() to find and reuse them.
		textLayer.killMembers();

		// Draw base line
		FlxSpriteUtil.drawLine(canvas, 0, y, canvas.width, y, {color: FlxColor.WHITE});

		// Draw beat and bar markers
		if (_conductor.beatDuration > 0)
		{
			var msPerBeat = _conductor.beatDuration * 1000;
			var totalBeats = Std.int(_conductor.music.length / msPerBeat);
			for (beat in 0...totalBeats + 2)
			{
				var isBarLine = (beat % _conductor.beatsPerBar == 0);
				drawMarker(beat * msPerBeat, isBarLine ? FlxColor.CYAN : FlxColor.RED, isBarLine ? 10 : 5, y);
			}
		}

		// Draw cue points
		if (_conductor.cuePoints != null)
		{
			for (name in _conductor.cuePoints.keys())
			{
				var time = _conductor.cuePoints.get(name);
				drawMarker(time, FlxColor.YELLOW, 15, y, name);
			}
		}
		// Draw tempo changes
		if (_conductor.tempoChanges != null)
			for (change in _conductor.tempoChanges)
				drawMarker(change.time, FlxColor.MAGENTA, 20, y, '${change.bpm} BPM');

		// Update current position marker coordinates
		if (_conductor.music != null && _conductor.music.length > 0)
		{
			positionMarker.x = canvas.x + (_conductor.music.time / _conductor.music.length) * canvas.width;
			positionMarker.y = canvas.y + (canvas.height / 2) - (positionMarker.height / 2);
		}
		_debugDraw = false;
	}

	/**
	 * Helper to draw a marker line and its label.
	 * Defined as a method to avoid closure allocation during redraws.
	 */
	private function drawMarker(time:Float, color:FlxColor, size:Float, centerY:Float, ?labelText:String):Void
	{
		if (_conductor.music.length == 0)
			return;

		var x = (time / _conductor.music.length) * canvas.width;
		FlxSpriteUtil.drawLine(canvas, x, centerY - size, x, centerY + size, {color: color, thickness: 2});

		if (labelText != null)
		{
			var label = textLayer.recycle(FlxText);
			label.setFormat(null, 8, color);
			label.text = labelText;
			label.setPosition(canvas.x + x + 2, canvas.y + centerY - size - 10);
			textLayer.add(label);
		}
	}

	/**
	 * Toggles debug mode.
	 */
	public function toggleDebugMode():Bool
	{
		debugMode = !debugMode;
		visible = debugMode;
		if (debugMode)
			markDirty();
		return debugMode;
	}

	/**
	 * Check if debug mode is enabled.
	 */
	public function isDebugMode():Bool
	{
		return debugMode;
	}
}
