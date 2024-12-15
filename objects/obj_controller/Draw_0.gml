/// @description

// DEBUG
if (is_navgrid_enabled)
{
	shader_set(sh_zfight);
	mp_grid_draw(navgrid);
	shader_reset();
}

// BATCH
for (var i=0; i<batches_count; i++)
	mbs[i].render();


// CONTROLLED KNIGHT
var model_info = models[? "knight"];
var model_anims = model_info[ANIMS];

gpu_set_cullmode(cull_counterclockwise);

shader_set(sh_vat);
shader_set_uniform_f(vat_u_tex_size, model_anims.tex_size, model_anims.tex_size);
texture_set_stage_vs(vat_u_anim_offsets, model_anims.tex_offsets);
texture_set_stage_vs(vat_u_anim_normals, model_anims.tex_normals);

var c = self;
with (iik)
{
	self.anim_manager.step();
	var u = self.anim_manager.get_shader_params();
	shader_set_uniform_i(c.vat_u_active_anims, u.active_anims);
	shader_set_uniform_f_array(c.vat_u_frame_start, u.frame_start);
	shader_set_uniform_f_array(c.vat_u_frame_end, u.frame_end);
	shader_set_uniform_f_array(c.vat_u_offset_min, u.offset_min);
	shader_set_uniform_f_array(c.vat_u_offset_dist, u.offset_dist);
	shader_set_uniform_f_array(c.vat_u_loop, u.loop);
	shader_set_uniform_f_array(c.vat_u_time, u.time);
	shader_set_uniform_f_array(c.vat_u_blend, u.blend);
	event_perform(ev_other, ev_user0);
}
shader_reset();
