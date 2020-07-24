package;

import kha.graphics2.Graphics;
import kha.input.Mouse;
import kha.math.FastVector2;
import kha.math.FastMatrix3;

using Math;
using support.FloatOps;

/**
  Objects of this type represent a point on screen which critters will try
  to avoid. It hooks into mouse events to provide an interactive experience.
**/
class Repulser {
  public var invProject:FastMatrix3 = FastMatrix3.identity();
  public var centeredAt(default, null):FastVector2 = {x: 0, y: 0};
  public var active(default, null):Bool = false;
  public var maxRadius:Float = 0;

  private var activeDuration:Float = 0.0;

  public function new() {
    Mouse.get().notify(onClick, onRelease, onMove, null);
  }

  /** The repulser's radius. Increases over 3 seconds. **/
  public function radius():Float {
    return (activeDuration / 3).clamp().lerp(0, maxRadius);
  }

  /** Draw a circle for the repulser if it's active **/
  public function draw(g2:Graphics) {
    if (!active) {
      return;
    }
    activeDuration += 1 / 60.0;
    final currentRadius = radius();
    var prevX = centeredAt.x + currentRadius;
    var prevY = centeredAt.y;
    for (i in 1...64) {
      final angle = (i / 64).lerp(0, Math.PI * 2);
      final x = centeredAt.x + angle.cos() * currentRadius;
      final y = centeredAt.y + angle.sin() * currentRadius;
      g2.drawLine(prevX, prevY, x, y, 4);
      prevX = x;
      prevY = y;
    }
    g2.drawLine(prevX, prevY, centeredAt.x + currentRadius, centeredAt.y, 4);
  }

  private function onClick(_button:Int, x:Int, y:Int) {
    centeredAt = invProject.multvec({x: x, y: y});
    active = true;
    activeDuration = 0.0;
  }

  private function onRelease(_button:Int, x:Int, y:Int) {
    active = false;
    activeDuration = 0.0;
  }

  private function onMove(x:Int, y:Int, dx:Int, dy:Int) {
    if (active) {
      centeredAt = invProject.multvec({x: x, y: y});
    }
  }
}
