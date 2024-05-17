function init_animations()
{
	globalvar	tex_size_param, anim_offsets_param, anim_normals_param,
				active_anims_param, frame_start_param, frame_end_param,
				offset_min_param, offset_dist_param, loop_param, time_param,
				blend_param, sample_param;
	
	// anim
	tex_size_param = shader_get_uniform(sh_vat, "u_tex_size");
	anim_offsets_param = shader_get_sampler_index(sh_vat, "u_anim_offsets");
	anim_normals_param = shader_get_sampler_index(sh_vat, "u_anim_normals");
	active_anims_param = shader_get_uniform(sh_vat, "u_active_anims");
	frame_start_param = shader_get_uniform(sh_vat, "u_frame_start");
	frame_end_param = shader_get_uniform(sh_vat, "u_frame_end");
	offset_min_param = shader_get_uniform(sh_vat, "u_offset_min");
	offset_dist_param = shader_get_uniform(sh_vat, "u_offset_dist");
	loop_param = shader_get_uniform(sh_vat, "u_loop");
	time_param = shader_get_uniform(sh_vat, "u_time");
	blend_param = shader_get_uniform(sh_vat, "u_blend");
	
	// settings
	sample_param = shader_get_uniform(sh_vat, "u_sample_num");
}

function PlayAnimation(anim, blend_func=undefined, end_func=undefined) constructor
{
	self.anim = anim;
	self.time = 0;
	self.is_over = false;
	
	self.blend_func = blend_func;
	self.end_func = end_func;
	
	static get_blend = function()
	{
		if (self.blend_func == undefined)
			return 1;
		
		var frame_current = self.time;
		var frame_count = self.anim.frame_end - self.anim.frame_start;
		return min(self.blend_func(frame_current, frame_count), 1);
	}
}


function AnimationManager(model_anims) constructor
{
	self.MAX_ANIMS = 5;
	
	self.model_anims = model_anims;
	self.play_anims = [];
	
	self.sample_num = 5;
	self.sample_func = undefined;
	
	// linear blend
	self.blend_default = function(frame_current, frame_count) {
		return (1 / frame_count) * frame_current;
	}
	
	// anims data
	self.active_anims = 0;
	self.frame_start = array_create(self.MAX_ANIMS);
	self.frame_end = array_create(self.MAX_ANIMS);
	self.offset_min = array_create(self.MAX_ANIMS);
	self.offset_dist = array_create(self.MAX_ANIMS);
	self.loop = array_create(self.MAX_ANIMS);
	self.time = array_create(self.MAX_ANIMS);
	self.blend = array_create(self.MAX_ANIMS);
	
	static set_shader_params = function()
	{
		self.active_anims = array_length(self.play_anims);
		
		// skip if no animations are set
		if (self.active_anims <= 0)
			return;
		
		for (var i=0; i<self.active_anims; i++)
		{
			var play_anim = self.play_anims[i];
			frame_start[i] = play_anim.anim.frame_start;
			frame_end[i] = play_anim.anim.frame_end;
			offset_min[i] = play_anim.anim.offset_min;
			offset_dist[i] = play_anim.anim.offset_dist;
			loop[i] = play_anim.anim.loop;
			time[i] = play_anim.time / self.model_anims.tex_size;
			blend[i] = play_anim.get_blend();
		}
		
		// shader_set_uniform_f(tex_size_param, self.model_anims.tex_size, self.model_anims.tex_size);
		// texture_set_stage_vs(anim_offsets_param, self.model_anims.tex_offsets);
		// texture_set_stage_vs(anim_normals_param, self.model_anims.tex_normals);
		shader_set_uniform_i(active_anims_param, self.active_anims);
		shader_set_uniform_f_array(frame_start_param, self.frame_start);
		shader_set_uniform_f_array(frame_end_param, self.frame_end);
		shader_set_uniform_f_array(offset_min_param, self.offset_min);
		shader_set_uniform_f_array(offset_dist_param, self.offset_dist);
		shader_set_uniform_f_array(loop_param, self.loop);
		shader_set_uniform_f_array(time_param, self.time);
		shader_set_uniform_f_array(blend_param, self.blend);
		
		// settings
		shader_set_uniform_f(sample_param, self.sample_num);
	}
	
	static step = function()
	{
		self.active_anims = array_length(self.play_anims);
		
		// skip if no animations are set
		if (self.active_anims <= 0)
			return;
		
		// sample num
		if (self.sample_func != undefined)
		{
			self.sample_func();
		}
		
		// increment frame time
		for (var i=0; i<self.active_anims; i++)
		{
			var play_anim = self.play_anims[i];
			play_anim.time += dt * 60 * play_anim.anim.speed * gspd;
		}
		
		// pop old animation
		if (self.active_anims >= 2)
		{
			if (self.play_anims[1].get_blend() >= 1)
			{
				self.play_anims[1].blend_func = undefined;
				array_shift(self.play_anims);
				self.active_anims -= 1;
			}
		}
		
		// animation over
		for (var i=0; i<self.active_anims; i++)
		{
			var play_anim = self.play_anims[i];
			var frame_count = play_anim.anim.frame_end - play_anim.anim.frame_start;
			if (!play_anim.is_over and 
				(play_anim.time >= frame_count or play_anim.time <= -frame_count))
			{
				// loop
				if (!play_anim.anim.loop)
					play_anim.is_over = true;
				else
					play_anim.time = 0;
			
				// call animation end function
				if (play_anim.end_func != undefined)
					play_anim.end_func();
			}
		}
	}
	
	static set_animation = function(anim_new)
	{
		// check animation exists
		if (!self.check_animation(anim_new))
			throw(string("Animation \"{0}\" does not exists.", anim_new));
		
		var play_anim = new PlayAnimation(self.model_anims.animations[? anim_new]);
		self.play_anims = [play_anim];
		
		return play_anim;
	}
	
	static change_animation = function(anim_new, blend_func=self.blend_default, end_func=undefined)
	{
		// check animation exists
		if (!self.check_animation(anim_new))
			throw(string("Animation \"{0}\" does not exists.", anim_new));
		
		// check max anims
		if (array_length(self.play_anims) >= self.MAX_ANIMS)
		{
			show_debug_message("Too many animations");
			return;
		}
		
		// check same anim
		var last_anim = array_last(self.play_anims);
		if (last_anim != undefined and last_anim.anim.name == anim_new)
			return;
		
		// add anim to the queue
		var play_anim = new PlayAnimation(self.model_anims.animations[? anim_new], blend_func, end_func);
		array_push(self.play_anims, play_anim);
		
		return play_anim;
	}
	
	static set_default_blend_func = function(blend_func)
	{
		self.blend_default = blend_func;
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
	
	static check_animation = function(anim_name)
	{
		return ds_map_exists(self.model_anims.animations, anim_name);
	}
}




