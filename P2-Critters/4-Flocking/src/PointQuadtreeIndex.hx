package;

import kha.math.FastVector2;

using support.VecOps;

class PointQuadtreeIndex implements CritterWorld.Index {
  var pool:Pool;
  var root:Node;

  public function new() {
    root = null;
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
    if (root == null) {
      return;
    } else {
      root.nearby(point, range, results);
    }
  }

  public function insert(critter:Critter) {
    if (root == null) {
      root = new Node();
      root.critter = critter;
    } else {
      root.insert(critter, pool);
    }
  }
}

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

  public inline function new() {}

  public inline function reset() {
    NW = null;
    NE = null;
    SW = null;
    SE = null;
    critter = null;
  }

  public function nearby(
    point:FastVector2,
    range:Float,
    results:Array<Critter>
  ) {
    final length = critter.pos.sub(point).sqrLen();
    if (length <= range * range) {
      results.push(critter);
      nearbyNW(point, range, results);
      nearbyNE(point, range, results);
      nearbySW(point, range, results);
      nearbySE(point, range, results);
    } else {
      if (point.x + range < critter.pos.x || point.x - range < critter.pos.x) {
        if (point.y + range < critter.pos.y || point.y
          - range < critter.pos.y) {
          nearbySW(point, range, results);
        }
        if (point.y - range >= critter.pos.y
          || point.y + range >= critter.pos.y) {
          nearbyNW(point, range, results);
        }
      }

      if (point.x - range >= critter.pos.x || point.x
        + range >= critter.pos.x) {
        if (point.y + range < critter.pos.y || point.y
          - range < critter.pos.y) {
          nearbySE(point, range, results);
        }
        if (point.y - range >= critter.pos.y
          || point.y + range >= critter.pos.y) {
          nearbyNE(point, range, results);
        }
      }
    }
  }

  private inline function nearbyNW(point, range, results) {
    if (NW != null)
      NW.nearby(point, range, results);
  }

  private inline function nearbyNE(point, range, results) {
    if (NE != null)
      NE.nearby(point, range, results);
  }

  private inline function nearbySW(point, range, results) {
    if (SW != null)
      SW.nearby(point, range, results);
  }

  private inline function nearbySE(point, range, results) {
    if (SE != null)
      SE.nearby(point, range, results);
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
