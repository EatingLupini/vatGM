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

// set projection matrix
var proj_mat = matrix_build_projection_perspective_fov(opt_fov, -view_get_wport(0)/view_get_hport(0), 1, 32000);
camera_set_proj_mat(camera, proj_mat);

// set camera
view_set_camera(0, camera);

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
dist = -32;	// -16;
off_dist = 8;
off_dir = -90;	// right

// speed
spd_min = 4;
spd_max = 8;
spd = spd_min;

#endregion

