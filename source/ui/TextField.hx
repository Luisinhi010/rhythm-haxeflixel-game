package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

/**
 * A simple text input field
 */
class TextField extends FlxSpriteGroup
{
	public var text:String = "";
	public var onChange:String->Void;
	
	private var bg:FlxSprite;
	private var textDisplay:FlxText;
	private var focused:Bool = false;
	private var cursorTimer:Float = 0;
	private var showCursor:Bool = false;
	private var maxLength:Int = 50;
	
	public function new(x:Float = 0, y:Float = 0, width:Float = 150, height:Float = 25, ?defaultText:String = "")
	{
		super(x, y);
		
		this.text = defaultText;
		
		// Background
		bg = new FlxSprite();
		bg.makeGraphic(Std.int(width), Std.int(height), FlxColor.fromRGB(40, 40, 40));
		add(bg);
		
		// Text display
		textDisplay = new FlxText(5, 0, width - 10, text);
		textDisplay.setFormat(null, 12, FlxColor.WHITE, LEFT);
		textDisplay.y = (height - textDisplay.height) / 2;
		add(textDisplay);
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		#if !mobile
		// Check for focus
		if (FlxG.mouse.justPressed)
		{
			var mouseOverlaps = bg.overlapsPoint(FlxG.mouse.getPosition());
			if (mouseOverlaps)
			{
				focused = true;
				bg.color = FlxColor.fromRGB(60, 60, 60);
			}
			else
			{
				focused = false;
				bg.color = FlxColor.fromRGB(40, 40, 40);
			}
		}
		
		// Handle input when focused
		if (focused)
		{
			// Cursor blinking
			cursorTimer += elapsed;
			if (cursorTimer >= 0.5)
			{
				cursorTimer = 0;
				showCursor = !showCursor;
			}
			
			// Handle keyboard input
			if (FlxG.keys.justPressed.BACKSPACE && text.length > 0)
			{
				text = text.substr(0, text.length - 1);
				updateText();
			}
			else if (FlxG.keys.justPressed.ENTER)
			{
				focused = false;
				bg.color = FlxColor.fromRGB(40, 40, 40);
			}
			else
			{
				// Get typed character
				var char = getTypedChar();
				if (char != null && text.length < maxLength)
				{
					text += char;
					updateText();
				}
			}
		}
		#end
	}
	
	private function updateText():Void
	{
		var displayText = text;
		if (focused && showCursor)
			displayText += "|";
		
		textDisplay.text = displayText;
		
		if (onChange != null)
			onChange(text);
	}
	
	private function getTypedChar():Null<String>
	{
		// Check for alphanumeric keys
		var keys = FlxG.keys.justPressed;
		
		// Letters
		if (keys.A) return "a";
		if (keys.B) return "b";
		if (keys.C) return "c";
		if (keys.D) return "d";
		if (keys.E) return "e";
		if (keys.F) return "f";
		if (keys.G) return "g";
		if (keys.H) return "h";
		if (keys.I) return "i";
		if (keys.J) return "j";
		if (keys.K) return "k";
		if (keys.L) return "l";
		if (keys.M) return "m";
		if (keys.N) return "n";
		if (keys.O) return "o";
		if (keys.P) return "p";
		if (keys.Q) return "q";
		if (keys.R) return "r";
		if (keys.S) return "s";
		if (keys.T) return "t";
		if (keys.U) return "u";
		if (keys.V) return "v";
		if (keys.W) return "w";
		if (keys.X) return "x";
		if (keys.Y) return "y";
		if (keys.Z) return "z";
		
		// Numbers
		if (keys.ZERO) return "0";
		if (keys.ONE) return "1";
		if (keys.TWO) return "2";
		if (keys.THREE) return "3";
		if (keys.FOUR) return "4";
		if (keys.FIVE) return "5";
		if (keys.SIX) return "6";
		if (keys.SEVEN) return "7";
		if (keys.EIGHT) return "8";
		if (keys.NINE) return "9";
		
		// Special characters
		if (keys.SPACE) return " ";
		if (keys.PERIOD) return ".";
		if (keys.MINUS) return "-";
		if (keys.SLASH) return "/";
		
		return null;
	}
	
	public function setText(newText:String):Void
	{
		text = newText;
		updateText();
	}
}
