#version 330 compatibility

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;
out vec3 normal;

in vec3 VAPosition; 

uniform sampler2D noisetex;

uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform vec3 cameraPosition;
uniform float frameTimeCounter;

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;

in vec2 mc_Entity;

void main() {
	vec3 position = gl_Vertex.xyz;
	vec4 viewPos = modelViewMatrix * vec4(VAPosition, 1.0);
	vec3 worldPos = (gbufferModelViewInverse * viewPos).xyz + cameraPosition;
	bool leaf_foliage = false;
	bool bush_foliage = false;
	bool crop_foliage = false;
	float diffx = cameraPosition.x - worldPos.x;
	float diffz = cameraPosition.z - worldPos.z;
	if (abs(diffx) < 30.0 && abs(diffz) < 30.0) {
		leaf_foliage = mc_Entity.x >= 1001.0 && mc_Entity.x <= 1011.0;
		bush_foliage = mc_Entity.x >= 2001.0 && mc_Entity.x <= 2029.0;
		crop_foliage = mc_Entity.x >= 3001.0 && mc_Entity.x <= 3012.0;
	}
	if (leaf_foliage || bush_foliage || crop_foliage) {
		float height = (position.y + 1.0) / 2.0;
		float movementAmount = 0.1 + height * 0.2;
	float offsetX = worldPos.x * 0.6 + worldPos.z * 0.4;
	float offsetZ = worldPos.x * 0.4 + worldPos.z * 0.6;
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