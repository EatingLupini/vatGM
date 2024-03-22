/// @description

#region 3D SETTINGS

//enable z-buffer
gpu_set_zwriteenable(true);	//Enables writing to the z-buffer
gpu_set_ztestenable(true);	//Enables the depth testing, so far away things are drawn beind closer things

//settings
gpu_set_cullmode(cull_counterclockwise);
gpu_set_texrepeat(false);
gpu_set_texfilter(false);
//gpu_set_tex_mip_enable(mip_on);

//force draw depth
layer_force_draw_depth(true, 0);

#endregion

#region ENTITIES
/*
var num_zombies = 32;
for (var j=0; j<num_zombies; j++)
	for (var i=0; i<num_zombies; i++)
		instance_create_depth(32 + 64 * i, 32 + 64 * j, 0, obj_entity);
*/

// instance_create_depth(32, 32, 0, obj_entity);

iik = instance_create_depth(32, 32, 0, obj_knight);

#endregion

#region CAMERA

cam = instance_create_depth(0, 0, 0, obj_camera);

#endregion
