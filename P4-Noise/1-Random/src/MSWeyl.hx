package;

import haxe.Int64;

/**
  An implementation of the Middle-Square method of generating pseudo-random
  numbers. Values are augmented by a Weyl sequence at each iteration which
  allegedly gives good statistical distribution.
  Based on the paper https://arxiv.org/abs/1704.00358v5
**/
class MSWeyl {
  public static var instance:MSWeyl = null;

  public static function random():Float {
    if (instance == null) {
      instance = new MSWeyl();
    }
    final val:UInt = instance.next();
    return val / 0xFFFFFFFF;
  }

  var seed:Int64;
  var weyl:Int64;
  var x:Int64;

  public function new() {
    seed = Int64.make(0xb5ad4ece, 0xda1ce2a9);
    weyl = 0;
    x = 0;
  }

  public function next():Int {
    x *= x;
    weyl += seed;
    x += weyl;
    x = Int64.make(x.low, x.high);
    return x.low;
  }
}
