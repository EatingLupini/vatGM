/**
 * The boundig box of a model.
 * @param {array<real>} [min_pos]=[0, 0, 0] Position of the corner that is nearest from the (0, 0, 0) origin.
 * @param {array<real>} [max_pos]=[0, 0, 0] Position of the corner that is farthest from the (0, 0, 0) origin.
 */
function ModelBBox(min_pos = [0, 0, 0], max_pos = [0, 0, 0]) constructor
{
	self.min_pos = min_pos;
	self.max_pos = max_pos;
	
	/**
	 * Returns an array containing the position of the 2 opposite corners of the bbox.
	 * @returns {array<array<real>>} Array containing the 2 opposite corners of the bbox
	 */
	static get_raw = function()
	{
		return [self.min_pos, self.max_pos];
	}
	
	/**
	 * Returns the coordinates and size of the bbox based on the center on its center.
	 * @returns {struct} Description
	 */
	static get_coordinates = function()
	{
	    return 
	    {
	        x : (self.min_pos[0] + self.max_pos[0]) / 2,
	        y : (self.min_pos[1] + self.max_pos[1]) / 2,
	        z : (self.min_pos[2] + self.max_pos[2]) / 2,
	        sizex : self.max_pos[0] - self.min_pos[0],
	        sizey : self.max_pos[1] - self.min_pos[1],
	        sizez : self.max_pos[2] - self.min_pos[2],
	    }
	}
	
	/**
	 * Returns a vertex buffer that can be used to draw the bounding box.
	 * @param {Constant.Color} color Color of the bounding box.
	 * @returns {id.VertexBuffer} The vertex buffer of the bbox.
	 */
	static build_vertex_buffer = function(color, alpha)
	{
		var vbuffer_bbox = vertex_create_buffer();
		var points = self.get_raw();
		var coords_map = global._bbox_lines;
		
		//Map every coordinate to a line and add the line to the vertex buffer.
		vertex_begin(vbuffer_bbox, global._line_vertex_format); 
		
		for (var i = 0; i < array_length(coords_map); i++)
		{
			var coords_line_map = coords_map[i];
			bbox_vertex_line_color(vbuffer_bbox, points[coords_line_map[0]][0], points[coords_line_map[1]][1], points[coords_line_map[2]][2], points[coords_line_map[3]][0], points[coords_line_map[4]][1], points[coords_line_map[5]][2], color, alpha);
		}
		
		vertex_end(vbuffer_bbox);
		vertex_freeze(vbuffer_bbox);
		
		return vbuffer_bbox;
	}
	
	/**
	 * Clones the bbox.
	 * @returns {struct} A copy of the bbox.
	 */
	static clone = function()
	{
		return new ModelBBox(self.min_pos, self.max_pos);
	}
}

function bbox_vertex_line_color(vertex_buffer, x1, y1, z1, x2, y2, z2, color, alpha)
{
	vertex_position_3d(vertex_buffer, x1, y1, z1);
	vertex_colour(vertex_buffer, color, alpha);  
	vertex_position_3d(vertex_buffer, x2, y2, z2);
	vertex_colour(vertex_buffer, color, alpha);
}