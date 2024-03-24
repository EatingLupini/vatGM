/// @description

// third person
if (is_controlled)
{
	#region INPUT
	var vdir = keyboard_check(ord("S")) - keyboard_check(ord("W"));
	var hdir = keyboard_check(ord("D")) - keyboard_check(ord("A"));
	var shift = keyboard_check(vk_shift);
	var shift_press = keyboard_check_pressed(vk_shift);
	var shift_rel = keyboard_check_released(vk_shift);
	var jump = keyboard_check(vk_space);
	var attack = mouse_check_button_pressed(mb_left);
	var block = mouse_check_button_pressed(mb_right);
	var is_blocking = mouse_check_button(mb_right);
	#endregion

	#region MOVEMENT (old)
	/*
	var final_spd = 0;
	var final_dir = dir;
	if (instance_exists(obj_camera) and (hdir != 0 or vdir != 0))
	{
		var input_dir = point_direction(0, 0, hdir, vdir) - 90;
		final_dir = input_dir + obj_camera.dir;
	}

	if (hdir != 0 or vdir != 0)
	{
		final_spd = shift ? spd_run : spd_walk;
	
		if (status == ST_IDLE)
		{
			status = ST_WALK;
			if (shift)
			{
				status = ST_RUN;
				anim_manager.change_animation("run_forward");
			}
			else
			{
				status = ST_WALK;
				anim_manager.change_animation("walk_forward");
			}
		}
		if (status == ST_WALK)
		{
			if (shift)
			{
				status = ST_RUN;
				anim_manager.change_animation("run_forward");
			}
		}
		if (status == ST_RUN)
		{
			if (shift_rel)
			{
				status = ST_WALK;
				anim_manager.change_animation("walk_forward");
			}
		}
	}
	else
	{
		if (status == ST_WALK or status == ST_RUN)
		{
			status = ST_IDLE;
			anim_manager.change_animation("idle_4", BLEND_FRAMES_10);
		}
	
		final_spd = 0;
	}

	if (attack)
	{
		if (status != ST_ATTACK)
		{
			status = ST_ATTACK;
			anim_manager.change_animation("attack_4", BLEND_FRAMES_10, method(self, function() {
				self.status = ST_IDLE;
				self.anim_manager.change_animation("idle_4", BLEND_FRAMES_10);
			})).anim.speed = 0.6;
		}
	}

	if (block)
	{
		if (status == ST_IDLE or status == ST_WALK)
		{
			status = ST_BLOCK;
			anim_manager.change_animation("block_high", BLEND_FRAMES_10, method(self, function() {
				self.status = ST_BLOCK;
				self.anim_manager.change_animation("block_idle", BLEND_FRAMES_10);
			}));
		}
	}

	if (status == ST_BLOCK)
	{
		if (!is_blocking)
		{
			status = ST_IDLE;
			anim_manager.change_animation("idle_4", BLEND_FRAMES_10);
		}
	}


	// actual movement
	if (status != ST_TURN)
	{
		dir = angle_lerp(dir, final_dir, 0.1);
		rot_z = dir;
	}
	x += lengthdir_x(spd, dir);
	y += lengthdir_y(spd, dir);


	// increase/decrease speed
	spd = lerp(spd, final_spd, 0.2);
	*/
	#endregion
	
	#region MOVEMENT
	var has_input_move = hdir != 0 or vdir != 0;
	var can_change_dir = true;
	var can_idle = status == ST_WALK or status == ST_RUN;
	var can_walk = status == ST_IDLE or status == ST_WALK or status == ST_RUN;
	var can_run = status == ST_IDLE or status == ST_WALK or status == ST_RUN;
	var can_attack = status == ST_IDLE or status == ST_WALK or status == ST_RUN;
	var can_block = status == ST_IDLE or status == ST_WALK or status == ST_RUN;
	
	var final_spd = 0;
	var final_dir = dir;
	if (instance_exists(obj_camera) and has_input_move)
	{
		var input_dir = point_direction(0, 0, hdir, vdir) - 90;
		final_dir = input_dir + obj_camera.dir;
	}
	
	if (has_input_move)
	{
		if (can_run and shift)
		{
			status = ST_RUN;
			anim_manager.change_animation("run_forward");
			final_spd = spd_run;
		}
		else if (can_walk)
		{
			status = ST_WALK;
			anim_manager.change_animation("walk_forward");
			final_spd = spd_walk;
		}
	}
	else
	{
		if (can_idle)
		{
			status = ST_IDLE;
			anim_manager.change_animation("idle_4", BLEND_FRAMES_10);
		}
	}

	if (attack)
	{
		if (status != ST_ATTACK)
		{
			status = ST_ATTACK;
			anim_manager.change_animation("attack_4", BLEND_FRAMES_10, method(self, function() {
				self.status = ST_IDLE;
				self.anim_manager.change_animation("idle_4", BLEND_FRAMES_10);
			})).anim.speed = 0.6;
		}
	}

	if (block)
	{
		if (status == ST_IDLE or status == ST_WALK)
		{
			status = ST_BLOCK;
			anim_manager.change_animation("block_high", BLEND_FRAMES_10, method(self, function() {
				self.status = ST_BLOCK;
				self.anim_manager.change_animation("block_idle", BLEND_FRAMES_10);
			}));
		}
	}

	if (status == ST_BLOCK)
	{
		if (!is_blocking)
		{
			status = ST_IDLE;
			anim_manager.change_animation("idle_4", BLEND_FRAMES_10);
		}
	}


	// actual movement
	if (status != ST_TURN)
	{
		dir = angle_lerp(dir, final_dir, 0.1);
		rot_z = dir;
	}
	x += lengthdir_x(spd, dir);
	y += lengthdir_y(spd, dir);


	// increase/decrease speed
	// https://www.construct.net/en/blogs/ashleys-blog-2/using-lerp-delta-time-924
	var f = 0.9;
	spd = lerp(spd, final_spd, power(1 - f, dt)); // 0.2

	#endregion
}

// rts
else
{
	
}
