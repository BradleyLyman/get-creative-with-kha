import kha.math.FastMatrix3;
import kha.math.FastVector2;

/**
  All of the configuration and tools for managing the space where critters
  act.
**/
@:structInit
class CritterWorld {
  /* The critter's world dimensions */
  public var size:FastVector2 = {x: 1000, y: 1000};

  /* The maximum acceleration a critter is allowed to experience */
  public var maxAccel:Float = 1000;

  /* The maximum velocity a critter is allowed to achieve */
  public var maxVel:Float = 250;

  /* The default integration step duration, in seconds */
  public var integrationSeconds:Float = 1.0 / 60.0;

  /* Create a new critter world. */
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

  public function spawn(at:FastVector2):Critter {
    return {world: this, pos: at};
  }

  /**
    Reset the critter world's aspect ratio.
    Called automatically when generating the projection.
  **/
  public function setAspect(widthOverHeight:Float) {
    size.x = widthOverHeight * size.y;
  }

  /**
    Create a projection matrix for the current world, mapping into a space with
    new dimensions W and H.
  **/
  public function orthoProjection(W:Float, H:Float):FastMatrix3 {
    setAspect(W / H);
    final bx = size.x / 2;
    final by = size.y / 2;

    // @formatter:off
    return new FastMatrix3(
      W/(2*bx), 0, W /2,
      0, -H/(2*by), H/2,
      0, 0, 1
    );
    // @formatter:on
  }
}
