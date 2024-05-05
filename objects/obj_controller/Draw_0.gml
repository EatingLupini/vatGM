/// @description

if (is_navgrid_enabled)
{
	shader_set(sh_zfight);
	mp_grid_draw(navgrid);
	shader_reset();
}
