package;

import zui.Ext;
import zui.Themes;
import zui.Id;
import kha.graphics2.Graphics;
import kha.Assets;
import kha.Color;
import kha.System;
import haxe.ds.Vector;
import kha.Framebuffer;
import zui.Zui;

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
  private final ui:Zui;

  private var color:Int = 0xFFFFFF;
  private var t:Float = 0.0;
  private var f1:Float = 2.1;
  private var f2:Float = 3.2;

  public function new() {
    final theme = Themes.dark;
    theme.FONT_SIZE = 24;
    ui = new Zui({
      font: Assets.fonts.NotoSans_Regular,
      theme: theme,
      color_wheel: Assets.images.color_wheel
    });
    xs = new Vector<Float>(POINTS);
    ys = new Vector<Float>(POINTS);
  }

  private function renderControls(g2:Graphics) {
    final sw = System.windowWidth();
    final sh = System.windowHeight();
    ui.begin(g2);
    if (ui.window(Id.handle(), sw - 300, 0, 300, 600, true)) {
      if (ui.panel(Id.handle(), "Controls")) {
        f1 = ui.slider(Id.handle({value: f1}), "frequency 1", 0.5, 5, 25);
        f2 = ui.slider(Id.handle({value: f2}), "frequency 2", 0.5, 5);
        color = Ext.colorWheel(ui, Id.handle()).value;
      }
    }
    ui.end();
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
      xs[i] = centerX + Math.cos((angle + t) * f1) * scale;
      ys[i] = centerY + Math.sin((angle + t) * f2) * scale;
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
          final c = Color.fromValue(color);
          c.A = normLen;
          g2.color = c;
          g2.drawLine(xs[i], ys[i], xs[j], ys[j], 1);
        }
      }
    }
    g2.end();

    renderControls(g2);
  }
}
