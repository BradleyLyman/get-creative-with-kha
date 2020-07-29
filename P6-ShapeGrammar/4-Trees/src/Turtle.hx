package;

import kha.math.FastVector2;
import LSystem.Symbol;

using Math;

@:structInit
class State {
  public var angle:Float;
  public var pos:FastVector2;

  public function new(angle:Float, pos:FastVector2) {
    this.angle = angle;
    this.pos = pos;
  }

  public function clone():State {
    return {
      angle: angle,
      pos: {x: pos.x, y: pos.y}
    };
  }
}

/**
  A LOGO style turtle for drawing L-System grammars in 2d.
**/
@:structInit
class Turtle {
  public var mesh:Mesh2d;
  public var angleStep:Float;
  public var step:Float;

  public var state:State;
  public var stack:Array<State>;

  public function new(step:Float, angleStep:Float) {
    stack = [];
    this.state = {
      angle: 0,
      pos: {x: 0, y: 0}
    };
    this.angleStep = angleStep;
    this.step = step;
    this.mesh = new Mesh2d();
  }

  public function interpret(program:Array<Symbol>) {
    for (symbol in program) {
      switch (symbol) {
        case F:
          line(step);
        case f:
          advance(step);
        case left:
          turn(-angleStep);
        case right:
          turn(angleStep);
        case push:
          push();
        case pop:
          pop();
      }
    }
  }

  public function push() {
    stack.push(state.clone());
  }

  public function pop() {
    final updated = stack.pop();
    if (updated != null) {
      state = updated;
    }
  }

  public function advance(d:Float) {
    state.pos.x += state.angle.cos() * d;
    state.pos.y += state.angle.sin() * d;
  }

  public function line(d:Float) {
    final last:FastVector2 = {x: state.pos.x, y: state.pos.y};
    advance(d);
    final here:FastVector2 = {x: state.pos.x, y: state.pos.y};
    mesh.addLine({start: last, end: here});
  }

  public function turn(da:Float) {
    state.angle += da;
  }
}
