package;

import kha.math.FastVector2;
import kha.graphics2.Graphics;

/**
  Represent geometry in 2 dimensions as a collection of lines which can be
  drawn.
**/
class Mesh2d {
  final lines:Array<Line>;

  var max:FastVector2;
  var min:FastVector2;
  var offset:FastVector2;
  var scale:Float;

  /** Create a new mesh **/
  public function new() {
    lines = [];
    max = {x: 0, y: 0};
    min = {x: 0, y: 0};
    offset = {x: 0, y: 0};
    scale = 1;
  }

  /** Add a line to the mesh **/
  public function addLine(line:Line) {
    lines.push(line);
    updateMin(line.min());
    updateMax(line.max());
  }

  /**
    Modify the mesh's display offset so that all coordinates are centered
    around the origin.
  **/
  public function center() {
    offset.x = -(max.x + min.x) / 2;
    offset.y = -(max.y + min.y) / 2;
  }

  /**
    Modify the mesh's display scale such that no point extends beyond the
    desired size.
  **/
  public function scaleToFit(desiredSize:FastVector2) {
    final size = max.sub(min);
    final s1 = desiredSize.x / size.x;
    final s2 = desiredSize.y / size.y;
    scale = Math.min(s1, s2);
  }

  /** Draw the mesh's points to the screen. **/
  public function draw(g2:Graphics) {
    for (line in lines) {
      final a = line.start.add(offset).mult(scale);
      final b = line.end.add(offset).mult(scale);
      g2.drawLine(a.x, a.y, b.x, b.y);
    }
  }

  /** Draw the mesh's bounding rectangle. **/
  public function drawBounds(g2:Graphics) {
    final a = min.add(offset).mult(scale);
    final width = (max.x - min.x) * scale;
    final height = (max.y - min.y) * scale;
    g2.drawRect(a.x, a.y, width, height);
  }

  private inline function updateMin(vec:FastVector2) {
    min.x = Math.min(min.x, vec.x);
    min.y = Math.min(min.y, vec.y);
  }

  private inline function updateMax(vec:FastVector2) {
    max.x = Math.max(max.x, vec.x);
    max.y = Math.max(max.y, vec.y);
  }
}

@:structInit
class Line {
  public var start:FastVector2;
  public var end:FastVector2;

  public inline function new(start:FastVector2, end:FastVector2) {
    this.start = start;
    this.end = end;
  }

  public inline function min():FastVector2 {
    return {
      x: Math.min(start.x, end.x),
      y: Math.min(start.y, end.y)
    };
  }

  public inline function max():FastVector2 {
    return {
      x: Math.max(start.x, end.x),
      y: Math.max(start.y, end.y)
    };
  }
}
