package states;

import backend.MusicMetaData;
import backend.Paths;
import flixel.FlxG;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUICheckBox;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import haxe.Json;
using StringTools;
#if sys
import sys.io.File;
#end

/**
 * A state for creating and editing song metadata.
 * Supports both mouse/keyboard and touch input for mobile.
 */
class MetadataEditorState extends DefaultState
{
	// UI Elements
	var titleLabel:FlxText;
	var titleInput:FlxInputText;
	
	var artistLabel:FlxText;
	var artistInput:FlxInputText;
	
	var bpmLabel:FlxText;
	var bpmInput:FlxInputText;
	
	var offsetLabel:FlxText;
	var offsetInput:FlxInputText;
	
	var timeSignatureLabel:FlxText;
	var timeSignatureInput:FlxInputText;
	
	var loopedLabel:FlxText;
	var loopedCheckbox:FlxUICheckBox;
	
	var saveButton:FlxUIButton;
	var loadButton:FlxUIButton;
	var newButton:FlxUIButton;
	var backButton:FlxUIButton;
	
	var statusText:FlxText;
	var instructionsText:FlxText;
	
	var songNameLabel:FlxText;
	var songNameInput:FlxInputText;
	
	// Cue points and tempo changes management
	var cuePointsLabel:FlxText;
	var cuePointsListText:FlxText;
	var addCueButton:FlxUIButton;
	var clearCueButton:FlxUIButton;
	
	var tempoChangesLabel:FlxText;
	var tempoChangesListText:FlxText;
	var addTempoButton:FlxUIButton;
	var clearTempoButton:FlxUIButton;
	
	// Current metadata being edited
	var currentSongName:String = "";
	var cuePoints:Map<String, Float>;
	var cuePointCount:Int = 0; // Track count for efficiency
	var tempoChanges:Array<{time:Float, bpm:Float}>;
	
	// UI Layout constants
	static inline var PADDING:Float = 20;
	static inline var LABEL_WIDTH:Float = 200;
	static inline var INPUT_WIDTH:Float = 300;
	static inline var LINE_HEIGHT:Float = 50;
	
