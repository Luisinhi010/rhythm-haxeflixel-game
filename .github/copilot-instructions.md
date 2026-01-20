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
      - `MusicMetaData.hx` - Music metadata typedef
    - `core/` - Core game systems and utilities
      - `events/` - Event system
        - `BeatEvent.hx` - Beat event typedef
      - `utils/` - Utility classes
        - `MathUtil.hx` - Math utilities (lerp, clamp, map, etc.)
        - `StringUtil.hx` - String utilities (formatting, padding, etc.)
        - `ArrayUtil.hx` - Array utilities (shuffle, random, etc.)
        - `SpriteUtil.hx` - Sprite creation and manipulation utilities
      - `domain/` - Domain models (reserved)
      - `services/` - Services (reserved)
      - `interfaces/` - Interfaces (reserved)
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
      - `DefaultSubState.hx` - Base substate with F5 reload support
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
- All game substates extend `DefaultSubState`, which extends `FlxSubState`
- Use `PlayState` for main gameplay
- Use `DebugState` for testing and debugging
- The initial state is `DebugState` in debug mode, `PlayState` in release
- **F5 key**: Reload current state (available in DefaultState and DefaultSubState)
- **F6 key**: Print debug information to console (screen size, FPS, object counts, etc.)

### Asset Loading
- **Never** directly access assets - always use the `Paths` class from `backend/Paths.hx`
- `Paths` provides caching for all resources (images, sounds, music, text files)
- **IMPORTANT**: Uses `StringUtil.isEmpty()` for all string validation checks
- Internal helper methods:
  - `loadTextContent(path)` - Centralizes synchronous text file loading with caching
  - `loadSoundAsset(path)` - Centralizes sound asset loading with caching
  - `createTextAsyncLoader(path)` - Generic async text loader
  - `createSoundAsyncLoader(path)` - Generic async sound loader
  - `getCacheSize<T>(cache)` - Generic cache size counter
- Use appropriate methods:
  - `Paths.getImage(name)` for BitmapData (validates with `StringUtil.isEmpty()`)
  - `Paths.getSprite(name)` for FlxSprite
  - `Paths.getSound(name)` for sounds
  - `Paths.getMusic(name)` for music
  - `Paths.getFlxSound(name)` / `Paths.getFlxMusic(name)` for FlxSound
  - `Paths.getMusicData(name)` for JSON metadata
- For async loading, use methods like `Paths.loadImageAsync()`, `Paths.loadSoundAsync()`
- Clear cache when needed with `Paths.clearCache()`
- File paths are managed by `FilePath` class, never construct paths manually

### File Path Management
- `FilePath` class (`backend/FilePath.hx`) manages all file path resolution
- **IMPORTANT**: Uses `StringUtil.isEmpty()` and `ArrayUtil.isEmpty()` for all validation checks
- Internal helper methods:
  - `isValidFileName(fileName)` - Validates file names using `StringUtil.isEmpty()`
  - `resolveFilePath(absPath, type, ignoreMod)` - Resolves mod/assets paths with priority
  - `getExtensionsForType(type)` - Centralizes extension arrays per file type
  - `findFirstExtension()` - Uses `ArrayUtil.isEmpty()` for validation
  - `resourceExists()` - Uses `ArrayUtil.isEmpty()` for extension checks
- Automatically checks both `mods/` and `assets/` folders (mods have priority)
- Supports multiple file extensions per type (e.g., .ogg, .mp3, .wav for audio)
- Use type-safe enums: `FilePathType` and `FilePathExtension`
- Common methods:
  - `FilePath.getImagePath(name)` - Returns path for image
  - `FilePath.getSoundPath(name)` - Returns path for sound
  - `FilePath.getMusicPath(name)` - Returns path for music
  - `FilePath.getMusicDataPath(name)` - Returns path for JSON metadata
  - `FilePath.imageExists(name)`, `soundExists(name)`, etc. - Check if file exists
- Extension handling: `getExtension(ext)` returns `.png`, `.ogg`, etc. (NONE returns empty string)
- Type safety: All null checks and validations are built-in
- **Best Practice**: Always use utility functions for consistency (StringUtil, ArrayUtil)

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
  - Internal helper methods:
    - `setBpm(value)` - Validates and sets BPM with automatic beatDuration update
    - `parseTimeSignature(signature)` - Parses time signature string into beatsPerBar and beatValue
  - Dispatches beat events via callbacks: `beatHit`, `stepHit`, `sectionHit`, `barHit`
  - Use `play()`, `pause()`, `stop()`, `restart()` for playback control
  - Use `jumpToCue(name)` to jump to named cue points
