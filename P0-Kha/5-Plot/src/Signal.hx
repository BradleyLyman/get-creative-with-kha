package;

import haxe.ds.Vector;

using support.FloatOps;

abstract Signal(Vector<Float>) to Vector<Float> from Vector<Float> {
  /**
    Create a new signal with values in a range.
    The signal always has steps+2 data points.
  **/
  public static function ofRange(start:Float, end:Float, steps:Int):Signal {
    final pointCount = 2 + steps; // one point for the start and end values
    final data = new Vector<Float>(pointCount);
    for (i in 0...pointCount) {
      final norm = i / (pointCount - 1);
      data[i] = norm.lerp(start, end);
    }
    return data;
  }

  /**
    Sample the system at each of the signal's data points.
    Return a new signal with the sampled values.
  **/
  public function sample(system:(x:Float) -> Float):Signal {
    return this.map(system);
  }
}
