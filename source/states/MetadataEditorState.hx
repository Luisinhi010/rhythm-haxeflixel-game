package states;

import backend.MusicMetaDataBuilder;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import sys.io.File;

/**
 * A visual metadata editor state for creating and editing song metadata.
 * Provides a graphical UI with input fields, buttons, and real-time preview.
 */
class MetadataEditorState extends DefaultState
{
	// UI Elements
	private var titleText:FlxText;
	private var inputFields:Array<InputField>;
	private var activeFieldIndex:Int = 0;
	
	// Data fields
	private var songFileName:String = "";
	private var songTitle:String = "";
	private var artistName:String = "";
	private var bpmValue:String = "120";
	private var offsetValue:String = "0";
	private var timeSignature:String = "4/4";
	private var looped:Bool = false;
	
	// Cue points and tempo changes
	private var cuePoints:Array<{name:String, measure:String}> = [];
	private var tempoChanges:Array<{measure:String, bpm:String}> = [];
	
	// UI State
	private var currentPage:Int = 0; // 0 = basic info, 1 = cue points, 2 = tempo changes, 3 = preview
	private var statusText:FlxText;
	private var previewText:FlxText;
	private var helpText:FlxText;
	
	// Buttons
	private var nextButton:FlxButton;
	private var prevButton:FlxButton;
	private var saveButton:FlxButton;
	private var addButton:FlxButton;
	
	override public function create():Void
	{
		super.create();
		
		// Background
		var bg = new FlxSprite();
		bg.makeGraphic(FlxG.width, FlxG.height, 0xFF1a1a2e);
		add(bg);
		
		// Title
		titleText = new FlxText(0, 20, FlxG.width, "Song Metadata Editor");
		titleText.setFormat(null, 32, FlxColor.WHITE, CENTER);
		add(titleText);
		
		// Status text
		statusText = new FlxText(20, 70, FlxG.width - 40, "");
		statusText.setFormat(null, 16, FlxColor.CYAN, LEFT);
		add(statusText);
		
		// Help text
		helpText = new FlxText(20, FlxG.height - 60, FlxG.width - 40, 
			"TAB: Next Field | SHIFT+TAB: Previous Field | ENTER: Confirm | ESC: Exit");
		helpText.setFormat(null, 12, FlxColor.GRAY, CENTER);
		add(helpText);
		
		// Initialize input fields
		inputFields = [];
		
		// Navigation buttons
		prevButton = new FlxButton(20, FlxG.height - 100, "< Previous", onPrevPage);
		prevButton.label.setFormat(null, 12, FlxColor.BLACK, CENTER);
		add(prevButton);
		
		nextButton = new FlxButton(FlxG.width - 120, FlxG.height - 100, "Next >", onNextPage);
		nextButton.label.setFormat(null, 12, FlxColor.BLACK, CENTER);
		add(nextButton);
		
		saveButton = new FlxButton(FlxG.width / 2 - 50, FlxG.height - 100, "Save", onSave);
		saveButton.label.setFormat(null, 12, FlxColor.BLACK, CENTER);
		saveButton.visible = false;
		add(saveButton);
		
		addButton = new FlxButton(FlxG.width / 2 - 100, FlxG.height - 150, "Add Entry", onAddEntry);
		addButton.label.setFormat(null, 12, FlxColor.BLACK, CENTER);
		addButton.visible = false;
		add(addButton);
		
		// Preview text
		previewText = new FlxText(40, 120, FlxG.width - 80, "");
		previewText.setFormat(null, 12, FlxColor.WHITE, LEFT);
		add(previewText);
		
		setupPage();
	}
	
