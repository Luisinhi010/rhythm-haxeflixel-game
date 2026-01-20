package objects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import objects.CuePointMarker;
import objects.BPMMarker;

/**
 * Timeline component for visualizing and editing song timing
 */
class Timeline extends FlxSpriteGroup
{
	public var timelineWidth:Float;
	public var timelineHeight:Float;
	public var songDuration:Float = 60000; // in milliseconds
	public var currentTime:Float = 0;
	public var bpm:Float = 120;
	public var zoom:Float = 1.0;
	public var scrollX:Float = 0;
	
	private var bg:FlxSprite;
	private var beatGrid:FlxSprite;
	private var playhead:FlxSprite;
	private var cueMarkers:Array<CuePointMarker>;
	private var bpmMarkers:Array<BPMMarker>;
	private var timeLabels:FlxSpriteGroup;
	private var isDirty:Bool = true;
	private var _tempRect:openfl.geom.Rectangle; // Reusable rectangle for drawing
	
	public var onTimelineClick:Float->Void;
	public var onCuePointClick:CuePointMarker->Void;
	public var onBPMMarkerClick:BPMMarker->Void;
	
	public function new(x:Float, y:Float, width:Float, height:Float)
	{
		super(x, y);
		
		this.timelineWidth = width;
		this.timelineHeight = height;
		
		cueMarkers = [];
		bpmMarkers = [];
		_tempRect = new openfl.geom.Rectangle();
		
		// Background
		bg = new FlxSprite();
		bg.makeGraphic(Std.int(width), Std.int(height), FlxColor.fromRGB(30, 30, 30));
		add(bg);
		
		// Beat grid
		beatGrid = new FlxSprite();
		beatGrid.makeGraphic(Std.int(width), Std.int(height), FlxColor.TRANSPARENT);
		add(beatGrid);
		
		// Time labels group
		timeLabels = new FlxSpriteGroup();
		add(timeLabels);
		
		// Playhead
		playhead = new FlxSprite();
		playhead.makeGraphic(2, Std.int(height), FlxColor.RED);
		add(playhead);
		
		drawBeatGrid();
	}
	
	public function drawBeatGrid():Void
	{
		if (!isDirty) return;
		
		_tempRect.x = 0;
		_tempRect.y = 0;
		_tempRect.width = beatGrid.width;
		_tempRect.height = beatGrid.height;
		beatGrid.pixels.fillRect(_tempRect, FlxColor.TRANSPARENT);
		
		var beatDuration = 60000 / bpm; // in milliseconds
		var visibleDuration = songDuration / zoom;
		var startTime = scrollX;
		var endTime = startTime + visibleDuration;
		
		var firstBeat = Math.floor(startTime / beatDuration);
		var lastBeat = Math.ceil(endTime / beatDuration);
		
		// Draw beat lines
		for (i in firstBeat...lastBeat)
		{
			var beatTime = i * beatDuration;
			var xPos = timeToX(beatTime);
			
			if (xPos >= 0 && xPos < timelineWidth)
			{
				var lineColor = (i % 4 == 0) ? FlxColor.fromRGB(80, 80, 80) : FlxColor.fromRGB(50, 50, 50);
				var lineHeight = (i % 4 == 0) ? Std.int(timelineHeight) : Std.int(timelineHeight * 0.7);
				
				// Draw vertical line using fillRect for better performance (reuse _tempRect)
				_tempRect.x = Std.int(xPos);
				_tempRect.y = 0;
				_tempRect.width = 1;
				_tempRect.height = lineHeight;
				beatGrid.pixels.fillRect(_tempRect, lineColor);
			}
		}
		
		isDirty = false;
	}
	
	public function timeToX(time:Float):Float
	{
		var visibleDuration = songDuration / zoom;
		var relativeTime = time - scrollX;
		return (relativeTime / visibleDuration) * timelineWidth;
	}
	
	public function xToTime(x:Float):Float
	{
		var visibleDuration = songDuration / zoom;
		var relativeX = x / timelineWidth;
		return scrollX + (relativeX * visibleDuration);
	}
	
