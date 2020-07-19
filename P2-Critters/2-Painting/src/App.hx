package;

import zui.Id;
import kha.Assets;
import zui.Themes;
import kha.Scaler;
import kha.Color;
import kha.Image;
import kha.input.Mouse;
import kha.System;
import kha.Framebuffer;
import zui.Zui;

using Math;
using support.FloatOps;

/**
  A first exploration with kha. Draw a lissajous diagram with 100 points all
  interconnected.
**/
class App {
  private var world:CritterWorld = {size: {x: 1000, y: 1000}};
  private var critters:Array<Critter> = [];
  private var canvasScale:Float = 0.5;
  private var maxCritters:Int = 200;

  private var clearCanvas:Bool = false;
  private var canvas:Image;
  private var ui:Zui;

  public function new() {
    final sw:Int = (System.windowWidth() * canvasScale).round();
    final sh:Int = (System.windowHeight() * canvasScale).round();
    canvas = Image.createRenderTarget(sw, sh, RGBA32, 4);
    Mouse.get().notify(spawnCritters, null, null, null);

    final theme = Themes.dark;
    theme.FONT_SIZE = 32;
    ui = new Zui({font: Assets.fonts.NotoSans_Regular, theme: theme});
  }

  private function canvasResize(w:Int, h:Int) {
    final sw:Int = (w * canvasScale).round();
    final sh:Int = (h * canvasScale).round();
    if (canvas.width != sw || canvas.height != sh) {
      canvas = Image.createRenderTarget(sw, sh, RGBA32, 4);
    }
  }

  public function spawnCritters(_button:Int, x:Int, y:Int) {
    final proj = world.orthoProjection(
      System.windowWidth(),
      System.windowHeight()
    );
    final realMouse = proj.inverse().multvec({x: x, y: y});
    while (critters.length > maxCritters) {
      critters.pop();
    }
    while (critters.length < maxCritters) {
      critters.push(world.spawn(realMouse));
    }
    for (critter in critters) {
      critter.pos = realMouse;
      critter.vel = {
        x: Math.random().lerp(-250, 250),
        y: Math.random().lerp(-250, 250)
      };
      critter.hsl = {h: Math.random().lerp(0, 360), s: 0.7, l: 0.7};
    }
  }

  public function update() {
    for (critter in critters) {
      critter.integrate();
    }
  }

  public function render(framebuffers:Array<Framebuffer>):Void {
    canvasResize(framebuffers[0].width, framebuffers[0].height);
    drawToCanvas();
    drawToScreen(framebuffers[0]);
  }

  private function drawToCanvas() {
    final g2 = canvas.g2;
    g2.begin(clearCanvas);
    clearCanvas = false;
    g2.pushTransformation(world.orthoProjection(canvas.width, canvas.height));
    for (critter in critters) {
      critter.drawTail(canvas.g2);
    }
    g2.popTransformation();
    g2.end();
  }

  private function drawToScreen(screen:Framebuffer) {
    final g2 = screen.g2;
    g2.begin();
    g2.color = Color.White;
    Scaler.scale(canvas, screen, RotationNone);
    g2.pushTransformation(world.orthoProjection(screen.width, screen.height));
    for (critter in critters) {
      critter.draw(g2);
    }
    g2.popTransformation();
    g2.end();

    drawZui(screen);
  }

  private function drawZui(screen:Framebuffer) {
    final uiWidth = 300;
    final maxUiHeight = 700;

    ui.begin(screen.g2);
    if (ui.window(
      Id.handle(),
      screen.width - uiWidth,
      0,
      uiWidth,
      maxUiHeight,
      true
    )) {
      if (ui.panel(Id.handle(), "controls")) {
        final critterCount = ui.slider(
          Id.handle({value: maxCritters}),
          "Critter Count",
          1, // min
          500, // max
          20, // steps
          true, // display value
          false // cannot edit text value
        );
        maxCritters = critterCount.round();

        ui.separator(ui.FONT_SIZE());

        if (ui.button("clear canvas")) {
          clearCanvas = true;
        }

        ui.separator(ui.FONT_SIZE());

        canvasScale = ui.slider(
          Id.handle({value: canvasScale}),
          "canvas scale",
          0.25,
          1.0,
          4
        );
      }
    }
    ui.end();
  }
}
