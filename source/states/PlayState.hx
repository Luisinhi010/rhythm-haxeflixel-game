package states;

import backend.FilePath;
import backend.MusicMetaData;
import flixel.FlxG;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.Json;
import objects.DefaultBar;

class PlayState extends DefaultState
{
	var hitbar:DefaultBar;

	override public function create():Void
	{
		FlxG.autoPause = false;

		hitbar = new DefaultBar(0, 0);
		hitbar.screenCenter();
		add(hitbar);
		
		// Add instructions
		var instructionsText = new FlxText(10, 10, FlxG.width - 20, "Press M for Metadata Editor");
		instructionsText.setFormat(null, 14, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		add(instructionsText);

		super.create();
	}
	
	override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		// Open metadata editor
		if (FlxG.keys.justPressed.M)
		{
			FlxG.switchState(new MetadataEditorState());
		}
	}
}
