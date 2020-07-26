package;

import kha.math.FastMatrix3;
import kha.math.Random;
import zui.Id;
import zui.Themes;
import kha.Assets;
import zui.Zui;
import kha.Image;
import kha.Color;
import kha.Framebuffer;

using Math;

class App {
  final ui:Zui;
  final canvas:Image;
  var needsRefil:Bool = true;
  var prng:() -> Float = Math.random;

  public function new() {
    final theme = Themes.dark;
    theme.FONT_SIZE = 24;
    ui = new Zui({font: Assets.fonts.NotoSans_Regular, theme: theme});

    canvas = Image.createRenderTarget(256, 256, RGBA32);
    setupRng();
  }

  private function setupRng() {
    kha.math.Random.init(5);
  }

  private function fillCanvas() {
    var vals:Array<Float> = [];

    canvas.g2.begin(true, Color.Black);
    canvas.g2.end();

    canvas.g1.begin();
    for (x in 0...canvas.width) {
      for (y in 0...canvas.height) {
        final c = prng();
        vals.push(c);
        final color = Color.fromFloats(c, c, c);
        canvas.g1.setPixel(x, y, color);
      }
    }
    canvas.g1.end();
  }

  public function update() {
    if (needsRefil) {
      needsRefil = false;
      fillCanvas();
    }
  }

  public function render(framebuffers:Array<Framebuffer>):Void {
    final screen = framebuffers[0];
    final g2 = screen.g2;
    final minDim:Int = Math.min(screen.width, screen.height).round();
    final x = (screen.width - minDim) / 2;
    final y = (screen.height - minDim) / 2;

    g2.begin();
    g2.drawScaledImage(canvas, x, y, minDim, minDim);
    g2.end();

    drawUI(screen);
  }

  private function drawUI(screen:Framebuffer) {
    ui.begin(screen.g2);
    if (ui.window(Id.handle(), screen.width - 250, 0, 250, 600)) {
      if (ui.panel(Id.handle(), "Rng Method")) {
        if (ui.button("Math.random")) {
          prng = Math.random;
          needsRefil = true;
        }
        if (ui.button("Kha.random")) {
          prng = Random.getFloat;
          needsRefil = true;
        }
        if (ui.button("Middle Sqr")) {
          prng = MiddleSqr.random;
          needsRefil = true;
        }
        if (ui.button("Mid Sqr Weyl")) {
          prng = MSWeyl.random;
          needsRefil = true;
        }
      }
    }
    ui.end();
  }
}
