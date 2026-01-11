package;

import backend.MusicMetaDataBuilder;
#if sys
import sys.io.File;
#end

/**
 * Example usage of the MusicMetaDataBuilder class.
 * This demonstrates how to programmatically create song metadata
 * without manually editing JSON files.
 */
class MetadataBuilderExample
{
	public static function main():Void
	{
		// Example 1: Simple song with basic metadata
		example1_SimpleSong();
		
		// Example 2: Song with cue points
		example2_SongWithCuePoints();
		
		// Example 3: Song with tempo changes
		example3_SongWithTempoChanges();
		
		// Example 4: Complex song with everything
		example4_ComplexSong();
		
		// Example 5: Editing existing metadata
		#if sys
		example5_EditExisting();
		#end
	}
	
	/**
	 * Example 1: Creating a simple song with just basic metadata.
	 */
	static function example1_SimpleSong():Void
	{
		trace("Example 1: Simple Song");
		trace("========================");
		
		var metadata = new MusicMetaDataBuilder()
			.setTitle("Simple Song")
			.setArtist("John Doe")
			.setBPM(120)
			.setOffset(0)
			.setTimeSignature("4/4")
			.setLooped(false)
			.toJson();
		
		trace(metadata);
		trace("");
	}
	
	/**
	 * Example 2: Creating a song with cue points.
	 * Shows different ways to add cue points.
	 */
	static function example2_SongWithCuePoints():Void
	{
		trace("Example 2: Song with Cue Points");
		trace("=================================");
		
		var metadata = new MusicMetaDataBuilder()
			.setTitle("Song with Markers")
			.setArtist("Jane Smith")
			.setBPM(140)
			// Add cue points by time in milliseconds
			.addCuePoint("intro", 0)
			// Add cue points by beat number (easier!)
			.addCuePointAtBeat("verse", 16)
			.addCuePointAtBeat("chorus", 64)
			// Add cue points by measure/bar number (even easier!)
			.addCuePointAtMeasure("bridge", 24)
			.addCuePointAtMeasure("outro", 32)
			.toJson();
		
		trace(metadata);
		trace("");
	}
	
	/**
	 * Example 3: Creating a song with tempo changes.
	 * Shows how to handle songs with varying BPM.
	 */
	static function example3_SongWithTempoChanges():Void
	{
		trace("Example 3: Song with Tempo Changes");
		trace("====================================");
		
		var metadata = new MusicMetaDataBuilder()
			.setTitle("Progressive Track")
			.setArtist("DJ BPM")
			.setBPM(120)
			// Add tempo changes by time
			.addTempoChange(30000, 125)
			// Add tempo changes by beat
			.addTempoChangeAtBeat(128, 130)
			// Add tempo changes by measure
			.addTempoChangeAtMeasure(48, 140)
			.toJson();
		
		trace(metadata);
		trace("");
	}
	
	/**
	 * Example 4: Creating a complex song with all features.
	 */
	static function example4_ComplexSong():Void
	{
		trace("Example 4: Complex Song");
		trace("========================");
		
		var metadata = new MusicMetaDataBuilder()
			.setTitle("Epic Journey")
			.setArtist("Orchestra Masters")
			.setBPM(100)
			.setOffset(50)
			.setTimeSignature("3/4")
			// Add cue points for different sections
			.addCuePointAtMeasure("intro", 0)
			.addCuePointAtMeasure("theme_1", 8)
			.addCuePointAtMeasure("transition", 16)
			.addCuePointAtMeasure("theme_2", 24)
			.addCuePointAtMeasure("climax", 32)
			// Add tempo changes for dramatic effect
			.addTempoChangeAtMeasure(16, 110)
			.addTempoChangeAtMeasure(32, 120)
			.setLooped(true)
			.toJson();
		
		trace(metadata);
		trace("");
	}
	
	/**
	 * Example 5: Loading and editing existing metadata.
	 * Only works on sys targets (neko, cpp, etc.)
	 */
	#if sys
	static function example5_EditExisting():Void
	{
		trace("Example 5: Edit Existing Metadata");
		trace("===================================");
		
		// Simulate loading existing metadata
		var existingJson = '{
			"title": "Old Song",
			"artist": "Old Artist",
			"bpm": 120,
			"offset": 0,
			"timeSignature": "4/4",
			"cuePoints": {},
			"tempoChanges": [],
			"looped": false
		}';
		
		// Load it into the builder
		var builder = MusicMetaDataBuilder.fromJson(existingJson);
		
		// Modify it
		builder
			.setTitle("Updated Song")
			.setBPM(125)
			.addCuePointAtMeasure("new_section", 8)
			.setLooped(true);
		
		// Convert back to JSON
		var updatedJson = builder.toJson();
		
		trace(updatedJson);
		trace("");
	}
	#end
}
