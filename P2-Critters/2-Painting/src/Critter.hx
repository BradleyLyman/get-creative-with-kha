import support.HSL;
import kha.graphics2.Graphics;
import kha.math.FastVector2;
import support.ds.CircleBuffer;

using support.VecOps;
using support.FloatOps;

@:structInit
class Critter {
  public var world:CritterWorld;
  public var pos:FastVector2;
  public var vel:FastVector2;
  public var acc:FastVector2;
  public var hsl:HSL;

  private var tail:CircleBuffer<FastVector2>;

  /**
    Create a new critter with the provided position, velocity, and acceleration.
    Coordinates are relative to the world size.
  **/ public inline function new(
    world:CritterWorld,
    pos:FastVector2,
    ?vel:FastVector2,
    ?acc:FastVector2,
    ?hsl:HSL
  ) {
    this.world = world;
    this.pos = pos != null ? pos : {x: 0, y: 0};
    this.vel = vel != null ? vel : {x: 0, y: 0};
    this.acc = acc != null ? acc : {x: 0, y: 0};
    this.hsl = hsl != null ? hsl : {h: 0, s: 0, l: 1};
    this.tail = new CircleBuffer<FastVector2>(this.pos, 15);
  }

  /**
    Integrate the critter's position and velocity by assuming acceleration is
    constant for the provided time frame.
  **/
  public function integrate() {
    final dt = world.integrationSeconds;
    enforceLimits();
    vel = vel.add(acc.mult(dt));
    pos = pos.add(vel.mult(dt));
    acc = acc.mult(0.0);

    tail.push(pos);
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

    hsl.l = 0.5;
    hsl.a = 1.0;
    g2.color = hsl.toColor();
    g2.drawLine(left.x, left.y, right.x, right.y, strength);
    g2.drawLine(right.x, right.y, front.x, front.y, strength);
    g2.drawLine(front.x, front.y, left.x, left.y, strength);
  }

  public function drawTail(g2:Graphics, maxSize:Float = 10) {
    final tailLength = tail.length;
    var count = 0;
    var last = pos;
    for (point in tail) {
      final norm = count++ / tailLength;
      hsl.l = norm.lerp(0.7, 0.1);
      g2.color = hsl.toColor();
      g2.drawLine(last.x, last.y, point.x, point.y, norm.lerp(1.0, maxSize));
      last = point;
    }
  }

  /**
    Steer the critter towards a target.
    @param desiredVel The desired velocity.
    @param force How hard the critter will try to adjust it's velocity to match
                 the desired velocity.
  **/
  public function steer(desiredVel:FastVector2, ?force:Float) {
    force = force == null ? world.maxAccel : force;
    final delta = desiredVel.sub(vel);
    final adjusted = delta.normalized().mult(force);
    acc = acc.add(adjusted);
  }

  /**
    Keep the critter inside of the world.
  **/
  private function enforceLimits() {
    vel.limit(world.maxVel);
    acc.limit(world.maxAccel);

    final hardLimit = world.size.mult(0.5);
    final softLimit = hardLimit.mult(0.95);
    pos.x = pos.x.clamp(-hardLimit.x, hardLimit.x);
    pos.y = pos.y.clamp(-hardLimit.y, hardLimit.y);

    if (pos.x < -softLimit.x) {
      steer({x: world.maxVel, y: vel.y});
    } else if (pos.x > softLimit.x) {
      steer({x: -world.maxVel, y: vel.y});
    }

    if (pos.y < -softLimit.y) {
      steer({x: vel.x, y: world.maxVel});
    } else if (pos.y > softLimit.y) {
      steer({x: vel.x, y: -world.maxVel});
    }
  }
}
