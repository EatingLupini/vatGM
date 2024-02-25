/// @description

model_info = models[? "zombie"];
anims_info = model_info[ANIMS];

anim = new AnimationManager(anims_info[2], function()
{
	//show_debug_message("Animation End: " + string(current_time / 1000));
});

inst = model_info[MODEL].new_instance();
inst.set_material(0, new TextureMaterialAnim(model_info[TEXTURE], 0, anim));

rot_z = 0;
