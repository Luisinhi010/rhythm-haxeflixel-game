package ui;

import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.group.FlxSpriteGroup;

/**
 * A simple clickable button with text label
 */
class Button extends FlxSpriteGroup
{
	public var onClick:Void->Void;
	public var label:FlxText;
	
	private var bg:FlxSprite;
	private var isHovered:Bool = false;
	private var normalColor:FlxColor;
	private var hoverColor:FlxColor;
	private var clickColor:FlxColor;
	
	public function new(x:Float = 0, y:Float = 0, text:String = "Button", width:Float = 100, height:Float = 30, ?onClick:Void->Void)
	{
		super(x, y);
		
		this.onClick = onClick;
		normalColor = FlxColor.fromRGB(70, 70, 70);
		hoverColor = FlxColor.fromRGB(90, 90, 90);
		clickColor = FlxColor.fromRGB(50, 50, 50);
		
		// Background
		bg = new FlxSprite();
		bg.makeGraphic(Std.int(width), Std.int(height), normalColor);
		add(bg);
		
		// Label
		label = new FlxText(0, 0, width, text);
		label.setFormat(null, 12, FlxColor.WHITE, CENTER);
		label.y = (height - label.height) / 2;
		add(label);
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		#if !mobile
		var mouseOverlaps = bg.overlapsPoint(flixel.FlxG.mouse.getPosition());
		
		if (mouseOverlaps)
		{
			if (!isHovered)
			{
				isHovered = true;
				bg.color = hoverColor;
			}
			
			if (flixel.FlxG.mouse.justPressed)
			{
				bg.color = clickColor;
				if (onClick != null)
					onClick();
			}
			else if (flixel.FlxG.mouse.pressed)
			{
				bg.color = clickColor;
			}
			else
			{
				bg.color = hoverColor;
			}
		}
		else
		{
			if (isHovered)
			{
				isHovered = false;
				bg.color = normalColor;
			}
		}
		#end
	}
}
