#define MAX_BATCH_SIZE 64
#define MAX_ANIMS 5

attribute vec3 in_Position;                  
attribute vec2 in_TextureCoord;           
attribute vec4 in_Colour;                
attribute vec3 in_Normal;
attribute float in_Index;

varying vec3 vertex_position;
varying vec2 uvs;
varying vec3 normal;
varying vec4 vertex_color;

// transfom
uniform vec3 translations[MAX_BATCH_SIZE];
uniform vec3 scales[MAX_BATCH_SIZE];
uniform vec4 rotations[MAX_BATCH_SIZE];
uniform float total_vertices;

// anims
uniform vec2 u_tex_size;
uniform sampler2D u_anim_offsets;
uniform sampler2D u_anim_normals;
uniform int u_active_anims[MAX_BATCH_SIZE];
uniform float u_frame_start[MAX_BATCH_SIZE * MAX_ANIMS];
uniform float u_frame_end[MAX_BATCH_SIZE * MAX_ANIMS];
uniform float u_offset_min[MAX_BATCH_SIZE * MAX_ANIMS];
uniform float u_offset_dist[MAX_BATCH_SIZE * MAX_ANIMS];
uniform bool u_loop[MAX_BATCH_SIZE * MAX_ANIMS];
uniform float u_time[MAX_BATCH_SIZE * MAX_ANIMS];
uniform float u_blend[MAX_BATCH_SIZE * MAX_ANIMS];

// mod function that works with negative numbers
float mod_neg(float xx, float mm)
{
    return mod(mod(xx, mm) + mm, mm);
}

// get the current frame value of the vertex
// val_type: 0 -> offset
//			 1 -> normal
vec3 get_frame_val(sampler2D anim_tex, int val_type)
{
	int index_model = int(in_Index / total_vertices);
	float index_vertex = mod(in_Index, total_vertices);
	float frame_px = 1.0 / u_tex_size.y;
	float frame_px_half = frame_px * 0.5;
	
	vec3 avg_val = vec3(0.0);
	for (int j=0; j<u_active_anims[index_model]; j++)
	{
		int i = index_model * MAX_ANIMS + j;
		float frame_count =  (u_frame_end[i] - u_frame_start[i] + 1.0) * frame_px;
	
		vec4 current_val = vec4(0.0);
		if (u_loop[i])
		{
			float current_vertex = (index_vertex + 0.5) / u_tex_size.x;
			float current_frame = mod_neg(u_frame_start[i] * frame_px + u_time[i] + frame_px_half, u_frame_start[i] * frame_px + frame_count);
			current_val += texture2DLod(anim_tex, vec2(current_vertex, current_frame), 0.0);
		}
		else
		{
			float current_vertex = (index_vertex + 0.5) / u_tex_size.x;
			float current_frame = clamp(u_frame_start[i] * frame_px + u_time[i] + frame_px_half, 0.0, u_frame_start[i] * frame_px + frame_count - frame_px_half);
			current_val += texture2DLod(anim_tex, vec2(current_vertex, current_frame), 0.0);
		}
			
		if (val_type == 0)
		{
			vec4 real_pos = current_val * u_offset_dist[i] + u_offset_min[i];
			avg_val = mix(avg_val, real_pos.xyz, u_blend[i]);
		}
		else
		{
			vec3 real_normal = current_val.xyz * 2.0 - 1.0;
			avg_val = mix(avg_val, real_normal.xyz, u_blend[i]);
		}
	}
	
	return avg_val;
}

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
	// get frame offset
	vec3 avg_pos = get_frame_val(u_anim_offsets, 0);
	
	// add offset to position
	vec3 anim_pos = in_Position + avg_pos;
	
	//Index of the transform.
	int index_model = int(in_Index / total_vertices);
	
	//Dynamic batch transformations.
	vec3 translation = translations[index_model];
	vec3 scale = scales[index_model];
	vec4 rotation = rotations[index_model];
	
	//Apply dynamic batch transformation.
    vec4 position = vec4(anim_pos, 1.0);
	position.xyz = rotate_vertex(position.xyz, rotation); 
	position.xyz *= scale;
	position.xyz += translation;
	
	//Apply projection.
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * position;
	
	//get frame normal
	vec3 real_normal = get_frame_val(u_anim_normals, 1);
	vec3 anim_normal = (gm_Matrices[MATRIX_WORLD] * vec4(real_normal, 0.0)).xyz;
    
	//Vertex data.
	vertex_position = in_Position; //Position.
    vertex_color = in_Colour; //Color.
    uvs = in_TextureCoord; //UVs.
	normal = rotate_vertex(anim_normal, rotation); //Normal.
}
