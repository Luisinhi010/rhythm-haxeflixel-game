package backend;

import backend.MusicMetaData;
import haxe.Json;
import haxe.ds.Map;

/**
 * A builder class for creating MusicMetaData objects programmatically.
 * This provides a fluent API for creating song metadata with validation
 * and helpful defaults, making it easier to create metadata without
 * manually editing JSON files.
 * 
 * Example usage:
 * ```haxe
 * var metadata = new MusicMetaDataBuilder()
 *     .setTitle("My Song")
 *     .setArtist("John Doe")
 *     .setBPM(120)
 *     .setOffset(100)
 *     .setTimeSignature("4/4")
 *     .addCuePoint("intro", 0)
 *     .addCuePoint("verse", 30000)
 *     .addTempoChange(60000, 125)
 *     .setLooped(true)
 *     .build();
 * ```
 */
class MusicMetaDataBuilder
{
	private var title:String;
	private var artist:String;
	private var bpm:Float;
	private var offset:Float;
	private var timeSignature:String;
	private var cuePoints:Map<String, Float>;
	private var tempoChanges:Array<{time:Float, bpm:Float}>;
	private var looped:Bool;

	/**
	 * Creates a new MusicMetaDataBuilder with default values.
	 */
	public function new()
	{
		// Set defaults
		this.title = "";
		this.artist = "Unknown";
		this.bpm = 120;
		this.offset = 0;
		this.timeSignature = "4/4";
		this.cuePoints = new Map<String, Float>();
		this.tempoChanges = [];
		this.looped = false;
	}

	/**
	 * Sets the title of the song.
	 * @param title The song title.
	 * @return This builder for method chaining.
	 */
	public function setTitle(title:String):MusicMetaDataBuilder
	{
		this.title = title;
		return this;
	}

	/**
	 * Sets the artist of the song.
	 * @param artist The artist name.
	 * @return This builder for method chaining.
	 */
	public function setArtist(artist:String):MusicMetaDataBuilder
	{
		this.artist = artist;
		return this;
	}

	/**
	 * Sets the BPM (beats per minute) of the song.
	 * @param bpm The BPM value (must be positive).
	 * @return This builder for method chaining.
	 * @throws String if BPM is not positive.
	 */
	public function setBPM(bpm:Float):MusicMetaDataBuilder
	{
		if (bpm <= 0)
			throw "BPM must be a positive number";
		this.bpm = bpm;
		return this;
	}

	/**
	 * Sets the offset of the song in milliseconds.
	 * @param offset The offset in milliseconds.
	 * @return This builder for method chaining.
	 */
	public function setOffset(offset:Float):MusicMetaDataBuilder
	{
		this.offset = offset;
		return this;
	}

	/**
	 * Sets the time signature of the song (e.g., "4/4", "3/4", "6/8").
	 * @param timeSignature The time signature string.
	 * @return This builder for method chaining.
	 * @throws String if time signature format is invalid.
	 */
	public function setTimeSignature(timeSignature:String):MusicMetaDataBuilder
	{
		// Validate time signature format
		var parts = timeSignature.split("/");
		if (parts.length != 2)
			throw "Time signature must be in format 'numerator/denominator' (e.g., '4/4')";
		
		var numerator = Std.parseInt(parts[0]);
		var denominator = Std.parseInt(parts[1]);
		
		if (numerator == null || numerator <= 0)
			throw "Time signature numerator must be a positive integer";
		if (denominator == null || denominator <= 0)
			throw "Time signature denominator must be a positive integer";
		
		this.timeSignature = timeSignature;
		return this;
	}

	/**
	 * Adds a cue point to the song.
	 * @param name The name of the cue point.
	 * @param time The time in milliseconds.
	 * @return This builder for method chaining.
	 * @throws String if time is negative.
	 */
	public function addCuePoint(name:String, time:Float):MusicMetaDataBuilder
	{
		if (time < 0)
			throw "Cue point time cannot be negative";
		this.cuePoints.set(name, time);
		return this;
	}

