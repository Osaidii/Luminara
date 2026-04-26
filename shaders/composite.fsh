#version 330 compatibility
#include "/libs/shadowDistort.glsl"
#define SHADOW_RADIUS 1
#define SHADOW_RANGE 3

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D depthtex0;
uniform mat4 gbufferModelViewInverse;
uniform vec3 shadowLightPosition;

const vec3 blocklightColor = vec3(1.0, 0.5, 0.08);
const vec3 skylightColor = vec3(0.05, 0.15, 0.3);
const vec3 sunlightColor = vec3(1.0);
const vec3 ambientColor = vec3(0.1);

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

/*
vec3 projectAndDivide(mat4 projectionMatrix, vec3 position) {
	vec4 homPos = projectionMatrix * vec4(position, 1.0);
	return homPos.xyz / homPos.w;
}

vec3 getShadow(vec3 shadowScreenPos) {
	float transparentShadow = step(shadowScreenPos.z, texture(shadowtex0, shadowScreenPos.xy).r);
	if (transparentShadow == 1.0) {
		return vec3(1.0);
	}
	float opaqueShadow = step(shadowScreenPos.z, texture(shadowtex1, shadowScreenPos.xy).r);
	if (opaqueShadow == 0.0) {
		return vec3(0.0);
	}
	vec4 shadowColor = texture(shadowcolor0, shadowScreenPos.xy);
	return shadowColor.rgb * (1.0 - shadowColor.a);
}

vec3 getSoftShadow(vec4 shadowClipPos) {
	vec3 shadowAccum = vec3(0.0);
	const int samples = (2 * SHADOW_RANGE) * (2 * SHADOW_RANGE);
	for (int x = -SHADOW_RANGE; x < SHADOW_RANGE; x++) {
		for (int y = -SHADOW_RANGE; y < SHADOW_RANGE; y++) {
			vec2 offset = vec2(x, y) * SHADOW_RADIUS / float(SHADOW_RANGE);
			offset /= 2048;
			vec4 offsetShadowClipPos = shadowClipPos + vec4(offset, 0.0, 0.0);
			offsetShadowClipPos.xyz = distortShadowClipPos(offsetShadowClipPos.xyz);
			vec3 shadowNdcPos = offsetShadowClipPos.xyz / offsetShadowClipPos.w;
			vec3 shadowScreenPos = shadowNdcPos * 0.5 + 0.5;
			shadowAccum += getShadow(shadowScreenPos);
		}
	}
	return shadowAccum / float(samples);
}

vec4 getNoise(vec2 coord) {
	ivec2 screenCoord = ivec2(coord * vec2(viewWidth, viewHeight));
	ivec2 noiseCoord = screenCoord % 64;
	return texelFetch(noisetex, noiseCoord, 0);
}
*/
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