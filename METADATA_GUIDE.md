# Music Metadata Creation Guide

This guide explains how to create and manage song metadata for the rhythm game using the new metadata creation tools.

## Overview

The metadata system now provides four ways to create metadata:

1. **Visual GUI Editor** (Recommended - easiest and most intuitive!)
2. **Interactive CLI Tool** (Good for terminal users)
3. **Programmatic Builder API** (For advanced users and in-game features)
4. **Manual JSON editing** (Legacy method, not recommended)

## Method 1: Visual GUI Editor (Recommended)

The visual metadata editor provides an in-game graphical interface for creating and editing song metadata with real-time preview.

### Launching the Editor

1. Run the game in debug mode:
   ```bash
   lime test neko -debug
   # or
   lime test windows -debug
   # or
   lime test html5 -debug
   ```

2. Press **M** key to open the Metadata Editor

### Using the Editor

The editor has 4 pages:

**Page 1 - Basic Information:**
- Song Filename (required)
- Song Title (required)
- Artist (required)
- BPM (required, must be positive)
- Offset in milliseconds (default: 0)
- Time Signature (default: 4/4)
- Looped toggle

**Page 2 - Cue Points:**
- Add cue points to mark song sections
- Specify by measure number (easiest!)
- Each cue point has a name and position

**Page 3 - Tempo Changes:**
- Add tempo changes for songs with varying BPM
- Specify by measure number
- Each change has a measure and new BPM

**Page 4 - Preview & Save:**
- Review the generated JSON
- Save to `assets/music/[filename].json`

### Controls

- **TAB**: Move to next field
- **SHIFT + TAB**: Move to previous field
- **Type**: Enter text in the active field
- **BACKSPACE**: Delete characters
- **Next/Previous buttons**: Navigate pages
- **Add Entry button**: Add cue points or tempo changes
- **Save button**: Save the metadata file
- **ESC**: Exit editor and return to debug state

## Method 2: Interactive CLI Tool

The interactive CLI tool (`MetadataCreator`) provides a user-friendly way to create and edit metadata through a menu-driven interface.

### Running the Tool

#### Using Lime/OpenFL:
```bash
lime build neko
cd export/debug/neko/bin
./MetadataCreator
```

#### Using Haxe directly:
```bash
haxe -main tools.MetadataCreator -lib hxcpp -cpp bin
./bin/MetadataCreator
```

### Features

- **Create new metadata**: Start from scratch with guided prompts
- **Edit existing metadata**: Load and modify existing JSON files
- **Add cue points**: Define by time (milliseconds), beat number, or measure number
- **Add tempo changes**: Define BPM changes by time, beat, or measure
- **Preview JSON**: See what the final JSON will look like before saving
- **Validation**: Automatic validation of inputs (BPM must be positive, etc.)

### Example Workflow

1. Run the tool
2. Select "Create new metadata"
3. Enter song information:
   - Filename: "MySong"
   - Title: "My Awesome Song"
   - Artist: "John Doe"
   - BPM: 140
   - Offset: 0 (or custom offset in milliseconds)
   - Time signature: 4/4 (or custom like 3/4, 6/8)
   - Looped: yes/no
4. Add cue points:
   - "intro" at measure 0
   - "verse" at measure 4
   - "chorus" at measure 12
5. Add tempo changes if needed:
   - BPM 150 at measure 24
6. Preview the JSON
7. Save

The tool will create `assets/music/MySong.json` with all the metadata.

## Method 3: Programmatic Builder API

For advanced users or in-game metadata creation, use the `MusicMetaDataBuilder` class.

### Basic Example

```haxe
import backend.MusicMetaDataBuilder;
import sys.io.File;

// Create a new metadata object
var metadata = new MusicMetaDataBuilder()
    .setTitle("My Song")
    .setArtist("John Doe")
    .setBPM(120)
    .setOffset(0)
    .setTimeSignature("4/4")
    .setLooped(false)
    .build();

// Save as JSON
var json = new MusicMetaDataBuilder()
    .setTitle("My Song")
    .setArtist("John Doe")
    .setBPM(120)
    .toJson();

File.saveContent("assets/music/MySong.json", json);
```

### Adding Cue Points

```haxe
var builder = new MusicMetaDataBuilder()
    .setTitle("My Song")
    .setArtist("John Doe")
    .setBPM(140);

// Add cue point by milliseconds
builder.addCuePoint("intro", 0);
builder.addCuePoint("verse", 30000);  // 30 seconds

// Add cue point by beat number (easier!)
builder.addCuePointAtBeat("chorus", 64);  // At beat 64

// Add cue point by measure number (even easier!)
builder.addCuePointAtMeasure("bridge", 16);  // At measure 16
```

### Adding Tempo Changes

```haxe
var builder = new MusicMetaDataBuilder()
    .setTitle("Progressive Song")
    .setArtist("Jane Smith")
    .setBPM(120);

// Add tempo change by milliseconds
builder.addTempoChange(60000, 125);  // 125 BPM at 60 seconds

// Add tempo change by beat
builder.addTempoChangeAtBeat(128, 130);  // 130 BPM at beat 128

// Add tempo change by measure
builder.addTempoChangeAtMeasure(32, 140);  // 140 BPM at measure 32
```