	private function setupPage():Void
	{
		// Clear existing fields
		for (field in inputFields)
		{
			field.destroy();
		}
		inputFields = [];
		activeFieldIndex = 0;
		
		// Hide/show buttons
		prevButton.visible = currentPage > 0;
		nextButton.visible = currentPage < 3;
		saveButton.visible = currentPage == 3;
		addButton.visible = currentPage == 1 || currentPage == 2;
		previewText.visible = currentPage == 3;
		
		switch (currentPage)
		{
			case 0: // Basic Info
				statusText.text = "Page 1/4: Basic Information";
				createBasicInfoPage();
			case 1: // Cue Points
				statusText.text = "Page 2/4: Cue Points (Optional)";
				createCuePointsPage();
			case 2: // Tempo Changes
				statusText.text = "Page 3/4: Tempo Changes (Optional)";
				createTempoChangesPage();
			case 3: // Preview
				statusText.text = "Page 4/4: Preview & Save";
				createPreviewPage();
		}
	}
	
	private function createBasicInfoPage():Void
	{
		var yPos = 120;
		var spacing = 70;
		
		inputFields.push(createInputField("Song Filename:", songFileName, 40, yPos, function(val) songFileName = val));
		inputFields.push(createInputField("Song Title:", songTitle, 40, yPos + spacing, function(val) songTitle = val));
		inputFields.push(createInputField("Artist:", artistName, 40, yPos + spacing * 2, function(val) artistName = val));
		inputFields.push(createInputField("BPM:", bpmValue, 40, yPos + spacing * 3, function(val) bpmValue = val));
		inputFields.push(createInputField("Offset (ms):", offsetValue, 40, yPos + spacing * 4, function(val) offsetValue = val));
		inputFields.push(createInputField("Time Signature:", timeSignature, 40, yPos + spacing * 5, function(val) timeSignature = val));
		
		// Looped checkbox
		var loopedLabel = new FlxText(40, yPos + spacing * 6, 200, "Looped:");
		loopedLabel.setFormat(null, 16, FlxColor.WHITE, LEFT);
		add(loopedLabel);
		
		var loopedValue = new FlxText(250, yPos + spacing * 6, 200, looped ? "YES" : "NO");
		loopedValue.setFormat(null, 16, looped ? FlxColor.GREEN : FlxColor.RED, LEFT);
		add(loopedValue);
		
		var loopedButton = new FlxButton(450, yPos + spacing * 6, "Toggle", function() {
			looped = !looped;
			loopedValue.text = looped ? "YES" : "NO";
			loopedValue.color = looped ? FlxColor.GREEN : FlxColor.RED;
		});
		add(loopedButton);
	}
	
	private function createCuePointsPage():Void
	{
		var infoText = new FlxText(40, 120, FlxG.width - 80, 
			"Cue points mark important sections in your song.\nAdd them by measure number (easiest) or exact time.");
		infoText.setFormat(null, 14, FlxColor.GRAY, LEFT);
		add(infoText);
		
		// List existing cue points
		var yPos = 180;
		for (i in 0...cuePoints.length)
		{
			var cp = cuePoints[i];
			var text = new FlxText(40, yPos, 600, '${i + 1}. "${cp.name}" at measure ${cp.measure}');
			text.setFormat(null, 14, FlxColor.WHITE, LEFT);
			add(text);
			
			var removeBtn = new FlxButton(650, yPos - 5, "Remove", function() {
				cuePoints.splice(i, 1);
				setupPage();
			});
			removeBtn.label.setFormat(null, 10, FlxColor.BLACK, CENTER);
			add(removeBtn);
			
			yPos += 30;
		}
		
		if (cuePoints.length == 0)
		{
			var emptyText = new FlxText(40, yPos, FlxG.width - 80, "No cue points added yet. Click 'Add Entry' to add one.");
			emptyText.setFormat(null, 12, FlxColor.GRAY, LEFT);
			add(emptyText);
		}
	}
	
