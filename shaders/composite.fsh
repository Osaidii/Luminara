#version 330 compatibility
#include "libs/shadowDistort.glsl"
#define SHADOW_RANGE 4
#define SHADOW_RADIUS 1

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D depthtex0;

/*
cosnt int colortex0Format = RGB16;
*/

uniform vec3 shadowLightPosition;
uniform mat4 gbufferModelViewInverse;

in vec3 normal;
in vec2 texcoord;

const vec3 blocklightColor = vec3(1.0, 0.5, 0.08);
const vec3 skylightColor = vec3(0.05, 0.15, 0.3);
const vec3 sunlightColor = vec3(1.0);
const vec3 ambientColor = vec3(0.1);
const vec3 rainColor = vec3(0.2);

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 lightmapData;
layout(location = 2) out vec4 encodedNormal;

void main() {
	vec2 lightmap = texture(colortex1, texcoord).xy;
	vec3 encodedNormal = texture(colortex2, texcoord).rgb;
	vec3 normal = normalize((encodedNormal - 0.5) * 2.0);
	vec3 lightVector = normalize(shadowLightPosition);
	vec3 worldLightVector = mat3(gbufferModelViewInverse) * lightVector;
	color = texture(colortex0, texcoord);
	color.rgb = pow(color.rgb, vec3(2.2));
	float depth = texture(depthtex0, texcoord).r;
	if (depth == 1.0) {
		return;
	}
	vec3 blocklight = lightmap.x * blocklightColor;
	vec3 skylight = lightmap.y * skylightColor;
	vec3 ambient = ambientColor;
	vec3 sunlight = sunlightColor * clamp(dot(worldLightVector, normal), 0.0, 1.0) * lightmap.y;
	color.rgb *= blocklight + skylight + ambient + sunlight;
	
}