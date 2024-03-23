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
		cam.view_type = VT_FREE;
	}
	
	// third person
	if (keyboard_check_pressed(ord("2")) and instance_exists(iik))
	{
		cam.view_type = VT_THIRD;
		cam.obj_to_follow = iik;
		//cam.dir = 0;
		//cam.zdir = 0;
	}
	
	// rts cam
	if (keyboard_check_pressed(ord("3")))
	{
		// ...
	}
}
#endregion

