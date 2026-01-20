package states;

import backend.MusicMetaData;
import backend.Paths;
import flixel.FlxG;
import flixel.util.FlxColor;
import haxe.Json;
import haxe.ui.ComponentBuilder;
import haxe.ui.Toolkit;
import haxe.ui.components.Button;
import haxe.ui.components.CheckBox;
import haxe.ui.components.Label;
import haxe.ui.components.NumberStepper;
import haxe.ui.components.TextField;
import haxe.ui.components.VBox;
import haxe.ui.containers.Box;
import haxe.ui.containers.HBox;
import haxe.ui.containers.ScrollView;
import haxe.ui.containers.VBox as HaxeUIVBox;
import haxe.ui.core.Screen;
#if sys
import sys.FileSystem;
import sys.io.File;
#end

/**
 * Metadata Editor State using Haxe-UI for cross-platform compatibility
 * Provides a comprehensive interface for editing music metadata files
 */
class MetadataEditorState extends DefaultState
{
	var mainContainer:ScrollView;
	var titleField:TextField;
	var artistField:TextField;
	var bpmStepper:NumberStepper;
	var offsetStepper:NumberStepper;
	var timeSignatureField:TextField;
	var loopedCheckbox:CheckBox;
	var cuePointsContainer:HaxeUIVBox;
	var tempoChangesContainer:HaxeUIVBox;
	var statusLabel:Label;
	
	var currentMetadata:MusicMetaData;
	var currentFilePath:String = "";
	
	override public function create():Void
	{
		super.create();
		
		// Initialize Haxe-UI
		Toolkit.init();
		Toolkit.theme = "dark";
		Toolkit.autoScale = true;
		
		// Set background color
		FlxG.camera.bgColor = FlxColor.fromRGB(25, 25, 35);
		
		// Initialize with default metadata
		currentMetadata = {
			title: "New Song",
			artist: "Unknown Artist",
			bpm: 120.0,
			offset: 0.0,
			timeSignature: "4/4",
			cuePoints: new Map<String, Float>(),
			tempoChanges: [],
			looped: false
		};
		
		buildUI();
	}
	
	function buildUI():Void
	{
		// Main container with scrolling
		mainContainer = new ScrollView();
		mainContainer.percentWidth = 100;
		mainContainer.percentHeight = 100;
		Screen.instance.addComponent(mainContainer);
		
		var content = new HaxeUIVBox();
		content.percentWidth = 100;
		content.styleString = "padding: 20px; spacing: 15px;";
		
		// Title
		var headerLabel = new Label();
		headerLabel.text = "Metadata Editor";
		headerLabel.styleString = "font-size: 32px; font-bold: true;";
		content.addComponent(headerLabel);
		
		// File Operations Section
		content.addComponent(createFileOperationsSection());
		
		// Basic Metadata Section
		content.addComponent(createSeparator());
		content.addComponent(createBasicMetadataSection());
		
		// Advanced Options Section
		content.addComponent(createSeparator());
		content.addComponent(createAdvancedOptionsSection());
		
		// Cue Points Section
		content.addComponent(createSeparator());
		content.addComponent(createCuePointsSection());
		
		// Tempo Changes Section
		content.addComponent(createSeparator());
		content.addComponent(createTempoChangesSection());
		
		// Status Label
		statusLabel = new Label();
		statusLabel.text = "Ready";
		statusLabel.styleString = "font-size: 14px; color: #88FF88;";
		content.addComponent(statusLabel);
		
		// Back Button
		var backBtn = new Button();
		backBtn.text = "Back to Menu";
		backBtn.styleString = "padding: 10px 20px; font-size: 16px;";
		backBtn.onClick = function(_) {
			Screen.instance.removeComponent(mainContainer);
			FlxG.switchState(new MainMenuState());
		};
		content.addComponent(backBtn);
		
		mainContainer.addComponent(content);
		
		// Load form with current metadata
		loadFormData();
	}
	
