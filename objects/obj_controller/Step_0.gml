/// @description

#region DEBUG
if (keyboard_check_pressed(vk_f4))
	window_set_fullscreen(!window_get_fullscreen());
if (window_get_width() != surface_get_width(application_surface))
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
		sel_world_start = screen_to_world(sel_screen_start[X], sel_screen_start[Y], cam.view_mat, cam.proj_mat);
		show_debug_message("fx: {0}\nfy: {1}", sel_world_start[X], sel_world_start[Y]);
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
		sel_world_end = screen_to_world(sel_screen_end[X], sel_screen_end[Y], cam.view_mat, cam.proj_mat);
	}
}
#endregion

