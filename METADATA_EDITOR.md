# Song Metadata Editor

## Overview
The Song Metadata Editor is a user-friendly UI tool for creating and editing song metadata files in the rhythm game. It supports both desktop (mouse/keyboard) and mobile (touch) input methods.

## Features
- **Visual Editing**: Edit all metadata fields through an intuitive UI
- **Load Existing Metadata**: Load and edit existing song metadata files
- **Save Functionality**: Save metadata as JSON files in the assets/music/ directory
- **Touch-Friendly**: All controls work with both mouse/keyboard and touch input
- **Real-time Validation**: Input validation for numeric fields (BPM, offset)
- **Keyboard Shortcuts**: Quick access to common actions (Desktop only)

## Accessing the Metadata Editor

### From Debug State (Development)
Press **M** key to open the metadata editor

### From Play State (Production)
Press **M** key to open the metadata editor

## UI Controls

### Basic Metadata Fields
1. **Song File Name**: The name of your song file (without extension)
   - This is used to load/save the metadata JSON file
   - Example: "MySong" will load/save "MySong.json"

2. **Title**: Display title of the song
   - Can be different from the file name
   - Supports any UTF-8 characters

3. **Artist**: Name of the song artist/composer
   - Default: "Unknown"

4. **BPM**: Beats per minute
   - Numeric only
   - Must be greater than 0
   - Default: 120

5. **Offset**: Audio synchronization offset in milliseconds
   - Numeric only
   - Can be negative or positive
   - Default: 0

6. **Time Signature**: Musical time signature
   - Common values: "4/4", "3/4", "6/8"
   - Default: "4/4"

7. **Loop Music**: Checkbox to enable/disable looping
   - When checked, the music will loop automatically
   - Default: unchecked

### Advanced Features

#### Cue Points
Cue points are named timestamps in the song useful for gameplay triggers.

- **Add Cue Point**: Creates a new cue point (defaults to time 0ms)
- **Clear All**: Removes all cue points
- **Note**: For custom cue point values, edit the JSON file directly

#### Tempo Changes
Tempo changes allow the BPM to change during the song.

- **Add Tempo Change**: Creates a new tempo change entry
- **Clear All**: Removes all tempo changes
- **Note**: For custom timing values, edit the JSON file directly

### Action Buttons

#### New Button
- Clears all fields and creates a blank metadata template
- Default values are loaded

#### Load Button
- Loads metadata from an existing JSON file
- Enter the song file name first
- Shows error if file not found

#### Save Button
- Saves the current metadata to a JSON file
- File is saved to `assets/music/[SongFileName].json`
- Validates required fields before saving
- On web/mobile: outputs JSON to console (sys targets save to disk)

#### Back Button
- Returns to the previous state (Debug or Play state)
- No confirmation dialog - changes are not auto-saved

## Keyboard Shortcuts (Desktop Only)

- **ESC**: Return to previous state
- **CTRL+S**: Save metadata
- **CTRL+O**: Load metadata
- **CTRL+N**: Create new metadata
- **TAB**: Navigate between input fields

## Touch Controls (Mobile)

All UI elements are designed to be touch-friendly:
- **Tap** on any text field to edit
- **Tap** on buttons to activate
- **Tap** on the checkbox to toggle loop
- Virtual keyboard will appear for text input on mobile devices

## JSON File Format

The metadata is saved in the following JSON format:

```json
{
	"title": "Song Title",
	"artist": "Artist Name",
	"bpm": 120,
	"offset": 0,
	"timeSignature": "4/4",
	"looped": false,
	"cuePoints": {
		"intro": 0,
		"chorus": 30000,
		"bridge": 60000
	},
	"tempoChanges": [
		{ "time": 0, "bpm": 120 },
		{ "time": 30000, "bpm": 140 }
	]
}
```

### Field Descriptions

- **title** (String, required): Display name of the song
- **artist** (String, required): Artist or composer name
- **bpm** (Float, required): Initial beats per minute
- **offset** (Float, optional): Offset in milliseconds (default: 0)
- **timeSignature** (String, optional): Time signature (default: "4/4")
- **looped** (Boolean, optional): Whether to loop (default: false)
- **cuePoints** (Object, optional): Named timestamps in milliseconds
- **tempoChanges** (Array, optional): Array of tempo change objects with time and bpm

## Best Practices

1. **Name your files consistently**: Use descriptive names without spaces
   - Good: "MyAwesomeSong", "battle_theme_01"
   - Avoid: "my song", "Song #1"

2. **Test offset values**: Use the game's debug mode to find the right offset
   - Positive values delay the audio
   - Negative values advance the audio

3. **Keep BPM accurate**: Use a BPM detector tool for existing songs

4. **Save frequently**: There's no auto-save, so remember to save your work

5. **Backup your files**: Keep copies of your metadata JSON files

## Troubleshooting

### "Metadata file not found" error
- Check that the song name matches exactly (case-sensitive)
- Verify the JSON file exists in `assets/music/` directory
- Make sure the file has a `.json` extension

### Save button doesn't work
- On web/mobile: Check the browser console for JSON output
- On desktop: Verify write permissions to the assets folder
- Make sure all required fields are filled

### Invalid BPM error
- BPM must be a number greater than 0
- Remove any non-numeric characters
- Use decimal point for fractional BPM (e.g., 120.5)

### Fields not accepting input
- Try clicking directly on the input field
- For numeric fields, only numbers and decimal points are allowed
- On mobile, ensure the virtual keyboard appears

## Technical Notes

### Platform Differences

- **Desktop (sys targets)**: Full save functionality to disk
- **Web/HTML5**: JSON output to console (requires manual file creation)
- **Mobile (Android/iOS)**: JSON output to console or app storage (platform-dependent)

### Dependencies

The metadata editor uses the following libraries:
- **flixel-ui**: For UI components (FlxInputText, FlxUIButton, FlxUICheckBox)
- **flixel**: For basic FlxText and state management
- **haxe.Json**: For JSON serialization

### File Locations

- **Metadata Files**: `assets/music/[SongName].json`
- **Audio Files**: `assets/music/[SongName].ogg` (or .mp3, .wav)
- **Source Code**: `source/states/MetadataEditorState.hx`

## Future Enhancements

Potential features for future versions:
- File browser for selecting songs
- Audio preview while editing
- Visual timeline for cue points and tempo changes
- Import/export from other formats
- Undo/redo functionality
- Auto-detect BPM from audio
- Advanced cue point and tempo change editors with dialogs

## Support

For issues or questions about the metadata editor:
1. Check this documentation first
2. Review the example metadata files in `assets/music/`
3. Test with the Debug State for detailed logging
4. Check the project's issue tracker on GitHub