	function createFileOperationsSection():HaxeUIVBox
	{
		var section = new HaxeUIVBox();
		section.styleString = "spacing: 10px;";
		
		var sectionLabel = new Label();
		sectionLabel.text = "File Operations";
		sectionLabel.styleString = "font-size: 20px; font-bold: true;";
		section.addComponent(sectionLabel);
		
		var buttonBox = new HBox();
		buttonBox.styleString = "spacing: 10px;";
		
		var newBtn = new Button();
		newBtn.text = "New";
		newBtn.onClick = function(_) { newMetadata(); };
		buttonBox.addComponent(newBtn);
		
		var loadBtn = new Button();
		loadBtn.text = "Load";
		loadBtn.onClick = function(_) { loadMetadata(); };
		buttonBox.addComponent(loadBtn);
		
		var saveBtn = new Button();
		saveBtn.text = "Save";
		saveBtn.onClick = function(_) { saveMetadata(); };
		buttonBox.addComponent(saveBtn);
		
		var saveAsBtn = new Button();
		saveAsBtn.text = "Save As";
		saveAsBtn.onClick = function(_) { saveMetadataAs(); };
		buttonBox.addComponent(saveAsBtn);
		
		section.addComponent(buttonBox);
		
		return section;
	}
	
	function createBasicMetadataSection():HaxeUIVBox
	{
		var section = new HaxeUIVBox();
		section.styleString = "spacing: 10px;";
		
		var sectionLabel = new Label();
		sectionLabel.text = "Basic Metadata";
		sectionLabel.styleString = "font-size: 20px; font-bold: true;";
		section.addComponent(sectionLabel);
		
		// Title
		section.addComponent(createFieldLabel("Title:"));
		titleField = new TextField();
		titleField.placeholder = "Song title";
		titleField.percentWidth = 100;
		section.addComponent(titleField);
		
		// Artist
		section.addComponent(createFieldLabel("Artist:"));
		artistField = new TextField();
		artistField.placeholder = "Artist name";
		artistField.percentWidth = 100;
		section.addComponent(artistField);
		
		// BPM
		section.addComponent(createFieldLabel("BPM (Beats Per Minute):"));
		bpmStepper = new NumberStepper();
		bpmStepper.min = 1;
		bpmStepper.max = 999;
		bpmStepper.step = 0.1;
		bpmStepper.pos = 120;
		bpmStepper.precision = 1;
		section.addComponent(bpmStepper);
		
		// Offset
		section.addComponent(createFieldLabel("Offset (milliseconds):"));
		offsetStepper = new NumberStepper();
		offsetStepper.min = -10000;
		offsetStepper.max = 10000;
		offsetStepper.step = 10;
		offsetStepper.pos = 0;
		section.addComponent(offsetStepper);
		
		// Time Signature
		section.addComponent(createFieldLabel("Time Signature:"));
		timeSignatureField = new TextField();
		timeSignatureField.placeholder = "e.g., 4/4, 3/4, 6/8";
		timeSignatureField.percentWidth = 100;
		section.addComponent(timeSignatureField);
		
		return section;
	}
	
	function createAdvancedOptionsSection():HaxeUIVBox
	{
		var section = new HaxeUIVBox();
		section.styleString = "spacing: 10px;";
		
		var sectionLabel = new Label();
		sectionLabel.text = "Advanced Options";
		sectionLabel.styleString = "font-size: 20px; font-bold: true;";
		section.addComponent(sectionLabel);
		
		// Looped
		loopedCheckbox = new CheckBox();
		loopedCheckbox.text = "Loop music playback";
		section.addComponent(loopedCheckbox);
		
		return section;
	}
	
	function createCuePointsSection():HaxeUIVBox
	{
		var section = new HaxeUIVBox();
		section.styleString = "spacing: 10px;";
		
		var sectionLabel = new Label();
		sectionLabel.text = "Cue Points";
		sectionLabel.styleString = "font-size: 20px; font-bold: true;";
		section.addComponent(sectionLabel);
		
		var infoLabel = new Label();
		infoLabel.text = "Cue points are named markers in the music (in milliseconds)";
		infoLabel.styleString = "font-size: 12px; color: #AAAAAA;";
		section.addComponent(infoLabel);
		
		cuePointsContainer = new HaxeUIVBox();
		cuePointsContainer.styleString = "spacing: 5px;";
		section.addComponent(cuePointsContainer);
		
		var addCueBtn = new Button();
		addCueBtn.text = "Add Cue Point";
		addCueBtn.onClick = function(_) { addCuePointRow(); };
		section.addComponent(addCueBtn);
		
		return section;
	}
	
