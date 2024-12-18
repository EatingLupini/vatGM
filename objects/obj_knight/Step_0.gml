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
	var jump = keyboard_check_pressed(vk_space);
	var attack = mouse_check_button_pressed(mb_left);
	var block = mouse_check_button(mb_right);
	#endregion

	#region MOVEMENT
	var has_input_move = hdir != 0 or vdir != 0;
	var can_change_dir = status != ST_ATTACK and status != ST_BLOCK;
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
		if (can_attack)
		{
			status = ST_ATTACK;
			var new_anim = anim_manager.change_animation("stand_slash_4", BLEND_FRAMES_10, method(self, function() {
				self.status = ST_IDLE;
				self.anim_manager.change_animation("idle_4", BLEND_FRAMES_10);
			}));
			if (new_anim != undefined)
				new_anim.anim.speed = 0.6;
		}
	}

	if (block)
	{
		if (can_block)
		{
			status = ST_BLOCK;
			var new_anim = anim_manager.change_animation("block_high", BLEND_FRAMES_10, method(self, function() {
				if (self.status == ST_BLOCK)
					self.anim_manager.change_animation("block_idle", BLEND_FRAMES_10);
			}));
			if (new_anim != undefined)
				new_anim.anim.speed = 1;
		}
	}
	else
	{
		if (status == ST_BLOCK)
		{
			status = ST_IDLE;
			anim_manager.change_animation("idle_4", BLEND_FRAMES_10);
		}
	}

	// actual movement
	if (can_change_dir)
	{
		dir = angle_lerp(dir, final_dir, 0.001);
		rot_z = dir;
	}
	
	// collision
	var max_angle = 90;
	for (var i=0; i<max_angle; i+=10)
	{
		var a = 1 - (1 / max_angle * i);
		
		var xnew = x + lengthdir_x(spd * a * dt * gspd, dir + i);
		var ynew = y + lengthdir_y(spd * a * dt * gspd, dir + i);
		if (collision_circle(xnew, ynew, radius, obj_prop, true, false) == noone)
		{
			x = xnew;
			y = ynew;
			break;
		}
		
		xnew = x + lengthdir_x(spd * a * dt * gspd, dir - i);
		ynew = y + lengthdir_y(spd * a * dt * gspd, dir - i);
		if (collision_circle(xnew, ynew, radius, obj_prop, true, false) == noone)
		{
			x = xnew;
			y = ynew;
			break;
		}
	}

	// increase/decrease speed
	spd = lerp(spd, final_spd, 1 - power(0.0005, dt * gspd));

	#endregion
}

// rts
else
{
	var can_idle = status == ST_WALK or status == ST_RUN;
	if (can_idle)
	{
		status = ST_IDLE;
		anim_manager.change_animation("idle_4", BLEND_FRAMES_10);
	}
}
