package;

import kha.math.FastVector2;

@:structInit
class Signal {
  public var frequency:Float;
  public var phase:Float;
  public var amplitude:Float;

  public function new(frequency:Float, phase:Float, amplitude:Float) {
    this.frequency = frequency;
    this.phase = phase;
    this.amplitude = amplitude;
  }

  public function sample(time:Float):FastVector2 {
    return {
      x: Math.cos((time * frequency) + phase) * amplitude,
      y: Math.sin((time * frequency) + phase) * amplitude
    };
  }
}
