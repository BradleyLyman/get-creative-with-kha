package;

import kha.Color;
import kha.math.FastMatrix3;
import kha.math.FastVector2;
import support.ds.CircleBuffer;
import kha.Framebuffer;

using kha.graphics2.GraphicsExtension;

/**
  Proof of concept. Draw epicycles to represent the frequency domain of a
  square wave. The DFT is hard coded so this is just a proof of concept for
  the rendering.
**/
class App {
  var t:Float = 0.0;
  var signals:Array<Signal> = [];
  var samples:CircleBuffer<Float>;

  public function new() {
    samples = new CircleBuffer<Float>(0, 200);

    // hardcoded DFT values for a square wave
    // https://en.wikipedia.org/wiki/Discrete-time_Fourier_transform
    final f = 0.25;
    final w = f * 2.0 * Math.PI;
    final r = 100;
    for (k in 0...10) {
      final n = 2 * k + 1;
      signals.push({
        frequency: n * w,
        phase: 0,
        amplitude: r * (4.0 / (Math.PI * n))
      });
    }

    signals.sort((a, b) -> Math.round(b.amplitude - a.amplitude));
  }

  public function update() {
    t += 1.0 / 60;
  }

  public function render(framebuffers:Array<Framebuffer>):Void {
    final screen = framebuffers[0];

    final midline = screen.width / 2;

    final g2 = screen.g2;
    g2.begin();

    final circle = Color.White;
    circle.A = 0.5;
    final line = Color.White;
    line.A = 1.0;

    // Draw epicycles
    final circleStart:FastVector2 = {x: screen.width / 4, y: screen.height / 2};
    for (signal in signals) {
      g2.color = circle;
      g2.drawCircle(circleStart.x, circleStart.y, signal.amplitude, 1.0);
      final at:FastVector2 = signal.sample(t);
      g2.color = line;
      g2.drawLine(
        circleStart.x,
        circleStart.y,
        circleStart.x + at.x,
        circleStart.y + at.y,
        2.0
      );
      g2.translate(at.x, at.y);
    }
    final endpoint = g2.transformation.multvec(circleStart);
    g2.transformation = FastMatrix3.identity();

    // connect to the plot
    g2.drawLine(endpoint.x, endpoint.y, midline, endpoint.y);

    // draw the plot
    final step:Float = (screen.width / 2.0) / samples.length;
    var lastX:Float = midline;
    var lastY:Float = endpoint.y;
    var count:Int = 1;
    for (sample in samples) {
      g2.drawLine(lastX, lastY, count * step + midline, sample);
      lastX = count * step + midline;
      lastY = sample;
      count++;
    }

    samples.push(endpoint.y);
    g2.end();
  }
}
