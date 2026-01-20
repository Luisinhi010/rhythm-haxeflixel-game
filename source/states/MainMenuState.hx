package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;

/**
 * Main menu state that provides access to different game features
 */
class MainMenuState extends DefaultState
{
	var titleText:FlxText;
	var playButton:FlxText;
	var debugButton:FlxText;
	var editorButton:FlxText;
	var selectedIndex:Int = 0;
	var menuItems:Array<FlxText> = [];

	override public function create():Void
	{
		super.create();

		var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(20, 20, 30));
		add(bg);

		// Title
		titleText = new FlxText(0, 100, FlxG.width, "Rhythm Game");
		titleText.setFormat(null, 48, FlxColor.WHITE, "center");
		add(titleText);

		// Menu items
		var startY = 300;
		var spacing = 80;

		playButton = createMenuItem("Play", startY);
		debugButton = createMenuItem("Debug", startY + spacing);
		editorButton = createMenuItem("Metadata Editor", startY + spacing * 2);

		menuItems = [playButton, debugButton, editorButton];
		updateSelection();
	}

	function createMenuItem(text:String, y:Float):FlxText
	{
		var item = new FlxText(0, y, FlxG.width, text);
		item.setFormat(null, 32, FlxColor.WHITE, "center");
		add(item);
		return item;
	}

	function updateSelection():Void
	{
		for (i in 0...menuItems.length)
		{
			menuItems[i].color = (i == selectedIndex) ? FlxColor.YELLOW : FlxColor.WHITE;
			menuItems[i].size = (i == selectedIndex) ? 36 : 32;
		}
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		// Keyboard navigation
		if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.W)
		{
			selectedIndex = (selectedIndex - 1 + menuItems.length) % menuItems.length;
			updateSelection();
		}
		else if (FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.S)
		{
			selectedIndex = (selectedIndex + 1) % menuItems.length;
			updateSelection();
		}
		else if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE)
		{
			selectItem();
		}

		// Mouse/Touch navigation
		for (i in 0...menuItems.length)
		{
			#if FLX_MOUSE
			if (FlxG.mouse.overlaps(menuItems[i]))
			{
				if (selectedIndex != i)
				{
					selectedIndex = i;
					updateSelection();
				}
				if (FlxG.mouse.justPressed)
				{
					selectItem();
				}
			}
			#end
		}
	}

	function selectItem():Void
	{
		switch (selectedIndex)
		{
			case 0: // Play
				FlxG.switchState(new PlayState());
			case 1: // Debug
				FlxG.switchState(new DebugState());
			case 2: // Metadata Editor
				FlxG.switchState(new MetadataEditorState());
		}
	}
}