	private function createTempoChangesPage():Void
	{
		var infoText = new FlxText(40, 120, FlxG.width - 80, 
			"Tempo changes allow the BPM to vary throughout the song.\nAdd them by measure number where the tempo changes.");
		infoText.setFormat(null, 14, FlxColor.GRAY, LEFT);
		add(infoText);
		
		// List existing tempo changes
		var yPos = 180;
		for (i in 0...tempoChanges.length)
		{
			var tc = tempoChanges[i];
			var text = new FlxText(40, yPos, 600, '${i + 1}. ${tc.bpm} BPM at measure ${tc.measure}');
			text.setFormat(null, 14, FlxColor.WHITE, LEFT);
			add(text);
			
			var removeBtn = new FlxButton(650, yPos - 5, "Remove", function() {
				tempoChanges.splice(i, 1);
				setupPage();
			});
			removeBtn.label.setFormat(null, 10, FlxColor.BLACK, CENTER);
			add(removeBtn);
			
			yPos += 30;
		}
		
		if (tempoChanges.length == 0)
		{
			var emptyText = new FlxText(40, yPos, FlxG.width - 80, "No tempo changes added yet. Click 'Add Entry' to add one.");
			emptyText.setFormat(null, 12, FlxColor.GRAY, LEFT);
			add(emptyText);
		}
	}
	
	private function createPreviewPage():Void
	{
		try
		{
			var builder = buildMetadata();
			var json = builder.toJson();
			previewText.text = "JSON Preview:\n\n" + json;
		}
		catch (e:Dynamic)
		{
			previewText.text = "Error generating preview:\n" + Std.string(e);
			previewText.color = FlxColor.RED;
		}
	}
	
	private function createInputField(label:String, value:String, x:Float, y:Float, onChange:String->Void):InputField
	{
		var field = new InputField(label, value, x, y, onChange);
		add(field.labelText);
		add(field.valueText);
		add(field.cursor);
		return field;
	}
	
	private function onNextPage():Void
	{
		if (currentPage == 0)
		{
			// Validate basic info before proceeding
			if (songFileName == "" || songTitle == "" || artistName == "")
			{
				showError("Please fill in filename, title, and artist!");
				return;
			}
			
			var bpm = Std.parseFloat(bpmValue);
			if (bpm == null || bpm <= 0)
			{
				showError("BPM must be a positive number!");
				return;
			}
		}
		
		currentPage++;
		setupPage();
	}
	
	private function onPrevPage():Void
	{
		currentPage--;
		setupPage();
	}
	
	private function onAddEntry():Void
	{
		if (currentPage == 1) // Cue Points
		{
			// Simple popup to add cue point
			var name = "Section " + (cuePoints.length + 1);
			var measure = "0";
			cuePoints.push({name: name, measure: measure});
			setupPage();
		}
		else if (currentPage == 2) // Tempo Changes
		{
			var measure = "0";
			var bpm = bpmValue;
			tempoChanges.push({measure: measure, bpm: bpm});
			setupPage();
		}
	}
	
	private function onSave():Void
	{
		try
		{
			var builder = buildMetadata();
			var json = builder.toJson();
			var path = 'assets/music/$songFileName.json';
			
			#if sys
			File.saveContent(path, json);
			showSuccess('Saved to $path!');
			#else
			showError("Saving not supported on this platform");
			#end
		}
		catch (e:Dynamic)
		{
			showError("Error saving: " + Std.string(e));
		}
	}
	
	private function buildMetadata():MusicMetaDataBuilder
	{
		var builder = new MusicMetaDataBuilder()
			.setTitle(songTitle)
			.setArtist(artistName)
			.setBPM(Std.parseFloat(bpmValue))
			.setOffset(Std.parseFloat(offsetValue))
			.setTimeSignature(timeSignature)
			.setLooped(looped);
		
		// Add cue points
		for (cp in cuePoints)
		{
			var measure = Std.parseFloat(cp.measure);
			if (measure != null)
				builder.addCuePointAtMeasure(cp.name, measure);
		}
		
		// Add tempo changes
		for (tc in tempoChanges)
		{
			var measure = Std.parseFloat(tc.measure);
			var bpm = Std.parseFloat(tc.bpm);
			if (measure != null && bpm != null)
				builder.addTempoChangeAtMeasure(measure, bpm);
		}
		
		return builder;
	}
	
