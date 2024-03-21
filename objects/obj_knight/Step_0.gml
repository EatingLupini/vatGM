/// @description

#region INPUT
var vdir = keyboard_check(ord("S")) - keyboard_check(ord("W"));
var hdir = keyboard_check(ord("D")) - keyboard_check(ord("A"));
var shift = keyboard_check(vk_shift);
var shift_press = keyboard_check_pressed(vk_shift);
var shift_rel = keyboard_check_released(vk_shift);
var jump = keyboard_check(vk_space);
#endregion

#region MOVEMENT
var final_spd = 0;
var final_dir = dir;
if (instance_exists(obj_camera) and (hdir != 0 or vdir != 0))
{
	var input_dir = point_direction(0, 0, hdir, vdir) - 90;
	var cam_vec = [obj_camera.local_dir.x, obj_camera.local_dir.y];
	var v_rotated = vec2_rotate(cam_vec, input_dir);
	final_dir = point_direction(0, 0, v_rotated[0], v_rotated[1]);
}


if (hdir != 0 or vdir != 0)
{
	if (status == ST_IDLE)
	{
		status = ST_WALKING;
		if (shift)
		{
			status = ST_RUNNING;
			anim_manager.change_animation("run_forward");
		}
		else
		{
			status = ST_WALKING;
			anim_manager.change_animation("walk_forward");
		}
	}
	if (status == ST_WALKING)
	{
		if (shift)
		{
			status = ST_RUNNING;
			anim_manager.change_animation("run_forward");
		}
	}
	if (status == ST_RUNNING)
	{
		if (shift_rel)
		{
			status = ST_WALKING;
			anim_manager.change_animation("walk_forward");
		}
	}
	/*
	if (status != ST_TURNING)
	{
		if (angle_difference(dir, final_dir) >= 160)
		{
			status = ST_TURNING;
			anim_manager.change_animation("turn_left_180", BLEND_FIRST_FRAMES, function() {
				show_debug_message("END");
				obj_knight.status = ST_IDLE;
				obj_knight.dir += 180;
			});
		}
	}
	*/
	
	final_spd = shift ? spd_run : spd_walk;
}
else
{
	/*
	if (status == ST_IDLE)
	{
		anim_manager.set_animation("idle");
	}
	*/
	if (status == ST_WALKING or status == ST_RUNNING)
	{
		status = ST_IDLE;
		anim_manager.change_animation("idle", BLEND_FIRST_FRAMES);
	}
	
	final_spd = 0;
}

// actual movement
if (status != ST_TURNING)
	dir = angle_lerp(dir, final_dir, 0.1);
x += lengthdir_x(spd, dir);
y += lengthdir_y(spd, dir);
rot_z = dir;

// increase/decrease speed
spd = lerp(spd, final_spd, 0.2);

#endregion

