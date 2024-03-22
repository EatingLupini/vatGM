/// @description

#region DEBUG

if (mouse_wheel_down())
	pl_spd -= 0.1;
if (mouse_wheel_up())
	pl_spd += 0.1;

#endregion

#region UPDATE MOVEMENT

// movement
var dir_ws = (keyboard_check(ord("W")) - keyboard_check(ord("S"))) * !is_paused;
var dir_da = (keyboard_check(ord("D")) - keyboard_check(ord("A"))) * !is_paused;
var dir_wasd = point_direction(pl_x, pl_y, pl_x + dir_ws, pl_y + dir_da);

if (view_type == VT_FREE)
{
	if (dir_ws != 0 or dir_da != 0)
	{
		pl_x += lengthdir_x(pl_spd, pl_direction + dir_wasd);
		pl_y += lengthdir_y(pl_spd, pl_direction + dir_wasd);
	}

	// fly up/down
	if (keyboard_check(vk_space))
		pl_z += pl_spd;
	if (keyboard_check(vk_control))
		pl_z -= pl_spd;
}

//mouse direction
if (!is_paused)
{
	if (view_type != VT_FIXED)
	{
		pl_direction += ((display_get_width() * 0.5) -display_mouse_get_x()) * opt_sensitivity;
		pl_zdirection += ((display_get_height() * 0.5) -display_mouse_get_y()) * opt_sensitivity;
	
		if (view_type == VT_FREE)
			pl_zdirection = clamp(pl_zdirection, -89, 89);
		else if (view_type == VT_THIRD)
			pl_zdirection = clamp(pl_zdirection, -75, 75);
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
		cam_x = pl_x + cos(degtorad(pl_direction));
		cam_y = pl_y - sin(degtorad(pl_direction));
		cam_z = pl_z + pl_zhigh + tan(degtorad(pl_zdirection));

		var m_look_at = matrix_build_lookat(pl_x, pl_y, pl_z + pl_zhigh, cam_x, cam_y, cam_z, 0, 0, 1);
		camera_set_view_mat(view_camera[0], m_look_at);
	}
	
	// third person
	if (view_type == VT_THIRD)
	{
		if (instance_exists(attached_to))
		{
			local_dir.x = dcos(pl_direction) * dcos(pl_zdirection);
			local_dir.y = -dsin(pl_direction) * dcos(pl_zdirection);
			local_dir.z = dsin(pl_zdirection);
		
			pl_x =  attached_to.x - local_dir.x * 32;
			pl_y =  attached_to.y - local_dir.y * 32;
			pl_z =  attached_to.z + 48 - local_dir.z * 32;
		
			cam_x = attached_to.x;
			cam_y = attached_to.y;
			cam_z = attached_to.z + 48;
		
			var m_look_at = matrix_build_lookat(pl_x, pl_y, pl_z, cam_x, cam_y, cam_z, 0, 0, 1);
			camera_set_view_mat(view_camera[0], m_look_at);
		}
		else
		{
			attached_to = noone;
			view_type = VT_FREE;
		}
	}
}

#endregion
