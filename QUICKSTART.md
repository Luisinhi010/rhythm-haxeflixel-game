# Quick Start Guide - Metadata Editor

## Installation

1. **Install Dependencies** (if not already installed):
   ```bash
   haxelib install flixel
   haxelib install haxeui-core
   haxelib install haxeui-flixel
   ```

2. **Build the Project**:
   ```bash
   lime build windows    # For Windows
   lime build linux      # For Linux
   lime build mac        # For macOS
   lime build html5      # For Web
   lime build android    # For Android
   ```

3. **Run the Application**:
   ```bash
   lime test windows     # Test on Windows
   lime test html5       # Test in browser
   ```

## Using the Metadata Editor

### Accessing the Editor

1. Launch the application
2. You'll see the main menu with three options:
   - **Play**: Start the game
   - **Debug**: Open debug state
   - **Metadata Editor**: Open the metadata editor
3. Navigate using:
   - **Keyboard**: Arrow keys or WASD, press Enter/Space to select
   - **Mouse**: Click on any menu item
   - **Touch**: Tap on any menu item (mobile)

### Creating a New Metadata File

1. Open the Metadata Editor from the main menu
2. Click "New" button to start with a blank template
3. Fill in the fields:
   - **Title**: Name of your song
   - **Artist**: Artist or composer name
   - **BPM**: Set the tempo (beats per minute)
   - **Offset**: Adjust audio sync (in milliseconds)
   - **Time Signature**: Musical time signature (e.g., "4/4")
   - **Looped**: Check if the music should loop
4. Add cue points (optional):
   - Click "Add Cue Point"
   - Enter a name (e.g., "intro", "chorus")
   - Set the time in milliseconds
5. Add tempo changes (optional):
   - Click "Add Tempo Change"
   - Set the time and new BPM
6. Click "Save As" to save your file
   - Files are saved to `assets/music/` directory
   - File name is based on the title (automatically sanitized)

### Editing Existing Metadata

1. Open the Metadata Editor
2. Click "Load" button
   - Currently loads the first available JSON file
   - Future versions will have a file picker
3. Modify any fields as needed
4. Click "Save" to update the current file
   - Or "Save As" to create a new copy

### Keyboard Shortcuts

While in the editor:
- **ESC**: Return to main menu
- **F5**: Reload the current state (development)
- **Tab**: Navigate between fields
- **Enter**: Interact with focused element

## File Locations

### Metadata Files
- Location: `assets/music/*.json`
- Example: `assets/music/Example.json`
- Format: JSON with specific structure (see below)

### Source Code
- Main Menu: `source/states/MainMenuState.hx`
- Editor: `source/states/MetadataEditorState.hx`
- Metadata Type: `source/backend/MusicMetaData.hx`

## JSON File Format

```json
{
    "title": "Song Name",
    "artist": "Artist Name",
    "bpm": 140.0,
    "offset": 0,
    "timeSignature": "4/4",
    "cuePoints": {
        "intro": 0,
        "verse": 8000,
        "chorus": 24000
    },
    "tempoChanges": [
        { "time": 60000, "bpm": 130.0 }
    ],
    "looped": false
}
```

### Field Descriptions

- **title** (string): Song title
- **artist** (string): Artist or composer
- **bpm** (number): Initial tempo in beats per minute
- **offset** (number): Audio sync offset in milliseconds
- **timeSignature** (string): Musical time signature
- **cuePoints** (object): Named markers with timestamps (ms)
- **tempoChanges** (array): BPM changes with timestamps (ms)
- **looped** (boolean): Whether to loop the music

## Tips

1. **Finding BPM**: Use online BPM detection tools or tap tempo apps
2. **Offset Adjustment**: Test in-game and adjust in small increments (±10ms)
3. **Cue Point Names**: Use consistent, descriptive names
4. **Testing**: Always test metadata in the debug state after editing
5. **Backup**: Keep backups of your metadata files before making major changes

## Troubleshooting

### Editor Not Opening
- Check that haxeui-core and haxeui-flixel are installed
- Verify Project.xml has the haxeui libraries enabled
- Try rebuilding the project from scratch

### Files Not Saving
- **Desktop**: Check write permissions for the assets/music directory
- **Web**: File saving may not work due to browser restrictions
- **Mobile**: Files save to application storage directory

### UI Elements Not Displaying
- Try resizing the window
- Check console for error messages
- Ensure all dependencies are properly installed

### File Not Loading
- Verify the JSON file is in assets/music/
- Check JSON syntax is valid (use a JSON validator)
- Look for error messages in the status label

## Next Steps

After creating your metadata files:
1. Place corresponding audio files (same name, .ogg format) in assets/music/
2. Test in Debug State to verify synchronization
3. Adjust offset if needed for better sync
4. Add cue points for gameplay triggers
5. Define tempo changes for variable-tempo songs

## Additional Resources

- **Full Documentation**: See `METADATA_EDITOR.md`
- **Implementation Details**: See `IMPLEMENTATION_SUMMARY.md`
- **Project Overview**: See `README.MD`
- **Haxe-UI Docs**: https://haxeui.org/
- **HaxeFlixel Docs**: https://haxeflixel.com/documentation/

## Support

If you encounter issues:
1. Check the troubleshooting section above
2. Review the full documentation in METADATA_EDITOR.md
3. Look for error messages in the console/status label
4. Verify all dependencies are correctly installed

## Example Workflow

Here's a complete workflow for adding a new song:

1. **Prepare Audio**:
   - Export your song as OGG format
   - Name it (e.g., "MySong.ogg")
   - Place in `assets/music/MySong.ogg`

2. **Create Metadata**:
   - Open Metadata Editor
   - Click "New"
   - Set title to "MySong"
   - Set artist name
   - Set BPM (use BPM detector if unsure)
   - Click "Save As"

3. **Test in Debug**:
   - Exit editor (ESC)
   - Go to Debug State
   - Song should load and play

4. **Fine-tune**:
   - If sync is off, adjust offset
   - Add cue points for important sections
   - Add tempo changes if needed
   - Save changes

5. **Use in Game**:
   - Song is now ready to use in gameplay
   - Access via Song class: `new Song("MySong")`

Enjoy creating rhythm game content!
