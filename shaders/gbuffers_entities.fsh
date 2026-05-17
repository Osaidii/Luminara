#version 330 compatibility

uniform sampler2D lightmap;
uniform sampler2D gtexture;
uniform vec4 entityColor;
uniform int worldTime;

uniform float alphaTestRef = 0.1;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;
in vec3 normal;

/* RENDERTARGETS: 0,1,2 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 lightmapData;
layout(location = 2) out vec4 encodedNormal;

void main() {
	color = texture(gtexture, texcoord) * glcolor;
	color.rgb = mix(color.rgb, entityColor.rgb, entityColor.a);
	color *= texture(lightmap, lmcoord);
	lightmapData = texture(lightmap, lmcoord);
	encodedNormal = vec4(0.5, 0.5, 1.0, 1.0);
	if (color.a < alphaTestRef) {
		discard;
	}
	float night = 0.0;
	if (worldTime >= 12700 && worldTime <= 22900) {
		night = 1.0 - smoothstep(12000.0, 14000.0, float(worldTime));
		night += smoothstep(22000.0, 24000.0, float(worldTime));
		night = clamp(night, 0.0, 1.0);
	}
    float multiplier = mix(1.0, 2.0, night);
	color.rgb *= multiplier;
	color.a = 1.0;
} 