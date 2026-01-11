package;

import backend.MusicMetaDataBuilder;

/**
 * Simple validation tests for the MusicMetaDataBuilder.
 * Run this to verify the builder is working correctly.
 */
class ValidateMetadataBuilder
{
	private static var testsPassed:Int = 0;
	private static var testsFailed:Int = 0;
	
	public static function main():Void
	{
		trace("==============================================");
		trace("  MusicMetaDataBuilder Validation Tests");
		trace("==============================================");
		trace("");
		
		// Run all tests
		testBasicBuilder();
		testValidation();
		testCuePoints();
		testTempoChanges();
		testConversions();
		testJsonRoundTrip();
		
		// Summary
		trace("");
		trace("==============================================");
		trace("Test Results:");
		trace('  Passed: $testsPassed');
		trace('  Failed: $testsFailed');
		trace("==============================================");
		
		if (testsFailed > 0)
			Sys.exit(1);
	}
	
	static function testBasicBuilder():Void
	{
		trace("Test: Basic Builder");
		try
		{
			var metadata = new MusicMetaDataBuilder()
				.setTitle("Test Song")
				.setArtist("Test Artist")
				.setBPM(120)
				.build();
			
			assertEqual(metadata.title, "Test Song", "Title should match");
			assertEqual(metadata.artist, "Test Artist", "Artist should match");
			assertEqual(metadata.bpm, 120.0, "BPM should match");
			assertEqual(metadata.offset, 0.0, "Offset should default to 0");
			assertEqual(metadata.timeSignature, "4/4", "Time signature should default to 4/4");
			assertEqual(metadata.looped, false, "Looped should default to false");
			
			trace("  ✓ Basic builder works correctly");
			testsPassed++;
		}
		catch (e:Dynamic)
		{
			trace('  ✗ Basic builder failed: $e');
			testsFailed++;
		}
		trace("");
	}
	
	static function testValidation():Void
	{
		trace("Test: Validation");
		var validationTests = 0;
		
		// Test BPM validation
		try
		{
			new MusicMetaDataBuilder().setBPM(-10);
			trace("  ✗ Should have thrown error for negative BPM");
			testsFailed++;
		}
		catch (e:Dynamic)
		{
			trace("  ✓ Correctly rejects negative BPM");
			validationTests++;
		}
		
		// Test time signature validation
		try
		{
			new MusicMetaDataBuilder().setTimeSignature("invalid");
			trace("  ✗ Should have thrown error for invalid time signature");
			testsFailed++;
		}
		catch (e:Dynamic)
		{
			trace("  ✓ Correctly rejects invalid time signature");
			validationTests++;
		}
		
		// Test required fields
		try
		{
			new MusicMetaDataBuilder().build();
			trace("  ✗ Should have thrown error for missing required fields");
			testsFailed++;
		}
		catch (e:Dynamic)
		{
			trace("  ✓ Correctly requires title and artist");
			validationTests++;
		}
		
		if (validationTests == 3)
			testsPassed++;
		else
			testsFailed++;
		
		trace("");
	}
	
	static function testCuePoints():Void
	{
		trace("Test: Cue Points");
		try
		{
			var builder = new MusicMetaDataBuilder()
				.setTitle("Test")
				.setArtist("Test")
				.setBPM(120);
			
			// Add cue points different ways
			builder
				.addCuePoint("manual", 1000)
				.addCuePointAtBeat("beat_based", 4)
				.addCuePointAtMeasure("measure_based", 2);
			
			var metadata = builder.build();
			
			assertTrue(metadata.cuePoints.exists("manual"), "Should have manual cue point");
			assertTrue(metadata.cuePoints.exists("beat_based"), "Should have beat-based cue point");
			assertTrue(metadata.cuePoints.exists("measure_based"), "Should have measure-based cue point");
			
			assertEqual(metadata.cuePoints.get("manual"), 1000.0, "Manual cue point time");
			assertEqual(metadata.cuePoints.get("beat_based"), 2000.0, "Beat-based cue point time (4 beats * 500ms)");
			assertEqual(metadata.cuePoints.get("measure_based"), 4000.0, "Measure-based cue point time (2 measures * 2000ms)");
			
			trace("  ✓ Cue points work correctly");
			testsPassed++;
		}
		catch (e:Dynamic)
		{
			trace('  ✗ Cue points failed: $e');
			testsFailed++;
		}
		trace("");
	}
	
