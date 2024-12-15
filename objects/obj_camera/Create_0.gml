/// @description

view_type = VT_FREE;
obj_to_follow = noone;
anim_time = 0;

#region SETTINGS

opt_fov = -90;
opt_sensitivity = 0.1;

#endregion

#region SETUP CAMERA

// hide cursor
window_set_cursor(cr_none);

// enable camera
view_enabled = true;
view_set_visible(0, true);

// create camera
camera = camera_create();

// set view matrix
view_mat = matrix_build_lookat(0, 0, 0, 1, 0, 0, 0, 0, 1);
camera_set_view_mat(camera, view_mat);

// set projection matrix
proj_mat = matrix_build_projection_perspective_fov(opt_fov, -view_get_wport(0)/view_get_hport(0), 1, 32000);
camera_set_proj_mat(camera, proj_mat);

// set camera
view_set_camera(0, camera);

// resize surface
//surface_resize(application_surface, 1920, 1080);
//surface_resize(application_surface, 640, 360);

#endregion

#region CAMERA VARS

xfrom = 0;
yfrom = 0;
zfrom = 0;

xto = 0;
yto = 0;
zto = 0;

dir_x = 0;
dir_y = 0;
dir_z = 0;

dir = 0;
zdir = 0;

// third person offset
dist = -32;		// distance from the object to follow
off_dist = 0;	// offset distance
off_dir = -90;	// offset direction (-90 -> right)

// rts offset
fixed_zoff = 384;
fixed_yoff = 256;
fixed_zcur = fixed_zoff;

// misc
num_diff = 60;
cur_diff = num_diff;
xfrom_old = 0;
yfrom_old = 0;
zfrom_old = 0;
xto_old = 0;
yto_old = 0;
zto_old = 0;

// speed
spd_min = 8;
spd_max = 16;
spd = spd_min;

#endregion

#region FUNCS
set_view_type = function(type, otf=noone)
{
	if (view_type != type)
	{
		switch (type)
		{
			case VT_FREE:
				view_type = VT_FREE;
				obj_to_follow = noone;
				window_set_cursor(cr_none);
				break;
			
			case VT_THIRD:
				view_type = VT_THIRD;
				obj_to_follow = otf;
				window_set_cursor(cr_none);
				cur_diff = 0;
				xfrom_old = xfrom;
				yfrom_old = yfrom;
				zfrom_old = zfrom;
				xto_old = xto;
				yto_old = yto;
				zto_old = zto;
				break;
			
			case VT_FIXED:
				view_type = VT_FIXED;
				obj_to_follow = noone;
				window_set_cursor(cr_default);
				fixed_zcur = fixed_zoff;
				xto_old = xto;
				yto_old = yto;
				zto_old = zto;
				break;
		}
	}
}

get_view_type = function()
{
	return view_type;
}
#endregion
