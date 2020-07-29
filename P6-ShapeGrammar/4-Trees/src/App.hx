package;

import LSystem.Preset;
import kha.Framebuffer;

/**
  Experiment with holding 2d geometry in a mesh object which provides tools for
  rescaling and centering itself.
**/
class App {
  var mesh:Mesh2d = new Mesh2d();
  var index:Int = 0;
  var amount:Float = 2;
  var buildSteps:Int = 1;

  var presets:Array<Preset> = [Preset.tree, Preset.tree2, Preset.tree3];

  public function new() {}

  public function update() {
    amount += 1.0 / 120;
    if (amount >= 1.5) {
      amount = 0;
      mesh = presets[index].buildMesh(buildSteps);
      buildSteps++;
    }
    if (buildSteps > presets[index].steps) {
      buildSteps = 1;
      index = (index + 1) % presets.length;
    }
  }

  public function render(framebuffers:Array<Framebuffer>):Void {
    final screen = framebuffers[0];
    final g2 = screen.g2;

    mesh.center();
    mesh.scaleToFit({x: screen.width * 0.95, y: screen.height * 0.95});

    g2.begin();
    g2.pushTranslation(screen.width / 2, screen.height / 2);
    mesh.draw(g2, amount);
    g2.popTransformation();
    g2.end();
  }
}
