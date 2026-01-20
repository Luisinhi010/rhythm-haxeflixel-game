# Metadata Editor UI Layout

```
┌────────────────────────────────────────────────────────────────────┐
│                    Song Metadata Editor                            │
├────────────────────────────────────────────────────────────────────┤
│ Edit song metadata below. Touch/Click fields to edit. Press TAB   │
│ to navigate.                                                       │
├────────────────────────────────────────────────────────────────────┤
│                                                                    │
│  Song File Name:    [_________________________]                   │
│                                                                    │
│  Title:             [_________________________]                   │
│                                                                    │
│  Artist:            [_________________________]                   │
│                                                                    │
│  BPM:               [_________________________] (numeric only)    │
│                                                                    │
│  Offset (ms):       [_________________________] (numeric only)    │
│                                                                    │
│  Time Signature:    [_________________________]                   │
│                                                                    │
│  Loop Music:        [✓] Enable Loop                               │
│                                                                    │
├────────────────────────────────────────────────────────────────────┤
│  Cue Points:                                                       │
│    (none) or list of cue points                                   │
│                                                                    │
│    [Add Cue Point]  [Clear All]                                   │
│                                                                    │
├────────────────────────────────────────────────────────────────────┤
│  Tempo Changes:                                                    │
│    (none) or list of tempo changes                                │
│                                                                    │
│    [Add Tempo Change]  [Clear All]                                │
│                                                                    │
├────────────────────────────────────────────────────────────────────┤
│                                                                    │
│                                                                    │
│  [New]  [Load]  [Save]                          [Back]            │
│                                                                    │
│  Status: Ready                                                     │
└────────────────────────────────────────────────────────────────────┘
```

## Touch-Friendly Features

### Input Fields
- **Large Touch Targets**: All input fields are 300px wide and use 16pt font
- **Clear Visual Feedback**: Input fields change appearance when focused
- **Virtual Keyboard**: Mobile devices automatically display keyboard when tapping fields
- **Field Border**: 2px borders make touch targets clear and easy to hit

### Buttons
- **Minimum Size**: All buttons are at least 100px wide × 30-40px tall
- **Touch Padding**: Adequate spacing (20px) between interactive elements
- **Visual States**: Buttons have hover/press states (handled by FlxUI)
- **Clear Labels**: Large, readable button text

### Checkbox
- **Large Hit Area**: Checkbox with text label extends touch target
- **Text Offset**: Label positioned 25px from checkbox for better touch accuracy
- **Visual Feedback**: Clear checked/unchecked states

### Scrolling (if needed)
- **Viewport**: Content fits in standard 1920×1080 screen
- **Scroll Support**: FlxUI components support native touch scrolling on mobile

### Mobile Considerations
- **Landscape Orientation**: Optimized for landscape mode (as per Project.xml)
- **No Hover States**: All interactions work with tap/touch only
- **No Required Keyboard Shortcuts**: All functions accessible via touch
- **Platform Detection**: Automatically adapts save behavior for web/mobile

## Color Scheme

- **Background**: Dark gray (#282C34) - easy on the eyes
- **Text**: White for labels, light colors for status
- **Input Fields**: Dark background (#3C3F41) with lighter borders (#50535)
- **Status Colors**:
  - Green: Success messages
  - Red: Error messages
  - Cyan: Information messages
  - Yellow: Warnings

## Accessibility Features

- **Keyboard Navigation**: TAB key moves between fields (desktop)
- **Keyboard Shortcuts**: Quick access to common actions (desktop)
- **Clear Labels**: Every input has a descriptive label
- **Status Messages**: Always inform user of actions and results
- **Error Validation**: Clear error messages for invalid input
- **No Time Limits**: Users can take as long as needed
- **Consistent Layout**: Predictable field ordering and button placement
