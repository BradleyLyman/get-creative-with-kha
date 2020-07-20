package;

import kha.Color;
import kha.Assets;
import kha.math.FastVector2;
import kha.Framebuffer;

/**
  First pass at creating a structured plot for a signal.
**/
class App {
  private var plot:Plot;
  private var t:Float = 0.0;
  private var x:Signal = Signal.ofRange(0, 1, 0);
  private var y:Signal = Signal.ofRange(0, 1, 0).sample((_) -> 0);

  public function new() {
    plot = {
      pos: {x: 20, y: 20},
      size: {x: 800, y: 300},
      xAxis: {start: 0, end: Math.PI * 2},
      yAxis: {start: -1, end: 1},
      fontSize: 16,
      background: Color.White,
      foreground: Color.Black,
      font: Assets.fonts.NotoSans_Regular
    };
  }

  public function update() {
    t += (1 / 60.0) * Math.PI / 4;
    x = Signal.ofRange(plot.xAxis.start, plot.xAxis.end, 200);
    y = x.sample((x) -> Math.sin(x + t));
  }

  public function render(framebuffers:Array<Framebuffer>):Void {
    final screen = framebuffers[0];
    center(plot, screen);
    screen.g2.begin();
    plot.draw(screen.g2, x, y);
    screen.g2.end();
  }

  private function center(plot:Plot, screen:Framebuffer) {
    final screenDims:FastVector2 = {x: screen.width, y: screen.height};
    final spaceRemaining = screenDims.sub(plot.size);
    plot.pos = spaceRemaining.div(2);
  }
}
