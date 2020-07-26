package;

import zui.Id;
import zui.Themes;
import kha.Assets;
import kha.Color;
import kha.math.FastMatrix3;
import kha.math.FastVector2;
import kha.Framebuffer;
import zui.Zui;

using kha.graphics2.GraphicsExtension;

/**
  Draw epicicles for the DFT decomposition of a rectangle.
**/
class App {
  var t:Float = 0.0;
  var signals:Array<Signal> = [];
  var samples:Array<FastVector2> = [];
  var ui:Zui;
  var used:Int = 10;

  public function new() {
    final x:Array<Complex> = [];
    for (i in 0...100) {
      x.push({
        re: -200,
        im: i * 2 - 100
      });
    }
    for (i in 0...100) {
      x.push({
        re: i * 4 - 200,
        im: 100
      });
    }
    for (i in 0...100) {
      x.push({
        re: 200,
        im: -i * 2 + 100
      });
    }
    for (i in 0...100) {
      x.push({
        re: -i * 4 + 200,
        im: -100
      });
    }

    final X = dft(x);

    var k:Float = 0;
    for (Xk in X) {
      final phi = (Math.PI * 2 * k) / X.length;
      signals.push({
        frequency: k,
        phase: Math.atan2(Xk.im, Xk.re),
        amplitude: Math.sqrt(Xk.im * Xk.im + Xk.re * Xk.re)
      });
      k++;
    }

    signals.sort((a, b) -> Math.round(b.amplitude - a.amplitude));

    final theme = Themes.dark;
    theme.FONT_SIZE = 24;
    ui = new Zui({font: Assets.fonts.NotoSans_Regular, theme: theme});
  }

  private inline function dft(x:Array<Complex>):Array<Complex> {
    final X:Array<Complex> = [];
    for (k in 0...x.length) {
      X.push(dftK(x, k));
    }
    return X;
  }

  private inline function dftK(x:Array<Complex>, k:Int):Complex {
    final Xk:Complex = {re: 0, im: 0};
    final N:Int = x.length;
    final TwoPiN = (Math.PI * 2) / N;
    for (n in 0...N) {
      final at:Complex = {
        re: Math.cos(TwoPiN * k * n),
        im: -Math.sin(TwoPiN * k * n)
      };
      final val = x[n].mult(at);
      Xk.re += val.re;
      Xk.im += val.im;
    }
    Xk.re = Xk.re / N;
    Xk.im = Xk.im / N;
    return Xk;
  }

  public function update() {
    final dt = (Math.PI * 2) / signals.length;
    t += dt;
  }

  public function render(framebuffers:Array<Framebuffer>):Void {
    final screen = framebuffers[0];
    final g2 = screen.g2;
    g2.begin();

    final circle = Color.White;
    circle.A = 0.5;
    final line = Color.White;
    line.A = 1.0;

    // Draw epicycles
    final circleStart:FastVector2 = {
      x: screen.width / 2,
      y: screen.height / 2
    };
    final n = used;
    for (s in 0...n) {
      g2.color = circle;
      g2.drawCircle(circleStart.x, circleStart.y, signals[s].amplitude, 1.0);
      final at:FastVector2 = signals[s].sample(t);
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
    final endpoint:FastVector2 = g2.transformation.multvec({x: 0, y: 0})
      .sub(circleStart);
    g2.transformation = FastMatrix3.identity();

    g2.color = line;
    for (i in 1...samples.length) {
      final start = circleStart.add(samples[i - 1]);
      final end = circleStart.add(samples[i]);
      g2.drawLine(start.x, start.y, end.x, end.y, 3);
    }

    samples.insert(0, endpoint.add(circleStart));
    if (samples.length > signals.length) {
      samples.pop();
    }

    g2.end();

    renderZui(screen);
  }

  private function renderZui(screen:Framebuffer) {
    ui.begin(screen.g2);
    if (ui.window(
      Id.handle({}),
      Math.round(screen.width / 2.0 - 150),
      10,
      300,
      300,
      true
    )) {
      final lowFreq = ui.slider(
        Id.handle({value: used}),
        "Low Frequencies",
        1,
        20
      );
      final highFreq = ui.slider(
        Id.handle({value: 0}),
        "High Frequencies",
        0,
        signals.length - 20
      );
      used = Math.round(lowFreq + highFreq);
    }
    ui.end();
  }
}

@:structInit
class Complex {
  public var re:Float;
  public var im:Float;

  public function new(re:Float, im:Float) {
    this.re = re;
    this.im = im;
  }

  public inline function mult(c:Complex):Complex {
    return clone().multWith(c);
  }

  public inline function multWith(c:Complex):Complex {
    final newRe = re * c.re - im * c.im;
    final newIm = re * c.im + im * c.re;
    this.re = newRe;
    this.im = newIm;
    return this;
  }

  public inline function clone():Complex {
    return {re: re, im: im};
  }
}
