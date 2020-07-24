package;

import kha.Framebuffer;

using Epicycle;
using support.FloatOps;

class App {
  var t:Float = 0.0;
  var cycles:Array<Epicycle> = [];

  public function new() {
    for (i in 1...5) {
      cycles.push({
        phase: (i / 5).lerp(0, Math.PI * 2),
        offset: Math.random() * i,
        amplitude: i * 10
      });
    }
    cycles.sort((a, b) -> Math.round(b.amplitude - a.amplitude));
  }

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
    final screen = framebuffers[0];
    final g2 = screen.g2;
    g2.begin();

    // propagate centers at time t
    cycles.propagateCenters({x: screen.width / 2, y: screen.height / 2}, t);

    // draw lines
    for (i in 1...cycles.length) {
      final last = cycles[i - 1].center;
      final now = cycles[i].center;
      g2.drawLine(last.x, last.y, now.x, now.y, 2);
    }
    final last = cycles[cycles.length - 1].center;
    final now = cycles[cycles.length - 1].sample(t);
    g2.drawLine(last.x, last.y, now.x, now.y, 2);

    for (cycle in cycles) {
      cycle.draw(g2, 64);
    }

    g2.end();
  }
}
