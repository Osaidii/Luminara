#version 330 compatibility

uniform sampler2D gtexture;

in vec2 texcoord;
in vec4 glcolor;

const int shadowMapResolution = 4096;

layout(location = 0) out vec4 color;

void main() {
  color.rgb = pow(color.rgb, vec3(1.0 / 2.2));
  color = texture(gtexture, texcoord) * glcolor;
  if (color.a < 0.1){
    discard;
  }
}