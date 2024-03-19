/// @description

model_info = models[? "knight"];
model_anims = model_info[ANIMS];

anim_manager = new AnimationManager(model_anims);

current_anim = 0;
list_anims_name = anim_manager.get_animations_list();

dist = 0;
a = 0;
anim_manager.set_sample_num(1, function()
{
	/*
	var sample_num_max = 50;
	var dist_max = 128;
	dist = point_distance_3d(x, y, 0, obj_camera.pl_x, obj_camera.pl_y, obj_camera.pl_z);
	
	a = sample_num_max / dist_max * dist;
	a = sample_num_max - clamp(a, 0, sample_num_max);
	anim_manager.sample_num = 2 + round(a);
	*/
	
	if (point_distance_3d(x, y, 0, obj_camera.pl_x, obj_camera.pl_y, obj_camera.pl_z) >= 128)
		anim_manager.sample_num = 1.0;
	else
		anim_manager.sample_num = 10.0;
	
});

inst = model_info[MODEL].new_instance();
inst.set_material(0, new TextureMaterialAnim(model_info[TEXTURE], 0, anim_manager));

rot_z = 0;
