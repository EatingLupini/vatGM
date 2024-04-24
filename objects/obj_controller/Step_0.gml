/// @description

#region DEBUG
if (keyboard_check_pressed(vk_f4))
	window_set_fullscreen(!window_get_fullscreen());
if (window_get_width() > 0 and  window_get_width() != surface_get_width(application_surface))
	surface_resize(application_surface, window_get_width(), window_get_height());

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
#endregion

#region PAUSE
if (keyboard_check_pressed(ord("P")))
{
	is_paused = !is_paused;
	window_set_cursor(is_paused ? cr_default : cr_none);
}
#endregion

#region CAMERA
if (instance_exists(cam))
{
	// free cam
	if (keyboard_check_pressed(ord("1")))
	{
		cam.set_view_type(VT_FREE);
		with (obj_knight)
			set_controlled(false);
	}
	
	// third person
	if (keyboard_check_pressed(ord("2")) and instance_exists(iik))
	{
		cam.set_view_type(VT_THIRD, iik);
		iik.set_controlled(true);
	}
	
	// rts cam
	if (keyboard_check_pressed(ord("3")))
	{
		cam.set_view_type(VT_FIXED);
		with (obj_knight)
			set_controlled(false);
	}
}
#endregion

#region SELECTION
if (cam.view_type == VT_FIXED)
{
	// strt selecting
	if (device_mouse_check_button_pressed(0, mb_left))
	{
		is_selecting = true;
		sel_screen_start = [device_mouse_x_to_gui(0), device_mouse_y_to_gui(0)];
		
		with (obj_knight)
			is_selected = false;
	}
	
	// stop selecting
	if (device_mouse_check_button_released(0, mb_left))
	{
		is_selecting = false;
	}
	
	// selecting
	if (is_selecting and device_mouse_check_button(0, mb_left))
	{
		sel_screen_end = [device_mouse_x_to_gui(0), device_mouse_y_to_gui(0)];
		
		if ((sel_screen_end[X] >= sel_screen_start[X] and sel_screen_end[Y] >= sel_screen_start[Y]) or
			(sel_screen_end[X] <= sel_screen_start[X] and sel_screen_end[Y] <= sel_screen_start[Y]))
		{
			sel_world_v[0] = screen_to_world(sel_screen_start[X], sel_screen_start[Y], cam.view_mat, cam.proj_mat);
			sel_world_v[1] = screen_to_world(sel_screen_end[X], sel_screen_start[Y], cam.view_mat, cam.proj_mat);
			sel_world_v[2] = screen_to_world(sel_screen_end[X], sel_screen_end[Y], cam.view_mat, cam.proj_mat);
			sel_world_v[3] = screen_to_world(sel_screen_start[X], sel_screen_end[Y], cam.view_mat, cam.proj_mat);
		}
		else
		{
			sel_world_v[0] = screen_to_world(sel_screen_start[X], sel_screen_end[Y], cam.view_mat, cam.proj_mat);
			sel_world_v[1] = screen_to_world(sel_screen_end[X], sel_screen_end[Y], cam.view_mat, cam.proj_mat);
			sel_world_v[2] = screen_to_world(sel_screen_end[X], sel_screen_start[Y], cam.view_mat, cam.proj_mat);
			sel_world_v[3] = screen_to_world(sel_screen_start[X], sel_screen_start[Y], cam.view_mat, cam.proj_mat);
		}
	}
	
	// select knights
	if (is_selecting and sel_screen_start[X] != sel_screen_end[X] and sel_screen_start[Y] != sel_screen_end[Y])
	{
		var ii_number = instance_number(obj_knight);
		for (var i=0; i<ii_number; i++)
		{
			// screen to world
			//var ii = instance_find(obj_knight, i);
			//ii.is_selected = point_in_quad(ii.x, ii.y, sel_world_v);
			
			// world to screen
			var ii = instance_find(obj_knight, i);
			var pos = world_to_screen(ii.x, ii.y, ii.z, obj_camera.view_mat, obj_camera.proj_mat);
			if (pos[X] >= 0)
				ii.is_selected = point_in_rectangle(pos[X], pos[Y], sel_screen_start[X], sel_screen_start[Y], sel_screen_end[X], sel_screen_end[Y]);
		}
	}
}
#endregion

