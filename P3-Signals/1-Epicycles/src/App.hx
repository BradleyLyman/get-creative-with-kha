package;

import kha.graphics2.Graphics;
import kha.math.FastVector2;
import kha.Framebuffer;

using Math;
using support.FloatOps;

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
}

class App {
  var t:Float = 0.0;

  public function new() {}

  /**
    The Kha scheduler attempts to run this every 16 milliseconds so assume a
    fixed time step.
  **/
  public function update() {
    t += 1.0 / 60;
  }

  /**
    The kha scheduler invokes this every time a frame is ready to be rendered.
    There is only one window for this app so the framebuffer array will always
    have exactly 1 frame.
  **/
  public function render(framebuffers:Array<Framebuffer>):Void {
    final g2 = framebuffers[0].g2;
    g2.begin();

    final c:Epicycle = {phase: 2, offset: 0, amplitude: 100};
    c.center = {x: framebuffers[0].width / 2, y: framebuffers[0].height / 2};
    c.draw(g2, 64);
    final sample = c.sample(t);
    g2.drawLine(c.center.x, c.center.y, sample.x, sample.y);

    g2.end();
  }
}
