package support;

import kha.math.FastVector2;

class VecOps {
  /**
    Clamp the vector's magnitude to the provided length.
    No-op if the vector is already shorter than the provided length.
  **/
  public static inline function limit(vec:FastVector2, length:Float) {
    if (sqrLen(vec) > length * length) {
      vec.length = length;
    }
  }

  /* Compute the squared length of the vector. (no sqrt operation) */
  public static inline function sqrLen(vec:FastVector2):Float {
    return vec.x * vec.x + vec.y * vec.y;
  }
}