- `Song` class is a data container for music metadata and audio
  - Loads metadata from JSON files
  - Internal helper methods:
    - `fallbackToDefaults(reason)` - Centralizes error handling and default metadata loading
    - `getFieldOrDefault<T>(data, field, defaultValue)` - Generic field extraction with fallback
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
- **F5**: Reload current state (available in all states/substates via DefaultState/DefaultSubState)
- **F6**: Print debug information to console (screen size, FPS, object counts, state-specific info)
- **DebugState Controls**:
  - **SPACE**: Toggle music playback (play/pause)
  - **R**: Restart music from beginning
  - **Q**: Jump to "test" cue point
  - **E**: Add cue point at current position
  - **S**: Remove "test" cue point
  - **A/D**: Skip backward/forward 10 seconds
  - **P**: Toggle ConductorDebugger detailed view
  - **T**: Toggle UtilTester display
  - **1-5**: Switch UtilTester sections (when tester is active)
  - **SPACE** (in tester): Execute current test

## Common Utilities

### Utility Usage Guidelines
**# Math Utilities (`core/utils/MathUtil.hx`)
Delegates to native Haxe/FlxMath implementations where possible:
- `clamp(value, min, max)` / `clampInt()` - Constrain values to ranges
- `lerp(a, b, t)` / `lerpClamp()` - Linear interpolation
- `mapRange(value, inMin, inMax, outMin, outMax)` - Map value from one range to another
- **Integer clamping**: Use `MathUtil.clampInt(value, min, max)` **ONLY when BOTH min AND max limits are required**
- These utilities are used consistently throughout `FilePath.hx` and `Paths
- `sign(x)` - Returns -1, 0, or 1
- `randomRange(min, max)` / `randomInt()` - Random value generation
- `percent(a, b)` - Calculate percentage
- Geometry functions:
  - `distance()` / `distanceSquared()` - Distance between points
  - `angleBetween()` / `angleBetweenDegrees()` - Angle between points
  - `wrapAngle()` - Wrap angle to [0, 360)
- Array operations:
  - `min()` / `max()` - Min/max of multiple values
  - `average()` - Calculate average
- Interpolation:
  - `smoothStep()` / `smootherStep()` - Smooth interpolation curves
- `inRange()` - Check if value within range

### String Utilities (`core/utils/StringUtil.hx`)
Delegates to native StringTools and FlxStringUtil:
- `capitalization(str)` - Capitalize first letter
- `formatTime(seconds)` / `formatTimeMs(ms)` - Format time as "MM:SS"
- `isEmpty(str)` - Null-safe empty check
- `trim(str)` - Remove whitespace
- `padLeft()` / `padRight()` - Pad strings with characters
- `repeat(str, times)` - Repeat string n times
- `truncate(str, maxLength, ellipsis)` - Truncate with ellipsis
- `removeWhitespace(str)` - Remove all whitespace
- String checks:
  - `containsIgnoreCase()` - Case-insensitive contains
  - `startsWith()` / `endsWith()` - Prefix/suffix checks
- String manipulation:
  - `reverse(str)` - Reverse string
  - `countOccurrences()` - Count substring occurrences
  - `wordWrap(str, width)` - Wrap text to line width

### Array Utilities (`core/utils/ArrayUtil.hx`)
Delegates to native Array methods and FlxG.random:
- `pickRandom(arr)` - Select random element
- `shuffle(arr, howManyTimes)` - Shuffle array (returns copy)
- `remove(arr, element)` - Remove element (deprecated, use native)
- `contains(arr, element)` - Check if contains (deprecated, use native)
- `first(arr)` / `last(arr)` - Get first/last element (null-safe)
- `isEmpty(arr)` - Check if null or empty
- Array manipulation:
  - `randomSubset(arr, count)` - Get random subset without duplicates
  - `unique(arr)` - Remove duplicates
  - `chunk(arr, size)` - Split into chunks
- Array search:
  - `indexOfMin(arr)` / `indexOfMax(arr)` - Find index of min/max value

### Sprite Utilities (`core/utils/SpriteUtil.hx`)
Sprite creation and manipulation utilities with validation:
- **`createColoredSprite(width, height, color, alpha)`** - Create solid-color sprite using GPU-efficient 1x1 texture technique
  - Uses only 1 pixel of texture memory
  - GPU handles scaling and coloring via shaders
  - Validates dimensions (minimum 1x1) and alpha (clamped 0-1)
  - Much more memory efficient than `makeGraphic(width, height, color)`
- `createColored(width, height, color, alpha)` - Shorthand alias for createColoredSprite
- `resize(sprite, width, height)` - Resize sprite efficiently using setGraphicSize + updateHitbox
- `setPosition(sprite, x, y)` - Set sprite position in one call
- `screenCenter(sprite, axes)` - Center sprite on screen (delegates to FlxSprite method)
- `setAlpha(sprite, alpha)` - Set alpha with automatic clamping (0-1)
- `setColor(sprite, color)` - Set sprite color
- `show(sprite)` / `hide(sprite)` - Control sprite visibility
- `toggleVisibility(sprite)` - Toggle visibility and return new state
- `getBounds(sprite)` - Get sprite bounds as {x, y, width, height} object
- `setSize(sprite, width, height)` - Set sprite dimensions directly
- `offset(sprite, offsetX, offsetY)` - Offset sprite position by amounts
- `isOnScreen(sprite)` - Check if sprite is visible on screen
- `reset(sprite)` - Reset sprite to default state (position 0,0, alpha 1, visible, white color)
- Internal helper methods:
  - `isValid(sprite)` - Null check helper (eliminates code duplication)
  - `validateDimensions(width, height)` - Ensures dimensions are at least 1x1

## Performance Considerations
- Cache assets aggressively - use `Paths` caching system
- Preload assets before gameplay with `Paths.preload()`
- Use `exists()` to check for resources before loading
- Clear unused assets with `Paths.clearCache()` or `Paths.uncache(path)`
- For async loading, use the `Future`-based async methods in `Paths`
- Avoid creating new objects every frame - reuse when possible
- **Efficient Colored Sprites**: Always use `SpriteUtil.createColoredSprite()` for solid-color sprites:
  ```haxe
  // ✅ CORRECT - Use SpriteUtil (1x1 texture + GPU scaling/shader)
  var sprite = SpriteUtil.createColoredSprite(width, height, FlxColor.RED);
  
  // ❌ WRONG - Creates full-size texture (wastes memory)
  var sprite = new FlxSprite();
  sprite.makeGraphic(width, height, FlxColor.RED);
  ```
  The `SpriteUtil` method creates only 1 pixel of texture and uses GPU scaling + shader for color, instead of creating a full `width × height` texture. Much more memory efficient and faster.
  - ✅ **SpriteUtil.createColoredSprite()** = minimal memory (1 pixel), maximum GPU performance, automatic validation
  - ❌ **makeGraphic(width, height, color)** = wastes memory and CPU for large sprites
  - Use `SpriteUtil.resize()` for resizing sprites efficiently
  - Use `SpriteUtil.setPosition()` for convenient sprite positioning
  - Use `SpriteUtil.screenCenter()` for centering sprites
  - Use `SpriteUtil.setAlpha()` for alpha with automatic clamping (0-1)
  - All SpriteUtil methods include null-safety checks and dimension validation

## Developer Guide

### Getting Started

#### Prerequisites
1. **Install Haxe**: Download from [https://haxe.org/download/](https://haxe.org/download/)
2. **Install Lime and OpenFL**:
   ```bash
   haxelib install lime
   haxelib install openfl
   haxelib install flixel
   haxelib run lime setup
   ```
3. **Clone the repository**:
   ```bash
   git clone https://github.com/Luisinhi010/rhythm-haxeflixel-game.git
   cd rhythm-haxeflixel-game
   ```
4. **Build and run**:
   ```bash
   lime test windows -debug
   ```

#### Project Structure Overview
```
source/
├── Main.hx                 # Entry point
├── Util.hx                 # Platform utilities
├── backend/                # Core systems (Paths, FilePath, Input, etc.)
├── core/                   # Reusable utilities and events
│   ├── events/            # Event typedefs (BeatEvent)
│   └── utils/             # Utility classes (MathUtil, StringUtil, etc.)
├── objects/               # Game objects (Conductor, Song, etc.)
└── states/                # Game states (PlayState, DebugState, etc.)

