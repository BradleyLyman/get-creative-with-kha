package support;

class FloatOps {
  /* Clamp the number into the specified range of values. */
  public static inline function clamp(
    t:Float,
    min:Float = 0,
    max:Float = 1
  ):Float {
    if (t < min) {
      return min;
    }
    if (t > max) {
      return max;
    }
    return t;
  }

  /* Linear interpolation between min and max. */
  public static inline function lerp(t:Float, start:Float, end:Float):Float {
    return (1.0 - t) * start + t * end;
  }
}
