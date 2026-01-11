# Quick Reference: Music Metadata Creation

## TL;DR - Quick Start

### Option 1: Interactive Tool (Easiest)
```bash
lime build neko
cd export/debug/neko/bin
./MetadataCreator
```
Follow the menu prompts to create/edit metadata.

### Option 2: Programmatic (In Code)
```haxe
import backend.MusicMetaDataBuilder;

var json = new MusicMetaDataBuilder()
    .setTitle("My Song")
    .setArtist("Artist Name")
    .setBPM(140)
    .addCuePointAtMeasure("intro", 0)
    .addCuePointAtMeasure("drop", 16)
    .toJson();

// Save to file
File.saveContent("assets/music/MySong.json", json);
```

## Common Use Cases

### Create Simple Metadata
```haxe
var json = new MusicMetaDataBuilder()
    .setTitle("Song Name")
    .setArtist("Artist")
    .setBPM(120)
    .toJson();
```

### Add Cue Points by Measure (Recommended)
```haxe
builder
    .addCuePointAtMeasure("intro", 0)      // Bar 0
    .addCuePointAtMeasure("verse", 4)      // Bar 4
    .addCuePointAtMeasure("chorus", 12)    // Bar 12
    .addCuePointAtMeasure("outro", 24);    // Bar 24
```

### Add Cue Points by Beat
```haxe
builder
    .addCuePointAtBeat("drop", 64)         // Beat 64
    .addCuePointAtBeat("breakdown", 128);  // Beat 128
```

### Add Cue Points by Time (ms)
```haxe
builder
    .addCuePoint("intro", 0)               // 0ms
    .addCuePoint("verse", 30000);          // 30 seconds
```

### Add Tempo Changes
```haxe
builder
    .setBPM(120)                           // Initial BPM
    .addTempoChangeAtMeasure(16, 140)      // Speed up at bar 16
    .addTempoChangeAtMeasure(32, 100);     // Slow down at bar 32
```

### Edit Existing Metadata
```haxe
var builder = MusicMetaDataBuilder.fromJson(
    File.getContent("assets/music/OldSong.json")
);

builder
    .addCuePointAtMeasure("new_section", 8)
    .setBPM(130);

File.saveContent(
    "assets/music/OldSong.json", 
    builder.toJson()
);
```

## Time Conversions

At 120 BPM in 4/4 time:
- 1 beat = 500ms
- 1 measure (4 beats) = 2000ms
- 16 beats (4 measures) = 8000ms

The builder does these conversions automatically when you use:
- `addCuePointAtBeat(name, beat)`
- `addCuePointAtMeasure(name, measure)`
- `addTempoChangeAtBeat(beat, bpm)`
- `addTempoChangeAtMeasure(measure, bpm)`

## Validation

The builder automatically validates:
- BPM must be > 0
- Time signature format (e.g., "4/4", "3/4")
- Times cannot be negative
- Required fields (title, artist)
- Tempo changes are sorted chronologically

## Builder API Methods

### Basic Info
- `setTitle(String)` - Set song title (required)
- `setArtist(String)` - Set artist name (required)
- `setBPM(Float)` - Set BPM (must be > 0)
- `setOffset(Float)` - Set offset in ms (default: 0)
- `setTimeSignature(String)` - Set time signature (default: "4/4")
- `setLooped(Bool)` - Set if song loops (default: false)

### Cue Points
- `addCuePoint(name, timeMs)` - Add by milliseconds
- `addCuePointAtBeat(name, beat)` - Add by beat number
- `addCuePointAtMeasure(name, measure)` - Add by measure number
- `removeCuePoint(name)` - Remove a cue point

### Tempo Changes
- `addTempoChange(timeMs, newBpm)` - Add by milliseconds
- `addTempoChangeAtBeat(beat, newBpm)` - Add by beat number
- `addTempoChangeAtMeasure(measure, newBpm)` - Add by measure number

### Build/Export
- `build()` - Returns MusicMetaData object
- `toJson(pretty?)` - Returns JSON string
- `fromJson(jsonString)` - Load from JSON (static)
- `fromMetadata(metadata)` - Load from metadata object (static)

### Utilities
- `timeToBeat(timeMs)` - Convert time to beat number

## CLI Tool Menu

The interactive tool provides:
1. Create new metadata
2. Edit existing metadata
3. Add cue points (time/beat/measure)
4. Add tempo changes (time/beat/measure)
5. Change basic info
6. Preview JSON before saving
7. Save to file

## Tips

1. **Use measures over beats** - Easier to think in terms of musical bars
2. **Use beats over time** - Easier than calculating milliseconds
3. **Start with the CLI tool** - Good for learning and quick edits
4. **Use the API for batches** - When creating many files programmatically
5. **Add meaningful cue point names** - "intro", "drop", "breakdown", etc.
6. **Test in game** - Always verify timing matches the audio

## Full Example

```haxe
import backend.MusicMetaDataBuilder;
import sys.io.File;

class CreateSongMetadata
{
    public static function main()
    {
        var json = new MusicMetaDataBuilder()
            // Basic info
            .setTitle("Epic Drop")
            .setArtist("DJ Bass")
            .setBPM(128)
            .setTimeSignature("4/4")
            .setLooped(true)
            
            // Structure (using measures - easiest!)
            .addCuePointAtMeasure("intro", 0)
            .addCuePointAtMeasure("buildup", 8)
            .addCuePointAtMeasure("drop", 16)
            .addCuePointAtMeasure("breakdown", 32)
            .addCuePointAtMeasure("final_drop", 48)
            
            // Tempo changes (speed up at drops)
            .addTempoChangeAtMeasure(16, 135)  // First drop
            .addTempoChangeAtMeasure(32, 120)  // Breakdown
            .addTempoChangeAtMeasure(48, 140)  // Final drop
            
            .toJson();
        
        File.saveContent("assets/music/EpicDrop.json", json);
        trace("Metadata created!");
    }
}
```

## Common Errors

### "BPM must be a positive number"
- BPM must be > 0
- Solution: Use a valid BPM (typically 60-200)

### "Time signature must be in format 'numerator/denominator'"
- Must be formatted as "X/Y" where X and Y are positive integers
- Solution: Use "4/4", "3/4", "6/8", etc.

### "Title is required"
- Cannot build without a title
- Solution: Call `.setTitle("Your Title")`

### "Artist is required"
- Cannot build without an artist
- Solution: Call `.setArtist("Artist Name")`

## See Also

- [METADATA_GUIDE.md](METADATA_GUIDE.md) - Full detailed guide
- [MetadataBuilderExample.hx](source/MetadataBuilderExample.hx) - Code examples
- [RecreateExistingMetadata.hx](source/RecreateExistingMetadata.hx) - Recreate existing files