	static function testTempoChanges():Void
	{
		trace("Test: Tempo Changes");
		try
		{
			var builder = new MusicMetaDataBuilder()
				.setTitle("Test")
				.setArtist("Test")
				.setBPM(120);
			
			builder
				.addTempoChange(5000, 130)
				.addTempoChangeAtBeat(8, 140)
				.addTempoChangeAtMeasure(4, 150);
			
			var metadata = builder.build();
			
			assertEqual(metadata.tempoChanges.length, 3, "Should have 3 tempo changes");
			
			// Check they're sorted by time
			assertTrue(metadata.tempoChanges[0].time <= metadata.tempoChanges[1].time, "Tempo changes should be sorted");
			assertTrue(metadata.tempoChanges[1].time <= metadata.tempoChanges[2].time, "Tempo changes should be sorted");
			
			trace("  ✓ Tempo changes work correctly");
			testsPassed++;
		}
		catch (e:Dynamic)
		{
			trace('  ✗ Tempo changes failed: $e');
			testsFailed++;
		}
		trace("");
	}
	
	static function testConversions():Void
	{
		trace("Test: Time Conversions");
		try
		{
			var builder = new MusicMetaDataBuilder()
				.setTitle("Test")
				.setArtist("Test")
				.setBPM(120);  // 120 BPM = 500ms per beat
			
			// Test beat to time conversion
			var time = builder.timeToBeat(2000);  // 2000ms should be 4 beats
			assertEqual(time, 4.0, "2000ms should equal 4 beats at 120 BPM");
			
			trace("  ✓ Time conversions work correctly");
			testsPassed++;
		}
		catch (e:Dynamic)
		{
			trace('  ✗ Time conversions failed: $e');
			testsFailed++;
		}
		trace("");
	}
	
	static function testJsonRoundTrip():Void
	{
		trace("Test: JSON Round Trip");
		try
		{
			var original = new MusicMetaDataBuilder()
				.setTitle("Test Song")
				.setArtist("Test Artist")
				.setBPM(140)
				.setOffset(100)
				.setTimeSignature("3/4")
				.addCuePoint("intro", 0)
				.addCuePoint("verse", 5000)
				.addTempoChange(10000, 150)
				.setLooped(true);
			
			// Convert to JSON and back
			var json = original.toJson();
			var rebuilt = MusicMetaDataBuilder.fromJson(json);
			var metadata = rebuilt.build();
			
			// Verify all fields survived the round trip
			assertEqual(metadata.title, "Test Song", "Title preserved");
			assertEqual(metadata.artist, "Test Artist", "Artist preserved");
			assertEqual(metadata.bpm, 140.0, "BPM preserved");
			assertEqual(metadata.offset, 100.0, "Offset preserved");
			assertEqual(metadata.timeSignature, "3/4", "Time signature preserved");
			assertEqual(metadata.looped, true, "Looped preserved");
			assertTrue(metadata.cuePoints.exists("intro"), "Cue points preserved");
			assertTrue(metadata.cuePoints.exists("verse"), "Cue points preserved");
			assertEqual(metadata.tempoChanges.length, 1, "Tempo changes preserved");
			
			trace("  ✓ JSON round trip works correctly");
			testsPassed++;
		}
		catch (e:Dynamic)
		{
			trace('  ✗ JSON round trip failed: $e');
			testsFailed++;
		}
		trace("");
	}
	
	// Helper assertion functions
	static function assertEqual(actual:Dynamic, expected:Dynamic, message:String):Void
	{
		if (actual != expected)
			throw '$message - Expected: $expected, Got: $actual';
	}
	
	static function assertTrue(condition:Bool, message:String):Void
	{
		if (!condition)
			throw '$message - Expected true, got false';
	}
}
