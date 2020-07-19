package;

import zui.Ext;
import kha.math.FastVector2;
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

class App {
  private var world:CritterWorld = {
    size: {x: 1000, y: 1000},
    maxAge: 5,
    maxVel: 250
  };
  private var critters:Array<Critter> = [];
  private var canvasScale:Float = 1.0;
  private var maxCritters:Int = 200;

  private var clearCanvas:Bool = false;
  private var canvas:Image;
  private var ui:Zui;
  private var totalTime:Float;

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
        x: Math.random().lerp(-world.maxVel, world.maxVel),
        y: Math.random().lerp(-world.maxVel, world.maxVel)
      };
      critter.hsl = {h: Math.random().lerp(0, 360), s: 0.7, l: 0.7};
      critter.age = 0.0;
      critter.resetTail();
    }
  }

  function fixedPoints(critter:Critter):FastVector2 {
    return {
      x: (critter.pos.x / 20).cos() * world.maxVel,
      y: (critter.pos.y / 20).sin() * world.maxVel
    };
  }

  function rotate(critter:Critter):FastVector2 {
    final dir:FastVector2 = {
      x: critter.pos.y,
      y: -critter.pos.x
    };
    return dir.normalized().mult(world.maxVel);
  }

  function toOrigin(critter:Critter):FastVector2 {
    return critter.pos.mult(-1).mult(world.maxVel);
  }

  function pickOperation():(critter:Critter) -> FastVector2 {
    final segment = totalTime / 5; // switch every n seconds
    final select = segment.round() % 3;
    return switch (select) {
      case 0: fixedPoints;
      case 1: rotate;
      case 2: toOrigin;
      default: rotate;
    }
  }

  public function update() {
    totalTime += world.integrationSeconds;
    final direction = pickOperation();
    for (critter in critters) {
      critter.steer(direction(critter), world.maxAccel / 5);
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
        if (ui.panel(Id.handle(), "critters")) {
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

          world.maxAge = ui.slider(
            Id.handle({value: world.maxAge}),
            "Max Age",
            1,
            60
          );

          world.maxVel = ui.slider(
            Id.handle({value: world.maxVel}),
            "Max Speed",
            200,
            1000
          );
          world.maxAccel = world.maxVel * 4;
        }

        if (ui.panel(Id.handle(), "canvas")) {
          ui.separator(ui.FONT_SIZE());

          if (ui.button("clear canvas")) {
            clearCanvas = true;
          }

          canvasScale = ui.slider(
            Id.handle({value: canvasScale}),
            "canvas scale",
            0.25,
            1.0,
            4
          );
        }
      }
    }
    ui.end();
  }
}
