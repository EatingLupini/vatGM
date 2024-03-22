/// @description

#macro VT_FREE		0
#macro VT_THIRD		1
#macro VT_FIXED		2

view_type = VT_FREE;
attached_to = noone;
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

pl_x = 0;
pl_y = 0;
pl_z = 0;

cam_x = 0;
cam_y = 0;
cam_z = 0;

pl_zhigh = 64;

pl_direction = 0;
pl_zdirection = 0;

pl_spd_min = 4;
pl_spd_max = 8;
pl_spd = pl_spd_min;

// for third person
local_dir = {x: 0, y: 0, z: 0};

#endregion

