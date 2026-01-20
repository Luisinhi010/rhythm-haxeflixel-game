package states;

import backend.MusicMetaData;
import backend.Paths;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import haxe.Json;
import objects.BPMMarker;
import objects.CuePointMarker;
import objects.Song;
import objects.Timeline;
import ui.Button;
import ui.TextField;

#if sys
import sys.io.File;
#end

using Util;

/**
 * Song metadata editor with timeline interface for managing cue points and BPM changes
 */
class MetadataEditorState extends DefaultState
{
	// UI Components
	private var timeline:Timeline;
	private var titleField:TextField;
	private var artistField:TextField;
	private var bpmField:TextField;
	private var offsetField:TextField;
	private var timeSignatureField:TextField;
	
	private var saveButton:Button;
	private var loadButton:Button;
	private var playPauseButton:Button;
	private var addCueButton:Button;
	private var addBPMButton:Button;
	
	private var statusText:FlxText;
	private var timeDisplay:FlxText;
	private var instructionsText:FlxText;
	
	// Metadata
	private var songName:String = "Test";
	private var metaData:MusicMetaData;
	private var music:FlxSound;
	
	// Selection
	private var selectedCueMarker:CuePointMarker;
	private var selectedBPMMarker:BPMMarker;
	
	// UI Lists
	private var cuePointsList:FlxText;
	private var bpmChangesList:FlxText;
	
	override public function create():Void
	{
		FlxG.autoPause = false;
		super.create();
		
		// Background
		var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(20, 20, 20));
		add(bg);
		
		// Title
		var titleLabel = new FlxText(10, 10, 0, "Song Metadata Editor", 16);
		titleLabel.color = FlxColor.WHITE;
		add(titleLabel);
		
		// Timeline (top section)
		timeline = new Timeline(10, 50, FlxG.width - 20, 150);
		add(timeline);
		
		timeline.onTimelineClick = function(time:Float)
		{
			if (music != null)
			{
				music.time = time;
				timeline.updatePlayhead(time);
			}
		};
		
		timeline.onCuePointClick = function(marker:CuePointMarker)
		{
			selectCueMarker(marker);
		};
		
		timeline.onBPMMarkerClick = function(marker:BPMMarker)
		{
			selectBPMMarker(marker);
		};
		
		// Time display
		timeDisplay = new FlxText(10, 210, 200, "Time: 0:00 / 0:00");
		timeDisplay.color = FlxColor.WHITE;
		add(timeDisplay);
		
		// Metadata fields section
		var fieldsY = 240;
		var fieldSpacing = 35;
		
		// Title
		var titleLbl = new FlxText(10, fieldsY, 100, "Title:");
		titleLbl.color = FlxColor.WHITE;
		add(titleLbl);
		titleField = new TextField(120, fieldsY, 200, 25, songName);
		titleField.onChange = function(text:String)
		{
			if (metaData != null) metaData.title = text;
		};
		add(titleField);
		
		// Artist
		fieldsY += fieldSpacing;
		var artistLbl = new FlxText(10, fieldsY, 100, "Artist:");
		artistLbl.color = FlxColor.WHITE;
		add(artistLbl);
		artistField = new TextField(120, fieldsY, 200, 25, "Unknown");
		artistField.onChange = function(text:String)
		{
			if (metaData != null) metaData.artist = text;
		};
		add(artistField);
		
		// BPM
		fieldsY += fieldSpacing;
		var bpmLbl = new FlxText(10, fieldsY, 100, "BPM:");
		bpmLbl.color = FlxColor.WHITE;
		add(bpmLbl);
		bpmField = new TextField(120, fieldsY, 100, 25, "120");
		bpmField.onChange = function(text:String)
		{
			var bpm = Std.parseFloat(text);
			if (!Math.isNaN(bpm) && metaData != null)
			{
				metaData.bpm = bpm;
				timeline.setBPM(bpm);
			}
		};
		add(bpmField);
		
