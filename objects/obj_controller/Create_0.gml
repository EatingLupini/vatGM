/// @description

#region 3D SETTINGS

//enable z-buffer
gpu_set_zwriteenable(true);	//Enables writing to the z-buffer
gpu_set_ztestenable(true);	//Enables the depth testing, so far away things are drawn beind closer things

//settings
gpu_set_cullmode(cull_counterclockwise);
gpu_set_texrepeat(true);
gpu_set_texfilter(false);
//gpu_set_tex_mip_enable(mip_on);

//force draw depth
layer_force_draw_depth(true, 0);

#endregion

#region ENTITIES

// skybox
instance_create_depth(0, 0, 0, obj_skybox);

// castle
instance_create_depth(0, 0, 0, obj_castle);

// tree
instance_create_depth(512, 512, 0, obj_tree);

// guards
var num = 30;
var sx = 512;
var sy = 512;
for (var j=0; j<num; j++)
	for (var i=0; i<num; i++)
		instance_create_depth(sx + 64 * i, sy + 64 * j, 0, obj_knight);
		
// knight
iik = instance_create_depth(384, 384, 0, obj_knight);

#endregion

#region CAMERA

cam = instance_create_depth(0, 0, 0, obj_camera);

#endregion

#region VARS
is_minimap_enabled = false;
is_navgrid_enabled = false;
is_selecting = false;
sel_screen_start = [0, 0];
sel_world_start = [0, 0];
sel_screen_end = [0, 0];
sel_world_end = [0, 0];
sel_world_v = [];
list_selected = ds_list_create();

// set navgrid collisions
navgrid = mp_grid_create(0, 0, room_width / 16, room_height / 16, 16, 16);
alarm[0] = 1;
#endregion

