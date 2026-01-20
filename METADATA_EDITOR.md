# Song Metadata Editor

A comprehensive visual editor for managing song metadata, cue points, and BPM changes in the rhythm game.

## Features

### Timeline View
- Visual beat grid based on the song's BPM
- Playback position indicator (red line)
- Scrollable and zoomable timeline
- Click anywhere on the timeline to seek to that position

### Cue Points Management
- Visual markers (cyan diamonds) on the timeline
- Add cue points at the current playback position
- Click markers to select them
- Delete selected markers with DELETE key
- Cue points are saved with custom names and timestamps

### BPM Changes Management
- Visual markers (orange squares) on the timeline
- Add BPM change markers at the current position
- Click markers to select them
- Delete selected markers with DELETE key
- BPM changes affect the beat grid visualization

### Metadata Fields
- **Title**: Song name
- **Artist**: Artist/composer name
- **BPM**: Initial beats per minute
- **Offset**: Audio offset in milliseconds (for sync adjustment)
- **Time Signature**: Musical time signature (e.g., 4/4, 3/4)

### Music Playback
- Play/Pause controls
- Real-time playback position display
- Seek by clicking timeline
- Time display shows current position and total duration

## Controls

### Mouse Controls
- **Click Timeline**: Seek to position
- **Click Marker**: Select cue point or BPM marker
- **Mouse Wheel**: Zoom in/out on timeline

### Keyboard Shortcuts
- **SPACE**: Play/Pause music
- **CTRL+S**: Save metadata to JSON file
- **DELETE**: Remove selected marker
- **+/-**: Zoom in/out
- **← →**: Scroll timeline left/right
- **M**: Toggle between Debug State and Metadata Editor
- **F5**: Reload current state
- **ENTER/ESC**: Exit text field editing

### Buttons
- **Play/Pause**: Toggle music playback
- **Add Cue**: Add cue point at current time
- **Add BPM**: Add BPM change at current time
- **Save**: Save metadata to JSON file
- **Load**: Reload song and metadata

## File Format

The editor saves metadata in JSON format compatible with the game's music loading system:

```json
{
  "title": "Song Name",
  "artist": "Artist Name",
  "bpm": 120,
  "offset": 0,
  "timeSignature": "4/4",
  "cuePoints": {
    "intro": 5000,
    "chorus": 15000
  },
  "tempoChanges": [
    {"time": 30000, "bpm": 140}
  ]
}
```

## Usage

1. **Access the Editor**:
   - In debug mode, press **M** from DebugState to open the editor
   - The editor loads the default "Test" song

2. **Edit Metadata**:
   - Click on text fields to edit title, artist, BPM, etc.
   - Press ENTER or click outside to confirm changes

3. **Add Cue Points**:
   - Play the song to find the desired position
   - Click "Add Cue" button or pause and click the timeline
   - The cue point will be added at the current time

4. **Add BPM Changes**:
   - Seek to the position where tempo changes
   - Click "Add BPM" button
   - The current BPM value is used (edit the BPM field first if needed)

5. **Navigate Timeline**:
   - Use mouse wheel to zoom in/out for precision
   - Use arrow keys or click-drag to scroll
   - Click anywhere to seek playback

6. **Save Your Work**:
   - Press **CTRL+S** or click "Save" button
   - Metadata is saved to `assets/music/[songname].json`
   - On desktop platforms, files are saved to the writable directory

## Tips

- **Precision Editing**: Zoom in for accurate marker placement
- **Beat Grid**: The visual grid helps align markers to beats
- **Quick Navigation**: Click the timeline to jump to any position instantly
- **Selection**: Click markers to select them before deleting or editing
- **Multiple Changes**: Add multiple BPM changes for songs with varying tempo

## Integration

The metadata editor integrates seamlessly with:
- **Song Class**: Loads and saves metadata
- **Conductor**: Uses BPM and tempo changes for rhythm tracking
- **Paths System**: Uses the existing asset loading system
- **Debug State**: Easy access for testing and development

## Future Enhancements

Potential improvements for future versions:
- Drag markers to reposition them
- Edit marker properties inline
- Visual waveform display
- Snap-to-beat option for precise alignment
- Undo/Redo functionality
- Multiple song management
- Copy/paste markers between songs
