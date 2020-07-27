package;

import kha.input.Mouse;
import kha.math.FastVector2;
import kha.Color;
import kha.graphics2.Graphics;
import kha.Framebuffer;

using Math;
using support.FloatOps;

/**
  This demo plays with randomness by creating rows of 'cells' onscreen.
  Cells travel to the right with some random velocity.
**/
class App {
  var rows:Array<Row> = [];
  var threshold:Float = 1.0;
  var screenWidth:Int = 1000;
  var screenHeight:Int = 800;

  public function new() {
    Mouse.get().notify(null, null, onMove, null);
  }

  private function onMove(x:Int, y:Int, dx:Int, dy:Int) {
    threshold = x / screenWidth;
  }

  private function onResize() {
    final rowHeight = 10;
    final count = Math.round(screenHeight / rowHeight);
    rows = [
      for (i in 0...count) {
        new Row(i * rowHeight, 10, screenWidth);
      }
    ];
  }

  public function update() {
    for (row in rows) {
      row.update();
    }
  }

  public function render(framebuffers:Array<Framebuffer>):Void {
    final screen = framebuffers[0];
    if (screen.width != screenWidth || screen.height != screenHeight) {
      screenWidth = screen.width;
      screenHeight = screen.height;
      onResize();
    }

    final g2 = screen.g2;
    g2.begin(true, Color.White);
    for (row in rows) {
      row.draw(g2, threshold);
    }
    g2.end();
  }
}

class Row {
  final cellWidth:Int = 4;
  final cells:Array<Cell> = [];
  final rowWidth:Int;

  var vel:Float = MSWeyl.random().lerp(1, 8).ceil();

  public function new(yPos:Int, height:Int, width:Int) {
    final count:Int = Math.ceil(width / cellWidth);
    cells = [
      for (i in 0...count) {
        new Cell(
          {x: i * cellWidth, y: yPos},
          MSWeyl.random(),
          cellWidth,
          height
        );
      }
    ];
    rowWidth = cellWidth * cells.length;
  }

  public function update() {
    var start:Float = rowWidth;
    for (cell in cells) {
      cell.pos.x += vel;
      if (cell.pos.x < start) {
        start = cell.pos.x; // find the x position of the first cell in the row
      }
    }

    // enforce bounds
    for (cell in cells) {
      if (cell.pos.x >= rowWidth) {
        start -= cellWidth;
        cell.pos.x = start;
        cell.val = MSWeyl.random();
      }
    }
  }

  public function draw(g2:Graphics, threshold:Float) {
    for (i in 0...cells.length) {
      cells[i].draw(g2, threshold);
    }
  }
}

class Cell {
  public var width:Int;
  public var height:Int;
  public var val:Float;
  public var nextVal:Float;
  public var pos:FastVector2;

  public function new(pos:FastVector2, val:Float, width:Int, height:Int) {
    this.pos = pos;
    this.val = val;
    this.nextVal = val;
    this.width = width;
    this.height = height;
  }

  public function draw(g2:Graphics, threshold:Float) {
    if (val >= threshold) {
      return;
    }
    g2.color = Color.fromFloats(val, val, val);
    g2.fillRect(pos.x, pos.y, width, height);
  }
}
