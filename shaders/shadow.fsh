#version 330 compatibility

uniform sampler2D gtexture;
uniform int worldTime;

in vec2 texcoord;
in vec4 glcolor;

const int shadowMapResolution = 2048;

layout(location = 0) out vec4 color;

void main() {
  color = texture(gtexture, texcoord) * glcolor;
  if(color.a < 0.1){
    discard;
  }
  if (worldTime <= 12785 || worldTime >= 22900) {
    color.rgb = pow(color.rgb, vec3(1.0 / 2.2));
  }
  }