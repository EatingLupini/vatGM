function TextureMaterialAnimBatch(texture, subimg, anim_managers) : TextureMaterial(sh_vat_dbatch, texture, subimg) constructor
{
	self.MAX_ANIMS = 5;
	self.anim_managers = anim_managers;
	
	// anim
	self.u_tex_size = shader_get_uniform(self.shader, "u_tex_size");
	self.u_anim_offsets = shader_get_sampler_index(self.shader, "u_anim_offsets");
	self.u_anim_normals = shader_get_sampler_index(self.shader, "u_anim_normals");
	self.u_active_anims = shader_get_uniform(self.shader, "u_active_anims");
	self.u_frame_start = shader_get_uniform(self.shader, "u_frame_start");
	self.u_frame_end = shader_get_uniform(self.shader, "u_frame_end");
	self.u_offset_min = shader_get_uniform(self.shader, "u_offset_min");
	self.u_offset_dist = shader_get_uniform(self.shader, "u_offset_dist");
	self.u_loop = shader_get_uniform(self.shader, "u_loop");
	self.u_time = shader_get_uniform(self.shader, "u_time");
	self.u_blend = shader_get_uniform(self.shader, "u_blend");
	
	// define params arrays
	self.arr_active_anims = array_create(0);
	self.arr_frame_start = array_create(0);
	self.arr_frame_end = array_create(0);
	self.arr_offset_min = array_create(0);
	self.arr_offset_dist = array_create(0);
	self.arr_loop = array_create(0);
	self.arr_time = array_create(0);
	self.arr_blend = array_create(0);
	
	
	static on_apply = function()
	{
		var u = undefined;
		for (var i=0; i<array_length(self.anim_managers); i++)
		{
			var anim_manager = anim_managers[i];
			
			// update anims
			anim_manager.step();
			u = anim_manager.get_shader_params();
			
			// set params arrays
			self.arr_active_anims[i] = u.active_anims;
			for (var j=0; j<self.MAX_ANIMS; j++)
			{
				var si = i*self.MAX_ANIMS+j;
				self.arr_frame_start[si] = u.frame_start[j];
				self.arr_frame_end[si] = u.frame_end[j];
				self.arr_offset_min[si] = u.offset_min[j];
				self.arr_offset_dist[si] = u.offset_dist[j];
				self.arr_loop[si] = u.loop[j];
				self.arr_time[si] = u.time[j];
				self.arr_blend[si] = u.blend[j];
			}
		}
		
		// set shader uniforms
		shader_set_uniform_f(self.u_tex_size, u.tex_size, u.tex_size);
		texture_set_stage_vs(self.u_anim_offsets, u.anim_offsets);
		texture_set_stage_vs(self.u_anim_normals, u.anim_normals);
		shader_set_uniform_i_array(self.u_active_anims, self.arr_active_anims);
		shader_set_uniform_f_array(self.u_frame_start, self.arr_frame_start);
		shader_set_uniform_f_array(self.u_frame_end, self.arr_frame_end);
		shader_set_uniform_f_array(self.u_offset_min, self.arr_offset_min);
		shader_set_uniform_f_array(self.u_offset_dist, self.arr_offset_dist);
		shader_set_uniform_f_array(self.u_loop, self.arr_loop);
		shader_set_uniform_f_array(self.u_time, self.arr_time);
		shader_set_uniform_f_array(self.u_blend, self.arr_blend);
	}
}

