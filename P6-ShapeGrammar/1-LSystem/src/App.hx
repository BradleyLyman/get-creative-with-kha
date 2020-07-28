package;

import kha.input.Mouse;
import kha.graphics2.Graphics;
import kha.math.FastVector2;
import kha.Framebuffer;

using Math;

class App {
  final framesPer:Int = 4;
  var frames:Int = 0;

  var step:Float = 10;
  var end:Int = 1;
  final seed:Array<Symbols> = [F, left, F, left, F, left, F];
  var program:Array<Symbols>;

  var offset:FastVector2 = {x: 0, y: 0};
  var scale:Float = 1.0;
  var pressed:Bool = false;

  public function new() {
    program = seed.copy();
    Mouse.get().notify(onMouseDown, onMouseUp, onMouseMove, null);
  }

  private function onMouseDown(button:Int, x:Int, y:Int) {
    pressed = true;
  }

  private function onMouseUp(button:Int, x:Int, y:Int) {
    pressed = false;
  }

  private function onMouseMove(x:Int, y:Int, dx:Int, dy:Int) {
    if (pressed) {
      offset.x += dx;
      offset.y += dy;
    }
  }

  public function update() {
    frames++;
    if (frames >= framesPer) {
      frames = 0;
      if (end < program.length) {
        end += (program.length / 100).ceil();
        end = Math.min(end, program.length).round();
      } else {
        end = 1;
        if (program.length < 500) {
          grow();
        } else {
          program = seed.copy();
        }
      }
    }
  }

  public function grow() {
    var grown:Array<Symbols> = [];
    for (symbol in program) {
      switch (symbol) {
        case f:
          grown.push(f);
        case left:
          grown.push(left);
        case right:
          grown.push(right);
        case F:
          grown.push(F);
          grown.push(left);
          grown.push(F);
          grown.push(right);
          grown.push(F);
          grown.push(right);
          grown.push(F);
          grown.push(F);
          grown.push(left);
          grown.push(F);
          grown.push(left);
          grown.push(F);
          grown.push(right);
          grown.push(F);
      };
    }
    program = grown;
  }

  public function render(framebuffers:Array<Framebuffer>):Void {
    final screen = framebuffers[0];
    final g2 = screen.g2;
    g2.begin();

    final turtle:Turtle = {
      pos: {x: screen.width / 2 + offset.x, y: screen.height / 2 + offset.y},
      angle: 0
    };
    final angle = Math.PI / 2.0;

    for (i in 0...end) {
      switch (program[i]) {
        case F:
          turtle.line(g2, step);
        case f:
          turtle.advance(step);
        case left:
          turtle.turn(-angle);
        case right:
          turtle.turn(angle);
      }
    }

    g2.end();
  }
}

enum abstract Symbols(String) {
  var F = "F";
  var f = "f";
  var left = "-";
  var right = "+";
}

/**
  A LOGO style turtle for drawing L-System grammars in 2d.
**/
@:structInit
class Turtle {
  public var angle:Float;
  public var pos:FastVector2;

  public function new(pos:FastVector2, angle:Float) {
    this.angle = angle;
    this.pos = pos;
  }

  public function advance(d:Float) {
    pos.x += angle.cos() * d;
    pos.y += angle.sin() * d;
  }

  public function line(g2:Graphics, d:Float) {
    final last:FastVector2 = {x: pos.x, y: pos.y};
    advance(d);
    g2.drawLine(last.x, last.y, pos.x, pos.y);
  }

  public function turn(da:Float) {
    angle += da;
  }
}
