package;

import kha.math.FastVector2;
import CritterWorld.Index;

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
