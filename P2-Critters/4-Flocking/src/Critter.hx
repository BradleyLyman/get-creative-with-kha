import kha.graphics2.Graphics;
import kha.math.FastVector2;

using support.FloatOps;
using support.VecOps;

/**
  A critter is a stateful agent which knows how to render itself.
  Critters track their own position, velocity, and acceleration, and provide
  methods which adjust these properties to make the critter seek a point,
  avoid neighbors, and other interesting behavior.

  Flocking is the combination of the three behaviors:
   - align
   - avoidAll
   - seekCenter
**/
@:structInit
class Critter {
  public var pos:FastVector2;
  public var vel:FastVector2;
  public var acc:FastVector2;

  /**
    Create a new critter with the provided position, velocity, and acceleration.
    Coordinates are relative to the world size.
  **/
  public inline function new(pos:FastVector2, vel:FastVector2) {
    this.pos = pos;
    this.vel = vel;
    this.acc = {x: 0, y: 0};
  }

  /**
    Draw the critter to the screen.
  **/
  public function draw(g2:Graphics, size:Float = 10) {
    var lookX:Float = 0;
    var lookY:Float = 1;
    if (vel.sqrLen() != 0) {
      final len = vel.length;
      lookX = vel.x / len;
      lookY = vel.y / len;
    }

    final leftX = pos.x - lookY * size * 0.25;
    final leftY = pos.y + lookX * size * 0.25;

    final rightX = pos.x + lookY * size * 0.25;
    final rightY = pos.y - lookX * size * 0.25;

    final frontX = pos.x + lookX * size;
    final frontY = pos.y + lookY * size;

    g2.fillTriangle(leftX, leftY, rightX, rightY, frontX, frontY);
  }

  /**
    Accelerate the critter so that it's target velocity adjusts towards the
    desired velocity.
    @param desiredVel The desired velocity.
    @param force How hard the critter will try to adjust it's velocity to match
                 the desired velocity.
  **/
  public inline function steer(desiredVel:FastVector2, force:Float) {
    final delta = desiredVel.sub(vel);
    final adjusted = delta.normalized().mult(force);
    acc.x += adjusted.x;
    acc.y += adjusted.y;
  }

  /**
    Adjust the critter's acceleration so that it approaches a target point.
    The critter will attempt to slow down as it approaches the point.

    @param target the target the critter should seek
    @param approachThreshold
      the distance where the critter will start to slow down
    @param approachSpeed
      the critter's approach speed, e.g. how fast the critter would like to
      zoom towards the target point
    @param force
      how hard the critter will push to try and reach the approachSpeed
  **/
  public inline function seek(
    target:FastVector2,
    approachThreshold:Float,
    approachSpeed:Float,
    force:Float
  ) {
    final direction = target.sub(pos); // point from position toward the target
    final length = direction.length;
    if (length == 0) {
      return;
    }
    final normDist:Float = length / approachThreshold;
    final clampedDist = normDist.clamp(0, 1);
    final seekSpeed = clampedDist.lerp(0, approachSpeed);
    final seekVelocity = direction.mult(seekSpeed / length);
    steer(seekVelocity, force);
  }

  /**
    Adjust the critter's acceleration so that it avoids a target point.
    The critter will try to run away faster as it gets closer to the target
    point. But, the critter will not experience any force if it's outside the
    repulse threshold.

    @param target the point the critter will try to avoid
    @param repulseThreshold
      outside this radius the critter will not experience any force
    @param repulseSpeed
      the maximum speed the critter will attempt to reach while fleeing the
      target
    @param force how hard the critter will push to reach the repulseSpeed
  **/
  public function avoid(
    target:FastVector2,
    repulseThreshold:Float,
    repulseSpeed:Float,
    force:Float
  ) {
    final direction = pos.sub(target); // point from the target toward position
    final length = direction.length;
    if (length > repulseThreshold) {
      return; // apply no force, the point is already too far away
    }
    final seekVelocity = direction.mult(repulseSpeed / length);
    steer(seekVelocity, force);
  }

  /**
    A specialized avoid function which gives good behavior when trying to
    avoid lots of nearby targets.
    @param targets A set of critters which this critter will try to avoid.
    @param repulseThreshold
      outside this radius the critter will not experience any force
    @param repulseSpeed
      the maximum speed the critter will attempt to reach while fleeing the
      target
    @param force how hard the critter will push to reach the repulse speed
  **/
  public function avoidAll(
    targets:Array<Critter>,
    repulseThreshold:Float,
    repulseSpeed:Float,
    force:Float
  ) {
    var targetsAvoided:Int = 0;
    var runDirection:FastVector2 = {x: 0, y: 0};
    for (target in targets) {
      final diff = pos.sub(target.pos);
      final dist = diff.length;
      if (dist > repulseThreshold || dist == 0) {
        continue;
      }
      final weight = (repulseThreshold / dist);
      runDirection.x += (diff.x / dist) * weight * weight;
      runDirection.y += (diff.y / dist) * weight * weight;
      targetsAvoided += 1;
    }
    if (targetsAvoided > 0) {
      final averageDirection = runDirection.div(targetsAvoided);
      final targetVelocity = averageDirection.normalized().mult(repulseSpeed);
      steer(targetVelocity, force);
    }
  }

  /**
    Seek the center of mass of all of the included targets.
    @param targets
      a set of critters which this critter will try to center itself within
    @param approachThreshold
      the distance within which the critter will slow while it approaches the
      center
    @param approachSpeed
      the maximum speed the critter will attempt to reach while seeking the
      center
    @param force how hard the critter will push to reach the attraction speed
  **/
  public function seekCenter(
    targets:Array<Critter>,
    approachThreshold:Float,
    approachSpeed:Float,
    force:Float
  ) {
    var targetsSought = 0;
    var sum:FastVector2 = {x: 0, y: 0};
    for (target in targets) {
      if (target == this) {
        continue;
      }
      targetsSought += 1;
      sum.x += target.pos.x;
      sum.y += target.pos.y;
    }
    if (targetsSought > 0) {
      final center = sum.div(targetsSought);
      seek(center, approachThreshold, approachSpeed, force);
    }
  }

  /**
    Compute the average velocity of all targets, then steer this critter's
    velocity to be aligned with the average.
  **/
  public function align(
    targets:Array<Critter>,
    alignedSpeed:Float,
    force:Float
  ) {
    if (targets.length == 0) {
      return;
    }
    var totalVel:FastVector2 = {x: 0, y: 0};
    for (target in targets) {
      totalVel.x += target.vel.x;
      totalVel.y += target.vel.y;
    }
    final avgVel = totalVel.div(targets.length);
    final targetVel = avgVel.normalized().mult(alignedSpeed);
    steer(targetVel, force);
  }
}
