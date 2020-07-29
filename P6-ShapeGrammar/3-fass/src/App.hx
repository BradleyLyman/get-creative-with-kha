package;

import kha.input.Keyboard;
import kha.Framebuffer;

/**
  Experiment with holding 2d geometry in a mesh object which provides tools for
  rescaling and centering itself.
**/
class App {
  var mesh:Mesh2d = new Mesh2d();
  var presets = [
    LSystem.Preset.dragonCurve, LSystem.Preset.eCurve,
    LSystem.Preset.kochIsland, LSystem.Preset.gosperCurve,
    LSystem.Preset.kochInside, LSystem.Preset.kochIslandQuadradic,
    LSystem.Preset.kochLakes, LSystem.Preset.kochRects,
    LSystem.Preset.serpinskiGasket, LSystem.Preset.snowflakeQuadradic
  ];
  var index:Int = 0;
  var amount:Float = 0;

  public function new() {
    mesh = presets[index].buildMesh();
    Keyboard.get().notify(null, null, onKeypress);
  }

  private function onKeypress(char:String) {
    index = (index + 1) % presets.length;
    mesh = presets[index].buildMesh();
  }

  public function update() {
    amount += 1.0 / 120;
    if (amount >= 2) {
      amount = 0;
      index = (index + 1) % presets.length;
      mesh = presets[index].buildMesh();
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