	function createTempoChangesSection():HaxeUIVBox
	{
		var section = new HaxeUIVBox();
		section.styleString = "spacing: 10px;";
		
		var sectionLabel = new Label();
		sectionLabel.text = "Tempo Changes";
		sectionLabel.styleString = "font-size: 20px; font-bold: true;";
		section.addComponent(sectionLabel);
		
		var infoLabel = new Label();
		infoLabel.text = "Define BPM changes at specific times (in milliseconds)";
		infoLabel.styleString = "font-size: 12px; color: #AAAAAA;";
		section.addComponent(infoLabel);
		
		tempoChangesContainer = new HaxeUIVBox();
		tempoChangesContainer.styleString = "spacing: 5px;";
		section.addComponent(tempoChangesContainer);
		
		var addTempoBtn = new Button();
		addTempoBtn.text = "Add Tempo Change";
		addTempoBtn.onClick = function(_) { addTempoChangeRow(); };
		section.addComponent(addTempoBtn);
		
		return section;
	}
	
	function createFieldLabel(text:String):Label
	{
		var label = new Label();
		label.text = text;
		label.styleString = "font-size: 14px; font-bold: true;";
		return label;
	}
	
	function createSeparator():Box
	{
		var separator = new Box();
		separator.percentWidth = 100;
		separator.height = 1;
		separator.styleString = "background-color: #444444;";
		return separator;
	}
	
	function addCuePointRow(?name:String, ?time:Float):Void
	{
		var row = new HBox();
		row.styleString = "spacing: 5px;";
		
		var nameField = new TextField();
		nameField.placeholder = "Cue name";
		nameField.width = 200;
		nameField.id = "cueName";
		if (name != null) nameField.text = name;
		row.addComponent(nameField);
		
		var timeStepper = new NumberStepper();
		timeStepper.min = 0;
		timeStepper.max = 999999;
		timeStepper.step = 100;
		timeStepper.pos = time != null ? time : 0;
		timeStepper.width = 150;
		timeStepper.id = "cueTime";
		row.addComponent(timeStepper);
		
		var removeBtn = new Button();
		removeBtn.text = "Remove";
		removeBtn.onClick = function(_) {
			cuePointsContainer.removeComponent(row);
		};
		row.addComponent(removeBtn);
		
		cuePointsContainer.addComponent(row);
	}
	
	function addTempoChangeRow(?time:Float, ?bpm:Float):Void
	{
		var row = new HBox();
		row.styleString = "spacing: 5px;";
		
		var timeLabel = new Label();
		timeLabel.text = "Time (ms):";
		row.addComponent(timeLabel);
		
		var timeStepper = new NumberStepper();
		timeStepper.min = 0;
		timeStepper.max = 999999;
		timeStepper.step = 100;
		timeStepper.pos = time != null ? time : 0;
		timeStepper.width = 150;
		timeStepper.id = "tempoTime";
		row.addComponent(timeStepper);
		
		var bpmLabel = new Label();
		bpmLabel.text = "BPM:";
		row.addComponent(bpmLabel);
		
		var bpmStepper = new NumberStepper();
		bpmStepper.min = 1;
		bpmStepper.max = 999;
		bpmStepper.step = 0.1;
		bpmStepper.pos = bpm != null ? bpm : 120;
		bpmStepper.precision = 1;
		bpmStepper.width = 120;
		bpmStepper.id = "tempoBpm";
		row.addComponent(bpmStepper);
		
		var removeBtn = new Button();
		removeBtn.text = "Remove";
		removeBtn.onClick = function(_) {
			tempoChangesContainer.removeComponent(row);
		};
		row.addComponent(removeBtn);
		
		tempoChangesContainer.addComponent(row);
	}
	
