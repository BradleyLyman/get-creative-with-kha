package;

import haxe.ds.Map;

using Math;

enum abstract Symbol(String) {
  var F = "F";
  var f = "f";
  var left = "-";
  var right = "+";
  var push = "[";
  var pop = "]";
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

  public function buildMesh(buildSteps:Int):Mesh2d {
    final system = new LSystem();
    system.seed(seed);
    for (_ in 0...buildSteps) {
      system.apply(rules);
    }
    final turtle = new Turtle(10, angle);
    turtle.interpret(system.program);
    return turtle.mesh;
  }

  // @formatter:off

  public static final tree:Preset = {
    seed: [left, left, left, F],
    rules: [
      F => [F, push, right, F, pop, F, push, left, F, pop, F]
    ],
    steps: 5,
    angle: 25.7 * (Math.PI/180.0)
  };

  public static final tree2:Preset = {
    seed: [left, left, left, left, F],
    rules: [
      F => [F, push, right, F, pop, F, push, left, F, pop, push, F, pop]
    ],
    steps: 5,
    angle: 20.0 * (Math.PI/180.0)
  };

  public static final tree3:Preset = {
    seed: [left, left, left, left, F],
    rules: [
      F => [F, F, left, push, left, F, right, F, right, F, pop, right,
            push, right, F, left, F, left, F, pop]
    ],
    steps: 5,
    angle: 22.5 * (Math.PI/180.0)
  };

  // @formatter:on
}
