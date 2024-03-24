/// @description

show_debug_message(string(surface_get_width(application_surface)));
show_debug_message(string(surface_get_height(application_surface)));


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
		var xnew = xfrom + lengthdir_x(spd, dir + dir_wasd);
		var ynew = yfrom + lengthdir_y(spd, dir + dir_wasd);
		if (collision_point(xnew, ynew, obj_prop, true, false) == noone)
		{
			xfrom += lengthdir_x(spd, dir + dir_wasd);
			yfrom += lengthdir_y(spd, dir + dir_wasd);
		}
	}

	// fly up/down
	if (keyboard_check(vk_space))
		zfrom += spd;
	if (keyboard_check(vk_control))
		zfrom -= spd;
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

		var m_look_at = matrix_build_lookat(xfrom, yfrom, zfrom, xto, yto, zto, 0, 0, 1);
		camera_set_view_mat(view_camera[0], m_look_at);
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
			
			xfrom =  obj_to_follow.x + xoff + dir_x * dist;
			yfrom =  obj_to_follow.y + yoff + dir_y * dist;
			zfrom =  obj_to_follow.z + 48 + dir_z * dist;
		
			xto = obj_to_follow.x + xoff;
			yto = obj_to_follow.y + yoff;
			zto = obj_to_follow.z + 48;
		
			var m_look_at = matrix_build_lookat(xfrom, yfrom, zfrom, xto, yto, zto, 0, 0, 1);
			camera_set_view_mat(view_camera[0], m_look_at);
		}
		else
		{
			obj_to_follow = noone;
			view_type = VT_FREE;
		}
	}
}

#endregion
