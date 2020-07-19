package;

import kha.input.Mouse;
import kha.System;
import kha.Framebuffer;

using support.FloatOps;

/**
  A first exploration with kha. Draw a lissajous diagram with 100 points all
  interconnected.
**/
class App {
  private var world:CritterWorld = {size: {x: 1000, y: 1000}};
  private var critters:Array<Critter>;

  public function new() {
    critters = [];
    Mouse.get().notify(spawnCritters, null, null, null);
  }

  public function spawnCritters(_button:Int, x:Int, y:Int) {
    final proj = world.orthoProjection(
      System.windowWidth(),
      System.windowHeight()
    );
    final realMouse = proj.inverse().multvec({x: x, y: y});
    critters = [
      for (_ in 0...200) {
        final critter = world.spawn();
        critter.pos = realMouse;
        critter.vel = {
          x: Math.random().lerp(-250, 250),
          y: Math.random().lerp(-250, 250)
        };
        critter;
      }
    ];
  }

  public function update() {
    for (critter in critters) {
      critter.integrate();
    }
  }

  public function render(framebuffers:Array<Framebuffer>):Void {
    final screen = framebuffers[0];
    final g2 = screen.g2;
    g2.begin();
    g2.transformation = world.orthoProjection(screen.width, screen.height);

    for (critter in critters) {
      critter.draw(g2);
    }

    g2.end();
  }
}
