/// @description
#macro ST_IDLE		0
#macro ST_WALKING	1
#macro ST_RUNNING	2


model_info = models[? "knight"];
model_anims = model_info[ANIMS];

anim_manager = new AnimationManager(model_anims);
anim_manager.set_animation("idle");

inst = model_info[MODEL].new_instance();
inst.set_material(0, new TextureMaterialAnim(model_info[TEXTURE], 0, anim_manager));

rot_z = 0;

state = ST_IDLE;
