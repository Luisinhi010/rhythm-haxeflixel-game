package objects;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

/**
 * Visual marker for cue points on the timeline
 */
class CuePointMarker extends FlxSpriteGroup
{
	public var cuePointName:String;
	public var timestamp:Float;
	public var isSelected:Bool = false;
	public var isDragging:Bool = false;
	
	private var marker:FlxSprite;
	private var label:FlxText;
	
	public function new(name:String, time:Float, x:Float = 0, y:Float = 0)
	{
		super(x, y);
		
		this.cuePointName = name;
		this.timestamp = time;
		
		// Marker shape (diamond)
		marker = new FlxSprite();
		marker.makeGraphic(12, 12, FlxColor.TRANSPARENT);
		// Draw diamond shape
		marker.pixels.fillRect(new openfl.geom.Rectangle(5, 0, 2, 2), FlxColor.CYAN);
		marker.pixels.fillRect(new openfl.geom.Rectangle(4, 2, 4, 2), FlxColor.CYAN);
		marker.pixels.fillRect(new openfl.geom.Rectangle(3, 4, 6, 2), FlxColor.CYAN);
		marker.pixels.fillRect(new openfl.geom.Rectangle(2, 6, 8, 2), FlxColor.CYAN);
		marker.pixels.fillRect(new openfl.geom.Rectangle(3, 8, 6, 2), FlxColor.CYAN);
		marker.pixels.fillRect(new openfl.geom.Rectangle(4, 10, 4, 2), FlxColor.CYAN);
		marker.x = -6; // Center the marker
		add(marker);
		
		// Label
		label = new FlxText(-50, 15, 100, name);
		label.setFormat(null, 8, FlxColor.CYAN, CENTER);
		add(label);
	}
	
	public function setSelected(selected:Bool):Void
	{
		isSelected = selected;
		if (selected)
		{
			marker.color = FlxColor.YELLOW;
			label.color = FlxColor.YELLOW;
		}
		else
		{
			marker.color = FlxColor.WHITE;
			label.color = FlxColor.CYAN;
		}
	}
	
	public function updateLabel(newName:String):Void
	{
		cuePointName = newName;
		label.text = newName;
	}
}
