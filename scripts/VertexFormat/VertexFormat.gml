/**
 * Initializes vertex buffer formats used by the importer.
 */
function init_buffer_formats()
{
	if (!variable_global_exists("buffer_format_size"))
	{
		//Create the default vertex buffer format.
		vertex_format_begin();
		vertex_format_add_position_3d();
		vertex_format_add_texcoord();
		vertex_format_add_color();
		vertex_format_add_normal();
		vertex_format_add_custom(vertex_type_float1, vertex_usage_texcoord);
		global.buffer_format = vertex_format_end();
		global.buffer_format_size = 3 * 4 + 2 * 4 + 4 + 3 * 4;
	}

	if (!variable_global_exists("dynamic_batch_buffer_format"))
	{
		//Create the default vertex buffer format.
		vertex_format_begin();
		vertex_format_add_position_3d();
		vertex_format_add_texcoord();
		vertex_format_add_color();
		vertex_format_add_normal();
		vertex_format_add_custom(vertex_type_float1, vertex_usage_texcoord);
		global.dynamic_batch_buffer_format = vertex_format_end();
		global.dynamic_batch_buffer_format_size = 3 * 4 + 2 * 4 + 4 + 3 * 4 + 4;
	}
	
}