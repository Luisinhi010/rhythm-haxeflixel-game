package backend;

class BeatEvent
{
    public var beat:Int;
    public var time:Float;
    public var isBar:Bool;
    public var measure:Int;
    
    public function new(beat:Int, time:Float, measure:Int = 0)
    {
        this.beat = beat;
        this.time = time;
        this.measure = measure;
    }
}