		// Offset
		fieldsY += fieldSpacing;
		var offsetLbl = new FlxText(10, fieldsY, 100, "Offset (ms):");
		offsetLbl.color = FlxColor.WHITE;
		add(offsetLbl);
		offsetField = new TextField(120, fieldsY, 100, 25, "0");
		offsetField.onChange = function(text:String)
		{
			var offset = Std.parseFloat(text);
			if (!Math.isNaN(offset) && metaData != null) metaData.offset = offset;
		};
		add(offsetField);
		
		// Time Signature
		fieldsY += fieldSpacing;
		var timeSigLbl = new FlxText(10, fieldsY, 100, "Time Signature:");
		timeSigLbl.color = FlxColor.WHITE;
		add(timeSigLbl);
		timeSignatureField = new TextField(120, fieldsY, 60, 25, "4/4");
		timeSignatureField.onChange = function(text:String)
		{
			if (metaData != null) metaData.timeSignature = text;
		};
		add(timeSignatureField);
		
		// Buttons section
		var buttonsY = fieldsY + 40;
		
		playPauseButton = new Button(10, buttonsY, "Play", 80, 30, togglePlayPause);
		add(playPauseButton);
		
		addCueButton = new Button(100, buttonsY, "Add Cue", 80, 30, addCuePoint);
		add(addCueButton);
		
		addBPMButton = new Button(190, buttonsY, "Add BPM", 80, 30, addBPMChange);
		add(addBPMButton);
		
		saveButton = new Button(280, buttonsY, "Save", 80, 30, saveMetadata);
		add(saveButton);
		
		loadButton = new Button(370, buttonsY, "Load", 80, 30, loadSong);
		add(loadButton);
		
		// Lists section (right side)
		var listsX = FlxG.width - 250;
		
		var cueListLabel = new FlxText(listsX, 240, 240, "Cue Points:");
		cueListLabel.color = FlxColor.CYAN;
		add(cueListLabel);
		
		cuePointsList = new FlxText(listsX, 260, 240, "");
		cuePointsList.color = FlxColor.WHITE;
		add(cuePointsList);
		
		var bpmListLabel = new FlxText(listsX, 360, 240, "BPM Changes:");
		bpmListLabel.color = FlxColor.ORANGE;
		add(bpmListLabel);
		
		bpmChangesList = new FlxText(listsX, 380, 240, "");
		bpmChangesList.color = FlxColor.WHITE;
		add(bpmChangesList);
		
		// Status text
		statusText = new FlxText(10, FlxG.height - 80, FlxG.width - 20, "");
		statusText.color = FlxColor.LIME;
		add(statusText);
		
		// Instructions
		instructionsText = new FlxText(10, FlxG.height - 60, FlxG.width - 20,
			"SPACE: Play/Pause | CTRL+S: Save | DELETE: Remove Selected | +/- or Wheel: Zoom | ← → : Scroll | Click Timeline to Seek | F5: Reload | M: Back to Debug");
		instructionsText.color = FlxColor.GRAY;
		add(instructionsText);
		
		// Load default song
		loadSong();
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		// Update timeline playhead
		if (music != null && music.playing)
		{
			timeline.updatePlayhead(music.time);
			updateTimeDisplay();
		}
		
		// Check if any text field is focused to avoid conflicts with keyboard shortcuts
		var anyFieldFocused = titleField.focused || artistField.focused || bpmField.focused 
			|| offsetField.focused || timeSignatureField.focused;
		
		// Keyboard shortcuts (only when not typing in fields)
		if (!anyFieldFocused)
		{
			if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.S)
			{
				saveMetadata();
			}
			
			if (FlxG.keys.justPressed.SPACE)
			{
				togglePlayPause();
			}
			
			if (FlxG.keys.justPressed.DELETE)
			{
				deleteSelected();
			}
			
			// Timeline scrolling with arrow keys
			if (FlxG.keys.pressed.LEFT)
			{
				var scroll = timeline.scrollX - (100 * elapsed);
				timeline.setScroll(scroll);
			}
			if (FlxG.keys.pressed.RIGHT)
			{
				var scroll = timeline.scrollX + (100 * elapsed);
				timeline.setScroll(scroll);
			}
			
