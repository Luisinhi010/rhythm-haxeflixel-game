package tools;

#if sys
import backend.MusicMetaDataBuilder;
import backend.Paths;
import sys.io.File;
import sys.FileSystem;

/**
 * Interactive command-line tool to create and edit song metadata.
 * This provides a better way to create metadata files than manually editing JSON.
 * 
 * Usage:
 * ```
 * lime test neko -Dmetadata_creator
 * ```
 * or
 * ```
 * haxe -main tools.MetadataCreator -lib hxcpp -cpp bin
 * ./bin/MetadataCreator
 * ```
 */
class MetadataCreator
{
	private static var builder:MusicMetaDataBuilder;
	private static var musicName:String;
	
	public static function main():Void
	{
		trace("==============================================");
		trace("  Music Metadata Creator");
		trace("==============================================");
		trace("");
		
		mainMenu();
	}
	
	private static function mainMenu():Void
	{
		trace("\nMain Menu:");
		trace("1. Create new metadata");
		trace("2. Edit existing metadata");
		trace("3. Exit");
		trace("");
		
		var choice = readLine("Enter your choice (1-3): ");
		
		switch (choice)
		{
			case "1":
				createNew();
			case "2":
				editExisting();
			case "3":
				trace("Goodbye!");
				Sys.exit(0);
			default:
				trace("Invalid choice. Please try again.");
				mainMenu();
		}
	}
	
	private static function createNew():Void
	{
		trace("\n--- Create New Metadata ---");
		builder = new MusicMetaDataBuilder();
		
		musicName = readLine("Enter song filename (without extension): ");
		
		var title = readLine("Enter song title: ");
		builder.setTitle(title);
		
		var artist = readLine("Enter artist name: ");
		builder.setArtist(artist);
		
		var bpmStr = readLine("Enter BPM (beats per minute): ");
		var bpm = Std.parseFloat(bpmStr);
		if (bpm == null || bpm <= 0)
		{
			trace("Invalid BPM. Using default 120.");
			bpm = 120;
		}
		builder.setBPM(bpm);
		
		var offsetStr = readLine("Enter offset in milliseconds (press Enter for 0): ");
		if (offsetStr != "")
		{
			var offset = Std.parseFloat(offsetStr);
			if (offset != null)
				builder.setOffset(offset);
		}
		
		var timeSignature = readLine("Enter time signature (press Enter for 4/4): ");
		if (timeSignature != "")
		{
			try
			{
				builder.setTimeSignature(timeSignature);
			}
			catch (e:Dynamic)
			{
				trace("Invalid time signature. Using default 4/4.");
			}
		}
		
		var loopedStr = readLine("Should the song loop? (y/n, press Enter for no): ");
		builder.setLooped(loopedStr.toLowerCase() == "y" || loopedStr.toLowerCase() == "yes");
		
		editMenu();
	}
	
	private static function editExisting():Void
	{
		trace("\n--- Edit Existing Metadata ---");
		musicName = readLine("Enter song filename (without extension): ");
		
		var jsonPath = 'assets/music/$musicName.json';
		if (!FileSystem.exists(jsonPath))
		{
			trace('Metadata file not found: $jsonPath');
			trace("Would you like to create a new one? (y/n): ");
			var create = readLine("");
			if (create.toLowerCase() == "y" || create.toLowerCase() == "yes")
			{
				createNew();
				return;
			}
			mainMenu();
			return;
		}
		
		try
		{
			var jsonContent = File.getContent(jsonPath);
			builder = MusicMetaDataBuilder.fromJson(jsonContent);
			trace("Metadata loaded successfully!");
			editMenu();
		}
		catch (e:Dynamic)
		{
			trace('Error loading metadata: $e');
			mainMenu();
		}
	}
	
	private static function editMenu():Void
	{
		trace("\n--- Edit Menu ---");
		trace("1. Add cue point");
		trace("2. Add cue point at beat");
		trace("3. Add cue point at measure");
		trace("4. Add tempo change");
		trace("5. Add tempo change at beat");
		trace("6. Add tempo change at measure");
		trace("7. Change basic info (title, artist, BPM, etc.)");
		trace("8. Preview JSON");
		trace("9. Save and exit");
		trace("0. Exit without saving");
		trace("");
		
		var choice = readLine("Enter your choice (0-9): ");
		
		switch (choice)
		{
			case "1":
				addCuePoint();
			case "2":
				addCuePointAtBeat();
			case "3":
				addCuePointAtMeasure();
			case "4":
				addTempoChange();
			case "5":
				addTempoChangeAtBeat();
			case "6":
				addTempoChangeAtMeasure();
			case "7":
				changeBasicInfo();
			case "8":
				previewJson();
			case "9":
				saveMetadata();
			case "0":
				trace("Discarding changes...");
				mainMenu();
			default:
				trace("Invalid choice. Please try again.");
				editMenu();
		}
	}
	
	private static function addCuePoint():Void
	{
		var name = readLine("Enter cue point name: ");
		var timeStr = readLine("Enter time in milliseconds: ");
		var time = Std.parseFloat(timeStr);
		
		if (time == null || time < 0)
		{
			trace("Invalid time. Cue point not added.");
		}
		else
		{
			builder.addCuePoint(name, time);
			trace('Cue point "$name" added at ${time}ms');
		}
		
		editMenu();
	}
	
