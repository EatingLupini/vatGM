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

// anims
uniform vec2 u_tex_size;
uniform sampler2D u_anim_offsets;
uniform sampler2D u_anim_normals;
uniform int u_active_anims;
uniform float u_frame_start[MAX_ANIMS];
uniform float u_frame_end[MAX_ANIMS];
uniform float u_offset_min[MAX_ANIMS];
uniform float u_offset_dist[MAX_ANIMS];
uniform bool u_loop[MAX_ANIMS];
uniform float u_time[MAX_ANIMS];
uniform float u_blend[MAX_ANIMS];

// settings
uniform float u_sample_num;


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
	float frame_px = 1.0 / u_tex_size.y;
	float frame_px_half = frame_px * 0.5;
	
	vec3 avg_val = vec3(0.0);
	if (u_active_anims > 0)
	{
		for (int i=0; i<u_active_anims; i++)
		{
			float frame_count =  (u_frame_end[i] - u_frame_start[i] + 1.0) * frame_px;
	
			vec4 current_val = vec4(0.0);
			if (u_loop[i])
			{
				float current_vertex = (in_Index + 0.5) / u_tex_size.x;
				float current_frame = mod_neg(u_frame_start[i] * frame_px + u_time[i] + frame_px_half, u_frame_start[i] * frame_px + frame_count);
				current_val += texture2DLod(anim_tex, vec2(current_vertex, current_frame), 0.0);
			}
			else
			{
				float current_vertex = (in_Index + 0.5) / u_tex_size.x;
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
	}
	
	return avg_val;
}


void main()
{
	// get frame offset
	vec3 avg_pos = get_frame_val(u_anim_offsets, 0);
	
	// add offset to position
	vec3 final_pos = in_Position + avg_pos;
	
	// update vertex position
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(final_pos, 1.);
	
	//get frame normal
	vec3 real_normal = get_frame_val(u_anim_normals, 1);
	normal = (gm_Matrices[MATRIX_WORLD] * vec4(real_normal, 0.0)).xyz;
	
    //Vertex data.
	vertex_position = in_Position;
	uvs = in_TextureCoord;
    vertex_color = in_Colour;

	// debug normal
	//vertex_color = vec4((normal + 1.0) * 0.5, 1.0);
}


