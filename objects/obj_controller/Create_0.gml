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
var ii = instance_create_depth(0, 0, 0, obj_prop, {model_info: models[? "castle"]});
ii.sprite_index = spr_coll_castle;
ii.image_xscale = 5;
ii.image_yscale = 5;

// tree
instance_create_depth(512, 512, 0, obj_prop, {model_info: models[? "tree"]});

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
is_selecting = false;
sel_screen_start = [0, 0];
sel_world_start = [0, 0];
sel_screen_end = [0, 0];
sel_world_end = [0, 0];
sel_world_v = [];

is_minimap_enabled = false;
#endregion

