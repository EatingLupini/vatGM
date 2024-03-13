function init_animations()
{
	globalvar	anim_offsets_param, anim_normals_param, frame_start_param, frame_end_param,
				offset_min_param, offset_dist_param, loop_param, time_param,
				anim_offsets_old_param, anim_normals_old_param, frame_count_old_param,
				offset_min_old_param, offset_dist_old_param, loop_old_param, time_old_param,
				tex_size_param, blend_param, sample_param;
	
	// anim 1
	anim_offsets_param = shader_get_sampler_index(sh_vat, "u_anim_offsets");
	anim_normals_param = shader_get_sampler_index(sh_vat, "u_anim_normals");
	frame_start_param = shader_get_uniform(sh_vat, "u_frame_start");
	frame_end_param = shader_get_uniform(sh_vat, "u_frame_end");
	offset_min_param = shader_get_uniform(sh_vat, "u_offset_min");
	offset_dist_param = shader_get_uniform(sh_vat, "u_offset_dist");
	loop_param = shader_get_uniform(sh_vat, "u_loop");
	time_param = shader_get_uniform(sh_vat, "u_time");
	
	// anim 2
	/*
	anim_offsets_old_param = shader_get_sampler_index(sh_vat, "u_anim_offsets_old");
	anim_normals_old_param = shader_get_sampler_index(sh_vat, "u_anim_normals_old");
	frame_count_old_param = shader_get_uniform(sh_vat, "u_frame_count_old");
	offset_min_old_param = shader_get_uniform(sh_vat, "u_offset_min_old");
	offset_dist_old_param = shader_get_uniform(sh_vat, "u_offset_dist_old");
	loop_old_param = shader_get_uniform(sh_vat, "u_loop_old");
	time_old_param = shader_get_uniform(sh_vat, "u_time_old");
	*/
	
	// shared
	tex_size_param = shader_get_uniform(sh_vat, "u_tex_size");
	blend_param = shader_get_uniform(sh_vat, "u_blend");
	sample_param = shader_get_uniform(sh_vat, "u_sample_num");
}


function AnimationManager(model_anims, anim_name, anim_end_func) constructor
{
	self.model_anims = model_anims;
	self.anim = model_anims.animations[? anim_name];
	self.anim_end_func = anim_end_func;
	self.time = 0;
	
	self.anim_old = undefined;
	self.time_old = 0;
	
	self.anim_over = false;
	self.blend = 0;
	self.sample_num = 5;
	self.sample_func = undefined;
	
	static set_shader_params = function()
	{
		// skip if the animation is not set
		if (self.anim == undefined)
			return;
		
		// anim 1
		texture_set_stage_vs(anim_offsets_param, self.model_anims.tex_offsets);
		texture_set_stage_vs(anim_normals_param, self.model_anims.tex_normals);
		shader_set_uniform_f(frame_start_param, self.anim.frame_start);
		shader_set_uniform_f(frame_end_param, self.anim.frame_end);
		shader_set_uniform_f(offset_min_param, self.anim.offset_min);
		shader_set_uniform_f(offset_dist_param, self.anim.offset_dist);
		shader_set_uniform_f(loop_param, self.anim.loop);
		shader_set_uniform_f(time_param, (self.time / self.model_anims.tex_size));
		
		// anim 2
		/*
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
		*/
		
		// shared
		shader_set_uniform_f(tex_size_param, self.model_anims.tex_size, self.model_anims.tex_size);
		shader_set_uniform_f(blend_param, self.blend);
		shader_set_uniform_f(sample_param, self.sample_num);
	}
	
	static step = function()
	{
		// skip if the animation is not set
		// or the animation is over
		if (self.anim == undefined or self.anim_over)
			return;
		
		/*
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
		*/
		
		// sample num
		if (self.sample_func != undefined)
		{
			self.sample_func();
		}
		
		// increment frame time
		self.time += dt * 60 * self.anim.speed * gspd;
		
		// animation over
		var frame_count = self.anim.frame_end - self.anim.frame_start;
		if (!self.anim_over and 
			(self.time >= frame_count or self.time <= -frame_count))
		{
			if (!self.anim.loop)
				self.anim_over = true;
			else
				self.time = 0;
			
			// call animation end function
			self.anim_end_func();
		}
	}
	
	static set_animation = function(anim_new)
	{
		self.anim = self.model_anims.animations[? anim_new];
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
	
	static set_sample_num = function(num, func=undefined)
	{
		self.sample_num = num;
		self.sample_func = func;
	}
	
	static get_animations_list = function()
	{
		return ds_map_keys_to_array(self.model_anims.animations);
	}
}