	private function showError(msg:String):Void
	{
		statusText.text = "ERROR: " + msg;
		statusText.color = FlxColor.RED;
	}
	
	private function showSuccess(msg:String):Void
	{
		statusText.text = "SUCCESS: " + msg;
		statusText.color = FlxColor.GREEN;
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		// ESC to exit
		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.switchState(new DebugState());
		}
		
		// Tab navigation
		if (FlxG.keys.justPressed.TAB && !FlxG.keys.pressed.SHIFT)
		{
			if (inputFields.length > 0)
			{
				activeFieldIndex = (activeFieldIndex + 1) % inputFields.length;
				updateActiveField();
			}
		}
		else if (FlxG.keys.justPressed.TAB && FlxG.keys.pressed.SHIFT)
		{
			if (inputFields.length > 0)
			{
				activeFieldIndex--;
				if (activeFieldIndex < 0) activeFieldIndex = inputFields.length - 1;
				updateActiveField();
			}
		}
		
		// Update active field with keyboard input
		if (inputFields.length > 0 && activeFieldIndex < inputFields.length)
		{
			var field = inputFields[activeFieldIndex];
			field.update(elapsed);
		}
	}
	
	private function updateActiveField():Void
	{
		for (i in 0...inputFields.length)
		{
			inputFields[i].setActive(i == activeFieldIndex);
		}
	}
}

/**
 * Helper class for input fields
 */
class InputField
{
	public var labelText:FlxText;
	public var valueText:FlxText;
	public var cursor:FlxSprite;
	public var value:String;
	private var onChange:String->Void;
	private var isActive:Bool = false;
	private var cursorBlink:Float = 0;
	
	public function new(label:String, initialValue:String, x:Float, y:Float, onChange:String->Void)
	{
		this.value = initialValue;
		this.onChange = onChange;
		
		labelText = new FlxText(x, y, 200, label);
		labelText.setFormat(null, 16, FlxColor.WHITE, LEFT);
		
		valueText = new FlxText(x + 220, y, 400, value);
		valueText.setFormat(null, 16, FlxColor.CYAN, LEFT);
		
		cursor = new FlxSprite(x + 220 + valueText.width, y);
		cursor.makeGraphic(2, 20, FlxColor.WHITE);
		cursor.visible = false;
	}
	
	public function setActive(active:Bool):Void
	{
		isActive = active;
		valueText.color = active ? FlxColor.YELLOW : FlxColor.CYAN;
		cursor.visible = active;
	}
	
	public function update(elapsed:Float):Void
	{
		if (!isActive) return;
		
		// Cursor blink
		cursorBlink += elapsed;
		cursor.visible = (cursorBlink % 1.0) < 0.5;
		
		// Handle text input
		var input = FlxG.keys.getIsDown();
		for (key in input)
		{
			if (FlxG.keys.justPressed.ANY)
			{
				// Handle backspace
				if (FlxG.keys.justPressed.BACKSPACE)
				{
					if (value.length > 0)
					{
						value = value.substr(0, value.length - 1);
						updateValue();
					}
				}
				// Handle alphanumeric and common symbols
				else
				{
					var char = getKeyChar();
					if (char != "")
					{
						value += char;
						updateValue();
					}
				}
			}
		}
		
		// Update cursor position
		cursor.x = valueText.x + valueText.width;
	}
	
	private function updateValue():Void
	{
		valueText.text = value;
		onChange(value);
	}
	
