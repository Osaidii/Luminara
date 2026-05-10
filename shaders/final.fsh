#version 330 compatibility

uniform sampler2D colortex0;

in vec2 texcoord;

void main() {
    vec3 color = texture(colortex0, texcoord).rgb;
    vec3 bloom = vec3(0.0);
    float offset = 0.002;
    bloom += texture(colortex0, texcoord + vec2(offset, 0.0)).rgb;
    bloom += texture(colortex0, texcoord + vec2(-offset, 0.0)).rgb;
    bloom += texture(colortex0, texcoord + vec2(0.0, offset)).rgb;
    bloom += texture(colortex0, texcoord + vec2(0.0, -offset)).rgb;
    bloom *= 0.7;
    float brightness = max(max(color.r, color.g), color.b);
    if (brightness > 0.6) {
        color += bloom * 0.7;
    }
    color.rgb = pow(color.rgb, vec3(1.0 / 2.2));
    gl_FragColor = vec4(color, 1.0);
}