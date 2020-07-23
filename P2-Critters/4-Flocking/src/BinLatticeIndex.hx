package;

import kha.math.FastVector2;

using Math;

typedef Critters = Array<Critter>;

/**
  A naive bin lattice index. The big idea is to divide the world's space into
  regularly-sized bins. Then, finding a critter's bin is just dividing the
  position by the bin size (resolution) and rounding to the nearest integer.

  The query then just checks all of the bins around the critter. A smarter
  implementation would use the distance to find all possible bins, but for this
  simulation it's enough to just say the query distance MUST BE less than the
  resolution.
**/
class BinLatticeIndex implements CritterWorld.Index {
  final resolution:Float;
  final bins:Array<Critters>;
  var rows:Int;
  var cols:Int;
  var size:FastVector2;

  public function new(critters:Critters, resolution:Float, size:FastVector2) {
    this.resolution = resolution;
    this.bins = [];
    this.size = size;

    resize(size);
    resetCritters(critters);
  }

  public function resize(size:FastVector2) {
    this.cols = (size.x / resolution).ceil() + 1;
    this.rows = (size.y / resolution).ceil() + 1;
    bins.resize(cols * rows);
    for (i in 0...bins.length) {
      if (bins[i] == null) {
        bins[i] = [];
      } else {
        bins[i].resize(0);
      }
    }
  }

  public function resetCritters(critters:Critters) {
    for (critter in critters) {
      final pos = critter.pos.add(size.div(2)); // positive coords
      final snapX = (pos.x / resolution).floor();
      final snapY = (pos.y / resolution).floor();
      bins[snapX + snapY * cols].push(critter);
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
      return (a[0] >= 0 && a[1] >= 0) && (a[0] < cols && a[1] < rows);
    });

    var critters:Array<Critter> = [];
    for (section in reduced) {
      final col = section[0];
      final row = section[1];
      critters = critters.concat(bins[col + row * cols]);
    }
    return critters;
  }
}
