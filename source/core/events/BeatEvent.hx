package core.events;

/**
 * Beat/rhythm event.
 * Contains information about the current rhythmic moment.
 */
class BeatEvent
{
	/**
	 * Beat number (integer).
	 */
	public var beat:Int;
	
	/**
	 * Time in milliseconds when the beat occurred.
	 */
	public var time:Float;
	
	/**
	 * If this beat marks the beginning of a bar (measure).
	 */
	public var isBar:Bool;
	
	/**
	 * Bar/measure number.
	 */
	public var measure:Int;
	
	/**
	 * Creates a new beat event.
	 * 
	 * @param beat Beat number
	 * @param time Time in milliseconds
	 * @param measure Measure number
	 */
	public function new(beat:Int, time:Float, measure:Int = 0)
	{
		this.beat = beat;
		this.time = time;
		this.measure = measure;
		this.isBar = false;
	}
}