### Editing Existing Metadata

```haxe
import backend.MusicMetaDataBuilder;
import sys.io.File;

// Load existing metadata
var jsonContent = File.getContent("assets/music/MySong.json");
var builder = MusicMetaDataBuilder.fromJson(jsonContent);

// Modify it
builder
    .addCuePoint("new_section", 45000)
    .setBPM(125);

// Save it back
var json = builder.toJson();
File.saveContent("assets/music/MySong.json", json);
```

### Helper Methods

The builder includes helper methods to convert between time formats:

```haxe
var builder = new MusicMetaDataBuilder().setBPM(120);

// Convert beat to time
var time = builder.timeToBeat(30000);  // Convert 30000ms to beat number

// These methods automatically handle conversions:
builder.addCuePointAtBeat("section", 32);      // Automatically converts beat 32 to ms
builder.addCuePointAtMeasure("part", 8);       // Automatically converts measure 8 to ms
builder.addTempoChangeAtBeat(64, 140);         // Automatically converts beat 64 to ms
builder.addTempoChangeAtMeasure(16, 150);      // Automatically converts measure 16 to ms
```

## Method 4: Manual JSON Editing (Not Recommended)

You can still manually create/edit JSON files, but this is error-prone and not recommended.

### JSON Format

```json
{
    "title": "Song Title",
    "artist": "Artist Name",
    "bpm": 120,
    "offset": 0,
    "timeSignature": "4/4",
    "cuePoints": {
        "intro": 0,
        "verse": 30000,
        "chorus": 60000
    },
    "tempoChanges": [
        { "time": 120000, "bpm": 125 },
        { "time": 180000, "bpm": 130 }
    ],
    "looped": false
}
```

## Best Practices

1. **Use beat/measure numbers instead of milliseconds** when possible - they're easier to work with and automatically calculated
2. **Add cue points for important sections** - helps with gameplay and debugging
3. **Test your metadata** by loading it in the game and checking if timing is correct
4. **Use meaningful cue point names** - "chorus", "verse", "drop", etc.
5. **Keep offset at 0** unless you need to sync the audio with visuals
6. **Sort tempo changes chronologically** - the builder does this automatically
7. **Use the CLI tool for creating new files** - it's faster and less error-prone
8. **Use the builder API for programmatic generation** - when you need to generate metadata dynamically

## Common Time Calculations

Here are some common calculations to help you work with time values:

### BPM to Beat Duration
- Beat duration (seconds) = 60 / BPM
- Beat duration (milliseconds) = 60000 / BPM

Example: At 120 BPM, each beat is 500ms (60000/120)

### Beats to Time
- Time (ms) = Beat × (60000 / BPM)

Example: At 120 BPM, beat 32 is at 16000ms (32 × 500)

### Measures to Beats
- Beats = Measure × Beats per bar

Example: In 4/4 time, measure 8 is beat 32 (8 × 4)

### Common Time Signatures
- 4/4: 4 beats per bar (most common)
- 3/4: 3 beats per bar (waltz time)
- 6/8: 6 beats per bar (compound time)

## Troubleshooting

### "BPM must be a positive number"
Ensure BPM is greater than 0. Typical values are 60-200.

### "Time signature must be in format 'numerator/denominator'"
Use format like "4/4", "3/4", "6/8" - both numbers must be positive integers.

### "Cue point time cannot be negative"
Times and beat/measure numbers must be 0 or greater.

### Metadata not loading in game
Check that:
1. JSON file is in `assets/music/` directory
2. Filename matches (e.g., "MySong.json" for song "MySong.ogg")
3. JSON is valid (use a JSON validator or the preview feature)

## Examples

### Simple Song (No tempo changes)

```haxe
var metadata = new MusicMetaDataBuilder()
    .setTitle("Simple Song")
    .setArtist("Artist")
    .setBPM(140)
    .addCuePointAtMeasure("intro", 0)
    .addCuePointAtMeasure("main", 4)
    .toJson();
```

### Complex Song (Multiple tempo changes)

```haxe
var metadata = new MusicMetaDataBuilder()
    .setTitle("Progressive Track")
    .setArtist("DJ Complex")
    .setBPM(120)
    .addCuePointAtMeasure("intro", 0)
    .addCuePointAtMeasure("buildup", 8)
    .addCuePointAtMeasure("drop", 16)
    .addTempoChangeAtMeasure(16, 140)
    .addCuePointAtMeasure("breakdown", 32)
    .addTempoChangeAtMeasure(32, 100)
    .addCuePointAtMeasure("final_drop", 48)
    .addTempoChangeAtMeasure(48, 150)
    .setLooped(false)
    .toJson();
```

### Editing Existing Metadata

```haxe
// Load, modify, and save
var builder = MusicMetaDataBuilder.fromJson(
    File.getContent("assets/music/OldSong.json")
);

builder
    .setBPM(125)  // Change BPM
    .addCuePointAtMeasure("new_part", 24)  // Add new cue point
    .setLooped(true);  // Enable looping

File.saveContent(
    "assets/music/OldSong.json",
    builder.toJson()
);
```
