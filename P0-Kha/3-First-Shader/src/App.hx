package;

import kha.Color;
import kha.Shaders;
import kha.graphics4.VertexStructure;
import kha.graphics4.IndexBuffer;
import kha.graphics4.VertexBuffer;
import kha.graphics4.PipelineState;
import kha.Framebuffer;

/**
  Use the mouse to draw persistent graphics on the screen.
**/
class App {
  private final pipeline:PipelineState;
  private final vertexBuffer:VertexBuffer;
  private final indexBuffer:IndexBuffer;

  public function new() {
    final layout = new VertexStructure();
    layout.add("pos", Float2);

    pipeline = new PipelineState();
    pipeline.inputLayout = [layout];
    pipeline.vertexShader = Shaders.pass_vert;
    pipeline.fragmentShader = Shaders.pass_frag;
    pipeline.compile();

    vertexBuffer = new VertexBuffer(3, layout, StaticUsage);
    final v = vertexBuffer.lock();
    v.set(0, -0.5); // x, bottom left
    v.set(1, -0.5); // y

    v.set(2, 0.5); // x
    v.set(3, -0.5); // y

    v.set(4, 0); // x
    v.set(5, 0.5); // y
    vertexBuffer.unlock();

    indexBuffer = new IndexBuffer(3, StaticUsage);
    final i = indexBuffer.lock();
    i[0] = 0;
    i[1] = 1;
    i[2] = 2;
    indexBuffer.unlock();
  }

  public function render(framebuffers:Array<Framebuffer>):Void {
    final graphics = framebuffers[0].g4;
    graphics.begin();
    graphics.clear(Color.Black);
    graphics.setPipeline(pipeline);
    graphics.setVertexBuffer(vertexBuffer);
    graphics.setIndexBuffer(indexBuffer);
    graphics.drawIndexedVertices();
    graphics.end();
  }

  /**
    The Kha scheduler attempts to run this every 16 milliseconds so assume a
    fixed time step.
  **/
  public function update() {}
}
