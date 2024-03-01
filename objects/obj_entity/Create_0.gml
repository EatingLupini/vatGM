/// @description

model_info = models[? "zombie"];
anims_info = model_info[ANIMS];

anim_manager = new AnimationManager(anims_info[2], function()
{
	//show_debug_message("Animation End: " + string(current_time / 1000));
});

anim_manager.set_sample_num(1, function() {
	var dist = point_distance_3d(x, y, 0, obj_camera.pl_x, obj_camera.pl_y, obj_camera.pl_z);
	var a = 4 / dist;
	
	/*
	if (point_distance_3d(x, y, 0, obj_camera.pl_x, obj_camera.pl_y, obj_camera.pl_z) >= 128)
		anim_manager.sample_num = 1.0;
	else
		anim_manager.sample_num = 5.0;
	*/
});


inst = model_info[MODEL].new_instance();
inst.set_material(0, new TextureMaterialAnim(model_info[TEXTURE], 0, anim_manager));

rot_z = 0;