assets/
├── images/                # Image assets
├── music/                 # Music files (.ogg, .mp3, .wav)
├── sounds/                # Sound effects
└── shaders/               # GLSL shaders
```

### Development Workflow

#### 1. Create a New Feature Branch
```bash
git checkout -b feature/your-feature-name
```

#### 2. Development Cycle
1. **Make changes** to your code
2. **Test locally** with `lime test windows -debug`
3. **Use F5** to reload state during development (no need to restart)
4. **Use F6** to print debug information to console
5. **Test on multiple platforms** if needed:
   ```bash
   lime test html5 -debug
   lime test windows -debug
   ```

#### 3. Testing Your Changes
- Run the game in debug mode: `lime test windows -debug`
- Use `DebugState` for testing new features:
  - Press **T** to open `UtilTester` for utility function testing
  - Use **F6** to print state information
- Add trace statements with `#if debug` wrapper:
  ```haxe
  #if debug
  trace('Debug info: $variable');
  #end
  ```

#### 4. Code Quality Checks
Before committing, ensure:
- Code follows naming conventions (PascalCase for classes, camelCase for variables/functions)
- All public methods have JavaDoc comments
- No compilation errors: `lime build windows`
- Utility functions are used instead of custom implementations
- No hardcoded values (use `LayoutConstants` for UI values)

### Adding New Features

