package;

import kha.System;
import kha.input.Mouse;
import kha.math.FastMatrix3;
import kha.graphics2.Graphics;
import kha.Framebuffer;
import support.HSL;

using Math;
using support.FloatOps;

/**
  A first exploration with kha. Draw a lissajous diagram with 100 points all
  interconnected.
**/
class App {
  public function new() {}

  /**
    The Kha scheduler attempts to run this every 16 milliseconds so assume a
    fixed time step.
  **/
  public function update() {}

  /**
    The kha scheduler invokes this every time a frame is ready to be rendered.
    There is only one window for this app so the framebuffer array will always
    have exactly 1 frame.
  **/
  public function render(framebuffers:Array<Framebuffer>):Void {
    final screen = framebuffers[0];
    final g2 = screen.g2;
    g2.begin();
    g2.drawLine(0, 0, 200, 300);
    g2.end();
  }
}
