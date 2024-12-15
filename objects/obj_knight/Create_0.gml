/// @description

model_info = models[? "knight"];
model_anims = model_info[ANIMS];

anim_manager = new AnimationManager(model_anims);
anim_manager.set_animation("idle_4");
anim_manager.set_default_blend_func(BLEND_LINEAR_3X);

inst = model_info[MODEL].new_instance();

z = 0;
rot_z = 0;
radius = 16;

is_controlled = false;
is_selected = false;
status = ST_IDLE;
dir = 0;
spd = 0;
spd_walk = 60;
spd_run = 180;
mask_index = spr_coll_knight;

navpath = path_add();
path_set_kind(navpath, true);
path_set_precision(navpath, 2);

#region FUNCS
set_controlled = function(controlled)
{
	is_controlled = controlled;
	spd = 0;
}
#endregion
