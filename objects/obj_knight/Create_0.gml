/// @description

model_info = models[? "knight"];
model_anims = model_info[ANIMS];

anim_manager = new AnimationManager(model_anims);
anim_manager.set_animation("idle_4");
anim_manager.set_default_blend_func(BLEND_LINEAR_3X);

inst = model_info[MODEL].new_instance();
inst.set_material(0, new TextureMaterialAnim(model_info[TEXTURE], 0, anim_manager));

z = 0;
rot_z = 0;

status = ST_IDLE;
dir = 0;
spd = 0;
spd_walk = 1;
spd_run = 3;





