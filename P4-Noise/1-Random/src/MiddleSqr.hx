package;

import haxe.Int64;

/**
  An implementation of the Middle-Square method of generating pseudo-random
  numbers. This is intended as a demonstration of the old method because it's
  simplicity makes it friendly to experiment with.

  https://en.wikipedia.org/wiki/Middle-square_method
**/
class MiddleSqr {
  public static var instance = null;

  public static function random():Float {
    if (instance == null) {
      instance = new MiddleSqr();
    }
    final val:UInt = instance.next();
    return val / 0xFFFFFFFF;
  }

  var x:Int64;

  public function new(?seed:Int64) {
    x = seed != null ? seed : Int64.make(0xb5ad4ece, 0xda1ce2a9);
  }

  public function next():Int {
    x *= x;
    x = Int64.make(x.low, x.high);
    return x.low;
  }
}
