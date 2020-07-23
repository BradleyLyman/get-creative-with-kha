package;

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

using support.FloatOps;

/**
  The application class is responsible for presenting the critter world by
  drawing each of the critters on screen. It is also responsible for handling
  user input to interact with critters.
**/
class App {
  private var ui:Zui;
  private var frameTimes:CircleBuffer<Float> = {init: 0, maxLen: 30};
  private var world:CritterWorld = new CritterWorld(
    {size: {x: 2000, y: 2000}}
  );

  public function new() {
    final theme = Themes.dark;
    theme.FONT_SIZE = 24;
    ui = new Zui({font: Assets.fonts.NotoSans_Regular, theme: theme});
    Mouse.get().notify(spawnCritters, null, onMove, null);
  }

  /** Critters chase the mouse when it moves. **/
  public function onMove(x:Int, y:Int, dx:Int, dy:Int) {
    final proj = orthoProjection(System.windowWidth(), System.windowHeight());
    final realMouse = proj.inverse().multvec({x: x, y: y});
    world.seek(realMouse);
  }

  /**
    Spawn more critters when the mouse is clicked. Arbitrarily stop when there
    are more than 2500 critters. The experience becomes pretty bad if there are
    more than about 3000 critters, but could be improved with optimizations.
  **/
  public function spawnCritters(_button:Int, x:Int, y:Int) {
    if (world.critters.length > 2500) {
      return;
    }
    final proj = orthoProjection(System.windowWidth(), System.windowHeight());
    final realMouse = proj.inverse().multvec({x: x, y: y});
    for (i in 0...100) {
      world.spawn(realMouse);
    }
  }

  /** Ask the world to integrate and record the time it took. **/
  public function update() {
    final start = Timer.stamp();
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
      ui.text('critters: ${world.critters.length}');
      ui.text('Avg Frame Time: ${avgFrameTime().fmt()}ms');
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
