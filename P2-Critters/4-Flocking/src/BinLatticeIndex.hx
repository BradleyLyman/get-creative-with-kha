package;

import kha.math.FastVector2;

using Math;

typedef Critters = Array<Critter>;

class BinLatticeIndex implements CritterWorld.Index {
  final resolution:Float;
  final cells:Array<Array<Critters>>;
  final rows:Int;
  final cols:Int;
  final size:FastVector2;

  public function new(critters:Critters, resolution:Float, size:FastVector2) {
    this.resolution = resolution;
    this.cells = [];
    this.size = size;

    this.cols = (size.x / resolution).ceil() + 1;
    this.rows = (size.y / resolution).ceil() + 1;
    for (c in 0...cols) {
      this.cells.push([]);
      for (r in 0...rows) {
        cells[c].push([]);
      }
    }

    for (critter in critters) {
      final pos = critter.pos.add(size.div(2)); // positive coords
      final snapX = (pos.x / resolution).round();
      final snapY = (pos.y / resolution).round();
      cells[snapX][snapY].push(critter);
    }
  }

  /**
    Retrieve all critters within a given distance of a point.
    @param point the query point
    @param distance how far away to include critters
    @return Array<Critter>
      all critters with the threshold distance from the target
  **/
  public function nearby(point:FastVector2, distance:Float):Array<Critter> {
    final transformed = point.add(size.div(2));
    final sX = (transformed.x / resolution).round();
    final sY = (transformed.y / resolution).round();

    function isNearby(critter:Critter):Bool {
      return critter.pos.sub(point).length <= distance;
    }
    final candidates = gatherAround(sX, sY);
    return candidates.filter(isNearby);
  }

  private function gatherAround(col:Int, row:Int):Array<Critter> {
    final coords = [
      [col, row], // center
      [col, row - 1], // above
      [col, row + 1], // below

      [col - 1, row], // left
      [col - 1, row - 1], // top left
      [col - 1, row + 1], // bottom left

      [col + 1, row], // right
      [col + 1, row - 1], // top right
      [col + 1, row + 1], // bottom right
    ];
    final reduced = coords.filter((a) -> {
      return (a[0] > 0 && a[1] > 0) && (a[0] < cols && a[1] < rows);
    });

    var critters:Array<Critter> = [];
    for (section in reduced) {
      final col = section[0];
      final row = section[1];
      critters = critters.concat(cells[col][row]);
    }
    return critters;
  }
}
