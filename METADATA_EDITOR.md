# Metadata Editor Documentation

## Overview

The Metadata Editor is a cross-platform UI tool built with Haxe-UI that allows you to create and edit metadata files for music tracks in the rhythm game. It provides a user-friendly interface for managing all aspects of music metadata.

## Features

### File Operations
- **New**: Create a new metadata file with default values
- **Load**: Load an existing metadata file from assets/music directory
- **Save**: Save changes to the current file
- **Save As**: Save the metadata to a new file

### Basic Metadata Fields
- **Title**: The name of the song (text input)
- **Artist**: The artist or composer name (text input)
- **BPM**: Beats per minute (numeric, 1-999, step: 0.1)
- **Offset**: Audio sync offset in milliseconds (numeric, -10000 to 10000, step: 10)
- **Time Signature**: Musical time signature (text input, e.g., "4/4", "3/4", "6/8")

### Advanced Options
- **Looped**: Whether the music should loop continuously (checkbox)

### Cue Points
Cue points are named markers in the music timeline, useful for triggering events at specific times.

- **Name**: A descriptive name for the cue point (e.g., "intro", "chorus", "drop")
- **Time**: The time in milliseconds when this cue point occurs
- Click "Add Cue Point" to add a new entry
- Click "Remove" next to any cue point to delete it

### Tempo Changes
Define BPM changes that occur during the song for tracks with variable tempo.

- **Time**: When the tempo change occurs (in milliseconds)
- **BPM**: The new tempo value
- Click "Add Tempo Change" to add a new entry
- Click "Remove" next to any tempo change to delete it

## Navigation

### Keyboard Controls
- **Arrow Keys / WASD**: Navigate menu items
- **Enter / Space**: Select menu item or interact with UI elements
- **ESC**: Return to main menu from the editor
- **F5**: Reload current state (development feature)

### Mouse/Touch Controls
- **Click/Tap**: Select and interact with all UI elements
- **Scroll**: Scroll through the editor content
- All buttons and fields are touch-friendly for mobile devices

## Usage Guide

### Creating a New Metadata File

1. Launch the game and select "Metadata Editor" from the main menu
2. Click "New" to start with a blank template
3. Fill in the basic metadata fields (title, artist, BPM, etc.)
4. Optionally add cue points and tempo changes
5. Click "Save As" to save your metadata file

### Editing an Existing File

1. Open the Metadata Editor from the main menu
2. Click "Load" to load an existing .json file from assets/music
3. Edit any fields as needed
4. Click "Save" to save changes, or "Save As" to create a copy

### Adding Cue Points

1. In the Cue Points section, click "Add Cue Point"
2. Enter a descriptive name (e.g., "verse1", "chorus")
3. Set the time in milliseconds when this point occurs
4. Repeat for additional cue points
5. Save your changes

### Adding Tempo Changes

1. In the Tempo Changes section, click "Add Tempo Change"
2. Set the time when the tempo changes (in milliseconds)
3. Set the new BPM value
4. Repeat for additional tempo changes
5. Save your changes

## File Format

Metadata files are saved as JSON with the following structure:

```json
{
    "title": "Song Title",
    "artist": "Artist Name",
    "bpm": 120.0,
    "offset": 0,
    "timeSignature": "4/4",
    "cuePoints": {
        "intro": 0,
        "chorus": 30000
    },
    "tempoChanges": [
        { "time": 60000, "bpm": 125 },
        { "time": 90000, "bpm": 130 }
    ],
    "looped": false
}
```

## Platform Support

The Metadata Editor is designed to work on:
- **Desktop**: Windows, macOS, Linux (with full file system access)
- **Mobile**: Android, iOS (with application storage directory)
- **Web**: HTML5 (with limited save/load functionality)

Note: On web platforms, file operations may be limited due to browser security restrictions.

## Tips and Best Practices

1. **BPM Accuracy**: Use a BPM detection tool to get accurate tempo values for your music
2. **Offset Calibration**: Adjust the offset value to sync audio with visual elements
3. **Cue Point Names**: Use consistent naming conventions (e.g., "intro", "verse1", "chorus1")
4. **Tempo Changes**: Only add tempo changes for music with variable tempo
5. **Testing**: Always test your metadata in the game to ensure proper synchronization

## Troubleshooting

### File Not Loading
- Ensure the .json file is in the assets/music directory
- Check that the JSON syntax is valid
- Verify file permissions on your system

### Save Not Working
- On desktop: Ensure you have write permissions for the assets/music directory
- On web: Use browser's download feature as an alternative
- Check console output for error messages

### UI Not Displaying Correctly
- Try resizing the window
- Check that haxeui-core and haxeui-flixel are properly installed
- Restart the application

## Development Notes

### Dependencies
- haxeui-core: Core Haxe-UI framework
- haxeui-flixel: Flixel backend for Haxe-UI
- flixel: Game framework

### File Locations
- Source: `source/states/MetadataEditorState.hx`
- Main Menu: `source/states/MainMenuState.hx`
- Metadata Type: `source/backend/MusicMetaData.hx`
- Assets: `assets/music/*.json`

### Extending the Editor

To add new metadata fields:

1. Update `MusicMetaData.hx` typedef with the new field
2. Add UI components in `MetadataEditorState.hx`:
   - Create the input component in `buildUI()`
   - Load data in `loadFormData()`
   - Save data in `saveFormData()`
   - Update `metadataToJson()` if needed

### Customization

The editor supports Haxe-UI theming. To change the appearance:
- Modify `Toolkit.theme` in `create()` method
- Add custom styles using `styleString` property
- Create custom CSS files for advanced styling

## Additional Resources

- [Haxe-UI Documentation](https://haxeui.org/)
- [HaxeFlixel Documentation](https://haxeflixel.com/documentation/)
- Project README for general game information