	/**
	 * Adds a cue point based on beat number instead of time.
	 * Useful when you know which beat something happens on.
	 * @param name The name of the cue point.
	 * @param beat The beat number (0-based).
	 * @return This builder for method chaining.
	 */
	public function addCuePointAtBeat(name:String, beat:Float):MusicMetaDataBuilder
	{
		var time = beatToTime(beat);
		return addCuePoint(name, time);
	}

	/**
	 * Adds a cue point based on measure/bar number instead of time.
	 * @param name The name of the cue point.
	 * @param measure The measure/bar number (0-based).
	 * @return This builder for method chaining.
	 */
	public function addCuePointAtMeasure(name:String, measure:Float):MusicMetaDataBuilder
	{
		var parts = timeSignature.split("/");
		var beatsPerBar = Std.parseInt(parts[0]);
		var beat = measure * beatsPerBar;
		return addCuePointAtBeat(name, beat);
	}

	/**
	 * Removes a cue point by name.
	 * @param name The name of the cue point to remove.
	 * @return This builder for method chaining.
	 */
	public function removeCuePoint(name:String):MusicMetaDataBuilder
	{
		this.cuePoints.remove(name);
		return this;
	}

	/**
	 * Adds a tempo change to the song.
	 * @param time The time in milliseconds when the tempo changes.
	 * @param newBpm The new BPM value.
	 * @return This builder for method chaining.
	 * @throws String if time is negative or newBpm is not positive.
	 */
	public function addTempoChange(time:Float, newBpm:Float):MusicMetaDataBuilder
	{
		if (time < 0)
			throw "Tempo change time cannot be negative";
		if (newBpm <= 0)
			throw "Tempo change BPM must be a positive number";
		this.tempoChanges.push({time: time, bpm: newBpm});
		return this;
	}

	/**
	 * Adds a tempo change based on beat number instead of time.
	 * @param beat The beat number when the tempo changes.
	 * @param newBpm The new BPM value.
	 * @return This builder for method chaining.
	 */
	public function addTempoChangeAtBeat(beat:Float, newBpm:Float):MusicMetaDataBuilder
	{
		var time = beatToTime(beat);
		return addTempoChange(time, newBpm);
	}

	/**
	 * Adds a tempo change based on measure/bar number instead of time.
	 * @param measure The measure/bar number when the tempo changes.
	 * @param newBpm The new BPM value.
	 * @return This builder for method chaining.
	 */
	public function addTempoChangeAtMeasure(measure:Float, newBpm:Float):MusicMetaDataBuilder
	{
		var parts = timeSignature.split("/");
		var beatsPerBar = Std.parseInt(parts[0]);
		var beat = measure * beatsPerBar;
		return addTempoChangeAtBeat(beat, newBpm);
	}

	/**
	 * Sets whether the song should loop.
	 * @param looped Whether the song should loop.
	 * @return This builder for method chaining.
	 */
	public function setLooped(looped:Bool):MusicMetaDataBuilder
	{
		this.looped = looped;
		return this;
	}

	/**
	 * Converts a beat number to time in milliseconds.
	 * @param beat The beat number.
	 * @return The time in milliseconds.
	 */
	private function beatToTime(beat:Float):Float
	{
		// Calculate time based on current BPM
		// Time = (beat * 60000) / BPM
		return (beat * 60000) / bpm;
	}

	/**
	 * Converts time in milliseconds to beat number.
	 * @param time The time in milliseconds.
	 * @return The beat number.
	 */
	public function timeToBeat(time:Float):Float
	{
		return (time * bpm) / 60000;
	}

