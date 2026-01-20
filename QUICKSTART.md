# Quick Start Guide - Metadata Editor

## Creating a New Song Metadata File

### Step 1: Access the Editor
- **From Debug State**: Press `M` key
- **From Play State**: Press `M` key

### Step 2: Create New Metadata
1. Click the **[New]** button to start fresh
2. Enter your song's file name (without .json extension)
   - Example: "MySong"

### Step 3: Fill in Basic Information
1. **Title**: Enter the display name for your song
2. **Artist**: Enter the artist or composer name
3. **BPM**: Enter the beats per minute (must be a number > 0)
4. **Offset**: Enter timing offset in milliseconds (use 0 if unsure)
5. **Time Signature**: Enter the time signature (e.g., "4/4")
6. **Loop Music**: Check the box if you want the song to loop

### Step 4: Save Your Metadata
1. Click the **[Save]** button
2. Check the status message at the bottom:
   - **Green**: File saved successfully!
   - **Red**: There was an error (read the message for details)

### Step 5: Verify Your File
- Desktop: Check `assets/music/YourSongName.json`
- Web/Mobile: Check the browser console for JSON output

---

## Editing Existing Metadata

### Step 1: Enter Song Name
Type the name of your existing song in the "Song File Name" field
- Example: "Test" (for Test.json)

### Step 2: Load the File
Click the **[Load]** button
- **Success**: All fields will populate with existing data
- **Error**: Check that the file exists in `assets/music/`

### Step 3: Make Your Changes
Edit any fields you want to change

### Step 4: Save Changes
Click the **[Save]** button to overwrite the existing file

---

## Touch Controls (Mobile)

### Entering Text
1. **Tap** on any text field
2. Virtual keyboard will appear
3. Type your text
4. **Tap** outside the field or press Done/Return to finish

### Using Buttons
- **Tap** any button to activate it
- Wait for the status message to confirm the action

### Checking/Unchecking Loop
- **Tap** the checkbox or the "Enable Loop" text to toggle

---

## Keyboard Shortcuts (Desktop)

| Shortcut | Action |
|----------|--------|
| `M` | Open Metadata Editor (from game) |
| `ESC` | Return to previous state |
| `TAB` | Move to next input field |
| `CTRL+S` | Save metadata |
| `CTRL+O` | Load metadata |
| `CTRL+N` | Create new metadata |

---

## Common Tasks

### Setting Up a Basic Song
```
1. Press M to open editor
2. Click [New]
3. Fill in:
   - Song File Name: "MySong"
   - Title: "My Awesome Song"
   - Artist: "Your Name"
   - BPM: 120
4. Click [Save]
```

### Adding Cue Points
```
Note: Use the editor to create placeholders, then edit the JSON file directly
for precise timing values.

1. Load your song metadata
2. Click [Add Cue Point] for each marker you want
3. Save
4. Open the .json file in a text editor
5. Edit the cue point times to match your song structure
```

### Adding Tempo Changes
```
Note: Similar to cue points, use the editor to create entries, then edit
the JSON file for precise timing.

1. Load your song metadata
2. Click [Add Tempo Change] for each BPM change
3. Save
4. Open the .json file
5. Edit the time and bpm values for each tempo change
```

---

## Troubleshooting

### Problem: Can't find my saved file
**Solution**: 
- Desktop: Check `assets/music/[YourSongName].json`
- Web: The file is logged to console - copy and save manually
- Mobile: Check app storage or console output

### Problem: "Invalid BPM value" error
**Solution**:
- Make sure BPM is a number
- BPM must be greater than 0
- Remove any letters or special characters
- Decimal values are OK (e.g., 120.5)

### Problem: Load button doesn't find my file
**Solution**:
- Make sure the file exists in `assets/music/`
- Check that the file name matches exactly (case-sensitive)
- Don't include ".json" in the file name field
- Verify the file is valid JSON format

### Problem: Touch/Click not working
**Solution**:
- Make sure you're tapping directly on the input field or button
- Try tapping in the center of the field
- For mobile, ensure the game has focus

### Problem: Virtual keyboard doesn't appear (mobile)
**Solution**:
- Tap directly on the text input field
- If still no keyboard, check your device settings
- Try restarting the app

---

## Tips & Best Practices

1. **Save Often**: There's no auto-save feature
2. **Test in Game**: After saving, test your song in the game
3. **Use Examples**: Check the Example.json file for reference
4. **BPM Tools**: Use online BPM detectors for existing songs
5. **Offset Tuning**: Use debug mode to fine-tune offset values
6. **Backup Files**: Keep copies of working metadata files
7. **Naming Convention**: Use descriptive names without spaces
8. **Simple First**: Start with basic metadata, add complexity later

---

## Next Steps

After creating your metadata:
1. Place your audio file in `assets/music/` with the same name
   - Example: `MySong.ogg` or `MySong.mp3`
2. Test in Debug State to verify timing
3. Adjust offset if needed
4. Add cue points for gameplay events
5. Add tempo changes if your song has BPM variations

---

## Support

For detailed information, see:
- **METADATA_EDITOR.md** - Full documentation
- **UI_LAYOUT.md** - UI design and touch features
- **README.MD** - Project overview

For bugs or feature requests, check the project's GitHub repository.
