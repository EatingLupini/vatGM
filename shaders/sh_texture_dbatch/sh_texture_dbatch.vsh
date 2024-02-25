#define MAX_BATCH_SIZE 1024

attribute vec3 in_Position;                  
attribute vec2 in_TextureCoord;           
attribute vec4 in_Colour;                
attribute vec3 in_Normal;
attribute float in_Index;

uniform vec3 translations[MAX_BATCH_SIZE];
uniform vec3 scales[MAX_BATCH_SIZE];
uniform vec4 rotations[MAX_BATCH_SIZE];

varying vec3 vertex_position;
varying vec2 uvs;
varying vec3 normal;
varying vec4 vertex_color;

vec4 quat_conj(vec4 q)
{ 
	return vec4(-q.x, -q.y, -q.z, q.w); 
}
  
vec4 quat_mult(vec4 q1, vec4 q2)
{ 
	vec4 qr;
	qr.x = (q1.w * q2.x) + (q1.x * q2.w) + (q1.y * q2.z) - (q1.z * q2.y);
	qr.y = (q1.w * q2.y) - (q1.x * q2.z) + (q1.y * q2.w) + (q1.z * q2.x);
	qr.z = (q1.w * q2.z) + (q1.x * q2.y) - (q1.y * q2.x) + (q1.z * q2.w);
	qr.w = (q1.w * q2.w) - (q1.x * q2.x) - (q1.y * q2.y) - (q1.z * q2.z);
	return qr;
}

vec3 rotate_vertex(vec3 position, vec4 rotation)
{ 
	vec4 qr = normalize(rotation);
	vec4 qr_conj = quat_conj(qr);
	vec4 q_pos = vec4(position.x, position.y, position.z, 0);
  
	vec4 q_tmp = quat_mult(qr, q_pos);
	qr = quat_mult(q_tmp, qr_conj);
  
	return vec3(qr.x, qr.y, qr.z);
}

void main()
{
	//Index of the transform.
	int index = int(in_Index);
	
	//Dynamic batch transformations.
	vec3 translation = translations[index]; 
	vec3 scale = scales[index];
	vec4 rotation = rotations[index];
	
	//Apply dynamic batch transformation.
    vec4 position = vec4(in_Position, 1.0);
	position.xyz = rotate_vertex(position.xyz, rotation); 
	position.xyz *= scale;
	position.xyz += translation;
	
	//Apply projection.
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * position;
    
	//Vertex data.
	vertex_position = in_Position; //Position.
    vertex_color = in_Colour; //Color.
    uvs = in_TextureCoord; //UVs.
	normal = rotate_vertex(in_Normal, rotation); //Normal.
}
