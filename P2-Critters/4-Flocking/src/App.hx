package;

import kha.math.FastVector2;
import haxe.Timer;
import zui.Id;
import kha.Assets;
import zui.Themes;
import kha.math.FastMatrix3;
import kha.input.Mouse;
import kha.System;
import kha.Framebuffer;
import support.ds.CircleBuffer;
import zui.Zui;

using Math;
using support.FloatOps;

/**
  The application class is responsible for presenting the critter world by
  drawing each of the critters on screen. It is also responsible for handling
  user input to interact with critters.
**/
class App {
  private var world:CritterWorld = new CritterWorld(
    {size: {x: 1500, y: 1500}}
  );

  private var pressed:Bool;
  private var pressedAt:FastVector2;
  private var ui:Zui;
  private var frameTimes:CircleBuffer<Float> = {init: 0, maxLen: 30};

  public function new() {
    final theme = Themes.dark;
    theme.FONT_SIZE = 24;
    ui = new Zui({font: Assets.fonts.NotoSans_Regular, theme: theme});
    Mouse.get().notify(onClick, onRelease, onMove, null);
    world.respawn(1000);
  }

  /** Critters chase the mouse when it's clicked **/
  public function onClick(_button:Int, x:Int, y:Int) {
    final proj = orthoProjection(System.windowWidth(), System.windowHeight());
    pressedAt = proj.inverse().multvec({x: x, y: y});
    pressed = true;
  }

  public function onRelease(_button:Int, x:Int, y:Int) {
    pressed = false;
  }

  public function onMove(x:Int, y:Int, dx:Int, dy:Int) {
    if (pressed) {
      final proj = orthoProjection(
        System.windowWidth(),
        System.windowHeight()
      );
      pressedAt = proj.inverse().multvec({x: x, y: y});
    }
  }

  /** Ask the world to integrate and record the time it took. **/
  public function update() {
    final start = Timer.stamp();
    if (pressed) {
      world.avoid(pressedAt);
    }
    world.integrate();
    final end = Timer.stamp();
    frameTimes.push(end - start);
  }

  /** Render the critters and the ui **/
  public function render(framebuffers:Array<Framebuffer>):Void {
    final screen = framebuffers[0];
    final g2 = screen.g2;
    g2.begin();
    g2.pushTransformation(orthoProjection(screen.width, screen.height));
    for (critter in world.critters) {
      critter.draw(g2);
    }
    g2.popTransformation();
    g2.end();

    drawUi(screen);
  }

  /**
    Create a projection matrix for the current world, mapping into a space with
    new dimensions W and H.
  **/
  public function orthoProjection(W:Float, H:Float):FastMatrix3 {
    setAspect(W / H);
    final bx = world.settings.size.x / 2;
    final by = world.settings.size.y / 2;

    // @formatter:off
    return new FastMatrix3(
      W/(2*bx), 0        , W/2,
      0       , -H/(2*by), H/2,
      0       , 0        , 1
    );
    // @formatter:on
  }

  /**
    Reset the critter world's aspect ratio. Convenient for making the world
    fill the entire screen without scaling artifacts.
  **/
  public function setAspect(widthOverHeight:Float) {
    world.settings.size.x = widthOverHeight * world.settings.size.y;
  }

  private function drawUi(screen:Framebuffer) {
    final hwin = Id.handle();
    hwin.redraws = 1;
    ui.begin(screen.g2);
    if (ui.window(hwin, screen.width - 300, 0, 300, 800, false)) {
      ui.text('Avg Frame Time: ${avgFrameTime().fmt()}ms');
      if (ui.panel(Id.handle(), "critters")) {
        final sliderValue = ui.slider(
          Id.handle({value: world.critters.length}),
          "critter",
          50,
          7000
        );
        if (ui.button("Respawn")) {
          world.respawn(sliderValue.round());
        }
      }
    }
    ui.end();
  }

  private function avgFrameTime():Float {
    var sum:Float = 0;
    for (time in frameTimes) {
      sum += time;
    }
    return (sum / frameTimes.length) * 1000;
  }
}
