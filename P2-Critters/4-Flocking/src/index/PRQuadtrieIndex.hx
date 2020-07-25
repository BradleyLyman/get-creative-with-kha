package index;

import kha.math.FastVector2;

using support.VecOps;

/**
  A Point-Region Quadtree implementation which partitions the input space
  rather than the value space. Hence the name quadTRIE rather than quadtree.

  This tree requires less fine-tuning than the bin lattice index to achieve
  similar (though slightly worse) lookup time. This semes to come from
  two factors:  this datastructure is more complex to build than the bin
  lattice, and the query must touch nodes that the bin lattice can entirely
  ignore by construction.

  The appeal is that no concern needs to be given to the size of a typical
  query vs the resolution of the lattice. Also, the PRQuadtrie is not
  susceptable to the unexpected slowdowns created by the point quadtree's
  sensitivity to insertion order.
**/
class PRQuadtrieIndex implements CritterWorld.Index {
  var root:Quad = null;
  var pool:QuadPool = new QuadPool();
  var frontier:Array<Quad> = [];

  public function new() {};

  public function refill(critters:Array<Critter>, size:FastVector2) {
    pool.reset(critters.length);
    root = pool.next();
    root.x = 0;
    root.y = 0;
    root.halfW = size.x / 2;
    root.halfH = size.y / 2;
    for (critter in critters) {
      root.insert(critter, pool);
    }
  }

  public function nearby(point:FastVector2, range:Float, out:Array<Critter>) {
    if (root == null) {
      return;
    }
    frontier.resize(0);
    frontier.push(root);
    while (frontier.length > 0) {
      final current = frontier.pop();
      if (current.isLeaf()) {
        for (critter in current.bucket) {
          final sqlen = critter.pos.sub(point).sqrLen();
          if (sqlen <= range * range) {
            out.push(critter);
          }
        }
      } else {
        push(current.NW, point, range);
        push(current.NE, point, range);
        push(current.SW, point, range);
        push(current.SE, point, range);
      }
    }
  }

  private inline function push(quad:Quad, point:FastVector2, range:Float) {
    if (quad.intersects(point, range)) {
      frontier.push(quad);
    }
  }
}

/**
  Keep a pool of quad objects to reduce GC pressure when reconstructing every
  iteration.
**/
class QuadPool {
  var current = 0;
  var quads:Array<Quad> = [];

  public inline function new() {};

  public function reset(hint:Int) {
    for (quad in quads) {
      quad.reset();
    }
    while (quads.length < hint / Quad.MAX) {
      quads.push(new Quad());
    }
    current = 0;
  }

  public function next():Quad {
    if (current >= quads.length) {
      quads.push(new Quad());
    }
    return quads[current++];
  }
}

class Quad {
  public static final MAX = 16;

  public var x:Float = 0;
  public var y:Float = 0;
  public var halfW:Float = 0;
  public var halfH:Float = 0;
  public var bucket:Array<Critter> = [];
  public var NE:Quad = null;
  public var NW:Quad = null;
  public var SE:Quad = null;
  public var SW:Quad = null;

  public function new() {}

  public function reset() {
    x = 0;
    y = 0;
    halfH = 0;
    halfW = 0;
    bucket.resize(0);
    NE = null;
    NW = null;
    SE = null;
    SW = null;
  }

  public inline function isLeaf() {
    return NE == null;
  }

  public function insert(critter:Critter, pool:QuadPool):Bool {
    if (!intersects(critter.pos, 0)) {
      return false; // critter can't go into this box
    }
    if (NE == null && bucket.length < MAX) {
      bucket.push(critter);
      return true;
    }

    if (NE == null) {
      subdivide(pool);
    }

    return (NE.insert(critter, pool)
      || NW.insert(critter, pool)
      || SE.insert(critter, pool)
      || SW.insert(critter, pool));
  }

  private inline function subdivide(pool:QuadPool) {
    NE = pool.next();
    NE.x = x + halfW / 2;
    NE.y = y + halfH / 2;
    NE.halfW = halfW / 2;
    NE.halfH = halfH / 2;

    NW = pool.next();
    NW.x = x - halfW / 2;
    NW.y = y + halfH / 2;
    NW.halfW = halfW / 2;
    NW.halfH = halfH / 2;

    SE = pool.next();
    SE.x = x + halfW / 2;
    SE.y = y - halfH / 2;
    SE.halfW = halfW / 2;
    SE.halfH = halfH / 2;

    SW = pool.next();
    SW.x = x - halfW / 2;
    SW.y = y - halfH / 2;
    SW.halfW = halfW / 2;
    SW.halfH = halfH / 2;

    var critter = bucket.pop();
    while (critter != null
      && (NE.insert(critter, pool)
        || NW.insert(critter, pool)
        || SE.insert(critter, pool)
        || SW.insert(critter, pool))) {
      critter = bucket.pop();
    }
    bucket.resize(0);
  }

  public inline function intersects(point:FastVector2, range:Float):Bool {
    final sMaxY = point.y + range;
    final sMinY = point.y - range;
    final sMaxX = point.x + range;
    final sMinX = point.x - range;

    final maxY = y + halfH;
    final minY = y - halfH;
    final maxX = x + halfW;
    final minX = x - halfW;

    if (sMaxX < minX || sMinX > maxX) {
      // separated on the X axis, cannot intersect
      return false;
    }

    if (sMaxY < minY || sMinY > maxY) {
      // separated on the Y axis, cannot intersect
      return false;
    }

    return true;
  }
}
