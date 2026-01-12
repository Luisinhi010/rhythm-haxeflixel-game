# Visual Metadata Editor - User Guide

## Quick Start Guide

### Step 1: Launch the Editor

Run your game in debug mode and press **M** to open the Metadata Editor:

```
┌─────────────────────────────────────┐
│     Debug State (Main Game)         │
│                                     │
│  Press M to open Metadata Editor    │
│                                     │
│  [Music playing, debug info shown]  │
└─────────────────────────────────────┘
                ↓ Press M
┌─────────────────────────────────────┐
│    Song Metadata Editor - Page 1    │
│         Basic Information           │
└─────────────────────────────────────┘
```

### Step 2: Fill in Basic Information

Navigate through fields using **TAB** (forward) or **SHIFT+TAB** (backward):

```
Page 1: Basic Information
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Required Fields:
  ✓ Song Filename      → File to save as
  ✓ Song Title         → Display name
  ✓ Artist             → Artist name
  ✓ BPM                → Beats per minute

Optional Fields:
  • Offset (ms)        → Timing adjustment
  • Time Signature     → Musical time (4/4, 3/4, etc.)
  • Looped             → Toggle YES/NO

Click "Next >" when done
```

### Step 3: Add Cue Points (Optional)

Mark important sections of your song:

```
Page 2: Cue Points
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
What are cue points?
  Markers for song sections like:
  • intro, verse, chorus, bridge, outro
  • drop, breakdown, buildup
  • any custom section name

How to add:
  1. Click "Add Entry"
  2. A new entry appears (can be edited later)
  3. Each entry has:
     - Name (e.g., "chorus")
     - Measure number (e.g., 16)
  
Example:
  1. "intro" at measure 0
  2. "verse" at measure 4
  3. "chorus" at measure 12
  4. "bridge" at measure 20
  5. "outro" at measure 28

Click "Next >" when done
```

### Step 4: Add Tempo Changes (Optional)

For songs that speed up or slow down:

```
Page 3: Tempo Changes
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
When to use:
  • Song starts at 120 BPM, speeds to 140
  • Multiple tempo shifts throughout
  • Progressive house, drum & bass, etc.

How to add:
  1. Click "Add Entry"
  2. Specify:
     - Measure number (when change happens)
     - New BPM value

Example:
  1. 120 BPM at measure 0   (start)
  2. 140 BPM at measure 16  (speed up)
  3. 100 BPM at measure 32  (slow down)

Click "Next >" when done
```

### Step 5: Preview & Save

Review and save your metadata:

```
Page 4: Preview & Save
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Shows the JSON that will be saved:
  ✓ All times automatically calculated
  ✓ Measures converted to milliseconds
  ✓ Properly formatted and validated

Click "Save" to write file:
  → assets/music/[filename].json

SUCCESS message will appear when saved!
```

## Keyboard Controls Reference

```
┌──────────────────────────────────────────────┐
│  Global Controls                             │
├──────────────────────────────────────────────┤
│  ESC          → Exit editor (back to game)   │
│  TAB          → Next field                   │
│  SHIFT + TAB  → Previous field               │
└──────────────────────────────────────────────┘

┌──────────────────────────────────────────────┐
│  Text Input (in active field)                │
├──────────────────────────────────────────────┤
│  A-Z, 0-9     → Type characters              │
│  SPACE        → Space character              │
│  BACKSPACE    → Delete last character        │
│  - . /        → Special characters           │
└──────────────────────────────────────────────┘

┌──────────────────────────────────────────────┐
│  Navigation                                  │
├──────────────────────────────────────────────┤
│  Click buttons or use mouse                  │
│  [< Previous] → Go to previous page          │
│  [Next >]     → Go to next page              │
│  [Add Entry]  → Add cue point/tempo change   │
│  [Remove]     → Remove specific entry        │
│  [Toggle]     → Toggle looped on/off         │
│  [Save]       → Save metadata file           │
└──────────────────────────────────────────────┘
```

## Visual Indicators

