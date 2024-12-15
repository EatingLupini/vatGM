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

// knight
iik = instance_create_depth(384, 384, 0, obj_knight);

// BATCH of guards
var model_info = models[? "knight"];
var model_anims = model_info[ANIMS];

batches_count = 14;
batches_line =  2;
mbs = array_create(batches_count);
for (var bc=0; bc<batches_count; bc++)
{
	var model_batch = new DynamicModelBatch(model_info[MODEL]);
	var anims_batch = array_create(0);
	var num = 8;
	var sx = 512;
	var sy = 512;
	for (var j=0; j<num; j++)
	{
		for (var i=0; i<num; i++)
		{
			var asd = model_batch.add(
						(bc mod batches_line) * num * 64 + sx + 64 * i,
						(bc div batches_line) * num * 64 + sy + 64 * j,
						0, 0, 0, 0, WORLD_UNIT, WORLD_UNIT, WORLD_UNIT);
			
			var anim_manager = new AnimationManager(model_anims);
			if (i == 4)
				anim_manager.set_animation("run_forward");
			else
				anim_manager.set_animation("idle_4");
			anim_manager.set_default_blend_func(BLEND_LINEAR_3X);
			
			array_push(anims_batch, anim_manager);
		}
	}
	model_batch.set_material(0, new TextureMaterialAnimBatch(model_info[TEXTURE][0], 0, anims_batch));
	model_batch.build();
	model_batch.freeze();
	
	mbs[bc] = model_batch;
}

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

#region SHADER UNIFORMS
vat_u_tex_size = shader_get_uniform(sh_vat, "u_tex_size");
vat_u_anim_offsets = shader_get_sampler_index(sh_vat, "u_anim_offsets");
vat_u_anim_normals = shader_get_sampler_index(sh_vat, "u_anim_normals");
vat_u_active_anims = shader_get_uniform(sh_vat, "u_active_anims");
vat_u_frame_start = shader_get_uniform(sh_vat, "u_frame_start");
vat_u_frame_end = shader_get_uniform(sh_vat, "u_frame_end");
vat_u_offset_min = shader_get_uniform(sh_vat, "u_offset_min");
vat_u_offset_dist = shader_get_uniform(sh_vat, "u_offset_dist");
vat_u_loop = shader_get_uniform(sh_vat, "u_loop");
vat_u_time = shader_get_uniform(sh_vat, "u_time");
vat_u_blend = shader_get_uniform(sh_vat, "u_blend");
#endregion
