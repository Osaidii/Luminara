#version 330 compatibility
#include "libs/shadowDistort.glsl"
#define SHADOW_RANGE 4
#define SHADOW_RADIUS 1

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D depthtex0;
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;
uniform sampler2D noisetex;

/*
cosnt int colortex0Format = RGB16;
*/

uniform vec3 shadowLightPosition;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform int shadowMapResolution;
uniform int worldTime;
uniform int isEyeInWater;
uniform float viewWidth;
uniform float viewHeight;
uniform float rainStrength;

in vec3 normal;
in vec2 texcoord;

const float shadowDistanceRenderMul = 1.0;
const vec3 blocklightColor = vec3(1.0, 0.5, 0.08);
const vec3 skylightColor = vec3(0.05, 0.15, 0.3);
const vec3 sunlightColor = vec3(1.0);
const vec3 ambientColor = vec3(0.1);
const vec3 rainColor = vec3(0.2);
const vec3 nightAmbientColor = vec3(0.3);

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 lightmapData;
layout(location = 2) out vec4 encodedNormal;

vec3 projectAndDivide(mat4 projectionMatrix, vec3 position){
    vec4 homPos = projectionMatrix * vec4(position, 1.0);
    return homPos.xyz / homPos.w;
}

vec3 getShadow(vec3 shadowScreenPos) {
	float transparentShadow =step(shadowScreenPos.z, texture(shadowtex0, shadowScreenPos.xy).r);
	if (transparentShadow == 1.0) {
		return vec3(1.0);
	}
	float opaqueShadow = step(shadowScreenPos.z, texture(shadowtex1, shadowScreenPos.xy).r);
	if(opaqueShadow == 0.0) {
		return vec3(0.0);
	}
	vec4 shadowColor = texture(shadowcolor0, shadowScreenPos.xy);
	return shadowColor.rgb * (1.0 - shadowColor.a);
}

vec4 getNoise(vec2 coord) {
    ivec2 screenCoord = ivec2(coord * vec2(viewWidth, viewHeight));
    ivec2 noiseCoord = screenCoord % 64;
    return texelFetch(noisetex, noiseCoord, 0);
}

vec3 getSoftShadow(vec4 shadowClipPos) {
	float noise = getNoise(texcoord).r;
	float theta = noise * radians(360.0);
	float cosTheta = cos(theta);
	float sinTheta = sin(theta);
	mat2 rotation = mat2(cosTheta, -sinTheta, sinTheta, cosTheta);
	vec3 shadowAccum = vec3(0.0);
	const int samples= SHADOW_RANGE * SHADOW_RANGE * 4;
	for (int x = -SHADOW_RANGE; x < SHADOW_RANGE; x++) {
		for (int y = -SHADOW_RANGE; y < SHADOW_RANGE; y++) {
			vec2 offset = vec2(x,y) * SHADOW_RADIUS / float(samples);
			offset = rotation * offset;
			offset /= shadowMapResolution;
			vec4 offsetShadowClipPos = shadowClipPos + vec4(offset, 0.0, 0.0);
			offsetShadowClipPos.z -= 0.001;
			offsetShadowClipPos.xyz = distortShadowClipPos(offsetShadowClipPos.xyz);
			vec3 shadowNDCPos = offsetShadowClipPos.xyz / offsetShadowClipPos.w;
			vec3 shadowScreenPos = shadowNDCPos * 0.5 + 0.5;
			shadowAccum += getShadow(shadowScreenPos);
		}
	}
	return shadowAccum / float(samples);
}

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
	vec3 NDCPos = vec3(texcoord.xy, depth) * 2.0 - 1.0;
	vec3 viewPos = projectAndDivide(gbufferProjectionInverse, NDCPos);
	vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
	vec3 shadowViewPos = (shadowModelView * vec4(feetPlayerPos, 1.0)).xyz;
	vec4 shadowClipPos = shadowProjection * vec4(shadowViewPos, 1.0);
	//vec3 shadow = getSoftShadow(shadowClipPos);
	shadowClipPos.z -= 0.002;
	shadowClipPos.xyz = distortShadowClipPos(shadowClipPos.xyz);
	vec3 shadowNDCPos = shadowClipPos.xyz / shadowClipPos.w;
	vec3 shadowScreenPos = shadowNDCPos * 0.5 + 0.5;
	vec3 shadow = vec3(0.0);
	vec3 blocklight = lightmap.x * blocklightColor;
	vec3 skylight = vec3(0.0);
	vec3 ambient = vec3(0.0);
	if ((worldTime <= 12700 || worldTime >= 22900) && rainStrength == 0.0) {
        skylight = lightmap.y * skylightColor;
        //shadow = getSoftShadow(shadowClipPos);
        shadow = getShadow(shadowScreenPos);
		ambient = ambientColor;
    }
	else {
        if (rainStrength > 0.1) {
            skylight = lightmap.y * rainColor;
        }
        else {
            skylight = lightmap.y * skylightColor;
        }
		ambient = nightAmbientColor;
    }
    ambient *= 0.3;
	vec3 sunlight = sunlightColor * clamp(dot(worldLightVector, normal), 0.0, 1.0) * shadow;
	color.rgb *= blocklight + skylight + ambient + sunlight;
	if (isEyeInWater == 1) {
		float waterFog = exp(-length(viewPos) * 0.015);
		vec3 waterColor = vec3(0.0, 0.35, 0.65);
		color.rgb = mix(waterColor, color.rgb, waterFog);
		color.rgb *= vec3(0.4, 0.7, 1.0);
		skylight *= 1.5;
	}
	else if (isEyeInWater == 2) {
		float lavaFog = exp(-length(viewPos) * 0.8);
		vec3 lavaColor = vec3(0.85, 0.18, 0.02);
		color.rgb = mix(lavaColor, color.rgb, lavaFog);
		color.rgb *= vec3(0.9, 0.3, 0.1);
	}
	else if (isEyeInWater == 3) {
		float snowFog = exp(-length(viewPos) * 0.5);
		vec3 snowColor = vec3(0.85, 0.85, 0.85);
		color.rgb = mix(snowColor, color.rgb, snowFog);
		color.rgb *= vec3(0.85, 0.85, 0.85);
	}
}