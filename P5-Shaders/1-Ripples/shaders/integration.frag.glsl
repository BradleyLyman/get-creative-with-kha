#version 450

uniform sampler2D tex;
in vec2 texCoord;
in vec4 color;
out vec4 FragColor;

// https://web.archive.org/web/20160418004149/http://freespace.virgin.net/hugo.elias/graphics/x_water.htm
// Buffer2(x, y) = (Buffer1(x-1,y)
//                  Buffer1(x+1,y)
//                  Buffer1(x,y+1)
//                  Buffer1(x,y-1)) / 2 - Buffer2(x,y)
// Buffer2(x,y) = Buffer2(x,y) * damping
// end loop
//
// Display Buffer2
// Swap the buffers
// By convention, Buffer2 is the R component and Buffer1 is the G component

void main() {
  ivec2 size = textureSize(tex, 0);
  vec2 pixelStep = 1.0 / size;
  vec2 pixelStepX = vec2(pixelStep.x, 0);
  vec2 pixelStepY = vec2(0, pixelStep.y);

  vec4 result = vec4(0.0f, 0.0f, 0.0f, 1.0f);
  vec4 current = texture(tex, texCoord);

  // primary source
  result.r = current.g;
  result.g = (texture(tex, texCoord - pixelStepX).g +
              texture(tex, texCoord + pixelStepX).g +
              texture(tex, texCoord + pixelStepY).g +
              texture(tex, texCoord - pixelStepY).g);
  result.g = result.g / 2;
  result.g = result.g - current.r;
  result.g = result.g * 0.99;


  // second source, reduced damping
  result.b = current.a;
  result.a = (texture(tex, texCoord - pixelStepX).a +
              texture(tex, texCoord + pixelStepX).a +
              texture(tex, texCoord + pixelStepY).a +
              texture(tex, texCoord - pixelStepY).a);
  result.a = result.a / 2;
  result.a = result.a - current.b;
  result.a = result.a * 0.991;

  FragColor = result;
}
