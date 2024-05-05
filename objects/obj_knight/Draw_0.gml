/// @description

if (is_selected)
{
	shader_set(sh_zfight)
	draw_sprite(spr_selection, 0, x, y);
	shader_reset();
}

// draw model
//if (point_in_camera(x, y, z, obj_camera.view_mat, obj_camera.proj_mat))
{
	var matrix = matrix_build(x, y, z, 0, 0, rot_z, WORLD_UNIT, WORLD_UNIT, WORLD_UNIT);
	matrix_set(matrix_world, matrix);
	inst.render();
	matrix_set(matrix_world, matrix_build_identity());
}
