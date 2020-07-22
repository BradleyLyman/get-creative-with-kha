import kha.graphics2.Graphics;
import kha.math.FastVector2;

using support.FloatOps;
using support.VecOps;

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
    final up:FastVector2 = {x: 0, y: 1};
    final look:FastVector2 = vel.sqrLen() != 0 ? vel.normalized() : up;
    final look90:FastVector2 = {x: -look.y, y: look.x};

    final left = pos.add(look90.mult(size * 0.25));
    final right = pos.sub(look90.mult(size * 0.25));
    final front = pos.add(look.mult(size));
    final strength = 3;

    g2.drawLine(left.x, left.y, right.x, right.y, strength);
    g2.drawLine(right.x, right.y, front.x, front.y, strength);
    g2.drawLine(front.x, front.y, left.x, left.y, strength);
  }

  /**
    Accelerate the critter so that it's target velocity adjusts towards the
    desired velocity.
    @param desiredVel The desired velocity.
    @param force How hard the critter will try to adjust it's velocity to match
                 the desired velocity.
  **/
  public function steer(desiredVel:FastVector2, force:Float) {
    final delta = desiredVel.sub(vel);
    final adjusted = delta.normalized().mult(force);
    acc = acc.add(adjusted);
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
  public function seek(
    target:FastVector2,
    approachThreshold:Float,
    approachSpeed:Float,
    force:Float
  ) {
    final direction = target.sub(pos); // point from position toward the target
    final normDist:Float = direction.length / approachThreshold;
    final clampedDist = normDist.clamp(0, 1);
    final seekSpeed = clampedDist.lerp(0, approachSpeed);
    final seekVelocity = direction.normalized().mult(seekSpeed);
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
}
