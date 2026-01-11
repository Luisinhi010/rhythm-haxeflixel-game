package;

import backend.MusicMetaDataBuilder;
#if sys
import sys.io.File;
#end

/**
 * This example recreates the existing song metadata files using the builder,
 * demonstrating how much easier it is compared to manual JSON editing.
 */
class RecreateExistingMetadata
{
	public static function main():Void
	{
		trace("Recreating existing metadata files using the builder...");
		trace("");
		
		// Recreate Test.json
		recreateTest();
		
		// Recreate Legion.json
		recreateLegion();
		
		// Recreate Narrator.json
		recreateNarrator();
		
		// Recreate Singularity.json (complex with tempo changes)
		recreateSingularity();
	}
	
	/**
	 * Recreates Test.json
	 * Original: {"title": "Test", "artist": "Luis", "bpm": 100, "offset": 0, "timeSignature": "4/4"}
	 */
	static function recreateTest():Void
	{
		trace("Test.json:");
		trace("-----------");
		
		var json = new MusicMetaDataBuilder()
			.setTitle("Test")
			.setArtist("Luis")
			.setBPM(100)
			.toJson();
		
		trace(json);
		trace("");
		
		#if sys
		File.saveContent("assets/music/Test_rebuilt.json", json);
		#end
	}
	
	/**
	 * Recreates Legion.json
	 * Original has cue points at specific times
	 */
	static function recreateLegion():Void
	{
		trace("Legion.json:");
		trace("-------------");
		
		var json = new MusicMetaDataBuilder()
			.setTitle("Legion")
			.setArtist("Michel F. April")
			.setBPM(127)
			.addCuePoint("Start", 0)
			.addCuePoint("Second Part", 12300)
			.toJson();
		
		trace(json);
		trace("");
		
		#if sys
		File.saveContent("assets/music/Legion_rebuilt.json", json);
		#end
	}
	
	/**
	 * Recreates Narrator.json
	 */
	static function recreateNarrator():Void
	{
		trace("Narrator.json:");
		trace("---------------");
		
		var json = new MusicMetaDataBuilder()
			.setTitle("Narrator Layer 1")
			.setArtist("Enthrallist")
			.setBPM(168)
			.toJson();
		
		trace(json);
		trace("");
		
		#if sys
		File.saveContent("assets/music/Narrator_rebuilt.json", json);
		#end
	}
	
	/**
	 * Recreates Singularity.json - the most complex one with multiple tempo changes
	 * This demonstrates how the builder makes complex metadata much easier to create.
	 */
	static function recreateSingularity():Void
	{
		trace("Singularity.json:");
		trace("------------------");
		
		// Using the builder, we can easily add all tempo changes in a clean, readable way
		var json = new MusicMetaDataBuilder()
			.setTitle("Singularity")
			.setArtist("Michel F. April")
			.setBPM(32)  // Initial BPM
			// Add all tempo changes
			.addTempoChange(0, 32)
			.addTempoChange(2820, 64)
			.addTempoChange(7500, 32)
			.addTempoChange(10320, 64)
			.addTempoChange(15000, 32)
			.addTempoChange(17820, 64)
			.addTempoChange(22500, 32)
			.addTempoChange(25320, 64)
			.toJson();
		
		trace(json);
		trace("");
		
		#if sys
		File.saveContent("assets/music/Singularity_rebuilt.json", json);
		#end
		
		// Show how using beats/measures could make this even cleaner
		trace("Alternative: Using beat-based tempo changes (if the times align):");
		trace("-------------------------------------------------------------------");
		
		// Note: This is just for demonstration - actual beat alignment would need
		// to be calculated based on the song structure
		var alternativeJson = new MusicMetaDataBuilder()
			.setTitle("Singularity")
			.setArtist("Michel F. April")
			.setBPM(32)
			.addTempoChangeAtBeat(0, 32)
			.addTempoChangeAtBeat(1.504, 64)  // 2820ms / (60000/32) = ~1.504 beats
			// ... etc
			.toJson();
		
		trace("(Not showing full output - just demonstrating the concept)");
		trace("");
	}
}
