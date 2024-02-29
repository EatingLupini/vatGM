/// @description

is_paused = false;
anim_time = 0;

#region SETTINGS

opt_fov = -90;
opt_sensitivity = 0.1;

#endregion

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

#endregion

#region ENTITIES

var num_zombies = 32;
for (var j=0; j<num_zombies; j++)
	for (var i=0; i<num_zombies; i++)
		instance_create_depth(32 + 64 * i, 32 + 64 * j, 0, obj_entity);

//instance_create_depth(32, 32, 0, obj_entity);

#endregion

#region BATCH

/*
model_zombie = load_model("zombie/zombie.obj");
batch = new StaticModelBatch(model_zombie);
batch.set_material(0, new TextureMaterialAnim(spr_tex_zombie, 0, current_anim, spr_anim_normals_zombie));
for (var j=0; j<10; j++)
{
	for (var i=0; i<10; i++)
	{
		if (i == 0 and j == 0)
			continue;
		batch.add(i * 64, j * 64, 0, 0, 0, irandom(360), 32, 32, 32);
	}
}
batch.build();
batch.freeze();
*/

#endregion


