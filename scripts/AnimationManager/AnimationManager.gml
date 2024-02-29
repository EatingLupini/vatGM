function AnimationManager(anim, anim_end_func) constructor
{
	self.anim = anim;
	self.anim_end_func = anim_end_func;
	self.time = 0;
	
	self.anim_old = undefined;
	self.time_old = 0;
	
	self.anim_over = false;
	self.blend = 0;
	self.sample = 0;
	
	static set_shader_params = function()
	{
		// skip if the animation is not set
		if (self.anim == undefined)
			return;
		
		// anim 1
		texture_set_stage_vs(anim_offsets_param, self.anim.tex_offsets);
		texture_set_stage_vs(anim_normals_param, self.anim.tex_normals);
		shader_set_uniform_f(frame_count_param, self.anim.frame_count);
		shader_set_uniform_f(offset_min_param, self.anim.offset_min);
		shader_set_uniform_f(offset_dist_param, self.anim.offset_dist);
		shader_set_uniform_f(loop_param, self.anim.loop);
		shader_set_uniform_f(time_param, (self.time / self.anim.tex_size));
		
		// anim 2
		if (self.anim_old != undefined)
		{
			texture_set_stage_vs(anim_offsets_old_param, self.anim_old.tex_offsets);
			texture_set_stage_vs(anim_normals_old_param, self.anim_old.tex_normals);
			shader_set_uniform_f(frame_count_old_param, self.anim_old.frame_count);
			shader_set_uniform_f(offset_min_old_param, self.anim_old.offset_min);
			shader_set_uniform_f(offset_dist_old_param, self.anim_old.offset_dist);
			shader_set_uniform_f(loop_old_param, self.anim_old.loop);
			shader_set_uniform_f(time_old_param, (self.time_old % (self.anim_old.frame_count - 1) / self.anim_old.tex_size));
		}
		
		// shared
		shader_set_uniform_f(tex_size_param, self.anim.tex_size, self.anim.tex_size);
		shader_set_uniform_f(blend_param, self.blend);
		shader_set_uniform_f(sample_param, self.sample);
	}
	
	static step = function()
	{
		// skip if the animation is not set
		// or the animation is over
		if (self.anim == undefined or self.anim_over)
			return;
		
		// blending
		if (self.anim_old != undefined)
		{
			self.time_old += dt * 60 * self.anim_old.speed * gspd;
			self.blend += 1 / (self.anim.frame_count - 1) * dt * 60 * self.anim.speed * gspd;
			
			// blend over
			if (self.blend > 1)
			{
				self.blend = 0;
				self.anim_old = undefined;
			}
		}
		
		// increment frame time
		self.time += dt * 60 * self.anim.speed * gspd;
		
		// animation over
		if (!self.anim_over and 
			(self.time >= self.anim.frame_count - 1 or self.time <= -self.anim.frame_count + 1))
		{
			if (!self.anim.loop)
				self.anim_over = true;
			else
				self.time = 0;
			
			// call animation end function
			self.anim_end_func();
		}
	}
	
	static set_animation = function(new_anim)
	{
		self.anim = new_anim;
		self.anim_over = false;
		self.time = 0;
	}
	
	static change_animation = function(anim_new, blend_func)
	{
		if (anim_over)
		{
			show_debug_message("Cannot blend the new animation when the previous one is over.");
			return;
		}
		if (anim_new == self.anim)
			return;
		
		self.anim_old = self.anim;
		self.anim = anim_new;
		
		self.time_old = self.time;
		self.time = 0;
	}
}


function init_animations()
{
	globalvar	anim_offsets_param, anim_normals_param, frame_count_param,
				offset_min_param, offset_dist_param, loop_param, time_param,
				anim_offsets_old_param, anim_normals_old_param, frame_count_old_param,
				offset_min_old_param, offset_dist_old_param, loop_old_param, time_old_param,
				tex_size_param, blend_param, sample_param;
	
	// anim 1
	anim_offsets_param = shader_get_sampler_index(sh_vat, "u_anim_offsets");
	anim_normals_param = shader_get_sampler_index(sh_vat, "u_anim_normals");
	frame_count_param = shader_get_uniform(sh_vat, "u_frame_count");
	offset_min_param = shader_get_uniform(sh_vat, "u_offset_min");
	offset_dist_param = shader_get_uniform(sh_vat, "u_offset_dist");
	loop_param = shader_get_uniform(sh_vat, "u_loop");
	time_param = shader_get_uniform(sh_vat, "u_time");
	
	// anim 2
	anim_offsets_old_param = shader_get_sampler_index(sh_vat, "u_anim_offsets_old");
	anim_normals_old_param = shader_get_sampler_index(sh_vat, "u_anim_normals_old");
	frame_count_old_param = shader_get_uniform(sh_vat, "u_frame_count_old");
	offset_min_old_param = shader_get_uniform(sh_vat, "u_offset_min_old");
	offset_dist_old_param = shader_get_uniform(sh_vat, "u_offset_dist_old");
	loop_old_param = shader_get_uniform(sh_vat, "u_loop_old");
	time_old_param = shader_get_uniform(sh_vat, "u_time_old");
	
	// shared
	tex_size_param = shader_get_uniform(sh_vat, "u_tex_size");
	blend_param = shader_get_uniform(sh_vat, "u_blend");
	sample_param = shader_get_uniform(sh_vat, "u_sample_num");
}

