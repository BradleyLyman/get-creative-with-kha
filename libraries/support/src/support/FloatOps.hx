package support;

using Math;

class FloatOps {
  /**
    Clamp this value betweenh a minimum and maximum value.
  **/
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

  /**
    Use this value to interpolate between a start and end value.
    @param t
    @param start the value returned when the input is 0
    @param end the value returned when the input is 1
  **/
  public static inline function lerp(t:Float, start:Float, end:Float):Float {
    return (1.0 - t) * start + t * end;
  }

  /**
    Format a float to have a fixd set of significant figures.
    @param t the actual number
    @param sig the significant figure count
    @return a float rounded to the requested significant figures
  **/
  public static inline function fmt(t:Float, sig:Int = 3):Float {
    final mult = 10.pow(sig).round();
    final snapped = (t * mult).round() / mult;
    return snapped;
  }
}