	private static function addCuePointAtBeat():Void
	{
		var name = readLine("Enter cue point name: ");
		var beatStr = readLine("Enter beat number (0-based): ");
		var beat = Std.parseFloat(beatStr);
		
		if (beat == null || beat < 0)
		{
			trace("Invalid beat number. Cue point not added.");
		}
		else
		{
			builder.addCuePointAtBeat(name, beat);
			var time = (beat * 60000) / builder.build().bpm;
			trace('Cue point "$name" added at beat $beat (${time}ms)');
		}
		
		editMenu();
	}
	
	private static function addCuePointAtMeasure():Void
	{
		var name = readLine("Enter cue point name: ");
		var measureStr = readLine("Enter measure/bar number (0-based): ");
		var measure = Std.parseFloat(measureStr);
		
		if (measure == null || measure < 0)
		{
			trace("Invalid measure number. Cue point not added.");
		}
		else
		{
			builder.addCuePointAtMeasure(name, measure);
			trace('Cue point "$name" added at measure $measure');
		}
		
		editMenu();
	}
	
	private static function addTempoChange():Void
	{
		var timeStr = readLine("Enter time in milliseconds: ");
		var time = Std.parseFloat(timeStr);
		var bpmStr = readLine("Enter new BPM: ");
		var bpm = Std.parseFloat(bpmStr);
		
		if (time == null || time < 0 || bpm == null || bpm <= 0)
		{
			trace("Invalid input. Tempo change not added.");
		}
		else
		{
			builder.addTempoChange(time, bpm);
			trace('Tempo change added: ${bpm} BPM at ${time}ms');
		}
		
		editMenu();
	}
	
	private static function addTempoChangeAtBeat():Void
	{
		var beatStr = readLine("Enter beat number (0-based): ");
		var beat = Std.parseFloat(beatStr);
		var bpmStr = readLine("Enter new BPM: ");
		var bpm = Std.parseFloat(bpmStr);
		
		if (beat == null || beat < 0 || bpm == null || bpm <= 0)
		{
			trace("Invalid input. Tempo change not added.");
		}
		else
		{
			builder.addTempoChangeAtBeat(beat, bpm);
			trace('Tempo change added: ${bpm} BPM at beat $beat');
		}
		
		editMenu();
	}
	
	private static function addTempoChangeAtMeasure():Void
	{
		var measureStr = readLine("Enter measure/bar number (0-based): ");
		var measure = Std.parseFloat(measureStr);
		var bpmStr = readLine("Enter new BPM: ");
		var bpm = Std.parseFloat(bpmStr);
		
		if (measure == null || measure < 0 || bpm == null || bpm <= 0)
		{
			trace("Invalid input. Tempo change not added.");
		}
		else
		{
			builder.addTempoChangeAtMeasure(measure, bpm);
			trace('Tempo change added: ${bpm} BPM at measure $measure');
		}
		
		editMenu();
	}
	
	private static function changeBasicInfo():Void
	{
		trace("\n--- Change Basic Info ---");
		var metadata = builder.build();
		
		trace('Current title: ${metadata.title}');
		var title = readLine("Enter new title (press Enter to keep): ");
		if (title != "")
			builder.setTitle(title);
		
		trace('Current artist: ${metadata.artist}');
		var artist = readLine("Enter new artist (press Enter to keep): ");
		if (artist != "")
			builder.setArtist(artist);
		
		trace('Current BPM: ${metadata.bpm}');
		var bpmStr = readLine("Enter new BPM (press Enter to keep): ");
		if (bpmStr != "")
		{
			var bpm = Std.parseFloat(bpmStr);
			if (bpm != null && bpm > 0)
				builder.setBPM(bpm);
		}
		
		trace('Current offset: ${metadata.offset}ms');
		var offsetStr = readLine("Enter new offset in ms (press Enter to keep): ");
		if (offsetStr != "")
		{
			var offset = Std.parseFloat(offsetStr);
			if (offset != null)
				builder.setOffset(offset);
		}
		
		trace('Current time signature: ${metadata.timeSignature}');
		var timeSignature = readLine("Enter new time signature (press Enter to keep): ");
		if (timeSignature != "")
		{
			try
			{
				builder.setTimeSignature(timeSignature);
			}
			catch (e:Dynamic)
			{
				trace("Invalid time signature. Keeping current value.");
			}
		}
		
		trace('Current looped: ${metadata.looped}');
		var loopedStr = readLine("Should loop? (y/n, press Enter to keep): ");
		if (loopedStr != "")
			builder.setLooped(loopedStr.toLowerCase() == "y" || loopedStr.toLowerCase() == "yes");
		
		trace("Basic info updated!");
		editMenu();
	}
	
	private static function previewJson():Void
	{
		trace("\n--- JSON Preview ---");
		trace(builder.toJson());
		trace("");
		editMenu();
	}
	
	private static function saveMetadata():Void
	{
		try
		{
			var json = builder.toJson();
			var outputPath = 'assets/music/$musicName.json';
			
			// Create directory if it doesn't exist
			var dir = "assets/music";
			if (!FileSystem.exists(dir))
				FileSystem.createDirectory(dir);
			
			File.saveContent(outputPath, json);
			trace('Metadata saved successfully to: $outputPath');
			trace("");
			
			mainMenu();
		}
		catch (e:Dynamic)
		{
			trace('Error saving metadata: $e');
			editMenu();
		}
	}
	
	private static function readLine(prompt:String):String
	{
		Sys.print(prompt);
		return Sys.stdin().readLine();
	}
}
#else
class MetadataCreator
{
	public static function main():Void
	{
		trace("This tool requires a sys target (e.g., neko, cpp, java, hl)");
	}
}
#end