#### Adding a New Game State
1. Create file in `source/states/YourState.hx`:
   ```haxe
   package states;
   
   import flixel.FlxG;
   
   class YourState extends DefaultState
   {
       override public function create():Void
       {
           super.create();
           // Your initialization code
       }
       
       override public function update(elapsed:Float):Void
       {
           super.update(elapsed);
           // Your update code
       }
   }
   ```

#### Adding a New Utility Function
1. Choose the appropriate utility class (`MathUtil`, `StringUtil`, `ArrayUtil`, `SpriteUtil`)
2. Add the function with proper documentation:
   ```haxe
   /**
    * Description of what the function does.
    * @param paramName Description of parameter
    * @return Description of return value
    */
   public static function yourFunction(paramName:Type):ReturnType
   {
       // Implementation
   }
   ```
3. Prefer delegating to native implementations when possible
4. Add validation using existing utility functions (e.g., `StringUtil.isEmpty()`)

#### Adding a New Asset
1. **Images**: Place in `assets/images/` (use `.png` format)
2. **Music**: Place in `assets/music/` (use `.ogg` for best compatibility)
3. **Sounds**: Place in `assets/sounds/`
4. **JSON metadata**: Place in `assets/music/` with same name as music file
5. Access via `Paths` class:
   ```haxe
   var sprite = Paths.getSprite("yourImage");
   var music = Paths.getMusic("yourSong");
   ```

#### Performance Guidelines
1. **Cache assets** - never load the same asset multiple times
2. **Use `SpriteUtil.createColoredSprite()`** for solid-color sprites (GPU-efficient)
3. **Avoid creating objects in `update()`** - use object pooling
4. **Clear unused caches** with `Paths.clearCache()`
5. **Use FlxPoint.get()/put()** for temporary points (memory management)

#### Error Handling
1. **Always validate inputs** using utility functions:
   ```haxe
   if (StringUtil.isEmpty(fileName))
       return;
   ```
2. **Check for null** before using objects:
   ```haxe
   if (sprite == null)
       return;
   ```
3. **Use helper methods** for repeated validation patterns
4. **Provide meaningful error messages** in debug builds

#### Documentation Standards
1. **All public APIs** must have JavaDoc comments
2. **Include usage examples** for complex functions
3. **Document helper methods** (private/internal) briefly
4. **Update copilot-instructions.md** when adding new systems
5. **Document breaking changes** in commit messages

### Common Development Tasks

#### Debugging Performance Issues
1. Use **F6** to check FPS and object counts
2. Profile with Chrome DevTools (for HTML5 builds)
3. Check memory usage with platform-specific tools
4. Look for objects created every frame in `update()`
5. Verify asset caching is working

#### Adding Keyboard Shortcuts
For debug/utility features, use `FlxG.keys` directly:
```haxe
if (FlxG.keys.justPressed.F5)
    FlxG.resetState();
```

For gameplay, use `InputManager`:
```haxe
InputManager.instance.bindKey("jump", FlxKey.SPACE);
if (InputManager.instance.isPressed("jump"))
    player.jump();
```

### Git Commit Guidelines
 Commit Message Format
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, no logic change)
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Build/tooling changes

**Examples**:
```bash

Closes #42

fix(conductor): correct beat calculation for tempo changes

The beat calculation was incorrect when tempo changes occurred.
Fixed by recalculating beat duration at each tempo change point.

docs(readme): update build instructions

Added prerequisites section and troubleshooting tips.
```

### Troubleshooting

#### Build Errors
1. **"Module not found"**: Run `haxelib install <module>`
2. **"Class not found"**: Check package/import statements match file path
3. **"Invalid field access"**: Verify variable/function exists and is accessible

#### Runtime Errors
1. **Null reference errors**: Add null checks before using objects
2. **Asset not found**: Verify file exists in `assets/` folder
3. **Performance issues**: Check for infinite loops or object creation in `update()`

#### Platform-Specific Issues
1. **Windows**: Ensure Visual Studio Build Tools are installed
2. **HTML5**: Use browser console for debugging (F12)
3. **Android**: Use `adb logcat` for logs

### Resources

#### Official Documentation
- [HaxeFlixel Docs](https://haxeflixel.com/documentation/)
- [Haxe Manual](https://haxe.org/manual/)
- [OpenFL Docs](https://api.openfl.org/)

#### Project Documentation
- `docs/conceitos.md` - Rhythm game concepts (Portuguese)
- `docs/implementacao.md` - Implementation guide (Portuguese)
- `.github/copilot-instructions.md` - This file

#### Community
- [HaxeFlixel Discord](https://discord.gg/rqEBAgF)
- [Haxe Community](https://community.haxe.org/)

## Portuguese Context
Note: Some documentation files use Portuguese (Brazilian Portuguese), such as `plano.txt` (the plan/design document) and `docs/` folder. This is intentional and reflects the project's origin.
