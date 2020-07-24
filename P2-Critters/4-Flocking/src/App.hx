package;

import haxe.Timer;
import zui.Id;
import kha.Assets;
import zui.Themes;
import kha.math.FastMatrix3;
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
  private var minDimSize:Float = 2000;
  private final maxCritters:Int = 7000;
  private var world:CritterWorld = new CritterWorld(
    {size: {x: 2000, y: 2000}}
  );
  private var critterCount:Int = 1000;
  private var needsRespawn:Bool = true;

  private var projection:FastMatrix3;
  private var repulser:Repulser;

  private var ui:Zui;
  private var frameTimes:CircleBuffer<Float> = {init: 0, maxLen: 30};

  public function new() {
    final theme = Themes.dark;
    theme.FONT_SIZE = 24;
    ui = new Zui({font: Assets.fonts.NotoSans_Regular, theme: theme});

    repulser = new Repulser();
    minDimSize = (critterCount / maxCritters).lerp(500, 3000);
  }

  /** Ask the world to integrate and record the time it took. **/
  public function update() {
    final start = Timer.stamp();
    if (repulser.active) {
      world.avoid(repulser.centeredAt, repulser.radius());
    }
    world.integrate();
    final end = Timer.stamp();
    frameTimes.push(end - start);
  }

  /** Render the critters and the ui **/
  public function render(framebuffers:Array<Framebuffer>):Void {
    final screen = framebuffers[0];

    updateProjection(screen.width, screen.height);
    if (needsRespawn) {
      respawn();
    }

    final g2 = screen.g2;
    g2.begin();
    g2.pushTransformation(projection);
    for (critter in world.critters) {
      critter.draw(g2);
    }
    repulser.draw(g2);
    g2.popTransformation();
    g2.end();

    drawUi(screen);
  }

  /** Set the projection from worldspace to screen space. **/
  public function updateProjection(W:Float, H:Float):Void {
    if (W >= H) {
      // reset the aspect ratio to fill the full screen
      world.settings.size.y = minDimSize;
      world.settings.size.x = (W / H) * world.settings.size.y;
    } else {
      world.settings.size.x = minDimSize;
      world.settings.size.y = (H / W) * world.settings.size.x;
    }

    final bx = world.settings.size.x / 2;
    final by = world.settings.size.y / 2;
    // @formatter:off
    projection = new FastMatrix3(
      W/(2*bx), 0        , W/2,
      0       , -H/(2*by), H/2,
      0       , 0        , 1
    );
    // @formatter:on
    repulser.invProject = projection.inverse();
    repulser.maxRadius = Math.min(
      world.settings.size.y,
      world.settings.size.x
    ) * 0.25;
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
          maxCritters
        );
        if (ui.button("Respawn")) {
          critterCount = sliderValue.round();
          minDimSize = (critterCount / maxCritters).lerp(500, 3000);
          needsRespawn = true;
        }
      }
    }
    ui.end();
  }

  private function respawn() {
    needsRespawn = false;
    world.respawn(critterCount);
  }

  private function avgFrameTime():Float {
    var sum:Float = 0;
    for (time in frameTimes) {
      sum += time;
    }
    return (sum / frameTimes.length) * 1000;
  }
}
