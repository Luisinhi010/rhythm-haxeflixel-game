# Copilot Repository Instructions

## Project Overview
This is a rhythm game built with Haxe, OpenFL, and HaxeFlixel. The game is a Guitar Hero / Friday Night Funkin' style rhythm game where players press keys to the beat of the music. The game targets Windows, Web (HTML5), and Android platforms.

## Technology Stack
- **Language**: Haxe
- **Framework**: HaxeFlixel (built on OpenFL and Lime)
- **Target Platforms**: Windows, Web (HTML5), Android
- **Build System**: Lime/OpenFL build system with Project.xml configuration

## Code Style and Conventions

### Haxe Language Guidelines
- Use tabs for indentation (following HaxeFlixel conventions)
- Brace placement (following `hxformat.json`):
  - General rule ("both"): Opening braces on new line, closing braces on new line
  - Object literals ("after"): Opening brace inline, closing brace on new line
  - Example class/function: opening `{` on new line after declaration
  - Example object: `var obj = {` with opening brace on same line
- Control flow: place `else` on the next line after the closing brace of the if block
- Follow the style defined in `hxformat.json`
- Use type annotations for all function parameters and return types
- Prefer explicit typing over dynamic typing

### Naming Conventions
- **Classes**: PascalCase (e.g., `DefaultBar`, `Conductor`, `PlayState`)
- **Variables**: camelCase (e.g., `hitbar`, `beatDuration`)
- **Constants**: UPPER_CASE (if needed)
- **Private fields**: prefix with underscore is optional, but use `private` keyword
- **Functions**: camelCase (e.g., `screenCenter()`, `getMusicData()`)

### File Organization
- One class per file
- File name must match the class name exactly
- Package structure follows directory structure
- Files are organized as:
  - `source/` - All source code
    - `backend/` - Core utilities and managers
      - `Paths.hx` - Asset loading and caching system
      - `InputManager.hx` - Input binding and management
      - `FilePath.hx` - File path utilities
      - `FlxGroupContainer.hx` - Positionable FlxGroup with x/y coordinates
      - Typedefs: `BeatEvent.hx`, `MusicMetaData.hx`
    - `core/` - Core game systems and utilities
      - `utils/` - Utility classes
        - `MathUtil.hx` - Math utilities (lerp, clamp, map, etc.)
        - `StringUtil.hx` - String utilities (formatting, padding, etc.)
        - `ArrayUtil.hx` - Array utilities (shuffle, random, etc.)
      - `domain/` - Domain models (reserved)
      - `services/` - Services (reserved)
    - `infrastructure/` - Infrastructure layer (reserved for future use)
      - `adapters/` - External adapters
      - `assets/` - Asset management
      - `audio/` - Audio systems
      - `input/` - Input systems
    - `presentation/` - Presentation layer (reserved for future use)
      - `states/` - UI states
    - `objects/` - Game objects
      - `Conductor.hx` - Music playback and rhythm tracking
      - `Song.hx` - Music data container
      - `DefaultBar.hx` - Base rhythm bar class
      - `ConductorDebugger.hx` - Visual debugger for Conductor
      - `Metronome.hx` - Metronome click sounds
      - `UtilTester.hx` - Visual tester for utility functions
    - `states/` - Game states
      - `DefaultState.hx` - Base state with common functionality
      - `PlayState.hx` - Main gameplay state
      - `DebugState.hx` - Testing and debugging state
  - `assets/` - Game assets
    - `images/` - Images
    - `music/` - Music files (.ogg, .mp3, .wav)
    - `sounds/` - Sound effects
    - `ui/` - UI assets

## Architecture Patterns

### State Management
- All game states extend `DefaultState`, which extends `FlxState`
- Use `PlayState` for main gameplay
- Use `DebugState` for testing and debugging
- The initial state is `DebugState` in debug mode, `PlayState` in release

### Asset Loading
- **Never** directly access assets - always use the `Paths` class from `backend/Paths.hx`
- `Paths` provides caching for all resources (images, sounds, music, text files)
- Use appropriate methods:
  - `Paths.getImage(name)` for BitmapData
  - `Paths.getSprite(name)` for FlxSprite
  - `Paths.getSound(name)` for sounds
  - `Paths.getMusic(name)` for music
  - `Paths.getFlxSound(name)` / `Paths.getFlxMusic(name)` for FlxSound
  - `Paths.getMusicData(name)` for JSON metadata
