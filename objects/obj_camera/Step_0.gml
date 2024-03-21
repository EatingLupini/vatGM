/// @description

#region DEBUG

if (keyboard_check_pressed(vk_f4))
	window_set_fullscreen(!window_get_fullscreen());

if (keyboard_check_pressed(vk_escape))
	game_end();

if (keyboard_check(190))	// .
	gspd += 0.01;
if (keyboard_check(188))	// ,
	gspd -= 0.01;
if (keyboard_check(189))	// -
	gspd = 0;

if (keyboard_check_pressed(ord("L")))
	game_set_speed(game_get_speed(gamespeed_fps) == 30 ? 60 : 30, gamespeed_fps);

if (mouse_wheel_down())
	pl_spd -= 0.1;
if (mouse_wheel_up())
	pl_spd += 0.1;

if (keyboard_check_pressed(ord("F")))
{
	pl_direction = 0;
	pl_zdirection = 0;
	
	free_cam = !free_cam;
	if (!instance_exists(iik))
		free_cam = true;
}

#endregion

#region UPDATE MOVEMENT

// pause
if (keyboard_check_pressed(ord("P")))
{
	is_paused = !is_paused;
	window_set_cursor(is_paused ? cr_default : cr_none);
}

// movement
var dir_ws = (keyboard_check(ord("W")) - keyboard_check(ord("S"))) * !is_paused;
var dir_da = (keyboard_check(ord("D")) - keyboard_check(ord("A"))) * !is_paused;
var dir_wasd = point_direction(pl_x, pl_y, pl_x + dir_ws, pl_y + dir_da);

if (free_cam)
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
	pl_direction += ((display_get_width() * 0.5) -display_mouse_get_x()) * opt_sensitivity;
	pl_zdirection += ((display_get_height() * 0.5) -display_mouse_get_y()) * opt_sensitivity;
	pl_zdirection = clamp(pl_zdirection, -89, 89);
}

#endregion

#region UPDATE CAMERA

if (!is_paused and window_has_focus())
{
	// third person
	if (!free_cam and instance_exists(iik))
	{
		local_dir.x = dcos(pl_direction);
		local_dir.y = -dsin(pl_direction);
		local_dir.z = dsin(pl_zdirection);
		
		pl_x =  iik.x - local_dir.x * 32;
		pl_y =  iik.y - local_dir.y * 32;
		pl_z =  iik.z + 48 - local_dir.z * 32;
		
		cam_x = iik.x;
		cam_y = iik.y;
		cam_z = iik.z + 48;
		
		var m_look_at = matrix_build_lookat(pl_x, pl_y, pl_z, cam_x, cam_y, cam_z, 0, 0, 1);
		camera_set_view_mat(view_camera[0], m_look_at);
	}
	
	// free cam
	else
	{
		//camera to
		cam_x = pl_x + cos(degtorad(pl_direction));
		cam_y = pl_y - sin(degtorad(pl_direction));
		cam_z = pl_z + pl_zhigh + tan(degtorad(pl_zdirection));

		var m_look_at = matrix_build_lookat(pl_x, pl_y, pl_z + pl_zhigh, cam_x, cam_y, cam_z, 0, 0, 1);
		camera_set_view_mat(view_camera[0], m_look_at);
	}
}

#endregion
