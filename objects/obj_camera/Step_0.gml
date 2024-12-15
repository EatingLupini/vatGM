/// @description

#region DEBUG

if (mouse_wheel_down())
	spd -= 0.1;
if (mouse_wheel_up())
	spd += 0.1;

#endregion

#region UPDATE MOVEMENT

// movement
var dir_ws = (keyboard_check(ord("W")) - keyboard_check(ord("S"))) * !is_paused;
var dir_da = (keyboard_check(ord("D")) - keyboard_check(ord("A"))) * !is_paused;
var dir_wasd = point_direction(xfrom, yfrom, xfrom + dir_ws, yfrom + dir_da);

if (view_type == VT_FREE)
{
	if (dir_ws != 0 or dir_da != 0)
	{
		xfrom += lengthdir_x(spd, dir + dir_wasd);
		yfrom += lengthdir_y(spd, dir + dir_wasd);
	}

	// fly up/down
	if (keyboard_check(vk_space))
		zfrom += spd;
	if (keyboard_check(vk_control))
		zfrom -= spd;
}
else if (view_type == VT_FIXED)
{
	if (dir_ws != 0 or dir_da != 0)
	{
		var xdiff = lengthdir_x(spd_max, dir_wasd + 90);
		var ydiff = lengthdir_y(spd_max, dir_wasd + 90);
	
		xfrom += xdiff;
		yfrom += ydiff;
		xto_old += xdiff;
		yto_old += ydiff;
	}
}

//mouse direction
if (!is_paused)
{
	if (view_type != VT_FIXED)
	{
		dir += ((display_get_width() * 0.5) -display_mouse_get_x()) * opt_sensitivity;
		zdir += ((display_get_height() * 0.5) -display_mouse_get_y()) * opt_sensitivity;
	
		if (view_type == VT_FREE)
			zdir = clamp(zdir, -89, 89);
		else if (view_type == VT_THIRD)
			zdir = clamp(zdir, -75, 75);
	}
}

#endregion

#region UPDATE CAMERA

if (!is_paused and window_has_focus())
{
	// free cam
	if (view_type == VT_FREE)
	{
		//camera to
		xto = xfrom + cos(degtorad(dir));
		yto = yfrom - sin(degtorad(dir));
		zto = zfrom + tan(degtorad(zdir));

		view_mat = matrix_build_lookat(xfrom, yfrom, zfrom, xto, yto, zto, 0, 0, 1);
		camera_set_view_mat(camera, view_mat);
	}
	
	// third person
	if (view_type == VT_THIRD)
	{
		if (instance_exists(obj_to_follow))
		{
			var xoff = dcos(dir + off_dir) * off_dist;
			var yoff = -dsin(dir + off_dir) * off_dist;
			
			dir_x = dcos(dir) * dcos(zdir);
			dir_y = -dsin(dir) * dcos(zdir);
			dir_z = dsin(zdir);
			
			// linear
			xfrom = xfrom_old + ((obj_to_follow.x + xoff + dir_x * dist) - xfrom_old) / num_diff * cur_diff;
			yfrom = yfrom_old + ((obj_to_follow.y + yoff + dir_y * dist) - yfrom_old) / num_diff * cur_diff;
			zfrom = zfrom_old + ((obj_to_follow.z + 48 + dir_z * dist) - zfrom_old) / num_diff * cur_diff;
			
			xto = xto_old + ((obj_to_follow.x + xoff) - xto_old) / num_diff * cur_diff;
			yto = yto_old + ((obj_to_follow.y + yoff) - yto_old) / num_diff * cur_diff;
			zto = zto_old + ((obj_to_follow.z + 48) - zto_old) / num_diff * cur_diff;
			
			if (cur_diff < num_diff)
				cur_diff += 1;
		
			view_mat = matrix_build_lookat(xfrom, yfrom, zfrom, xto, yto, zto, 0, 0, 1);
			camera_set_view_mat(camera, view_mat);
		}
		else
		{
			set_view_type(VT_FREE);
		}
	}
	
	// fixed
	if (view_type == VT_FIXED)
	{
		xfrom = lerp(xfrom, xto_old, 1 - power(0.2, dt * gspd));
		yfrom = lerp(yfrom, yto_old + fixed_yoff, 1 - power(0.2, dt * gspd));
		zfrom = lerp(zfrom, zto_old + fixed_zcur, 1 - power(0.2, dt * gspd));
		
		xto = xto_old;
		yto = yto_old;
		zto = zto_old;
		
		view_mat = matrix_build_lookat(xfrom, yfrom, zfrom, xto, yto, zto, 0, 0, 1);
		camera_set_view_mat(camera, view_mat);
	}
}

#endregion
