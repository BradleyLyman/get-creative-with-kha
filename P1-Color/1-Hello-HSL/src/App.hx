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
  final X_RANGE:Float = 360;
  final Y_RANGE:Float = 1.0;
  var rows:Int = 10;
  var columns:Int = 10;

  public function new() {
    Mouse.get().notify(null, null, onMouseMove, null);
  }

  private function onMouseMove(x:Int, y:Int, dx:Int, dy:Int) {
    final normX = x / System.windowWidth(0);
    final normY = y / System.windowHeight(0);
    columns = normX.clamp().lerp(3, 360).round();
    rows = normY.clamp().lerp(3, 50).round();
  }

  private function lerp(t:Float, start:Float, end:Float):Float {
    return (1.0 - t) * start + t * end;
  }

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
    final graphics = screen.g2;
    graphics.pushTransformation(
      FastMatrix3.scale(screen.width / X_RANGE, screen.height / Y_RANGE)
    );
    draw(graphics);
  }

  /**
    Draw a grid of rectangles with hue changing according to the X coordinate
    and lightness changing according to the Y coordinate.
    @param graphics
  **/
  private function draw(graphics:Graphics) {
    final width = X_RANGE / columns;
    final height = Y_RANGE / rows;

    graphics.begin();
    for (col in 0...columns) {
      for (row in 0...rows) {
        final normC = col / columns;
        final normR = row / rows;
        final nextR = (row + 1) / rows;

        final hsl:HSL = {h: normC * 360, s: 0.7, l: (normR + nextR) / 2.0};
        graphics.color = hsl.toColor();

        graphics.fillRect(X_RANGE * normC, Y_RANGE * normR, width, height);
      }
    }
    graphics.end();
  }
}
