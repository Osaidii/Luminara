#version 330

uniform sampler2D colortex0;
uniform sampler2D depthtex0;
uniform int viewHeight;
uniform int viewWidth;
uniform mat4 gbufferProjectionInverse;
uniform vec3 fogColor;
uniform float far;

in vec2 texcoord;

const int fog_density = 6;

vec3 projectAndDivide(mat4 projectionMatrix, vec3 position) {
	vec4 homPos = projectionMatrix * vec4(position, 1.0);
	return homPos.xyz / homPos.w;
}

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	color = texture(colortex0, texcoord);
	float depth = texture(depthtex0, texcoord).r;
	if (depth == 1.0) {
		return;
	}
	vec3 ndcPos = vec3(texcoord.xy, depth) * 2.0 - 1.0;
	vec3 viewPos = projectAndDivide(gbufferProjectionInverse, ndcPos);
	vec3 horizontal = viewPos.xyz;
	float dist = length(horizontal) / far;
	float fogFactor = exp(-fog_density * (1.0 - dist));
	color.rgb = mix(color.rgb, pow(fogColor, vec3(2.2)), clamp(fogFactor, 0.0, 1.0));
	vec2 pixel = 1.0 / vec2(viewWidth, viewHeight);
	vec3 bloom = vec3(0.0);
	color.rgb += bloom * 0.3;
}