	override public function create():Void
	{
		super.create();
		FlxG.autoPause = false;
		
		// Initialize data structures
		cuePoints = new Map<String, Float>();
		tempoChanges = [];
		
		// Set background
		bgColor = FlxColor.fromRGB(40, 44, 52);
		
		var yPos:Float = PADDING;
		
		// Title
		var headerText = new FlxText(0, yPos, FlxG.width, "Song Metadata Editor");
		headerText.setFormat(null, 32, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		add(headerText);
		yPos += 50;
		
		// Instructions
		instructionsText = new FlxText(PADDING, yPos, FlxG.width - PADDING * 2, 
			"Edit song metadata below. Touch/Click fields to edit. Press TAB to navigate.");
		instructionsText.setFormat(null, 14, FlxColor.GRAY, LEFT);
		add(instructionsText);
		yPos += 40;
		
		// Song name (file name without extension)
		songNameLabel = new FlxText(PADDING, yPos, LABEL_WIDTH, "Song File Name:");
		songNameLabel.setFormat(null, 16, FlxColor.WHITE, LEFT);
		add(songNameLabel);
		
		songNameInput = new FlxInputText(PADDING + LABEL_WIDTH, yPos, Std.int(INPUT_WIDTH), "", 16);
		songNameInput.backgroundColor = FlxColor.fromRGB(60, 63, 65);
		songNameInput.fieldBorderColor = FlxColor.fromRGB(80, 83, 85);
		songNameInput.fieldBorderThickness = 2;
		songNameInput.caretColor = FlxColor.WHITE;
		add(songNameInput);
		yPos += LINE_HEIGHT;
		
		// Title
		titleLabel = new FlxText(PADDING, yPos, LABEL_WIDTH, "Title:");
		titleLabel.setFormat(null, 16, FlxColor.WHITE, LEFT);
		add(titleLabel);
		
		titleInput = new FlxInputText(PADDING + LABEL_WIDTH, yPos, Std.int(INPUT_WIDTH), "", 16);
		titleInput.backgroundColor = FlxColor.fromRGB(60, 63, 65);
		titleInput.fieldBorderColor = FlxColor.fromRGB(80, 83, 85);
		titleInput.fieldBorderThickness = 2;
		titleInput.caretColor = FlxColor.WHITE;
		add(titleInput);
		yPos += LINE_HEIGHT;
		
		// Artist
		artistLabel = new FlxText(PADDING, yPos, LABEL_WIDTH, "Artist:");
		artistLabel.setFormat(null, 16, FlxColor.WHITE, LEFT);
		add(artistLabel);
		
		artistInput = new FlxInputText(PADDING + LABEL_WIDTH, yPos, Std.int(INPUT_WIDTH), "", 16);
		artistInput.backgroundColor = FlxColor.fromRGB(60, 63, 65);
		artistInput.fieldBorderColor = FlxColor.fromRGB(80, 83, 85);
		artistInput.fieldBorderThickness = 2;
		artistInput.caretColor = FlxColor.WHITE;
		add(artistInput);
		yPos += LINE_HEIGHT;
		
		// BPM
		bpmLabel = new FlxText(PADDING, yPos, LABEL_WIDTH, "BPM:");
		bpmLabel.setFormat(null, 16, FlxColor.WHITE, LEFT);
		add(bpmLabel);
		
		bpmInput = new FlxInputText(PADDING + LABEL_WIDTH, yPos, Std.int(INPUT_WIDTH), "120", 16);
		bpmInput.backgroundColor = FlxColor.fromRGB(60, 63, 65);
		bpmInput.fieldBorderColor = FlxColor.fromRGB(80, 83, 85);
		bpmInput.fieldBorderThickness = 2;
		bpmInput.caretColor = FlxColor.WHITE;
		bpmInput.filterMode = FlxInputText.ONLY_NUMERIC;
		add(bpmInput);
		yPos += LINE_HEIGHT;
		
		// Offset
		offsetLabel = new FlxText(PADDING, yPos, LABEL_WIDTH, "Offset (ms):");
		offsetLabel.setFormat(null, 16, FlxColor.WHITE, LEFT);
		add(offsetLabel);
		
		offsetInput = new FlxInputText(PADDING + LABEL_WIDTH, yPos, Std.int(INPUT_WIDTH), "0", 16);
		offsetInput.backgroundColor = FlxColor.fromRGB(60, 63, 65);
		offsetInput.fieldBorderColor = FlxColor.fromRGB(80, 83, 85);
		offsetInput.fieldBorderThickness = 2;
		offsetInput.caretColor = FlxColor.WHITE;
		offsetInput.filterMode = FlxInputText.ONLY_NUMERIC;
		add(offsetInput);
		yPos += LINE_HEIGHT;
		
		// Time Signature
		timeSignatureLabel = new FlxText(PADDING, yPos, LABEL_WIDTH, "Time Signature:");
		timeSignatureLabel.setFormat(null, 16, FlxColor.WHITE, LEFT);
		add(timeSignatureLabel);
		
		timeSignatureInput = new FlxInputText(PADDING + LABEL_WIDTH, yPos, Std.int(INPUT_WIDTH), "4/4", 16);
		timeSignatureInput.backgroundColor = FlxColor.fromRGB(60, 63, 65);
		timeSignatureInput.fieldBorderColor = FlxColor.fromRGB(80, 83, 85);
		timeSignatureInput.fieldBorderThickness = 2;
		timeSignatureInput.caretColor = FlxColor.WHITE;
		add(timeSignatureInput);
		yPos += LINE_HEIGHT;
		
		// Looped checkbox
		loopedLabel = new FlxText(PADDING, yPos, LABEL_WIDTH, "Loop Music:");
		loopedLabel.setFormat(null, 16, FlxColor.WHITE, LEFT);
		add(loopedLabel);
		
		loopedCheckbox = new FlxUICheckBox(PADDING + LABEL_WIDTH, yPos, null, null, "Enable Loop", 100);
		loopedCheckbox.textX = 25;
		add(loopedCheckbox);
		yPos += LINE_HEIGHT;
		
		// Cue points section
		cuePointsLabel = new FlxText(PADDING, yPos, LABEL_WIDTH * 2, "Cue Points:");
		cuePointsLabel.setFormat(null, 18, FlxColor.CYAN, LEFT);
		add(cuePointsLabel);
		yPos += 30;
		
		cuePointsListText = new FlxText(PADDING + 20, yPos, FlxG.width - PADDING * 2 - 40, "(none)");
		cuePointsListText.setFormat(null, 12, FlxColor.GRAY, LEFT);
		add(cuePointsListText);
		yPos += 40;
		
		addCueButton = new FlxUIButton(PADDING, yPos, "Add Cue Point", onAddCuePoint);
		addCueButton.resize(150, 30);
		add(addCueButton);
		
		clearCueButton = new FlxUIButton(PADDING + 160, yPos, "Clear All", onClearCuePoints);
		clearCueButton.resize(100, 30);
		add(clearCueButton);
		yPos += 50;
		
		// Tempo changes section
		tempoChangesLabel = new FlxText(PADDING, yPos, LABEL_WIDTH * 2, "Tempo Changes:");
		tempoChangesLabel.setFormat(null, 18, FlxColor.CYAN, LEFT);
		add(tempoChangesLabel);
		yPos += 30;
		
		tempoChangesListText = new FlxText(PADDING + 20, yPos, FlxG.width - PADDING * 2 - 40, "(none)");
		tempoChangesListText.setFormat(null, 12, FlxColor.GRAY, LEFT);
		add(tempoChangesListText);
		yPos += 40;
		
		addTempoButton = new FlxUIButton(PADDING, yPos, "Add Tempo Change", onAddTempoChange);
		addTempoButton.resize(150, 30);
		add(addTempoButton);
		
		clearTempoButton = new FlxUIButton(PADDING + 160, yPos, "Clear All", onClearTempoChanges);
		clearTempoButton.resize(100, 30);
		add(clearTempoButton);
		yPos += 50;
		
		// Bottom buttons
		var buttonY = FlxG.height - 80;
		
		newButton = new FlxUIButton(PADDING, buttonY, "New", onNew);
		newButton.resize(120, 40);
		add(newButton);
		
		loadButton = new FlxUIButton(PADDING + 130, buttonY, "Load", onLoad);
		loadButton.resize(120, 40);
		add(loadButton);
		
		saveButton = new FlxUIButton(PADDING + 260, buttonY, "Save", onSave);
		saveButton.resize(120, 40);
		add(saveButton);
		
		backButton = new FlxUIButton(FlxG.width - 150, buttonY, "Back", onBack);
		backButton.resize(120, 40);
		add(backButton);
		
		// Status text
		statusText = new FlxText(PADDING, FlxG.height - 30, FlxG.width - PADDING * 2, "Ready");
		statusText.setFormat(null, 14, FlxColor.GREEN, LEFT);
		add(statusText);
		
		// Load default values
		loadDefaultMetadata();
	}
	
	function loadDefaultMetadata():Void
	{
		currentSongName = "";
		songNameInput.text = "";
		titleInput.text = "";
		artistInput.text = "Unknown";
		bpmInput.text = "120";
		offsetInput.text = "0";
		timeSignatureInput.text = "4/4";
		loopedCheckbox.checked = false;
		cuePoints.clear();
		cuePointCount = 0;
		tempoChanges = [];
		updateCuePointsList();
		updateTempoChangesList();
	}
	
	function onNew():Void
	{
		loadDefaultMetadata();
		setStatus("New metadata created. Enter song details.", FlxColor.CYAN);
	}
	
	function onLoad():Void
	{
		var songName = songNameInput.text.trim();
		if (songName == "")
		{
			setStatus("Error: Enter a song file name to load.", FlxColor.RED);
			return;
		}
		
		var jsonString = Paths.getMusicData(songName);
		if (jsonString == null)
		{
			setStatus("Error: Metadata file not found for '" + songName + "'", FlxColor.RED);
			return;
		}
		
		try
		{
			var parsedData:Dynamic = Json.parse(jsonString);
			currentSongName = songName;
			
			// Load basic fields
			titleInput.text = parsedData.title != null ? parsedData.title : songName;
			artistInput.text = parsedData.artist != null ? parsedData.artist : "Unknown";
			bpmInput.text = parsedData.bpm != null ? Std.string(parsedData.bpm) : "120";
			offsetInput.text = parsedData.offset != null ? Std.string(parsedData.offset) : "0";
			timeSignatureInput.text = parsedData.timeSignature != null ? parsedData.timeSignature : "4/4";
			loopedCheckbox.checked = parsedData.looped != null ? parsedData.looped : false;
			
			// Load cue points
			cuePoints.clear();
			cuePointCount = 0;
			var cuePointsObj:Dynamic = parsedData.cuePoints;
			if (cuePointsObj != null)
			{
				for (fieldName in Reflect.fields(cuePointsObj))
				{
					cuePoints.set(fieldName, Reflect.field(cuePointsObj, fieldName));
					cuePointCount++;
				}
			}
			updateCuePointsList();
			
			// Load tempo changes
			tempoChanges = [];
			if (parsedData.tempoChanges != null)
			{
				var changes:Array<Dynamic> = parsedData.tempoChanges;
				for (change in changes)
				{
					tempoChanges.push({time: change.time, bpm: change.bpm});
				}
			}
			updateTempoChangesList();
			
			setStatus("Loaded metadata for '" + songName + "'", FlxColor.GREEN);
		}
		catch (e:Dynamic)
		{
			setStatus("Error parsing metadata: " + e, FlxColor.RED);
		}
	}
	
	function onSave():Void
	{
		var songName = songNameInput.text.trim();
		if (songName == "")
		{
			setStatus("Error: Enter a song file name to save.", FlxColor.RED);
			return;
		}
		
		// Parse BPM
		var bpm = Std.parseFloat(bpmInput.text);
		if (Math.isNaN(bpm) || bpm <= 0)
		{
			setStatus("Error: Invalid BPM value.", FlxColor.RED);
			return;
		}
		
		// Parse offset
		var offset = Std.parseFloat(offsetInput.text);
		if (Math.isNaN(offset))
			offset = 0;
		
		// Build metadata object
		var metadata:Dynamic = {
			title: titleInput.text.trim() != "" ? titleInput.text.trim() : songName,
			artist: artistInput.text.trim() != "" ? artistInput.text.trim() : "Unknown",
			bpm: bpm,
			offset: offset,
			timeSignature: timeSignatureInput.text.trim() != "" ? timeSignatureInput.text.trim() : "4/4",
			looped: loopedCheckbox.checked
		};
		
		// Add cue points if any
		if (cuePointCount > 0)
		{
			var cuePointsObj:Dynamic = {};
			for (key in cuePoints.keys())
			{
				Reflect.setField(cuePointsObj, key, cuePoints.get(key));
			}
			metadata.cuePoints = cuePointsObj;
		}
		
		// Add tempo changes if any
		if (tempoChanges.length > 0)
		{
			metadata.tempoChanges = tempoChanges;
		}
		
		// Convert to JSON
		var jsonString = Json.stringify(metadata, null, "\t");
		
		// Save to file
		#if sys
		try
		{
			var filePath = "assets/music/" + songName + ".json";
			File.saveContent(filePath, jsonString);
			setStatus("Saved metadata to '" + filePath + "'", FlxColor.GREEN);
			currentSongName = songName;
		}
		catch (e:Dynamic)
		{
			setStatus("Error saving file: " + e, FlxColor.RED);
		}
		#else
		// For non-sys targets, show the JSON in the console
		trace("Metadata JSON for '" + songName + "':");
		trace(jsonString);
		setStatus("Saved! Check console for JSON output (web/mobile)", FlxColor.YELLOW);
		#end
	}
	
	function onBack():Void
	{
		#if debug
		FlxG.switchState(new DebugState());
		#else
		FlxG.switchState(new PlayState());
		#end
	}
	
	function onAddCuePoint():Void
	{
		// Simple dialog-like approach using input
		var cueName = "cue_" + cuePointCount;
		var cueTime = 0.0;
		
		// In a real implementation, you'd want a proper dialog
		// For now, we'll add a sample cue point
		cuePoints.set(cueName, cueTime);
		cuePointCount++;
		updateCuePointsList();
		setStatus("Added cue point '" + cueName + "'. Edit JSON file for custom values.", FlxColor.YELLOW);
	}
	
	function onClearCuePoints():Void
	{
		cuePoints.clear();
		cuePointCount = 0;
		updateCuePointsList();
		setStatus("Cleared all cue points.", FlxColor.CYAN);
	}
	
	function onAddTempoChange():Void
	{
		// Add a sample tempo change
		var time = 0.0;
		var bpm = Std.parseFloat(bpmInput.text);
		if (Math.isNaN(bpm))
			bpm = 120;
		
		tempoChanges.push({time: time, bpm: bpm});
		updateTempoChangesList();
		setStatus("Added tempo change. Edit JSON file for custom values.", FlxColor.YELLOW);
	}
	
	function onClearTempoChanges():Void
	{
		tempoChanges = [];
		updateTempoChangesList();
		setStatus("Cleared all tempo changes.", FlxColor.CYAN);
	}
	
	function updateCuePointsList():Void
	{
		if (cuePointCount == 0)
		{
			cuePointsListText.text = "(none)";
			cuePointsListText.color = FlxColor.GRAY;
		}
		else
		{
			var list = [];
			for (key in cuePoints.keys())
			{
				list.push(key + ": " + cuePoints.get(key) + "ms");
			}
			cuePointsListText.text = list.join(", ");
			cuePointsListText.color = FlxColor.WHITE;
		}
	}
	
	function updateTempoChangesList():Void
	{
		if (tempoChanges.length == 0)
		{
			tempoChangesListText.text = "(none)";
			tempoChangesListText.color = FlxColor.GRAY;
		}
		else
		{
			var list = [];
			for (change in tempoChanges)
			{
				list.push(change.time + "ms -> " + change.bpm + " BPM");
			}
			tempoChangesListText.text = list.join(", ");
			tempoChangesListText.color = FlxColor.WHITE;
		}
	}
	
	function setStatus(message:String, color:FlxColor):Void
	{
		statusText.text = message;
		statusText.color = color;
	}
	
	override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		// Keyboard shortcuts
		if (FlxG.keys.justPressed.ESCAPE)
		{
			onBack();
		}
		
		#if sys
		// Desktop keyboard shortcuts
		if (FlxG.keys.pressed.CONTROL)
		{
			if (FlxG.keys.justPressed.S)
				onSave();
			if (FlxG.keys.justPressed.O)
				onLoad();
			if (FlxG.keys.justPressed.N)
				onNew();
		}
		#end
	}
}
