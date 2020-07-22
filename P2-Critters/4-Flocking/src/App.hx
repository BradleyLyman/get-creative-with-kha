package;

import kha.math.FastMatrix3;
import kha.input.Mouse;
import kha.System;
import kha.Framebuffer;

class App {
  private var world:CritterWorld = new CritterWorld(
    {size: {x: 1000, y: 1000}}
  );

  public function new() {
    Mouse.get().notify(spawnCritters, null, onMove, null);
  }

  public function onMove(x:Int, y:Int, dx:Int, dy:Int) {
    final proj = orthoProjection(System.windowWidth(), System.windowHeight());
    final realMouse = proj.inverse().multvec({x: x, y: y});
    world.avoid(realMouse);
  }

  public function spawnCritters(_button:Int, x:Int, y:Int) {
    world.clear();
    final proj = orthoProjection(System.windowWidth(), System.windowHeight());
    final realMouse = proj.inverse().multvec({x: x, y: y});
    for (i in 0...200) {
      world.spawn(realMouse);
    }
  }

  public function update() {
    world.integrate();
  }

  public function render(framebuffers:Array<Framebuffer>):Void {
    final screen = framebuffers[0];
    final g2 = screen.g2;
    g2.begin();
    g2.transformation = orthoProjection(screen.width, screen.height);
    for (critter in world.critters) {
      critter.draw(g2);
    }
    g2.end();
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
}
