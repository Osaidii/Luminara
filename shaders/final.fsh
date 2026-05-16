#version 330 compatibility

uniform sampler2D colortex0;
uniform sampler2D shadowtex0;

in vec2 texcoord;

layout(location = 0) out vec4 color;

void main() {
    vec3 base = texture(colortex0, texcoord).rgb;
    vec3 bloom = vec3(0.0);
    float offset = 0.002;
    bloom += texture(colortex0, texcoord + vec2(offset, 0.0)).rgb;
    bloom += texture(colortex0, texcoord + vec2(-offset, 0.0)).rgb;
    bloom += texture(colortex0, texcoord + vec2(0.0, offset)).rgb;
    bloom += texture(colortex0, texcoord + vec2(0.0, -offset)).rgb;
    bloom *= 0.25;
    float brightness = max(max(base.r, base.g), base.b);
    vec3 finalColor = base;
    if (brightness > 0.6) {
        finalColor += bloom * 0.4;
    }
    finalColor = pow(finalColor, vec3(1.0 / 2.2));
    color = vec4(finalColor, 1.0);
}