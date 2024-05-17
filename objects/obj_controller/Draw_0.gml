/// @description

if (is_navgrid_enabled)
{
	shader_set(sh_zfight);
	mp_grid_draw(navgrid);
	shader_reset();
}

// draw knight
var model_info = models[? "knight"];
var model_anims = model_info[ANIMS];

gpu_set_cullmode(cull_counterclockwise);

shader_set(sh_vat);
shader_set_uniform_f(tex_size_param, model_anims.tex_size, model_anims.tex_size);
texture_set_stage_vs(anim_offsets_param, model_anims.tex_offsets);
texture_set_stage_vs(anim_normals_param, model_anims.tex_normals);
with (obj_knight)
{
	anim_manager.step();
	anim_manager.set_shader_params();
	event_perform(ev_other, ev_user0);
}
shader_reset();
