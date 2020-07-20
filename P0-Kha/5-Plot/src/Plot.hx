package;

import haxe.ds.Vector;
import kha.math.FastMatrix3;
import kha.graphics2.Graphics;
import kha.Color;
import kha.Font;
import kha.math.FastVector2;
import support.Projection;

using Math;
using support.FloatOps;

@:structInit
class Interval {
  public var start:Float;
  public var end:Float;

  public inline function new(start:Float, end:Float) {
    this.start = start;
    this.end = end;
  }
}

@:structInit
class Plot {
  // layout properties
  public var pos:FastVector2;
  public var size:FastVector2;

  private var padding:FastVector2;

  // style properties
  public var font:Font;
  public var fontSize:Int;
  public var background:Color;
  public var foreground:Color;

  // math
  public var xAxis:Interval;
  public var yAxis:Interval;

  /**
    Create a new plot.
  **/
  public function new(
    pos:FastVector2,
    size:FastVector2,
    font:Font,
    ?fontSize:Int = 24,
    ?background:Color = Color.White,
    ?foreground:Color = Color.Black,
    ?padding:FastVector2,
    ?xAxis:Interval,
    ?yAxis:Interval
  ) {
    // layout
    this.pos = pos;
    this.size = size;
    this.padding = padding != null ? padding : {x: 0, y: 0};

    // style
    this.font = font;
    this.fontSize = fontSize;
    this.background = background;
    this.foreground = foreground;

    // math
    this.xAxis = xAxis != null ? xAxis : {start: 0, end: size.x};
    this.yAxis = yAxis != null ? yAxis : {start: 0, end: size.y};
  }

  /**
    Render a line plot with the provided points.
    x and y coordinates should be within the plot's x and y axis bounds.
  **/
  public function draw(g2:Graphics, x:Vector<Float>, y:Vector<Float>) {
    drawBackground(g2);
    drawForeground(g2, x, y);
  }

  private function drawBackground(g2:Graphics) {
    g2.color = background;
    g2.fillRect(pos.x, pos.y, size.x, size.y);
  }

  private function drawForeground(
    g2:Graphics,
    x:Vector<Float>,
    y:Vector<Float>
  ) {
    drawAxisLabels(g2);
    drawAxisLines(g2);
    drawData(g2, x, y);
  }

  private function drawAxisLabels(g2:Graphics) {
    foreground.A = 1.0;
    g2.color = foreground;
    g2.font = font;
    g2.fontSize = fontSize;

    final yStartLabel = ' ${yAxis.start.fmt(4)} ';
    final yEndLabel = ' ${yAxis.end.fmt(4)} ';
    final xStartLabel = ' ${xAxis.start.fmt(4)} ';
    final xEndLabel = ' ${xAxis.end.fmt(4)} ';

    padding.x = Math.max(
      g2.font.width(g2.fontSize, yStartLabel),
      g2.font.width(g2.fontSize, yEndLabel)
    );
    padding.y = g2.fontSize;

    g2.drawString(xStartLabel, pos.x + padding.x, pos.y + size.y - padding.y);
    g2.drawString(
      xEndLabel,
      pos.x + size.x - padding.x - g2.font.width(g2.fontSize, xEndLabel),
      pos.y + size.y - padding.y
    );

    g2.drawString(yStartLabel, pos.x, pos.y + size.y - padding.y * 2);
    g2.drawString(yEndLabel, pos.x, pos.y + padding.y);
  }

  private function drawAxisLines(g2:Graphics) {
    foreground.A = 0.5;
    g2.color = foreground;

    final transform:FastMatrix3 = interiorProjection();
    final start:FastVector2 = transform.multvec(
      {x: xAxis.start, y: yAxis.start}
    );
    final yExtent:FastVector2 = transform.multvec(
      {x: xAxis.start, y: yAxis.end}
    );
    final xExtent:FastVector2 = transform.multvec(
      {x: xAxis.end, y: yAxis.start}
    );
    g2.drawLine(start.x, start.y, xExtent.x, xExtent.y);
    g2.drawLine(start.x, start.y, yExtent.x, yExtent.y);
  }

  private function drawData(g2:Graphics, x:Vector<Float>, y:Vector<Float>) {
    foreground.A = 1.0;
    g2.color = foreground;

    // the transform is used on the input points, but it's not applied to the
    // graphics object itself. This is because line width should be a function
    // of screen space, not the X and Y axis space
    final transform:FastMatrix3 = interiorProjection();

    final len:Int = Math.min(x.length, y.length).round();
    if (len == 0) {
      return;
    }
    var prev = transform.multvec({x: x[0], y: y[0]});
    for (i in 1...len) {
      final current = transform.multvec({x: x[i], y: y[i]});
      g2.drawLine(prev.x, prev.y, current.x, current.y);
      prev = current;
    }
  }

  private function interiorProjection():FastMatrix3 {
    return Projection.ortho(
      {start: xAxis.start, end: xAxis.end},
      {start: yAxis.start, end: yAxis.end},
      {start: pos.x + padding.x, end: pos.x + size.x - padding.x},
      {start: pos.y + size.y - padding.y, end: pos.y + padding.y}
    );
  }
}
