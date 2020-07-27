#version 450

uniform sampler2D tex;
in vec2 texCoord;
in vec4 color;
out vec4 FragColor;

void main() {
  vec4 val = texture(tex, texCoord) * 10;
	FragColor = vec4(val.r, val.r, val.b, 1.0);
}