			// Zoom with +/- keys
			if (FlxG.keys.justPressed.PLUS || FlxG.keys.justPressed.NUMPADPLUS)
			{
				var newZoom = timeline.zoom * 1.2;
				timeline.setZoom(newZoom);
			}
			if (FlxG.keys.justPressed.MINUS || FlxG.keys.justPressed.NUMPADMINUS)
			{
				var newZoom = timeline.zoom * 0.8;
				timeline.setZoom(newZoom);
			}
			
			// Go back to debug state
			if (FlxG.keys.justPressed.M)
			{
				FlxG.switchState(new DebugState());
			}
		}
	}
	
	private function loadSong():Void
	{
		try
		{
			var song = new Song(songName);
			metaData = song.metaData;
			music = song.music;
			
			if (metaData != null)
			{
				// Update fields
				titleField.setText(metaData.title);
				artistField.setText(metaData.artist);
				bpmField.setText(Std.string(metaData.bpm));
				offsetField.setText(Std.string(metaData.offset != null ? metaData.offset : 0));
				timeSignatureField.setText(metaData.timeSignature != null ? metaData.timeSignature : "4/4");
				
				// Update timeline
				timeline.setBPM(metaData.bpm);
				if (music != null)
				{
					timeline.setSongDuration(music.length);
				}
				
				// Clear existing markers
				timeline.clearMarkers();
				
				// Load cue points
				if (metaData.cuePoints != null)
				{
					for (name in metaData.cuePoints.keys())
					{
						var time = metaData.cuePoints.get(name);
						timeline.addCueMarker(name, time);
					}
				}
				
				// Load tempo changes
				if (metaData.tempoChanges != null)
				{
					for (change in metaData.tempoChanges)
					{
						timeline.addBPMMarker(change.time, change.bpm);
					}
				}
				
				updateLists();
				setStatus('Loaded song: ${metaData.title}');
			}
		}
		catch (e:Dynamic)
		{
			setStatus('Error loading song: $e');
		}
	}
	
	private function saveMetadata():Void
	{
		#if (sys && !android && !ios)
		try
		{
			// Build metadata object for JSON export
			var exportData:Dynamic = {
				title: metaData.title,
				artist: metaData.artist,
				bpm: metaData.bpm,
				offset: metaData.offset,
				timeSignature: metaData.timeSignature
			};
			
			// Convert cue points map to object
			if (metaData.cuePoints != null && metaData.cuePoints.keys().hasNext())
			{
				var cueObj:Dynamic = {};
				for (name in metaData.cuePoints.keys())
				{
					Reflect.setField(cueObj, name, metaData.cuePoints.get(name));
				}
				exportData.cuePoints = cueObj;
			}
			
			// Add tempo changes
			if (metaData.tempoChanges != null && metaData.tempoChanges.length > 0)
			{
				exportData.tempoChanges = metaData.tempoChanges;
			}
			
			// Add looped flag if exists
			if (metaData.looped != null)
			{
				exportData.looped = metaData.looped;
			}
			
			var jsonString = Json.stringify(exportData, null, "\t");
			
			// Determine save path
			var savePath = 'assets/music/$songName.json';
			
			// Try to get writable path
			savePath = savePath.getWritablePath();
			
			File.saveContent(savePath, jsonString);
			setStatus('Saved metadata to: $savePath');
		}
		catch (e:Dynamic)
		{
			setStatus('Error saving: $e');
		}
		#else
		setStatus('Saving not supported on this platform');
		#end
	}
	
	private function togglePlayPause():Void
	{
		if (music == null) return;
		
		if (music.playing)
		{
			music.pause();
			playPauseButton.label.text = "Play";
		}
		else
		{
			music.play();
			playPauseButton.label.text = "Pause";
		}
	}
	
	private function addCuePoint():Void
	{
		if (metaData == null) return;
		
		var time = music != null ? music.time : 0;
		var name = 'cue_${Math.floor(time / 1000)}';
		
		if (metaData.cuePoints == null)
		{
			metaData.cuePoints = new Map<String, Float>();
		}
		
		metaData.cuePoints.set(name, time);
		timeline.addCueMarker(name, time);
		updateLists();
		setStatus('Added cue point: $name at ${formatTime(time)}');
	}
	
	private function addBPMChange():Void
	{
		if (metaData == null) return;
		
		var time = music != null ? music.time : 0;
		var currentBPM = metaData.bpm;
		
		if (metaData.tempoChanges == null)
		{
			metaData.tempoChanges = [];
		}
		
		metaData.tempoChanges.push({time: time, bpm: currentBPM});
		timeline.addBPMMarker(time, currentBPM);
		updateLists();
		setStatus('Added BPM change: ${currentBPM} at ${formatTime(time)}');
	}
	
	private function deleteSelected():Void
	{
		if (selectedCueMarker != null)
		{
			var name = selectedCueMarker.cuePointName;
			if (metaData.cuePoints != null && metaData.cuePoints.exists(name))
			{
				metaData.cuePoints.remove(name);
				timeline.removeCueMarker(selectedCueMarker);
				selectedCueMarker = null;
				updateLists();
				setStatus('Deleted cue point: $name');
			}
		}
		else if (selectedBPMMarker != null)
		{
			if (metaData.tempoChanges != null)
			{
				metaData.tempoChanges = metaData.tempoChanges.filter(function(change)
				{
					return change.time != selectedBPMMarker.timestamp;
				});
				timeline.removeBPMMarker(selectedBPMMarker);
				selectedBPMMarker = null;
				updateLists();
				setStatus('Deleted BPM change');
			}
		}
	}
	
	private function selectCueMarker(marker:CuePointMarker):Void
	{
		// Deselect previous
		if (selectedCueMarker != null)
		{
			selectedCueMarker.setSelected(false);
		}
		if (selectedBPMMarker != null)
		{
			selectedBPMMarker.setSelected(false);
			selectedBPMMarker = null;
		}
		
		selectedCueMarker = marker;
		marker.setSelected(true);
		setStatus('Selected cue point: ${marker.cuePointName}');
	}
	
	private function selectBPMMarker(marker:BPMMarker):Void
	{
		// Deselect previous
		if (selectedCueMarker != null)
		{
			selectedCueMarker.setSelected(false);
			selectedCueMarker = null;
		}
		if (selectedBPMMarker != null)
		{
			selectedBPMMarker.setSelected(false);
		}
		
		selectedBPMMarker = marker;
		marker.setSelected(true);
		setStatus('Selected BPM change: ${marker.bpm} BPM at ${formatTime(marker.timestamp)}');
	}
	
	private function updateLists():Void
	{
		// Update cue points list
		var cueText = "";
		if (metaData.cuePoints != null)
		{
			for (name in metaData.cuePoints.keys())
			{
				var time = metaData.cuePoints.get(name);
				cueText += '$name: ${formatTime(time)}\n';
			}
		}
		cuePointsList.text = cueText.length > 0 ? cueText : "(none)";
		
		// Update BPM changes list
		var bpmText = "";
		if (metaData.tempoChanges != null)
		{
			for (change in metaData.tempoChanges)
			{
				bpmText += '${formatTime(change.time)}: ${change.bpm} BPM\n';
			}
		}
		bpmChangesList.text = bpmText.length > 0 ? bpmText : "(none)";
	}
	
	private function updateTimeDisplay():Void
	{
		if (music != null)
		{
			var current = formatTime(music.time);
			var total = formatTime(music.length);
			timeDisplay.text = 'Time: $current / $total';
		}
	}
	
	private function formatTime(ms:Float):String
	{
		var seconds = Math.floor(ms / 1000);
		var minutes = Math.floor(seconds / 60);
		var remainingSeconds = seconds % 60;
		return '$minutes:${remainingSeconds < 10 ? "0" : ""}$remainingSeconds';
	}
	
	private function setStatus(message:String):Void
	{
		statusText.text = message;
		#if debug
		trace(message);
		#end
	}
}
