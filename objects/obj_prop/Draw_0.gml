/// @description

var m_scale = image_xscale * WORLD_UNIT;
var matrix = matrix_build(x, y, z, 0, 0, 0, m_scale, m_scale, m_scale);
matrix_set(matrix_world, matrix);
inst.render();
matrix_set(matrix_world, matrix_build_identity());