	/**
	 * Builds and returns the MusicMetaData object.
	 * @return The constructed MusicMetaData.
	 * @throws String if required fields are not set.
	 */
	public function build():MusicMetaData
	{
		if (title == null || title == "")
			throw "Title is required";
		if (artist == null || artist == "")
			throw "Artist is required";
		
		// Sort tempo changes by time
		tempoChanges.sort((a, b) -> Std.int(a.time - b.time));
		
		return {
			title: title,
			artist: artist,
			bpm: bpm,
			offset: offset,
			timeSignature: timeSignature,
			cuePoints: cuePoints,
			tempoChanges: tempoChanges,
			looped: looped
		};
	}

	/**
	 * Builds the metadata and exports it as a JSON string.
	 * @param pretty Whether to format the JSON with indentation.
	 * @return The JSON string representation of the metadata.
	 */
	public function toJson(pretty:Bool = true):String
	{
		var metadata = build();
		
		// Convert Map to object for JSON serialization
		var cuePointsObj:Dynamic = {};
		for (key in metadata.cuePoints.keys())
		{
			Reflect.setField(cuePointsObj, key, metadata.cuePoints.get(key));
		}
		
		var jsonObj = {
			title: metadata.title,
			artist: metadata.artist,
			bpm: metadata.bpm,
			offset: metadata.offset,
			timeSignature: metadata.timeSignature,
			cuePoints: cuePointsObj,
			tempoChanges: metadata.tempoChanges,
			looped: metadata.looped
		};
		
		if (pretty)
			return Json.stringify(jsonObj, null, "\t");
		else
			return Json.stringify(jsonObj);
	}

	/**
	 * Creates a new builder from an existing MusicMetaData object.
	 * Useful for editing existing metadata.
	 * @param metadata The existing metadata to copy.
	 * @return A new builder with the metadata values.
	 */
	public static function fromMetadata(metadata:MusicMetaData):MusicMetaDataBuilder
	{
		var builder = new MusicMetaDataBuilder();
		builder.title = metadata.title;
		builder.artist = metadata.artist;
		builder.bpm = metadata.bpm;
		builder.offset = metadata.offset != null ? metadata.offset : 0;
		builder.timeSignature = metadata.timeSignature != null ? metadata.timeSignature : "4/4";
		
		if (metadata.cuePoints != null)
		{
			builder.cuePoints = new Map<String, Float>();
			for (key in metadata.cuePoints.keys())
			{
				builder.cuePoints.set(key, metadata.cuePoints.get(key));
			}
		}
		
		if (metadata.tempoChanges != null)
			builder.tempoChanges = metadata.tempoChanges.copy();
		
		builder.looped = metadata.looped != null ? metadata.looped : false;
		
		return builder;
	}

	/**
	 * Creates a new builder from a JSON string.
	 * @param jsonString The JSON string to parse.
	 * @return A new builder with the parsed metadata values.
	 */
	public static function fromJson(jsonString:String):MusicMetaDataBuilder
	{
		var parsedData:Dynamic = Json.parse(jsonString);
		var builder = new MusicMetaDataBuilder();
		
		builder.title = parsedData.title != null ? parsedData.title : "";
		builder.artist = parsedData.artist != null ? parsedData.artist : "Unknown";
		builder.bpm = parsedData.bpm != null ? parsedData.bpm : 120;
		builder.offset = parsedData.offset != null ? parsedData.offset : 0;
		builder.timeSignature = parsedData.timeSignature != null ? parsedData.timeSignature : "4/4";
		
		// Parse cue points
		if (parsedData.cuePoints != null)
		{
			builder.cuePoints = new Map<String, Float>();
			for (fieldName in Reflect.fields(parsedData.cuePoints))
			{
				builder.cuePoints.set(fieldName, Reflect.field(parsedData.cuePoints, fieldName));
			}
		}
		
		// Parse tempo changes
		if (parsedData.tempoChanges != null)
			builder.tempoChanges = parsedData.tempoChanges;
		
		builder.looped = parsedData.looped != null ? parsedData.looped : false;
		
		return builder;
	}
}
