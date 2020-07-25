package index;

import kha.math.FastVector2;

using Math;

typedef Critters = Array<Critter>;

/**
  A bin lattice index. The big idea is to divide the world's space into
  regularly-sized bins. Then, finding a critter's bin is just dividing the
  position by the bin size (resolution) and rounding to the nearest integer.

  There is a trade-off regarding bin size. Smaller bins require more memory
  but could include fewer critters in each query. Until the bins become so small
  that checking bins is equally as expensive as checking critters.

  Conversely, large bins include more critters in each query. This is lighter
  on memory requirements, but once the bins are too large the benefits are
  reduced.

  This demo has tuned the resolution to equal the seach radius. The simple
  construction and indexing means that this index typically outperforms the
  other tree methods in CPU time (if not memory).
**/
class BinLatticeIndex implements CritterWorld.Index {
  final resolution:Float;
  final bins:Array<Critters>;
  var rows:Int = 0;
  var cols:Int = 0;
  var size:FastVector2 = {x: 0, y: 0};

  /**
    Create a new BinLattice index for looking up critters.
    @param resolution
      the size of each bin. Larger bins means more critters are included in
      each check. Smaller bins require more memory to be used.
  **/
  public function new(resolution:Float) {
    this.resolution = resolution;
    this.bins = [];
  }

  /**
    Refill the index with the provided set of critters.
    Removes all existing content.
    @param critters The critters to index by their position
    @param size the size of the world where the critters live
  **/
  public function flush(critters:Critters, size:FastVector2) {
    resize(size);
    resetCritters(critters);
  }

  /**
    Retrieve all critters within a given distance of a point.
    @param point the query point
    @param distance how far away to include critters
    @param out Array<Critter>
      all critters with the threshold distance from the target
  **/
  public function nearby(
    point:FastVector2,
    distance:Float,
    out:Critters
  ):Void {
    final sqdistance = distance * distance;
    inline function isNearby(critter:Critter):Bool {
      final dx = critter.pos.x - point.x;
      final dy = critter.pos.y - point.y;
      return (dx * dx + dy * dy) <= sqdistance;
    }
    final transformed = point.add(size.div(2));
    final sX = (transformed.x / resolution).round();
    final sY = (transformed.y / resolution).round();
    final searchRadius = (distance / resolution).ceil();

    for (col in (sX - searchRadius)...(sX + searchRadius)) {
      for (row in (sY - searchRadius)...(sY + searchRadius)) {
        if (!inBounds(col, row)) {
          continue;
        }
        for (critter in bins[col + row * cols]) {
          if (isNearby(critter)) {
            out.push(critter);
          }
        }
      }
    }
  }

  /** Resize the lattice. Attempt to re-use arrays where possible. **/
  private function resize(size:FastVector2) {
    this.size = size;
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

  /**
    Fill bins with critters based on their rounded positions. Must be called
    after a resize to prevent out of bounds errors.
  **/
  private function resetCritters(critters:Critters) {
    for (critter in critters) {
      final pos = critter.pos.add(size.div(2)); // positive coords
      final snapX = (pos.x / resolution).floor();
      final snapY = (pos.y / resolution).floor();
      bins[snapX + snapY * cols].push(critter);
    }
  }

  /**
    Check that a given row and column pair is within the lattice's bounds.
  **/
  private function inBounds(col:Int, row:Int) {
    return (row >= 0 && col >= 0) && (col < cols && row < rows);
  }
}
