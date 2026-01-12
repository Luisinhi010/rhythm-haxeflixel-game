# Metadata Editor UI Screenshots

## Visual GUI Editor Overview

The Metadata Editor provides a clean, intuitive interface for creating song metadata without writing JSON.

### Page 1: Basic Information
```
╔════════════════════════════════════════════════════════════════╗
║                    Song Metadata Editor                        ║
╠════════════════════════════════════════════════════════════════╣
║  Page 1/4: Basic Information                                   ║
╠════════════════════════════════════════════════════════════════╣
║                                                                ║
║  Song Filename:     [MySong_______________]                    ║
║                                                                ║
║  Song Title:        [My Awesome Song______]                    ║
║                                                                ║
║  Artist:            [John Doe_____________]                    ║
║                                                                ║
║  BPM:               [140__________________]                    ║
║                                                                ║
║  Offset (ms):       [0____________________]                    ║
║                                                                ║
║  Time Signature:    [4/4__________________]                    ║
║                                                                ║
║  Looped:            YES  [Toggle]                              ║
║                                                                ║
╠════════════════════════════════════════════════════════════════╣
║  TAB: Next Field | SHIFT+TAB: Prev | ENTER: Confirm | ESC: Exit║
╠════════════════════════════════════════════════════════════════╣
║  [< Previous]                                      [Next >]    ║
╚════════════════════════════════════════════════════════════════╝
```

### Page 2: Cue Points
```
╔════════════════════════════════════════════════════════════════╗
║                    Song Metadata Editor                        ║
╠════════════════════════════════════════════════════════════════╣
║  Page 2/4: Cue Points (Optional)                               ║
╠════════════════════════════════════════════════════════════════╣
║                                                                ║
║  Cue points mark important sections in your song.              ║
║  Add them by measure number (easiest) or exact time.           ║
║                                                                ║
║  Current Cue Points:                                           ║
║  ─────────────────────────────────────────────────────────     ║
║  1. "intro" at measure 0                      [Remove]         ║
║  2. "verse" at measure 4                      [Remove]         ║
║  3. "chorus" at measure 12                    [Remove]         ║
║  4. "bridge" at measure 20                    [Remove]         ║
║                                                                ║
║                    [Add Entry]                                 ║
║                                                                ║
╠════════════════════════════════════════════════════════════════╣
║  TAB: Next Field | SHIFT+TAB: Prev | ENTER: Confirm | ESC: Exit║
╠════════════════════════════════════════════════════════════════╣
║  [< Previous]                                      [Next >]    ║
╚════════════════════════════════════════════════════════════════╝
```

### Page 3: Tempo Changes
```
╔════════════════════════════════════════════════════════════════╗
║                    Song Metadata Editor                        ║
╠════════════════════════════════════════════════════════════════╣
║  Page 3/4: Tempo Changes (Optional)                            ║
╠════════════════════════════════════════════════════════════════╣
║                                                                ║
║  Tempo changes allow the BPM to vary throughout the song.      ║
║  Add them by measure number where the tempo changes.           ║
║                                                                ║
║  Current Tempo Changes:                                        ║
║  ─────────────────────────────────────────────────────────     ║
║  1. 140 BPM at measure 0                      [Remove]         ║
║  2. 160 BPM at measure 16                     [Remove]         ║
║  3. 120 BPM at measure 32                     [Remove]         ║
║                                                                ║
║                    [Add Entry]                                 ║
║                                                                ║
╠════════════════════════════════════════════════════════════════╣
║  TAB: Next Field | SHIFT+TAB: Prev | ENTER: Confirm | ESC: Exit║
╠════════════════════════════════════════════════════════════════╣
║  [< Previous]                                      [Next >]    ║
╚════════════════════════════════════════════════════════════════╝
```

### Page 4: Preview & Save
```
╔════════════════════════════════════════════════════════════════╗
║                    Song Metadata Editor                        ║
╠════════════════════════════════════════════════════════════════╣
║  Page 4/4: Preview & Save                                      ║
╠════════════════════════════════════════════════════════════════╣
║  JSON Preview:                                                 ║
║                                                                ║
║  {                                                             ║
║      "title": "My Awesome Song",                               ║
║      "artist": "John Doe",                                     ║
║      "bpm": 140,                                               ║
║      "offset": 0,                                              ║
║      "timeSignature": "4/4",                                   ║
║      "cuePoints": {                                            ║
║          "intro": 0,                                           ║
║          "verse": 6857.142857142857,                           ║
║          "chorus": 20571.428571428572,                         ║
║          "bridge": 34285.714285714286                          ║
║      },                                                        ║
║      "tempoChanges": [                                         ║
║          { "time": 0, "bpm": 140 },                            ║
║          { "time": 27428.571428571428, "bpm": 160 },           ║
║          { "time": 54857.14285714286, "bpm": 120 }             ║
║      ],                                                        ║
║      "looped": true                                            ║
║  }                                                             ║
║                                                                ║
╠════════════════════════════════════════════════════════════════╣
║  TAB: Next Field | SHIFT+TAB: Prev | ENTER: Confirm | ESC: Exit║
╠════════════════════════════════════════════════════════════════╣
║  [< Previous]                        [Save]                    ║
╚════════════════════════════════════════════════════════════════╝
```

## How to Access

1. **Run the game in debug mode:**
   ```bash
   lime test neko -debug
   # or
   lime test windows -debug
   # or
   lime test html5 -debug
   ```

2. **Press the M key** while in the DebugState to open the editor

3. **Navigate through the pages** using the Next/Previous buttons or keyboard shortcuts

4. **Save your metadata** on the final page

## Features

✅ **Intuitive Form Interface** - No JSON editing required
✅ **Tab Navigation** - Easily move between fields
✅ **Visual Feedback** - Active field highlighted in yellow
✅ **Add/Remove Buttons** - Easy cue point and tempo change management
✅ **Real-time Preview** - See your JSON before saving
✅ **Automatic Calculations** - Measures converted to milliseconds
✅ **Validation** - Errors shown immediately
✅ **Keyboard Controls** - Full keyboard navigation support

## Color Scheme

- Background: Dark blue (#1a1a2e)
- Title: White
- Status Text: Cyan (info), Red (error), Green (success)
- Field Labels: White
- Inactive Field Values: Cyan
- Active Field Values: Yellow (with blinking cursor)
- Help Text: Gray
