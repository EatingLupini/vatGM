attribute vec3 in_Position;                  
attribute vec2 in_TextureCoord;           
attribute vec4 in_Colour;                
attribute vec3 in_Normal;
attribute float in_Index;

varying vec3 vertex_position;
varying vec2 uvs;
varying vec3 normal;
varying vec4 vertex_color;

// anim 1
uniform sampler2D u_anim_offsets;
uniform sampler2D u_anim_normals;
uniform float u_frame_start;
uniform float u_frame_end;
uniform float u_offset_min;
uniform float u_offset_dist;
uniform bool u_loop;
uniform float u_time;

// shared
uniform vec2 u_tex_size;
uniform float u_blend;
uniform float u_sample_num;


// mod function that works with negative numbers
float mod_neg(float xx, float mm)
{
    return mod(mod(xx, mm) + mm, mm);
}


void main()
{
	float frame_px = 1.0 / u_tex_size.y;
	float frame_px_half = frame_px * 0.5;
	float frame_count =  (u_frame_end - u_frame_start + 1.0) * frame_px;
	
	// fix wobbling effect
	float sample_range = frame_px * 2.0;
	
	vec4 avg_pos = vec4(0.0);
	if (u_loop)
	{
		float current_vertex = (in_Index + 0.5) / u_tex_size.x;
		float current_frame = mod_neg(u_frame_start * frame_px + u_time + frame_px_half, u_frame_start * frame_px + frame_count);
		avg_pos += texture2DLod(u_anim_offsets, vec2(current_vertex, current_frame), 0.0);
	}
	else
	{
		float current_vertex = (in_Index + 0.5) / u_tex_size.x;
		float current_frame = clamp(u_frame_start * frame_px + u_time + frame_px_half, 0.0, u_frame_start * frame_px + frame_count);
		avg_pos += texture2DLod(u_anim_offsets, vec2(current_vertex, current_frame), 0.0);
	}
	/*
	vec4 avg_pos = vec4(0.0);
	for (float i=-sample_range*0.5; i<sample_range*0.5; i+=sample_range/u_sample_num)
	{
		if (u_loop)
			avg_pos += texture2DLod(u_anim_offsets, vec2((in_Index + 0.5) / u_tex_size.x, mod_neg(u_time + frame_px_half + i, (u_frame_count - 1.0) * frame_px)), 0.0);
		else
			avg_pos += texture2DLod(u_anim_offsets, vec2((in_Index + 0.5) / u_tex_size.x, clamp(u_time + frame_px_half + i, 0.0, (u_frame_count - 1.0) * frame_px)), 0.0);
	}
	avg_pos /= u_sample_num;
	*/
	vec4 real_pos = avg_pos * u_offset_dist + u_offset_min;
	
	// add offset to position
	vec3 final_pos = in_Position + real_pos.xyz;
	
	//Vertex position.
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(final_pos, 1.);
	
	// normals
	//vec4 color_normal = texture2DLod(u_anim_normals, vec2((in_Index + 0.5) / u_tex_size.x, clamp(u_time + frame_px_half, 0.0, (u_frame_count - 1.0) * frame_px)), 0.0);
	//vec3 real_normal = color_normal.xyz * 2.0 - 1.0;
	
    //Vertex data.
	vertex_position = in_Position;
	uvs = in_TextureCoord;
    vertex_color = in_Colour;
	//normal = (gm_Matrices[MATRIX_WORLD] * vec4(real_normal, 0.0)).xyz;
	normal = (gm_Matrices[MATRIX_WORLD] * vec4(in_Normal, 0.0)).xyz;

	//vertex_color = vec4((normal + 1.0) * 0.5, 1.0);
}


