
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
	
	// linear blend
	self.blend_default = function(frame_current, frame_count) {
		return (1 / frame_count) * frame_current;
	}
	
	// anims data
	self.params = {};
	self.active_anims = 0;
	self.frame_start = array_create(self.MAX_ANIMS);
	self.frame_end = array_create(self.MAX_ANIMS);
	self.offset_min = array_create(self.MAX_ANIMS);
	self.offset_dist = array_create(self.MAX_ANIMS);
	self.loop = array_create(self.MAX_ANIMS);
	self.time = array_create(self.MAX_ANIMS);
	self.blend = array_create(self.MAX_ANIMS);
	
	static get_shader_params = function()
	{
		self.active_anims = array_length(self.play_anims);
		
		// skip if no animations are set
		if (self.active_anims <= 0)
			return;
		
		for (var i=0; i<self.active_anims; i++)
		{
			var play_anim = self.play_anims[i];
			self.frame_start[i] = play_anim.anim.frame_start;
			self.frame_end[i] = play_anim.anim.frame_end;
			self.offset_min[i] = play_anim.anim.offset_min;
			self.offset_dist[i] = play_anim.anim.offset_dist;
			self.loop[i] = play_anim.anim.loop;
			self.time[i] = play_anim.time / self.model_anims.tex_size;
			self.blend[i] = play_anim.get_blend();
		}
		
		self.params.tex_size = self.model_anims.tex_size;
		self.params.anim_offsets = self.model_anims.tex_offsets;
		self.params.anim_normals = self.model_anims.tex_normals;
		self.params.active_anims = self.active_anims;
		self.params.frame_start = self.frame_start;
		self.params.frame_end = self.frame_end;
		self.params.offset_min = self.offset_min;
		self.params.offset_dist = self.offset_dist;
		self.params.loop = self.loop;
		self.params.time = self.time;
		self.params.blend = self.blend;
		
		return self.params;
	}
	
	static step = function()
	{
		self.active_anims = array_length(self.play_anims);
		
		// skip if no animations are set
		if (self.active_anims <= 0)
			return;
		
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
	
	static get_animations_list = function()
	{
		return ds_map_keys_to_array(self.model_anims.animations);
	}
	
	static check_animation = function(anim_name)
	{
		return ds_map_exists(self.model_anims.animations, anim_name);
	}
}




