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
uniform float u_frame_count;
uniform float u_offset_min;
uniform float u_offset_dist;
uniform bool u_loop;
uniform float u_time;

// anim 2
uniform sampler2D u_anim_offsets_old;
uniform sampler2D u_anim_normals_old;
uniform float u_frame_count_old;
uniform float u_offset_min_old;
uniform float u_offset_dist_old;
uniform bool u_loop_old;
uniform float u_time_old;

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
	
	// fix wobbling effect
	float sample_range = frame_px * 10.0;
	
	vec4 avg_pos = vec4(0.0);
	for (float i=-sample_range*0.5; i<sample_range*0.5; i+=sample_range/u_sample_num)
	{
		if (u_loop)
			avg_pos += texture2DLod(u_anim_offsets, vec2((in_Index + 0.5) / u_tex_size.x, mod_neg(u_time + frame_px_half + i, (u_frame_count - 1.0) * frame_px)), 0.0);
		else
			avg_pos += texture2DLod(u_anim_offsets, vec2((in_Index + 0.5) / u_tex_size.x, clamp(u_time + frame_px_half + i, 0.0, (u_frame_count - 1.0) * frame_px)), 0.0);
	}
	avg_pos /= u_sample_num;
	vec4 real_pos = avg_pos * u_offset_dist + u_offset_min;
	
	// blend animations
	if (u_blend > 0.0)
	{
		avg_pos = vec4(0.0);
		for (float i=-sample_range*0.5; i<sample_range*0.5; i+=sample_range/u_sample_num)
		{
			if (u_loop_old)
				avg_pos += texture2DLod(u_anim_offsets_old, vec2((in_Index + 0.5) / u_tex_size.x, mod_neg(u_time_old + frame_px_half + i, (u_frame_count_old - 1.0) * frame_px)), 0.0);
			else
				avg_pos += texture2DLod(u_anim_offsets_old, vec2((in_Index + 0.5) / u_tex_size.x, clamp(u_time_old + frame_px_half + i, 0.0, (u_frame_count_old - 1.0) * frame_px)), 0.0);
		}
		avg_pos /= u_sample_num;
		vec4 real_pos_old = avg_pos * u_offset_dist_old + u_offset_min_old;
		
		real_pos = mix(real_pos_old, real_pos, u_blend);
	}
	
	// add offset to position
	vec3 final_pos = in_Position + real_pos.xyz;
	
	//Vertex position.
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(final_pos, 1.);
	
	// normals
	vec4 color_normal = texture2DLod(u_anim_normals, vec2((in_Index + 0.5) / u_tex_size.x, clamp(u_time + frame_px_half, 0.0, (u_frame_count - 1.0) * frame_px)), 0.0);
	
	// blend normal
	if (u_blend > 0.0)
	{
		vec4 color_normal_old = texture2DLod(u_anim_normals_old, vec2((in_Index + 0.5) / u_tex_size.x, clamp(u_time_old + frame_px_half, 0.0, (u_frame_count_old - 1.0) * frame_px)), 0.0);
		color_normal = mix(color_normal_old, color_normal, u_blend);
	}
	vec3 real_normal = color_normal.xyz * 2.0 - 1.0;
	
    //Vertex data.
	vertex_position = in_Position;
	uvs = in_TextureCoord;
    vertex_color = in_Colour;
	normal = (gm_Matrices[MATRIX_WORLD] * vec4(real_normal, 0.0)).xyz;

	//vertex_color = vec4((normal + 1.0) * 0.5, 1.0);
}


