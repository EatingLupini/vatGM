/// @description

// draw model
var m_x = x;
var m_y = y;
var m_z = 0;
var m_scale = WORLD_UNIT;

var matrix = matrix_build(m_x, m_y, m_z, 0, 0, rot_z, m_scale, m_scale, m_scale);
matrix_set(matrix_world, matrix);
inst.render();
matrix_set(matrix_world, matrix_build_identity());
