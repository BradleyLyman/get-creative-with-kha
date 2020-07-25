package index;

import kha.math.FastVector2;

using support.VecOps;

/**
  The Point Quadtree Index is a unbounded 'binary' tree of points. Each node
  contains a single point which divides space into 4 quads. The advantage of
  this index is that it scales logarithmically (unlike the brute force index)
  and doesn't require careful tuning (unlike the bin lattice index).

  The principle disadvantage is that the tree is highly sensative to the
  insertion order for critters. This means that it will occasionally degrade
  in performance due to how critters are arranged on screen and in memory.
  This could be mitigated by sorting the critters before inserting them, but
  then the additional cost of a sort must be paid.

  Finally, even in the best case, this index *typically* checks more critters
  than a well tuned bin lattice index.
**/
class PointQuadtreeIndex implements CritterWorld.Index {
  var pool:Pool;
  var root:Node;
  var frontier:Array<Node>;

  public function new() {
    root = null;
    frontier = [];
    pool = new Pool();
  }

  public function insertAll(critters:Array<Critter>) {
    pool.reset(critters.length);
    root = pool.next();
    root.critter = critters[0];
    for (i in 1...critters.length) {
      root.insert(critters[i], pool);
    }
  }

  public function nearby(
    point:FastVector2,
    range:Float,
    results:Array<Critter>
  ) {
    frontier.resize(0);
    push(root);

    while (frontier.length > 0) {
      final current = frontier.pop();

      final length = current.critter.pos.sub(point).sqrLen();
      if (length <= range * range) {
        results.push(current.critter);
        push(current.NW);
        push(current.NE);
        push(current.SW);
        push(current.SE);
      } else {
        final left = point.x - range;
        final right = point.x + range;
        final top = point.y + range;
        final bottom = point.y - range;
        if (right < current.critter.pos.x || left < current.critter.pos.x) {
          if (top < current.critter.pos.y || bottom < current.critter.pos.y) {
            push(current.SW);
          }
          if (bottom >= current.critter.pos.y || top >= current.critter.pos.y) {
            push(current.NW);
          }
        }

        if (left >= current.critter.pos.x || right >= current.critter.pos.x) {
          if (top < current.critter.pos.y || bottom < current.critter.pos.y) {
            push(current.SE);
          }
          if (bottom >= current.critter.pos.y || top >= current.critter.pos.y) {
            push(current.NE);
          }
        }
      }
    }
  }

  private inline function push(node:Node) {
    if (node != null) {
      frontier.push(node);
    }
  }
}

/**
  Use a pool of nodes to build the tree. This prevents uneeded GC pressure
  when the tree is rebuilt on each iteration.
**/
class Pool {
  var current = 0;
  var nodes:Array<Node> = [];

  public inline function new() {};

  public function reset(hint:Int) {
    for (node in nodes) {
      node.reset();
    }
    while (nodes.length < hint) {
      nodes.push(new Node());
    }
    current = 0;
  }

  public function next():Node {
    if (current >= nodes.length) {
      nodes.push(new Node());
    }
    return nodes[current++];
  }
}

class Node {
  public var NW:Node = null;
  public var NE:Node = null;
  public var SW:Node = null;
  public var SE:Node = null;
  public var critter:Critter = null;

  static var frontier = new Array<Node>();

  public inline function new() {}

  public inline function reset() {
    NW = null;
    NE = null;
    SW = null;
    SE = null;
    critter = null;
  }

  public function insert(toAdd:Critter, pool:Pool) {
    if (toAdd.pos.x < critter.pos.x) {
      if (toAdd.pos.y < critter.pos.y) {
        insertSW(toAdd, pool);
      } else {
        insertNW(toAdd, pool);
      }
    } else {
      if (toAdd.pos.y < critter.pos.y) {
        insertSE(toAdd, pool);
      } else {
        insertNE(toAdd, pool);
      }
    }
  }

  public inline function insertNW(toAdd:Critter, pool:Pool) {
    if (NW == null) {
      NW = pool.next();
      NW.critter = toAdd;
    } else {
      NW.insert(toAdd, pool);
    }
  }

  public inline function insertNE(toAdd:Critter, pool:Pool) {
    if (NE == null) {
      NE = pool.next();
      NE.critter = toAdd;
    } else {
      NE.insert(toAdd, pool);
    }
  }

  public inline function insertSW(toAdd:Critter, pool:Pool) {
    if (SW == null) {
      SW = pool.next();
      SW.critter = toAdd;
    } else {
      SW.insert(toAdd, pool);
    }
  }

  public inline function insertSE(toAdd:Critter, pool:Pool) {
    if (SE == null) {
      SE = pool.next();
      SE.critter = toAdd;
    } else {
      SE.insert(toAdd, pool);
    }
  }
}
