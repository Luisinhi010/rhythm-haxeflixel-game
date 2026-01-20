package objects;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

/**
 * Visual marker for BPM changes on the timeline
 */
class BPMMarker extends FlxSpriteGroup
{
	public var timestamp:Float;
	public var bpm:Float;
	public var isSelected:Bool = false;
	public var isDragging:Bool = false;
	
	private var marker:FlxSprite;
	private var label:FlxText;
	
	public function new(time:Float, bpmValue:Float, x:Float = 0, y:Float = 0)
	{
		super(x, y);
		
		this.timestamp = time;
		this.bpm = bpmValue;
		
		// Marker shape (square)
		marker = new FlxSprite();
		marker.makeGraphic(10, 10, FlxColor.ORANGE);
		marker.x = -5; // Center the marker
		add(marker);
		
		// Label
		label = new FlxText(-30, 15, 60, Std.string(Math.round(bpm)) + " BPM");
		label.setFormat(null, 8, FlxColor.ORANGE, CENTER);
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
			marker.color = FlxColor.ORANGE;
			label.color = FlxColor.ORANGE;
		}
	}
	
	public function updateBPM(newBPM:Float):Void
	{
		bpm = newBPM;
		label.text = Std.string(Math.round(bpm)) + " BPM";
	}
}
