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
  A critter world index enables a nearest-neighbor query to find critters.
**/
interface Index {
  /**
    Retrieve all critters within a given distance of a point.
    @param point the query point
    @param distance how far away to include critters
    @param out Array<Critter>
      all critters with the threshold distance from the target are pushed into
      this array
  **/
  function nearby(point:FastVector2, distance:Float, out:Array<Critter>):Void;
}

/**
  The simulation world for a collection of critters.
**/
@:structInit
class CritterWorld {
  public var settings:Settings;
  public var critters:Array<Critter>;

  public var index(default, null):Index;

  private var binLatticeIndex:BinLatticeIndex;
  private var pointQuadtreeIndex:PointQuadtreeIndex;

  /* Create a new critter world. */
  public function new(settings:Settings) {
    this.settings = settings;
    critters = [];
    binLatticeIndex = new BinLatticeIndex(50);
    pointQuadtreeIndex = new PointQuadtreeIndex();
    index = pointQuadtreeIndex;
  }

  /**
    Integrate the critter's position and velocity by assuming acceleration is
    constant for the provided time frame.
  **/
  public function integrate() {
    for (critter in critters) {
      enforceBounds(critter);
    }

    index = buildIndex();

    final dt = settings.integrationSeconds;
    final nearby:Array<Critter> = [];
    for (critter in critters) {
      // lookup all critters within 50 units of this one
      nearby.resize(0); // reuse the nearby array to lessen GC pressure
      index.nearby(critter.pos, 50, nearby);

      // Apply the flocking algorithm forces radii and multipliers are
      // arbitrarily chosen based on what looks good
      critter.align(nearby, settings.maxVel, settings.maxAccel * 0.75);
      critter.seekCenter(nearby, 50, settings.maxVel, settings.maxAccel * 0.5);
      critter.avoidAll(nearby, 35, settings.maxVel, settings.maxAccel);

      // kinematic integration (euler's method)
      critter.acc.limit(settings.maxAccel);
      critter.vel.x += critter.acc.x * dt;
      critter.vel.y += critter.acc.y * dt;
      critter.vel.limit(settings.maxVel);
      critter.pos.x += critter.vel.x * dt;
      critter.pos.y += critter.vel.y * dt;
      critter.acc.x = 0;
      critter.acc.y = 0;
    }
  }

  private function buildIndex():Index {
    // switch with this line to see the proof of concept index
    // performance degrades with the square of the number of critters
    // return new BruteForceIndex(critters);

    // switch to this line to see the simplest implementation for the bin
    // lattice index. Creating it each frame introduces GC churn which will
    // cause periodic stuttering
    // return new BinLatticeIndex(critters, 50, settings.size);

    // Reuse the binlattice index, rather than replace it. This allows internal
    // buffers to be resized instead of replaced and should (hopefully) have
    // less GC overhead.
    // binLatticeIndex.flush(critters, settings.size);
    // return binLatticeIndex;

    // Uncomment to use the Point Quadtree implementation.
    // This simple quadtree outperforms the brute force index, but is still
    // significantly less performant than the tuned BinLattice index.
    pointQuadtreeIndex.insertAll(critters);
    return pointQuadtreeIndex;
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
    Make all of the critters in the world flee from a single point in the
    world.
  **/
  public function avoid(point:FastVector2, radius:Float) {
    for (critter in critters) {
      critter.avoid(point, radius, settings.maxVel, settings.maxAccel);
    }
  }

  /**
    Spawn n critters at random positions and velocities within the world.
    @param N the number of critters to spawn
  **/
  public function respawn(N:Int) {
    critters.resize(0); // empty the world

    // spawn the critters
    for (_ in 0...N) {
      critters.push({
        pos: {
          x: Math.random().lerp(-settings.size.x / 2, settings.size.x / 2),
          y: Math.random().lerp(-settings.size.y / 2, settings.size.y / 2)
        },
        vel: {
          x: Math.random().lerp(-settings.maxVel, settings.maxVel),
          y: Math.random().lerp(-settings.maxVel, settings.maxVel)
        }
      });
    }
  }
}
