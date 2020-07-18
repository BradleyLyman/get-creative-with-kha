package;

import kha.Color;
import kha.System;
import haxe.ds.Vector;
import kha.Framebuffer;

using Math;

/**
  A first exploration with kha. Draw a lissajous diagram with 100 points all
  interconnected.
**/
class App {
  private final ANGULAR_SPEED:Float = Math.PI / 4;
  private final FRAME_TIME:Float = 1 / 60.0;
  private final POINTS:Int = 100;
  private final xs:Vector<Float>;
  private final ys:Vector<Float>;

  private var t:Float = 0.0;

  public function new() {
    xs = new Vector<Float>(POINTS);
    ys = new Vector<Float>(POINTS);
  }

  /**
    The Kha scheduler attempts to run this every 16 milliseconds so assume a
    fixed time step.
  **/
  public function update() {
    t += FRAME_TIME * ANGULAR_SPEED;

    final centerX = System.windowWidth() / 2;
    final centerY = System.windowHeight() / 2;
    final scale = Math.min(centerX, centerY) * 0.9;

    for (i in 0...POINTS) {
      final angle = (i / (POINTS - 1)) * Math.PI * 2;
      xs[i] = centerX + Math.cos((angle + t) * 2.1) * scale;
      ys[i] = centerY + Math.sin((angle + t) * 1.4) * scale;
    }
  }

  /**
    The kha scheduler invokes this every time a frame is ready to be rendered.
    There is only one window for this app so the framebuffer array will always
    have exactly 1 frame.
  **/
  public function render(framebuffers:Array<Framebuffer>):Void {
    final centerX = System.windowWidth() / 2;
    final centerY = System.windowHeight() / 2;
    final scale = Math.min(centerX, centerY) * 0.9;

    final maxLen = scale / 2;
    final g2 = framebuffers[0].g2; // use the graphics2 level api
    g2.begin();
    for (i in 0...POINTS) {
      for (j in 0...POINTS) {
        final dx = xs[j] - xs[i];
        final dy = ys[j] - ys[i];
        final len = dx * dx + dy * dy;
        if (len < maxLen * maxLen) {
          final normLen = (maxLen - len.sqrt()) / maxLen;
          g2.color = Color.fromFloats(1, 1, 1, normLen);
          g2.drawLine(xs[i], ys[i], xs[j], ys[j], 1);
        }
      }
    }
    g2.end();
  }
}