	function loadFormData():Void
	{
		titleField.text = currentMetadata.title;
		artistField.text = currentMetadata.artist;
		bpmStepper.pos = currentMetadata.bpm;
		offsetStepper.pos = currentMetadata.offset;
		timeSignatureField.text = currentMetadata.timeSignature;
		loopedCheckbox.selected = currentMetadata.looped;
		
		// Clear and reload cue points
		cuePointsContainer.removeAllComponents();
		if (currentMetadata.cuePoints != null)
		{
			for (name in currentMetadata.cuePoints.keys())
			{
				addCuePointRow(name, currentMetadata.cuePoints.get(name));
			}
		}
		
		// Clear and reload tempo changes
		tempoChangesContainer.removeAllComponents();
		if (currentMetadata.tempoChanges != null)
		{
			for (change in currentMetadata.tempoChanges)
			{
				addTempoChangeRow(change.time, change.bpm);
			}
		}
	}
	
	function saveFormData():Void
	{
		currentMetadata.title = titleField.text;
		currentMetadata.artist = artistField.text;
		currentMetadata.bpm = bpmStepper.pos;
		currentMetadata.offset = offsetStepper.pos;
		currentMetadata.timeSignature = timeSignatureField.text;
		currentMetadata.looped = loopedCheckbox.selected;
		
		// Save cue points
		currentMetadata.cuePoints = new Map<String, Float>();
		for (component in cuePointsContainer.childComponents)
		{
			if (Std.isOfType(component, HBox))
			{
				var row = cast(component, HBox);
				var nameField:TextField = row.findComponent("cueName", TextField);
				var timeStepper:NumberStepper = row.findComponent("cueTime", NumberStepper);
				if (nameField != null && timeStepper != null && nameField.text != null && nameField.text.length > 0)
				{
					currentMetadata.cuePoints.set(nameField.text, timeStepper.pos);
				}
			}
		}
		
		// Save tempo changes
		currentMetadata.tempoChanges = [];
		for (component in tempoChangesContainer.childComponents)
		{
			if (Std.isOfType(component, HBox))
			{
				var row = cast(component, HBox);
				var timeStepper:NumberStepper = row.findComponent("tempoTime", NumberStepper);
				var bpmStepper:NumberStepper = row.findComponent("tempoBpm", NumberStepper);
				if (timeStepper != null && bpmStepper != null)
				{
					currentMetadata.tempoChanges.push({
						time: timeStepper.pos,
						bpm: bpmStepper.pos
					});
				}
			}
		}
	}
	
	function newMetadata():Void
	{
		currentMetadata = {
			title: "New Song",
			artist: "Unknown Artist",
			bpm: 120.0,
			offset: 0.0,
			timeSignature: "4/4",
			cuePoints: new Map<String, Float>(),
			tempoChanges: [],
			looped: false
		};
		currentFilePath = "";
		loadFormData();
		setStatus("New metadata created", true);
	}
	
	function loadMetadata():Void
	{
		#if sys
		// List available metadata files
		var musicPath = "assets/music";
		if (FileSystem.exists(musicPath) && FileSystem.isDirectory(musicPath))
		{
			var files = FileSystem.readDirectory(musicPath);
			var jsonFiles = files.filter(f -> f.endsWith(".json"));
			
			if (jsonFiles.length > 0)
			{
				// For simplicity, load the first available file
				// In a real implementation, you'd show a file picker dialog
				var fileName = jsonFiles[0];
				var filePath = musicPath + "/" + fileName;
				
				setStatus("Loading: " + fileName + "...", true);
				
				try
				{
					var content = File.getContent(filePath);
					var parsed:Dynamic = Json.parse(content);
					
					// Convert cuePoints from object to Map
					var cuePointsMap = new Map<String, Float>();
					if (parsed.cuePoints != null)
					{
						for (field in Reflect.fields(parsed.cuePoints))
						{
							cuePointsMap.set(field, Reflect.field(parsed.cuePoints, field));
						}
					}
					
					currentMetadata = {
						title: parsed.title != null ? parsed.title : "Unknown",
						artist: parsed.artist != null ? parsed.artist : "Unknown",
						bpm: parsed.bpm != null ? parsed.bpm : 120.0,
						offset: parsed.offset != null ? parsed.offset : 0.0,
						timeSignature: parsed.timeSignature != null ? parsed.timeSignature : "4/4",
						cuePoints: cuePointsMap,
						tempoChanges: parsed.tempoChanges != null ? parsed.tempoChanges : [],
						looped: parsed.looped != null ? parsed.looped : false
					};
					
					currentFilePath = filePath;
					loadFormData();
					setStatus("Successfully loaded: " + fileName, true);
				}
				catch (e:Dynamic)
				{
					setStatus("Error loading file: " + e, false);
				}
			}
			else
			{
				setStatus("No JSON files found in assets/music", false);
			}
		}
		else
		{
			setStatus("Music directory not found", false);
		}
		#else
		setStatus("Load not supported on this platform", false);
		#end
	}
	
