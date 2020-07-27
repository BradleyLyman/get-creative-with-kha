package;

import kha.input.Mouse;
import support.Projection;
import kha.math.FastMatrix3;
import kha.math.FastVector2;
import kha.Color;
import kha.graphics4.VertexStructure;
import kha.Shaders;
import kha.graphics4.PipelineState;
import kha.Image;
import kha.Framebuffer;

using Math;

/**
  Demonstrate the water ripple effect described here:
  https://web.archive.org/web/20160418004149/http://freespace.virgin.net/hugo.elias/graphics/x_water.htm
**/
class App {
  private var present:Image;
  private var lastFrame:Image;
  private final drawWater:PipelineState;
  private final integrate:PipelineState;
  private var scale:Float = 1.0;

  private var pressed:Bool = false;
  private var mousePos:FastVector2 = {x: 0, y: 0};
  private var invProj:FastMatrix3 = FastMatrix3.identity();

  public function new() {
    present = Image.createRenderTarget(1, 1, RGBA128);
    lastFrame = Image.createRenderTarget(1, 1, RGBA128);

    drawWater = new PipelineState();
    drawWater.inputLayout = [new VertexStructure()];
    drawWater.vertexShader = Shaders.painter_image_vert;
    drawWater.fragmentShader = Shaders.painter_water_frag;
    drawWater.compile();

    integrate = new PipelineState();
    integrate.inputLayout = [new VertexStructure()];
    integrate.vertexShader = Shaders.painter_image_vert;
    integrate.fragmentShader = Shaders.integration_frag;
    integrate.compile();
    Mouse.get().notify(onClick, onRelease, onMove, null);
  }

  private function onClick(button:Int, x:Int, y:Int) {
    pressed = true;
    mousePos = invProj.multvec({x: x, y: y});
  }

  private function onRelease(button:Int, x:Int, y:Int) {
    pressed = false;
    mousePos = invProj.multvec({x: x, y: y});
  }

  private function onMove(x:Int, y:Int, dx:Int, dy:Int) {
    mousePos = invProj.multvec({x: x, y: y});
  }

  private function canvasResize(w:Int, h:Int) {
    final scaledW = (w * scale).round();
    final scaledH = (h * scale).round();
    if (present.width != scaledW || present.height != scaledH) {
      present = Image.createRenderTarget(scaledW, scaledH, RGBA128);
      lastFrame = Image.createRenderTarget(scaledW, scaledH, RGBA128);

      present.g2.begin(true, Color.fromFloats(0, 0, 0, 0));
      present.g2.end();

      final projection = Projection.ortho(
        {start: 0, end: present.width},
        {start: 0, end: present.height},
        {start: 0, end: w},
        {start: 0, end: h}
      );
      invProj = projection.inverse();
    }
  }

  public function update() {}

  public function render(framebuffers:Array<Framebuffer>):Void {
    final screen = framebuffers[0];
    canvasResize(screen.width, screen.height);

    if (pressed) {
      lastFrame.g2.begin(false);
      lastFrame.g2.fillRect(mousePos.x, mousePos.y, 1, 1);
      lastFrame.g2.end();
    }

    // execute the integration kernel
    present.g2.begin(Color.fromFloats(0, 0, 0, 0));
    present.g2.pipeline = integrate;
    // edge-condition: don't update pixels around the border of the screen
    present.g2.drawSubImage(
      lastFrame,
      1,
      1,
      1,
      1,
      lastFrame.width - 1,
      lastFrame.height - 1
    );
    present.g2.pipeline = null;
    present.g2.end();

    // render the water ripple
    screen.g2.begin();
    screen.g2.pipeline = drawWater;
    screen.g2.drawScaledImage(present, 0, 0, screen.width, screen.height);
    screen.g2.pipeline = null;
    screen.g2.end();

    // swap the integration buffers
    final tmp = lastFrame;
    lastFrame = present;
    present = tmp;
  }
}