	private function getKeyChar():String
	{
		// Numbers
		if (FlxG.keys.justPressed.ZERO) return "0";
		if (FlxG.keys.justPressed.ONE) return "1";
		if (FlxG.keys.justPressed.TWO) return "2";
		if (FlxG.keys.justPressed.THREE) return "3";
		if (FlxG.keys.justPressed.FOUR) return "4";
		if (FlxG.keys.justPressed.FIVE) return "5";
		if (FlxG.keys.justPressed.SIX) return "6";
		if (FlxG.keys.justPressed.SEVEN) return "7";
		if (FlxG.keys.justPressed.EIGHT) return "8";
		if (FlxG.keys.justPressed.NINE) return "9";
		
		// Letters
		if (FlxG.keys.justPressed.A) return FlxG.keys.pressed.SHIFT ? "A" : "a";
		if (FlxG.keys.justPressed.B) return FlxG.keys.pressed.SHIFT ? "B" : "b";
		if (FlxG.keys.justPressed.C) return FlxG.keys.pressed.SHIFT ? "C" : "c";
		if (FlxG.keys.justPressed.D) return FlxG.keys.pressed.SHIFT ? "D" : "d";
		if (FlxG.keys.justPressed.E) return FlxG.keys.pressed.SHIFT ? "E" : "e";
		if (FlxG.keys.justPressed.F) return FlxG.keys.pressed.SHIFT ? "F" : "f";
		if (FlxG.keys.justPressed.G) return FlxG.keys.pressed.SHIFT ? "G" : "g";
		if (FlxG.keys.justPressed.H) return FlxG.keys.pressed.SHIFT ? "H" : "h";
		if (FlxG.keys.justPressed.I) return FlxG.keys.pressed.SHIFT ? "I" : "i";
		if (FlxG.keys.justPressed.J) return FlxG.keys.pressed.SHIFT ? "J" : "j";
		if (FlxG.keys.justPressed.K) return FlxG.keys.pressed.SHIFT ? "K" : "k";
		if (FlxG.keys.justPressed.L) return FlxG.keys.pressed.SHIFT ? "L" : "l";
		if (FlxG.keys.justPressed.M) return FlxG.keys.pressed.SHIFT ? "M" : "m";
		if (FlxG.keys.justPressed.N) return FlxG.keys.pressed.SHIFT ? "N" : "n";
		if (FlxG.keys.justPressed.O) return FlxG.keys.pressed.SHIFT ? "O" : "o";
		if (FlxG.keys.justPressed.P) return FlxG.keys.pressed.SHIFT ? "P" : "p";
		if (FlxG.keys.justPressed.Q) return FlxG.keys.pressed.SHIFT ? "Q" : "q";
		if (FlxG.keys.justPressed.R) return FlxG.keys.pressed.SHIFT ? "R" : "r";
		if (FlxG.keys.justPressed.S) return FlxG.keys.pressed.SHIFT ? "S" : "s";
		if (FlxG.keys.justPressed.T) return FlxG.keys.pressed.SHIFT ? "T" : "t";
		if (FlxG.keys.justPressed.U) return FlxG.keys.pressed.SHIFT ? "U" : "u";
		if (FlxG.keys.justPressed.V) return FlxG.keys.pressed.SHIFT ? "V" : "v";
		if (FlxG.keys.justPressed.W) return FlxG.keys.pressed.SHIFT ? "W" : "w";
		if (FlxG.keys.justPressed.X) return FlxG.keys.pressed.SHIFT ? "X" : "x";
		if (FlxG.keys.justPressed.Y) return FlxG.keys.pressed.SHIFT ? "Y" : "y";
		if (FlxG.keys.justPressed.Z) return FlxG.keys.pressed.SHIFT ? "Z" : "z";
		
		// Common symbols
		if (FlxG.keys.justPressed.SPACE) return " ";
		if (FlxG.keys.justPressed.MINUS) return "-";
		if (FlxG.keys.justPressed.PERIOD) return ".";
		if (FlxG.keys.justPressed.SLASH) return "/";
		
		return "";
	}
	
	public function destroy():Void
	{
		labelText.destroy();
		valueText.destroy();
		cursor.destroy();
	}
}
