package;

import kha.math.FastVector2;
import LSystem.Symbol;

using Math;

/**
  A LOGO style turtle for drawing L-System grammars in 2d.
**/
@:structInit
class Turtle {
  public var mesh:Mesh2d;
  public var angle:Float;

  public var angleStep:Float;
  public var step:Float;
  public var pos:FastVector2;

  public function new(step:Float, angleStep:Float) {
    this.angle = 0;
    this.angleStep = angleStep;
    this.step = step;
    this.pos = {x: 0, y: 0};
    this.mesh = new Mesh2d();
  }

  public function interpret(program:Array<Symbol>) {
    for (symbol in program) {
      switch (symbol) {
        case F:
          line(step);
        case Fr:
          line(step);
        case Fl:
          line(step);
        case f:
          advance(step);
        case left:
          turn(-angleStep);
        case right:
          turn(angleStep);
      }
    }
  }

  public function advance(d:Float) {
    pos.x += angle.cos() * d;
    pos.y += angle.sin() * d;
  }

  public function line(d:Float) {
    final last:FastVector2 = {x: pos.x, y: pos.y};
    advance(d);
    final here:FastVector2 = {x: pos.x, y: pos.y};
    mesh.addLine({start: last, end: here});
  }

  public function turn(da:Float) {
    angle += da;
  }
}
