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

if (keyboard_check_pressed(ord("M")))
	is_minimap_enabled = !is_minimap_enabled;
	
if (keyboard_check_pressed(ord("N")))
	is_navgrid_enabled = !is_navgrid_enabled;

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
	// start selecting
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
		ds_list_clear(list_selected);
	}
	
	// select knights
	if (is_selecting and
		sel_screen_start[X] != sel_screen_end[X] and sel_screen_start[Y] != sel_screen_end[Y])
	{
		var ii_number = instance_number(obj_knight);
		for (var i=0; i<ii_number; i++)
		{
			// world to screen
			var ii = instance_find(obj_knight, i);
			var pos = world_to_screen(ii.x, ii.y, ii.z, cam.view_mat, cam.proj_mat);
			if (pos[X] >= 0)
			{
				var sel_start = [min(sel_screen_start[X], sel_screen_end[X]), min(sel_screen_start[Y], sel_screen_end[Y])];
				var sel_end = [max(sel_screen_start[X], sel_screen_end[X]), max(sel_screen_start[Y], sel_screen_end[Y])];
				ii.is_selected = point_in_rectangle(pos[X], pos[Y], sel_start[X], sel_start[Y], sel_end[X], sel_end[Y]);
				if (ii.is_selected)
					ds_list_add(list_selected, ii);
			}
		}
	}
}

// DEBUG
if (keyboard_check_pressed(ord("0")))
{
	with (obj_knight)
	{
		if (is_selected)
			anim_manager.change_animation("walk_forward");
		else
			anim_manager.change_animation("idle_4");
	}
}
#endregion

#region ORDERS
if (cam.view_type == VT_FIXED)
{
	if (device_mouse_check_button_pressed(0, mb_right))
	{
		var pos = screen_to_world(
						device_mouse_x_to_gui(0), device_mouse_y_to_gui(0),
						cam.view_mat, cam.proj_mat);
		for (var i=0; i<ds_list_size(list_selected); i++)
		{
			var ent = list_selected[| i];
			mp_grid_path(navgrid, ent.navpath, ent.x, ent.y, pos[X], pos[Y] , true);
			with (ent)
				path_start(navpath, 2, path_action_stop, true);
		}
	}
}
#endregion

