package;

import backend.MusicMetaDataBuilder;
import objects.Song;

/**
 * Example demonstrating the Song.fromBuilder() convenience method.
 * This shows how to create a song with programmatically generated metadata.
 */
class SongFromBuilderExample
{
	public static function main():Void
	{
		trace("Example: Creating a Song from Builder");
		trace("======================================");
		trace("");
		
		// Create metadata using the builder
		var builder = new MusicMetaDataBuilder()
			.setTitle("Programmatic Song")
			.setArtist("Code Generator")
			.setBPM(140)
			.addCuePointAtMeasure("intro", 0)
			.addCuePointAtMeasure("main", 4)
			.addCuePointAtMeasure("outro", 32)
			.setLooped(true);
		
		// Create a Song directly from the builder
		// This will:
		// 1. Generate the JSON
		// 2. Save it to assets/music/GeneratedSong.json
		// 3. Load the song normally
		#if sys
		var song = Song.fromBuilder("GeneratedSong", builder, true);
		
		trace("Song created!");
		trace('  Name: ${song.name}');
		trace('  Title: ${song.metaData.title}');
		trace('  Artist: ${song.metaData.artist}');
		trace('  BPM: ${song.metaData.bpm}');
		trace('  Looped: ${song.metaData.looped}');
		trace("");
		
		// Alternative: Create metadata but don't save JSON
		// (useful if you're managing metadata in code only)
		var builder2 = new MusicMetaDataBuilder()
			.setTitle("Temporary Song")
			.setArtist("In-Memory")
			.setBPM(120);
		
		// Note: This will still try to load from the JSON file, so make sure it exists
		// If you want purely in-memory metadata, you'd need to modify Song class
		trace("You can also create metadata without saving to disk");
		trace("(but the Song class still needs the JSON file to exist)");
		#else
		trace("This example requires a sys target (neko, cpp, etc.)");
		#end
	}
}