```
Color Coding:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  WHITE    → Labels and static text
  CYAN     → Inactive field values
  YELLOW   → Active field (you can type here!)
  GREEN    → Success messages, "YES" states
  RED      → Error messages, "NO" states
  GRAY     → Help text and descriptions

Cursor:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Blinking cursor (|) shows where text will appear
  Only visible in active field
```

## Example Workflow

### Creating "Epic Drop" Metadata

```
1. LAUNCH EDITOR
   Press M in debug mode
   
2. PAGE 1 - Basic Info
   Filename:       EpicDrop
   Title:          Epic Drop
   Artist:         DJ Bass
   BPM:            140
   Offset:         0
   Time Signature: 4/4
   Looped:         YES
   → Click "Next >"

3. PAGE 2 - Cue Points
   Click "Add Entry" 5 times, then edit:
   • intro     → measure 0
   • buildup   → measure 8
   • drop      → measure 16
   • breakdown → measure 32
   • outro     → measure 48
   → Click "Next >"

4. PAGE 3 - Tempo Changes
   Click "Add Entry" 3 times, then edit:
   • measure 0  → 140 BPM (start)
   • measure 16 → 150 BPM (drop faster)
   • measure 32 → 120 BPM (breakdown slower)
   → Click "Next >"

5. PAGE 4 - Preview & Save
   Review the JSON preview
   → Click "Save"
   
6. DONE!
   File saved to: assets/music/EpicDrop.json
   Press ESC to return to game
```

## Tips & Tricks

### Best Practices

1. **Use Measure Numbers**: Much easier than calculating milliseconds!
2. **Meaningful Names**: Use descriptive cue point names
3. **Test in Game**: After saving, test your metadata by loading the song
4. **Start Simple**: Begin with just basic info, add cue points/tempo later
5. **Preview Before Save**: Always check the preview page

### Common Mistakes to Avoid

❌ Forgetting to fill in required fields (filename, title, artist, BPM)
❌ Using negative values for measures or BPM
❌ Using invalid time signatures (must be "X/Y" format)
❌ Forgetting to click "Save" on the final page

### Time Conversions

The editor automatically converts measure numbers to milliseconds:

```
At 140 BPM in 4/4 time:
  Measure 0  =     0 ms
  Measure 1  =  1714 ms
  Measure 4  =  6857 ms
  Measure 16 = 27428 ms
  
Formula: time_ms = (measure × beats_per_bar × 60000) / BPM
```

## Troubleshooting

### Error Messages

```
"Please fill in filename, title, and artist!"
→ Required fields missing on page 1

"BPM must be a positive number!"
→ BPM is 0, negative, or not a number

"Error generating preview: [details]"
→ Invalid data in one of the fields
→ Check time signature format (X/Y)
```

### Can't Type in Fields

- Make sure field is highlighted in YELLOW
- Press TAB to select a field
- If still stuck, try pressing ESC and reopening editor

### Save Not Working

- Ensure you're on platform that supports file writing (neko, cpp, etc.)
- Check that assets/music/ directory exists
- Look for error message in status text

## Comparison: GUI vs CLI vs Manual

```
┌──────────────┬──────────┬──────────┬──────────┐
│ Feature      │ GUI      │ CLI      │ Manual   │
├──────────────┼──────────┼──────────┼──────────┤
│ Ease of Use  │ ⭐⭐⭐⭐⭐ │ ⭐⭐⭐⭐   │ ⭐⭐      │
│ Speed        │ ⭐⭐⭐⭐⭐ │ ⭐⭐⭐    │ ⭐⭐      │
│ Visual       │ ⭐⭐⭐⭐⭐ │ ⭐⭐      │ ⭐        │
│ Validation   │ ⭐⭐⭐⭐⭐ │ ⭐⭐⭐⭐   │ ⭐        │
│ Preview      │ ⭐⭐⭐⭐⭐ │ ⭐⭐⭐⭐   │ ⭐        │
└──────────────┴──────────┴──────────┴──────────┘

Recommendation: Use GUI for most tasks!
```
