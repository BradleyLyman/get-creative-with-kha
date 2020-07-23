package;

import kha.math.FastVector2;
import CritterWorld.Index;

/**
  This index does no preprocessing on the critter array and therefore each
  query requires checking every critter.

  It is included as a demonstration of how simple the concept of the index is,
  but it makes the full simulation's execution speed scale like
  O(critters.length * critters.length).
**/
class BruteForceIndex implements Index {
  final critters:Array<Critter>;

  public function new(critters:Array<Critter>) {
    this.critters = critters;
  }

  /**
    Retrieve all critters within a given distance of a point.
    @param point the query point
    @param distance how far away to include critters
    @return Array<Critter>
      all critters with the threshold distance from the target
  **/
  public function nearby(point:FastVector2, distance:Float):Array<Critter> {
    function isNearby(critter:Critter):Bool {
      return critter.pos.sub(point).length <= distance;
    }
    return critters.filter(isNearby);
  }
}
