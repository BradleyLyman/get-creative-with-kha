package;

import haxe.ds.GenericStack;
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
      Node.nearby(root, point, range, results);
      // root.nearby(point, range, results);
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

  static var frontier = new Array<Node>();

  public inline function new() {}

  public inline function reset() {
    NW = null;
    NE = null;
    SW = null;
    SE = null;
    critter = null;
  }

  public static function nearby(
    root:Node,
    point:FastVector2,
    range:Float,
    results:Array<Critter>
  ) {
    frontier.resize(0);
    frontier.push(root);

    while (frontier.length > 0) {
      final current = frontier.pop();

      final length = current.critter.pos.sub(point).sqrLen();
      if (length <= range * range) {
        results.push(current.critter);
        if (current.NW != null)
          frontier.push(current.NW);
        if (current.NE != null)
          frontier.push(current.NE);
        if (current.SW != null)
          frontier.push(current.SW);
        if (current.SE != null)
          frontier.push(current.SE);
      } else {
        if (point.x + range < current.critter.pos.x
          || point.x - range < current.critter.pos.x) {
          if (point.y + range < current.critter.pos.y
            || point.y - range < current.critter.pos.y) {
            if (current.SW != null)
              frontier.push(current.SW);
          }
          if (point.y - range >= current.critter.pos.y
            || point.y + range >= current.critter.pos.y) {
            if (current.NW != null)
              frontier.push(current.NW);
          }
        }

        if (point.x - range >= current.critter.pos.x
          || point.x + range >= current.critter.pos.x) {
          if (point.y + range < current.critter.pos.y
            || point.y - range < current.critter.pos.y) {
            if (current.SE != null)
              frontier.push(current.SE);
          }
          if (point.y - range >= current.critter.pos.y
            || point.y + range >= current.critter.pos.y) {
            if (current.NE != null)
              frontier.push(current.NE);
          }
        }
      }
    }
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
