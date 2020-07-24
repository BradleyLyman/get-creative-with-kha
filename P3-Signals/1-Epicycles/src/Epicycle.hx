package;

import kha.graphics2.Graphics;
import kha.math.FastVector2;

using Math;
using support.FloatOps;

/**
  Objects of this type represent a drawable epicycle.
**/
@:structInit
class Epicycle {
  public var phase:Float;
  public var offset:Float;
  public var amplitude:Float;

  public var center:FastVector2;

  public function new(phase:Float, offset:Float, amplitude:Float) {
    this.phase = phase;
    this.offset = offset;
    this.amplitude = amplitude;
    this.center = {x: 0, y: 0};
  }

  public function sample(t:Float):FastVector2 {
    final x = Math.cos((t * phase) + offset) * amplitude;
    final y = Math.sin((t * phase) + offset) * amplitude;
    return center.add({x: x, y: y});
  }

  public function draw(g2:Graphics, segments:Int = 32) {
    var prevX = center.x + amplitude;
    var prevY = center.y;
    for (i in 1...segments) {
      final angle = (i / segments).lerp(0, Math.PI * 2);
      final x = center.x + angle.cos() * amplitude;
      final y = center.y + angle.sin() * amplitude;
      g2.drawLine(prevX, prevY, x, y);
      prevX = x;
      prevY = y;
    }
    g2.drawLine(prevX, prevY, center.x + amplitude, center.y);
  }

  /**
    Update an array of epipicycles so each subsequent cycle's origin is set to
    the previous cycle's sample.
    @param cycles the collection of epicycle objects
    @param origin the first cycle's center
    @param time the simulation time
  **/
  public static function propagateCenters(
    cycles:Array<Epicycle>,
    origin:FastVector2,
    time:Float
  ) {
    cycles[0].center = origin;
    for (i in 1...cycles.length) {
      cycles[i].center = cycles[i - 1].sample(time);
    }
  }
}
