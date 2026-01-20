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
- Place opening braces on the same line for object literals, on a new line for functions and classes
- Use `if-else` with the `else` on the next line
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
    - `backend/` - Core utilities and managers (Paths, InputManager, typedefs)
    - `core/` - Core game systems
    - `objects/` - Game objects (Conductor, Song, DefaultBar, etc.)
    - `states/` - Game states (PlayState, DebugState, DefaultState)
  - `assets/` - Game assets
    - `imagens/` - Images (Portuguese: "images")
    - `videos/` - Videos
    - `sons/` - Sounds (Portuguese: "sounds")

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
- Music metadata is stored in JSON files with the following structure:
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

### Input Handling
- Use `InputManager` from `backend/InputManager.hx` for input
- Never directly access `FlxG.keys` in game logic - use InputManager
- Support multiple platforms (keyboard, touch, gamepad when needed)

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

## Common Utilities
- Use `Util.hx` for common utility functions
- Use `FlxStringUtil` for string formatting
- Use `FlxColor` for color management (provides color constants and utilities)

## Best Practices
- Always dispose of BitmapData when clearing cache or removing sprites
- Use object pooling for frequently created/destroyed objects (like bars)
- Prefer `using` imports for extension methods (e.g., `using Util;`)
- Test on multiple platforms when making changes to platform-specific code
- Use `FlxG.autoPause = false;` in PlayState to keep music playing when window loses focus
- Use `trace()` for debugging in development, but wrap in `#if debug` for production

## Performance Considerations
- Cache assets aggressively - use `Paths` caching system
- Preload assets before gameplay with `Paths.preload()`
- Use `exists()` to check for resources before loading
- Clear unused assets with `Paths.clearCache()` or `Paths.uncache(path)`
- For async loading, use the `Future`-based async methods in `Paths`
- Avoid creating new objects every frame - reuse when possible

## Portuguese Context
Note: Some parts of the codebase and documentation use Portuguese (Brazilian Portuguese):
- `imagens` = images
- `sons` = sounds
- `plano.txt` = plan/design document
This is intentional and should be maintained for consistency with the project's origin.
