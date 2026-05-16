#version 330 compatibility

uniform sampler2D lightmap;
uniform sampler2D gtexture;
uniform vec4 entityColor;
uniform int worldTime;

uniform float alphaTestRef = 0.1;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	color = texture(gtexture, texcoord) * glcolor;
	color.rgb = mix(color.rgb, entityColor.rgb, entityColor.a);
	color *= texture(lightmap, lmcoord);
	if (color.a < alphaTestRef) {
		discard;
	}
	float night = 1.0 - smoothstep(12000.0, 14000.0, float(worldTime));
    night += smoothstep(22000.0, 24000.0, float(worldTime));
    float multiplier = mix(1.8, 2.2, night);
	color.rgb *= multiplier;
}