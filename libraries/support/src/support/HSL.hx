package support;

using Math;
using support.FloatOps;

/**
  A structured representation for colors described by their hue, saturation,
  and lightness.
**/
@:structInit
class HSL {
  /**
    The color's hue. Angles from 0 - 360.
  **/
  public var h(default, set):Float;

  /**
    The color's saturation.
    1 - fully saturated
    0 - not saturated at all, greyscale determined by the lightness
  **/
  public var s(default, set):Float;

  /**
    The colors lightness.
    1 - the color is entirely white
    0 - the color is entirely black
    0.5 - the pure color
  **/
  public var l(default, set):Float;

  /**
    The color's alpha.
    0 - fully transparent
    1 - fully opaque
  **/
  public var a(default, set):Float;

  /* Create a new HSL color with sensible defaults. */
  public function new(
    h:Float,
    ?s:Float = 1.0,
    ?l:Float = 0.5,
    ?a:Float = 1.0
  ) {
    this.h = h;
    this.s = s;
    this.l = l;
    this.a = a;
  };

  /**
    Convert the HSL color to an RGBA color for use with shaders and kha
    builtins.
    @return kha.Color
  **/
  public function toColor():kha.Color {
    final C:Float = this.s * (1.0 - Math.abs(2.0 * this.l - 1));
    final H:Float = this.h / 60.0;
    final X:Float = C * (1 - Math.abs((H % 2.0) - 1));
    final triple = switch (H) {
      case _ if (H >= 0.0 && H < 1.0): {r: C, g: X, b: 0}
      case _ if (H >= 1.0 && H < 2.0): {r: X, g: C, b: 0}
      case _ if (H >= 2.0 && H < 3.0): {r: 0, g: C, b: X}
      case _ if (H >= 3.0 && H < 4.0): {r: 0, g: X, b: C}
      case _ if (H >= 4.0 && H < 5.0): {r: X, g: 0, b: C}
      case _ if (H >= 5.0 && H < 6.0): {r: C, g: 0, b: X}
      default: {r: 0, g: 0, b: 0};
    };
    final m = this.l - (C / 2.0);
    return kha.Color.fromFloats(
      triple.r + m,
      triple.g + m,
      triple.b + m,
      this.a
    );
  }

  private inline function set_h(h:Float):Float {
    if (h >= 0) {
      return this.h = h % 360;
    } else {
      final mod = h.abs() % 360;
      return this.h = 360 - mod;
    }
  }

  private inline function set_s(s:Float):Float {
    return this.s = s.clamp();
  }

  private inline function set_l(l:Float):Float {
    return this.l = l.clamp();
  }

  private inline function set_a(a:Float):Float {
    return this.a = a.clamp();
  }
}