	function saveMetadata():Void
	{
		if (currentFilePath == "")
		{
			saveMetadataAs();
			return;
		}
		
		saveFormData();
		
		#if sys
		try
		{
			var jsonString = metadataToJson();
			File.saveContent(currentFilePath, jsonString);
			setStatus("Saved: " + currentFilePath, true);
		}
		catch (e:Dynamic)
		{
			setStatus("Error saving: " + e, false);
		}
		#else
		setStatus("Save not supported on this platform", false);
		#end
	}
	
	function saveMetadataAs():Void
	{
		saveFormData();
		
		#if sys
		// In a real implementation, you'd show a file picker dialog
		// For now, save with a default name based on the title
		var fileName = sanitizeFileName(currentMetadata.title) + ".json";
		var filePath = "assets/music/" + fileName;
		
		try
		{
			var jsonString = metadataToJson();
			File.saveContent(filePath, jsonString);
			currentFilePath = filePath;
			setStatus("Saved as: " + fileName, true);
		}
		catch (e:Dynamic)
		{
			setStatus("Error saving: " + e, false);
		}
		#else
		setStatus("Save not supported on this platform", false);
		#end
	}
	
	function sanitizeFileName(name:String):String
	{
		// Replace spaces with underscores
		var sanitized = StringTools.replace(name, " ", "_");
		// Remove or replace invalid characters for file names
		var invalidChars = ["<", ">", ":", "\"", "/", "\\", "|", "?", "*"];
		for (char in invalidChars)
		{
			sanitized = StringTools.replace(sanitized, char, "_");
		}
		// Ensure the name is not empty
		if (sanitized.length == 0)
		{
			sanitized = "metadata";
		}
		return sanitized;
	}
	
	function metadataToJson():String
	{
		// Convert Map to object for JSON serialization
		var cuePointsObj:Dynamic = {};
		if (currentMetadata.cuePoints != null)
		{
			for (name in currentMetadata.cuePoints.keys())
			{
				Reflect.setField(cuePointsObj, name, currentMetadata.cuePoints.get(name));
			}
		}
		
		var obj:Dynamic = {
			title: currentMetadata.title,
			artist: currentMetadata.artist,
			bpm: currentMetadata.bpm,
			offset: currentMetadata.offset,
			timeSignature: currentMetadata.timeSignature,
			looped: currentMetadata.looped
		};
		
		// Only add cuePoints if not empty
		if (Lambda.count(currentMetadata.cuePoints) > 0)
		{
			obj.cuePoints = cuePointsObj;
		}
		
		// Only add tempoChanges if not empty
		if (currentMetadata.tempoChanges != null && currentMetadata.tempoChanges.length > 0)
		{
			obj.tempoChanges = currentMetadata.tempoChanges;
		}
		
		return Json.stringify(obj, null, "    ");
	}
	
	function setStatus(message:String, success:Bool):Void
	{
		statusLabel.text = message;
		statusLabel.styleString = "font-size: 14px; color: " + (success ? "#88FF88" : "#FF8888") + ";";
		
		#if debug
		trace("MetadataEditor: " + message);
		#end
	}
	
	override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		// Keyboard shortcut to go back
		if (FlxG.keys.justPressed.ESCAPE)
		{
			Screen.instance.removeComponent(mainContainer);
			FlxG.switchState(new MainMenuState());
		}
	}
	
	override function destroy():Void
	{
		// Clean up UI components
		if (mainContainer != null && Screen.instance != null)
		{
			Screen.instance.removeComponent(mainContainer);
		}
		
		super.destroy();
	}
}
