#version 330 compatibility

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;
out vec3 normal;

uniform sampler2D noisetex;

uniform mat4 gbufferModelViewInverse;
uniform float frameTimeCounter;

in vec2 mc_Entity;

void main() {
	vec3 position = gl_Vertex.xyz;
	bool leaf_foliage = mc_Entity.x >= 1001.0 && mc_Entity.x <= 1011.0;
	bool bush_foliage = mc_Entity.x >= 2001.0 && mc_Entity.x <= 2015.0;
	if (leaf_foliage || bush_foliage) {
		float height = (position.y + 1.0) / 2.0;
		float movementAmount = 0.1 + height * 0.3;
		float offsetX = position.y * 1.8 + position.z * 0.9;
		float offsetZ = position.y * 1.5 + position.x * 1.0;
		float swayX = sin((frameTimeCounter * 1.8) + offsetX) * 0.11;
		float swayZ = cos((frameTimeCounter * 1.5) + offsetZ) * 0.09;
		position.x += swayX * movementAmount;
		position.z += swayZ * movementAmount;
	}
	gl_Position = gl_ModelViewProjectionMatrix * vec4(position, 1.0);
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;
	normal = gl_NormalMatrix * gl_Normal;
	normal = mat3(gbufferModelViewInverse) * normal;
}