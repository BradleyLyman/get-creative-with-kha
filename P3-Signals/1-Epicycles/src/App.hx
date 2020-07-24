package;

import support.ds.CircleBuffer;
import kha.Framebuffer;

using Epicycle;
using support.FloatOps;

class App {
  var t:Float = 0.0;
  var cycles:Array<Epicycle> = [];
  var heights:CircleBuffer<Float>;

  public function new() {
    final x:Array<Float> = [];
    for (i in 0...200) {
      x.push(i);
    }
    heights = new CircleBuffer<Float>(400, x.length);

    final X = dft(x);
    final N = X.length;
    for (k in 0...N) {
      cycles.push({
        phase: (k / N) * Math.PI * 2,
        offset: Math.atan2(X[k].im, X[k].re) + Math.PI / 2,
        amplitude: 1 / N * Math.sqrt(X[k].re * X[k].re + X[k].im * X[k].im)
      });
    }
    cycles.sort((a, b) -> Math.round(b.amplitude - a.amplitude));
  }

  function dft(signal:Array<Float>):Array<{re:Float, im:Float}> {
    final N = signal.length;
    final res:Array<{re:Float, im:Float}> = [];
    final TWOPIN = Math.PI * 2 / N;

    for (k in 0...signal.length) {
      var r:Float = 0;
      var i:Float = 0;
      for (n in 0...signal.length) {
        final x = signal[n];
        r += x * Math.cos(TWOPIN * k * n);
        i += x * Math.sin(TWOPIN * k * n);
      }
      res.push({re: r, im: i});
    }
    return res;
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
    cycles.propagateCenters({x: screen.width / 8, y: screen.height / 2}, t);

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

    g2.drawLine(now.x, now.y, screen.width / 2, now.y);

    var start = screen.width / 2;
    var step = (screen.width / 2) / cycles.length;
    var count = 1;
    var last = now.y;
    for (height in heights) {
      g2.drawLine(
        start + step * (count - 1),
        last,
        start + step * count,
        height
      );
      last = height;
      count++;
    }

    g2.end();

    heights.push(now.y);
  }
}
