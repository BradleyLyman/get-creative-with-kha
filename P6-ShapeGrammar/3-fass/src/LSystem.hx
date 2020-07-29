package;

import haxe.ds.Map;

enum abstract Symbol(String) {
  var F = "F";
  var Fr = "Fr";
  var Fl = "Fl";
  var f = "f";
  var left = "-";
  var right = "+";
}

typedef Rules = Map<Symbol, Array<Symbol>>;

class LSystem {
  public var program:Array<Symbol>;

  public function new() {
    this.program = [];
  }

  public function seed(program:Array<Symbol>) {
    this.program = program.copy();
  }

  public function apply(rules:Rules) {
    var next:Array<Symbol> = [];
    for (symbol in program) {
      if (rules.exists(symbol)) {
        addAll(next, rules[symbol]);
      } else {
        next.push(symbol);
      }
    }
    program = next;
  }

  private function addAll(out:Array<Symbol>, toAdd:Array<Symbol>) {
    for (a in toAdd) {
      out.push(a);
    }
  }
}

@:structInit
class Preset {
  public final seed:Array<LSystem.Symbol>;
  public final rules:LSystem.Rules;
  public final steps:Int;
  public final angle:Float;

  public function new(
    seed:Array<LSystem.Symbol>,
    rules:LSystem.Rules,
    steps:Int,
    ?angle:Float
  ) {
    this.seed = seed;
    this.rules = rules;
    this.steps = steps;
    this.angle = angle != null ? angle : Math.PI / 2;
  }

  public function buildMesh():Mesh2d {
    final system = new LSystem();
    system.seed(seed);
    for (_ in 0...steps) {
      system.apply(rules);
    }
    final turtle = new Turtle(10, angle);
    turtle.interpret(system.program);
    return turtle.mesh;
  }

  // @formatter:off

  public static final kochIsland:Preset = {
    seed: [F, left, F, left, F, left, F],
    rules: [
      F => [F, left, F, right, F, right, F, F, left, F, left, F, right, F]
    ],
    steps: 3
  };

  public static final kochIslandQuadradic:Preset = {
    seed: [F, left, F, left, F, left, F],
    rules: [
      F => [F, right, F, F, left, F, F, left, F, left, F, right, F, right,
            F, F, left, F, left, F, right, F, right, F, F, right, F, F, left, F]
    ],
    steps: 2
  };

  public static final snowflakeQuadradic:Preset = {
    seed: [left, left, F],
    rules: [
      F => [F, right, F, left, F, left, F, right, F]
    ],
    steps: 4
  };

  public static final kochLakes:Preset = {
    seed: [F, right, F, right, F, right, F],
    rules: [
      F => [F, right, f, left, F, F, right, F, right, F, F, right, F, f, right,
            F, F, left, f, right, F, F, left, F, left, F, F, left, F, f, left,
            F, F, F],
      f => [f, f, f, f, f, f]
    ],
    steps: 2
  };

  public static final kochRects:Preset = {
    seed: [F, left, F, left, F, left, F],
    rules: [
      F => [F, F, left, F, right, F, left, F, left, F, F]
    ],
    steps: 3
  };

  public static final kochInside:Preset = {
    seed: [F, left, F, left, F, left, F],
    rules: [
      F => [F, F, left, F, left, left, F, left, F]
    ],
    steps: 4
  };

  public static final serpinskiGasket:Preset = {
    seed: [Fr],
    rules: [
      Fl => [Fr, right, Fl, right, Fr],
      Fr => [Fl, left, Fr, left, Fl]
    ],
    steps: 6,
    angle: Math.PI * (1.0/3.0)
  };

  public static final gosperCurve:Preset = {
    seed: [Fl],
    rules: [
      Fl => [Fl, right, Fr, right, right, Fr, left, Fl, left, left, Fl, Fl,
             left, Fr, right],
      Fr => [left, Fl, right, Fr, Fr, right, right, Fr, right , Fl, left, left,
             Fl, left, Fr]
    ],
    steps: 4,
    angle: Math.PI * (1.0 / 3.0)
  };

  public static final eCurve:Preset = {
    seed: [left, Fr],
    rules: [
      Fl => [Fl, Fl, left, Fr, left, Fr, right, Fl, right, Fl, left, Fr, left,
             Fr, Fl, right, Fr, right, Fl, Fl, Fr, left, Fl, right, Fr, right,
             Fl, Fl, right,Fr, left, Fl, Fr, left, Fr, left, Fl, right, Fl,
             right, Fr, Fr, left],
      Fr => [right, Fl, Fl, left, Fr, left, Fr, right, Fl, right, Fl, Fr, right,
             Fl, left, Fr, Fr, left, Fl, left, Fr, right, Fl, Fr, Fr, left, Fl,
             left, Fr, Fl, right, Fl, right, Fr, left, Fr, left, Fl, right, Fl,
             right, Fr, Fr]
    ],
    steps: 2
  };

  public static final dragonCurve:Preset = {
    seed: [Fl],
    rules: [
      Fl => [Fl, right, Fr, right],
      Fr => [left, Fl, left, Fr]
    ],
    steps: 10
  };

  // @formatter:on
}
