function TextureMaterialAnim(texture, subimg, anim_manager) : TextureMaterial(sh_vat, texture, subimg) constructor
{
	self.anim_manager = anim_manager;
	
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
	
	static on_apply = function()
	{
		//gpu_set_cullmode(cull_counterclockwise);
		self.anim_manager.step();
		var u = self.anim_manager.get_shader_params();
		shader_set_uniform_f(self.u_tex_size, u.tex_size, u.tex_size);
		texture_set_stage_vs(self.u_anim_offsets, u.anim_offsets);
		texture_set_stage_vs(self.u_anim_normals, u.anim_normals);
		shader_set_uniform_i(self.u_active_anims, u.active_anims);
		shader_set_uniform_f_array(self.u_frame_start, u.frame_start);
		shader_set_uniform_f_array(self.u_frame_end, u.frame_end);
		shader_set_uniform_f_array(self.u_offset_min, u.offset_min);
		shader_set_uniform_f_array(self.u_offset_dist, u.offset_dist);
		shader_set_uniform_f_array(self.u_loop, u.loop);
		shader_set_uniform_f_array(self.u_time, u.time);
		shader_set_uniform_f_array(self.u_blend, u.blend);
	}
}

