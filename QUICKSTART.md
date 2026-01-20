# Metadata Editor - Quick Start Guide

Get started with the Song Metadata Editor in 5 minutes!

## 🚀 Quick Access

1. **Build and run the game in debug mode**:
   ```bash
   haxelib run lime test windows -debug
   # or
   haxelib run lime test html5 -debug
   ```

2. **Press `M` key** when in DebugState to open the Metadata Editor

3. **Start editing!** The editor loads the "Test" song by default

## 🎯 Common Tasks

### Edit Song Information
1. Click any text field (Title, Artist, BPM, etc.)
2. Type your changes
3. Press **ENTER** or click outside to confirm

### Add a Cue Point
1. Play the song (**SPACE**) and pause at the desired moment
2. Click **Add Cue** button
3. The cue point appears on the timeline with a cyan diamond ◆

### Add a BPM Change
1. First, edit the BPM field to the new tempo value
2. Seek to the position where the tempo changes
3. Click **Add BPM** button
4. The BPM marker appears with an orange square ■

### Navigate the Timeline
- **Click** anywhere to jump to that position
- **Mouse Wheel** to zoom in/out
- **Arrow Keys** (← →) to scroll
- **+/-** keys to zoom in/out

### Save Your Work
- Press **CTRL+S** or click **Save** button
- File is saved to `assets/music/[songname].json`

### Delete a Marker
1. Click the marker to select it (turns yellow)
2. Press **DELETE** key

## ⌨️ Essential Keyboard Shortcuts

| Key | Action |
|-----|--------|
| **SPACE** | Play/Pause music |
| **CTRL+S** | Save metadata |
| **DELETE** | Remove selected marker |
| **+/-** | Zoom timeline |
| **← →** | Scroll timeline |
| **M** | Toggle Editor ↔ Debug State |
| **F5** | Reload state |

## 📝 Example Workflow

### Creating metadata for a new song:

1. Add your song files to `assets/music/`:
   - `mysong.ogg` (or .mp3, .wav)
   - `mysong.json` (create empty file or copy Test.json)

2. Open the editor and load your song (modify the default song name in code or load system)

3. Play the song and identify key moments:
   - Intro end
   - Verse start
   - Chorus start
   - Bridge
   - Outro start

4. For each moment:
   - Pause at the right time
   - Click **Add Cue**
   - (Optional) Edit the cue name later in the JSON

5. If the song changes tempo:
   - Find where tempo changes
   - Update BPM field to new value
   - Click **Add BPM** at that position

6. Edit metadata fields:
   - Title: "My Awesome Song"
   - Artist: "Composer Name"
   - BPM: Initial tempo
   - Offset: 0 (adjust if audio is out of sync)
   - Time Signature: "4/4" (or "3/4", etc.)

7. **Save** with CTRL+S

8. Test with the game's rhythm system!

## 🎨 Visual Guide

### Timeline Legend
```
   ║ ║ ║ ║    = Beat grid (vertical lines)
     ◆        = Cue point (cyan)
     ■        = BPM change (orange)
     |        = Playhead (red, shows current position)
```

### Marker States
- **Normal**: Cyan (cue) or Orange (BPM)
- **Selected**: Yellow (click to select, then press DELETE to remove)

## 💡 Tips

1. **Zoom in for precision**: Use the mouse wheel to zoom in when placing markers at exact beats

2. **Use the beat grid**: The vertical lines help align markers to the song's rhythm

3. **Test playback**: Always test by clicking the timeline to verify cue points are at the right positions

4. **Save often**: Press CTRL+S frequently to avoid losing work

5. **Start simple**: Begin with just a few important cue points (intro, chorus, outro) and add more later

## 🐛 Troubleshooting

**Problem**: Can't type in text fields
- **Solution**: Click the field first to focus it

**Problem**: Keyboard shortcuts don't work
- **Solution**: Make sure no text field is focused (press ESC or click outside)

**Problem**: Can't see markers on timeline
- **Solution**: Try zooming out with the mouse wheel or minus key

**Problem**: Song doesn't play
- **Solution**: Check that the .ogg file exists in `assets/music/`

**Problem**: Save doesn't work
- **Solution**: Make sure you're on a desktop platform (Windows/Linux/Mac). Web and mobile have restrictions.

## 📚 More Information

- Full documentation: See `METADATA_EDITOR.md`
- Technical details: See `IMPLEMENTATION_SUMMARY.md`
- Questions? Check the main project README

## 🎵 Ready to Create!

You're all set! Press **M** in debug mode and start creating amazing song metadata for your rhythm game.

Happy editing! 🎮✨
