package;

import kha.Framebuffer;

/**
  Experiment with holding 2d geometry in a mesh object which provides tools for
  rescaling and centering itself.
**/
class App {
  public function new() {}

  public function update() {}

  public function grow() {}

  public function render(framebuffers:Array<Framebuffer>):Void {
    final screen = framebuffers[0];
    final g2 = screen.g2;

    final mesh = new Mesh2d();
    mesh.addLine({start: {x: 0, y: 100}, end: {x: 200, y: 0}});
    mesh.addLine({start: {x: 10, y: 10}, end: {x: 100, y: 100}});
    mesh.addLine({start: {x: -25, y: -98}, end: {x: 0, y: -4}});

    mesh.center();
    mesh.scaleToFit({x: screen.width * 0.95, y: screen.height * 0.95});

    g2.begin();
    g2.pushTranslation(screen.width / 2, screen.height / 2);
    mesh.draw(g2);
    mesh.drawBounds(g2);
    g2.popTransformation();
    g2.end();
  }
}
