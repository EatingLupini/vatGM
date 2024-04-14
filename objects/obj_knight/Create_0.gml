/// @description

model_info = models[? "knight"];
model_anims = model_info[ANIMS];

anim_manager = new AnimationManager(model_anims);
anim_manager.set_animation("idle_4");
anim_manager.set_default_blend_func(BLEND_LINEAR_3X);

inst = model_info[MODEL].new_instance();
for (var i=0; i<array_length(model_info[TEXTURE]); i++)
	inst.set_material(i, new TextureMaterialAnim(model_info[TEXTURE][i], 0, anim_manager));

z = 0;
rot_z = 0;

is_controlled = false;
status = ST_IDLE;
dir = 0;
spd = 0;
spd_walk = 60;
spd_run = 180;


#region FUNCS
set_controlled = function(controlled)
{
	is_controlled = controlled;
	spd = 0;
}
#endregion
