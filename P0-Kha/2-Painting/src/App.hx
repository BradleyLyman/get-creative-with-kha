package;

import kha.System;
import kha.graphics2.Graphics;
import kha.graphics4.Usage;
import kha.Scaler;
import kha.Image;
import kha.math.FastVector2;
import kha.input.Mouse;
import kha.Framebuffer;

/**
  Use the mouse to draw persistent graphics on the screen.
**/
class App {
  private var t:Float = 0.0;
  private var mouse:FastVector2 = {x: 0, y: 0};
  private var backbuffer:Image;

  public function new() {
    Mouse.get().notify(null, null, setMouse, null);
    backbuffer = Image.createRenderTarget(
      System.windowWidth(),
      System.windowHeight(),
      Usage.DynamicUsage
    );
  }

  public function onResize(w:Int, h:Int):Void {
    trace('resized $w, $h');
    final newBuf = Image.createRenderTarget(w, h, Usage.DynamicUsage);
    Scaler.scale(backbuffer, newBuf, RotationNone);
    backbuffer = newBuf;
  }

  /**
    The Kha scheduler attempts to run this every 16 milliseconds so assume a
    fixed time step.
  **/
  public function update() {}

  /**
    The kha scheduler invokes this every time a frame is ready to be rendered.
    There is only one window for this app so the framebuffer array will always
    have exactly 1 frame.
  **/
  public function render(framebuffers:Array<Framebuffer>):Void {
    syncBackbuffer(framebuffers[0]);
    drawGraphics(backbuffer.g2);
    showBackbuffer(framebuffers[0]);
  }

  private function drawGraphics(graphics:Graphics) {
    final halfWidth = 10;
    graphics.begin(false); // don't clear
    graphics.drawRect(
      mouse.x - halfWidth,
      mouse.y - halfWidth,
      halfWidth * 2,
      halfWidth * 2,
      5
    );
    graphics.end();
  }

  private function showBackbuffer(screen:Framebuffer) {
    screen.g2.begin();
    Scaler.scale(backbuffer, screen, RotationNone);
    screen.g2.end();
  }

  /**
    Some plateforms (notably, html5) do not call window.notifyResize when the
    framebuffer changes. This method compares dimensions and upscales/downscales
    the backbuffer accordingly.

    Why doesn't onResize get called for the html5 target? Answer, because it
    doesn't actually make much sense to do so. The canvas can be styled with
    css, so it's fully possible that the window resizes but the canvas doesn't.
    Or vice versa.

    Thus, for the browser, this seems like a viable option for a continuous
    fullscreen capture without scaling.
  **/
  private function syncBackbuffer(screen:Framebuffer) {
    if (backbuffer.width != screen.width || backbuffer.height != screen.height) {
      onResize(screen.width, screen.height);
    }
  }

  private function setMouse(x:Int, y:Int, mx:Int, my:Int) {
    mouse.x = x;
    mouse.y = y;
  }
}