- For async loading, use methods like `Paths.loadImageAsync()`, `Paths.loadSoundAsync()`
- Clear cache when needed with `Paths.clearCache()`
- File paths are managed by `FilePath` class, never construct paths manually

### Music and Rhythm System
- The `Conductor` class handles music playback and rhythm tracking
- Music metadata is stored in JSON files with the following structure (parsed into `MusicMetaData` typedef):
```json
{
    "title": "Song Name",
    "artist": "Artist Name",
    "bpm": 120,
    "offset": 0,
    "timeSignature": "4/4",
    "cuePoints": {
        "intro": 0,
        "chorus": 30000
    },
    "tempoChanges": [
        { "time": 60000, "bpm": 125 }
    ],
    "looped": false
}
```
- Note: `cuePoints` is represented as an object in JSON but becomes `Map<String, Float>` when parsed
- `offset`: Initial delay in milliseconds
- `cuePoints`: Reference points in the music (in milliseconds)
- `tempoChanges`: BPM changes throughout the song (in milliseconds)
- Use the `Song` class as a container for music data
- Use `BeatEvent` typedef for beat events
- The `Conductor` calculates beats, steps, and subdivisions in real-time

### Game Objects
- Extend `FlxSprite` or `FlxBasic` for game objects
- Use `DefaultBar` as the base class for rhythm game bars
- Implement `update(elapsed:Float)` for per-frame logic
- Use FlxTween for smooth animations
- Use FlxTimer for timed events

### Conductor System
- `Conductor` class manages music playback and rhythm tracking
  - Handles BPM, beats, steps, bars, and sections
  - Supports tempo changes mid-song
  - Supports cue points for jumping to specific sections
  - Dispatches beat events via callbacks: `beatHit`, `stepHit`, `sectionHit`, `barHit`
  - Use `play()`, `pause()`, `stop()`, `restart()` for playback control
  - Use `jumpToCue(name)` to jump to named cue points
- `Song` class is a data container for music metadata and audio
  - Loads metadata from JSON files
  - Holds FlxSound instance
  - Manages cue points and tempo changes
- `ConductorDebugger` provides visual debugging for Conductor
  - Shows beats, cue points, and tempo changes on a timeline
  - Displays current position marker
  - Toggle with `toggleDebugMode()`
- `Metronome` provides click sounds for beats
  - Supports pitch variation for accented beats
  - Use `click(beat)` to play a metronome sound

### Input Handling
- Use `InputManager` from `backend/InputManager.hx` for game-specific input handling
- Direct `FlxG.keys` access is acceptable for debug/utility features (e.g., F5 to reload state in DefaultState)
- For gameplay input, prefer InputManager for consistency and multi-platform support

## Platform-Specific Code
- Use conditional compilation for platform-specific code:
  - `#if debug` - Debug builds only
  - `#if sys` - Native platforms (Windows, Mac, Linux)
  - `#if (sys && !android && !ios)` - Desktop platforms only
  - `#if html5` - Web builds
  - `#if mobile` - Mobile platforms
  - `#if (android || ios)` - Mobile platforms
  - `#if js` - JavaScript/web target
- File I/O on desktop uses `sys.io.File`
- Web and mobile use OpenFL Assets API

## Documentation
- Add documentation comments for all public classes and methods
- Use JavaDoc-style comments with `/**  */`
- Document parameters with `@param name description`
- Document return values with `@return description`
- Include usage examples for complex APIs

## Game Design Specifics
- The game features a central bar with incoming bars from the sides
- Players must press directional keys when bars align with the central bar
- Bars can have different speeds (players must adapt)
- Bars can have different colors (damage vs healing)
- Features include:
  - Health bar (decreases when missing notes)
  - Combo counter (increases on consecutive hits)
  - Score display
  - Background can be an image or video depending on the song
  - Difficulty selection (affects bar speed and quantity)
  - Song selection
  - Game mode selection
  - Theme/color customization

## Building and Testing
- Build with: `lime build <target>` where target is `windows`, `html5`, `android`, etc.
- Test with: `lime test <target>`
- Debug builds: `lime test <target> -debug`
- Release builds: `lime test <target> -release`
- The build output goes to `export/debug/` or `export/release/` based on the build type

