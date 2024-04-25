/// @description

// SELECTION
if (is_selecting or ds_list_size(list_selected) > 0)
{
	// https://forum.gamemaker.io/index.php?threads/how-to-read-a-gml-buffer-inside-of-a-shader-gms-1-4.95635/post-575772
	if (!surface_exists(sel_surf))
		sel_surf = surface_create(32, 32, surface_rgba16float);
	buffer_set_surface(sel_buffer, sel_surf, 0);
	
	var sel_surf_tex = surface_get_texture(sel_surf);
	shader_set(sh_selection);
	shader_set_uniform_i(u_num_ent, sel_num_ent);
	texture_set_stage(u_sel_ent, sel_surf_tex);
	draw_sprite_stretched(spr_selection, 0, 0, 0, room_width, room_height);
	shader_reset();
}
