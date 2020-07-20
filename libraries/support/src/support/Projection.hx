package support;

import kha.math.FastMatrix3;

class Projection {
  /**
    Build a 2d transformation which maps points in the fromX/Y ranges to the
    toX/Y ranges.
    @param fromX
    @param fromY
    @param toX
    @param toY
    @return FastMatrix3
  **/
  public static function ortho(
    fromX:Interval,
    fromY:Interval,
    toX:Interval,
    toY:Interval
  ):FastMatrix3 {
    final scaleX = (toX.end - toX.start) / (fromX.end - fromX.start);
    final scaleY = (toY.end - toY.start) / (fromY.end - fromY.start);
    final dx = toX.start - fromX.start * scaleX;
    final dy = toY.start - fromY.start * scaleY;

    // @formatter:off
    return new FastMatrix3(
      scaleX, 0,      dx,
      0,      scaleY, dy,
      0,      0,      1
    );
    // @formatter:on
  }
}

@:structInit
class Interval {
  public var start:Float;
  public var end:Float;

  public function new(start:Float, end:Float) {
    this.start = start;
    this.end = end;
  }
}