	public function updatePlayhead(time:Float):Void
	{
		currentTime = time;
		var xPos = timeToX(time);
		playhead.x = xPos - 1; // Center the 2-pixel wide playhead
		playhead.visible = (xPos >= 0 && xPos < timelineWidth);
	}
	
	public function addCueMarker(name:String, time:Float):CuePointMarker
	{
		var marker = new CuePointMarker(name, time);
		var xPos = timeToX(time);
		marker.x = xPos;
		marker.y = timelineHeight / 2;
		cueMarkers.push(marker);
		add(marker);
		return marker;
	}
	
	public function removeCueMarker(marker:CuePointMarker):Void
	{
		cueMarkers.remove(marker);
		remove(marker);
	}
	
	public function addBPMMarker(time:Float, bpm:Float):BPMMarker
	{
		var marker = new BPMMarker(time, bpm);
		var xPos = timeToX(time);
		marker.x = xPos;
		marker.y = timelineHeight / 3;
		bpmMarkers.push(marker);
		add(marker);
		return marker;
	}
	
	public function removeBPMMarker(marker:BPMMarker):Void
	{
		bpmMarkers.remove(marker);
		remove(marker);
	}
	
	public function updateMarkerPositions():Void
	{
		for (marker in cueMarkers)
		{
			var xPos = timeToX(marker.timestamp);
			marker.x = xPos;
		}
		
		for (marker in bpmMarkers)
		{
			var xPos = timeToX(marker.timestamp);
			marker.x = xPos;
		}
	}
	
	public function setZoom(newZoom:Float):Void
	{
		zoom = newZoom;
		isDirty = true;
		drawBeatGrid();
		updateMarkerPositions();
	}
	
	public function setScroll(newScroll:Float):Void
	{
		scrollX = Math.max(0, Math.min(newScroll, songDuration - (songDuration / zoom)));
		isDirty = true;
		drawBeatGrid();
		updateMarkerPositions();
	}
	
	public function setBPM(newBPM:Float):Void
	{
		bpm = newBPM;
		isDirty = true;
		drawBeatGrid();
	}
	
	public function setSongDuration(duration:Float):Void
	{
		songDuration = duration;
		isDirty = true;
		drawBeatGrid();
	}
	
	public function clearMarkers():Void
	{
		for (marker in cueMarkers)
		{
			remove(marker);
		}
		cueMarkers = [];
		
		for (marker in bpmMarkers)
		{
			remove(marker);
		}
		bpmMarkers = [];
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		#if !mobile
		// Handle mouse wheel for zooming
		if (FlxG.mouse.wheel != 0)
		{
			var mousePos = FlxG.mouse.getPosition();
			var localX = mousePos.x - x;
			var localY = mousePos.y - y;
			
			if (localX >= 0 && localX < timelineWidth && localY >= 0 && localY < timelineHeight)
			{
				var zoomFactor = FlxG.mouse.wheel > 0 ? 1.1 : 0.9;
				var newZoom = zoom * zoomFactor;
				newZoom = Math.max(0.5, Math.min(newZoom, 10));
				setZoom(newZoom);
			}
		}
		
		// Handle timeline clicks
		if (FlxG.mouse.justPressed)
		{
			var mousePos = FlxG.mouse.getPosition();
			var localX = mousePos.x - x;
			var localY = mousePos.y - y;
			
			if (localX >= 0 && localX < timelineWidth && localY >= 0 && localY < timelineHeight)
			{
				// Check if clicked on a marker
				var clickedCue = false;
				for (marker in cueMarkers)
				{
					if (Math.abs(localX - marker.x) < 10 && Math.abs(localY - marker.y) < 10)
					{
						if (onCuePointClick != null)
							onCuePointClick(marker);
						clickedCue = true;
						break;
					}
				}
				
				if (!clickedCue)
				{
					var clickedBPM = false;
					for (marker in bpmMarkers)
					{
						if (Math.abs(localX - marker.x) < 10 && Math.abs(localY - marker.y) < 10)
						{
							if (onBPMMarkerClick != null)
								onBPMMarkerClick(marker);
							clickedBPM = true;
							break;
						}
					}
					
					if (!clickedBPM && onTimelineClick != null)
					{
						var clickedTime = xToTime(localX);
						onTimelineClick(clickedTime);
					}
				}
			}
		}
		#end
	}
}
