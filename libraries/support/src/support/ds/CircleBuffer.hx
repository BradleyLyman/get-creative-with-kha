package support.ds;

import haxe.ds.Vector;

/**
  A rudimentary circle buffer implementation.

  Rudimentary because the buffer is assumed to always be entirely full and
  repeated calls to 'push' just change where values are written.

  It could be faster, it could have more features, but that'll happen when it
  needs to be faster or the features are needed.
**/
@:structInit
class CircleBuffer<T> {
  private var cursor:Int;
  private var buffer:Vector<T>;

  public var length(get, null):Int;

  /** Create a new buffer with a fixed length, and all elements initialized **/
  public function new(init:T, maxLen:Int) {
    buffer = new Vector<T>(maxLen);
    cursor = 0;
    for (i in 0...buffer.length) {
      buffer[i] = init;
    }
  }

  /* push a new value, invalidates any existing iterators */
  public function push(val:T) {
    buffer[cursor] = val;
    inc();
  }

  /* iterate the buffer from most recent values to least recent values */
  public function iterator():Iterator<T> {
    return new NewToOldIterator<T>(this);
  }

  /* increment the cursor, wrap if it goes past the end */
  private function inc() {
    cursor = (cursor + 1) % buffer.length;
  }

  /* the buffer's length */
  private function get_length():Int {
    return buffer.length;
  }
}

class NewToOldIterator<T> {
  private var cb:CircleBuffer<T>;
  private var myCursor:Int;
  private var steps:Int;

  public function new(cb:CircleBuffer<T>) {
    @:privateAccess
    this.myCursor = cb.cursor;
    this.cb = cb;
    dec();
    steps = 0;
  }

  public function hasNext():Bool {
    // invalid if the cursor moves
    @:privateAccess
    return steps < cb.buffer.length;
  }

  public function next():T {
    @:privateAccess
    final val = cb.buffer[myCursor];
    dec();
    steps++;
    return val;
  }

  private function dec() {
    myCursor -= 1;
    if (myCursor < 0) {
      @:privateAccess
      myCursor = cb.buffer.length - 1;
    }
  }
}