### Debug Tools
- **F5**: Reload current state (available in all states via DefaultState)
- **DebugState Controls**:
  - **SPACE**: Toggle music playback (play/pause)
  - **R**: Restart music from beginning
  - **Q**: Jump to "test" cue point
  - **T**: Toggle UtilTester display
  - **Arrow Keys**: Navigate between utility test sections in UtilTester
- **UtilTester**: Visual demonstrations of MathUtil, StringUtil, and ArrayUtil functions
- **ConductorDebugger**: Visual timeline showing beats, cue points, and tempo changes

## Common Utilities

### Platform Utilities (`Util.hx`)
- Use `Util.hx` (located at `source/Util.hx`) for platform-specific utilities
  - `getWritablePath()`: Converts relative paths to platform-specific writable paths

### Math Utilities (`core/utils/MathUtil.hx`)
Delegates to native Haxe/FlxMath implementations where possible:
- `clamp(value, min, max)` / `clampInt()` - Constrain values to ranges
- `lerp(a, b, t)` / `lerpClamp()` - Linear interpolation
- `mapRange(value, inMin, inMax, outMin, outMax)` - Map value from one range to another
- `roundTo(value, precision)` - Round to decimal places
- `degToRad()` / `radToDeg()` - Angle conversion
- `positiveMod()` - Always positive modulo
- `approxEqual(a, b, epsilon)` - Floating point comparison
- `sign(x)` - Returns -1, 0, or 1
- `randomRange(min, max)` / `randomRangeInt()` - Random value generation

### String Utilities (`core/utils/StringUtil.hx`)
Delegates to native StringTools and FlxStringUtil:
- `capitalization(str)` - Capitalize first letter
- `formatTime(seconds)` / `formatTimeMs(ms)` - Format time as "MM:SS"
- `isEmpty(str)` - Null-safe empty check
- `trim(str)` - Remove whitespace
- `padLeft()` / `padRight()` - Pad strings with characters

### Array Utilities (`core/utils/ArrayUtil.hx`)
Delegates to native Array methods and FlxG.random:
- `pickRandom(arr)` - Select random element
- `shuffle(arr, howManyTimes)` - Shuffle array (returns copy)
- `remove(arr, element)` - Remove element (deprecated, use native)
- `contains(arr, element)` - Check if contains (deprecated, use native)
- `first(arr)` / `last(arr)` - Get first/last element (null-safe)

### Container Utilities (`backend/FlxGroupContainer.hx`)
- A `FlxGroup` that supports positioning with `x` and `y` coordinates
- Useful for grouping mixed types of `FlxBasic` objects
- Children are positioned relative to the container
- Similar to `FlxTypedSpriteGroup` but works with any `FlxBasic`

### Framework Utilities
- Use `FlxStringUtil` for advanced string formatting
- Use `FlxColor` for color management (provides color constants and utilities)
- Use `FlxMath` for additional math operations
- Use `FlxG.random` for random number generation

## Best Practices
- Always dispose of BitmapData when clearing cache or removing sprites
- Use object pooling for frequently created/destroyed objects (like bars)
- Prefer `using` imports for extension methods (e.g., `using Util;`)
- Test on multiple platforms when making changes to platform-specific code
- Use `FlxG.autoPause = false;` in PlayState to keep music playing when window loses focus
- Use `trace()` for debugging in development, but wrap in `#if debug` for production
- Prefer native implementations over custom utilities (use FlxMath, FlxG.random, Array methods)
- Use `FlxGroupContainer` for positioning groups of mixed FlxBasic objects
- Set up beat callbacks on Conductor for rhythm-based gameplay events
- Use `UtilTester` in DebugState (press T) to visualize and test utility functions

## Performance Considerations
- Cache assets aggressively - use `Paths` caching system
- Preload assets before gameplay with `Paths.preload()`
- Use `exists()` to check for resources before loading
- Clear unused assets with `Paths.clearCache()` or `Paths.uncache(path)`
- For async loading, use the `Future`-based async methods in `Paths`
- Avoid creating new objects every frame - reuse when possible

## Portuguese Context
Note: Some documentation files use Portuguese (Brazilian Portuguese), such as `plano.txt` (the plan/design document). This is intentional and reflects the project's origin.
