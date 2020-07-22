import kha.math.FastVector2;

using Math;
using support.FloatOps;
using support.VecOps;

@:structInit
class Settings {
  /** The critter's world dimensions **/
  public var size:FastVector2 = {x: 1000, y: 1000};

  /** The maximum acceleration a critter is allowed to experience **/
  public var maxAccel:Float = 1000;

  /** The maximum velocity a critter is allowed to achieve **/
  public var maxVel:Float = 250;

  /** The default integration step duration, in seconds **/
  public var integrationSeconds:Float = 1.0 / 60.0;

  /**
    Create a new instance of critter world settings with sensible defaults.
  **/
  public function new(
    size:FastVector2,
    ?maxAccel:Float = 1000,
    ?maxVel:Float = 250,
    ?integrationSeconds:Float = 1.0 / 60.0
  ) {
    this.size = size;
    this.maxAccel = maxAccel;
    this.maxVel = maxVel;
    this.integrationSeconds = integrationSeconds;
  }
}

/**
  The simulation world for a collection of critters.
**/
@:structInit
class CritterWorld {
  public var settings:Settings;
  public var critters:Array<Critter>;

  /* Create a new critter world. */
  public function new(settings:Settings) {
    this.settings = settings;
    critters = [];
  }

  /**
    Integrate the critter's position and velocity by assuming acceleration is
    constant for the provided time frame.
  **/
  public function integrate() {
    final dt = settings.integrationSeconds;
    for (critter in critters) {
      enforceBounds(critter);

      critter.acc.limit(settings.maxAccel);
      critter.vel = critter.vel.add(critter.acc.mult(dt));
      critter.vel.limit(settings.maxVel);
      critter.pos = critter.pos.add(critter.vel.mult(dt));
      critter.acc = critter.acc.mult(0.0);
    }
  }

  public function avoid(point:FastVector2) {
    for (critter in critters) {
      critter.avoid(point, 100, settings.maxVel / 2, settings.maxAccel);
    }
  }

  /**
    Keep the critter inside of the world.
  **/
  private function enforceBounds(critter:Critter) {
    final hardLimit = settings.size.mult(0.5);
    final softLimit = hardLimit.mult(0.95);
    critter.pos.x = critter.pos.x.clamp(-hardLimit.x, hardLimit.x);
    critter.pos.y = critter.pos.y.clamp(-hardLimit.y, hardLimit.y);

    final force = settings.maxAccel;
    if (critter.pos.x < -softLimit.x) {
      critter.steer({x: settings.maxVel, y: critter.vel.y}, force);
    } else if (critter.pos.x > softLimit.x) {
      critter.steer({x: -settings.maxVel, y: critter.vel.y}, force);
    }

    if (critter.pos.y < -softLimit.y) {
      critter.steer({x: critter.vel.x, y: settings.maxVel}, force);
    } else if (critter.pos.y > softLimit.y) {
      critter.steer({x: critter.vel.x, y: -settings.maxVel}, force);
    }
  }

  /**
    Spawn a single critter at the specified point with a random velocity.
  **/
  public function spawn(at:FastVector2) {
    critters.push({
      pos: at,
      vel: {
        x: Math.random().lerp(-settings.maxVel, settings.maxVel),
        y: Math.random().lerp(-settings.maxVel, settings.maxVel)
      }
    });
  }

  /**
    Clear all critters from the world.
  **/
  public function clear() {
    critters.resize(0);
  }
}
