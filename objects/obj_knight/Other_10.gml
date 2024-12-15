/// @description

var matrix = matrix_build(x, y, z, 0, 0, rot_z, WORLD_UNIT, WORLD_UNIT, WORLD_UNIT);
matrix_set(matrix_world, matrix);
inst.render_without_materials(model_info[TEXTURE]);
matrix_set(matrix_world, matrix_build_identity());
