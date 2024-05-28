/**
 * Model is used to render a model, usually you don't need to create a Model instance 
 * manually and you should use the function load_model(...).
 * @param {array<id.VertexBuffer>} buffers Array of vertex buffer (one for each material of the model).
 * @param {real} material_count Number of materials of the model.
 */
function Model(buffers, material_count) constructor
{
	self.vertex_buffers = buffers; //Number of meshes (split by material).
	self.vertex_counts = array_create(material_count); //Number of vertices in each buffer.
	self.material_count = material_count; //Material count.
	self.bbox = undefined; //Bounding box of the model.
	self.name = "epic_model"; //Name of the file.
	
	//Get vertex count from vertex each vertex buffer.
	for (var i = 0; i < self.material_count; i++)
		self.vertex_counts[i] = vertex_get_number(self.vertex_buffers[i]);
	
	/**
	 * Returns a new ModelInstance of this Model.
	 * @returns {struct.ModelInstance} A new instance of the model.
	 */
	static new_instance = function()
	{
		return new ModelInstance(self);
	}
	/**
	 * Renders the vertex buffer with the given index, material must be applied before calling this method.
	 * @param {real} index The index of the vertex buffer to render.
	 * @param {pointer.texture} texture The texture to apply to the vertex buffer.
	 */
	static render = function(index, texture)
	{
		vertex_submit(self.vertex_buffers[index], pr_trianglelist, texture);
	}

	/**
	 * Returns the array of vertex buffers as normal buffers.
	 * @returns {array<Id.Buffer>} An array containing the vertex buffers as normal buffers.
	 */
	static to_buffer = function()
	{
		var out_buffers = array_create(self.material_count);
		
		for (var i = 0; i < self.material_count; i++)
			out_buffers[i] = buffer_create_from_vertex_buffer(self.vertex_buffers[i], buffer_vbuffer, 1);
		
		return out_buffers;
	}
	
	/**
	 * Returns the array of vertex buffers as buffers used by DynamicModelBatch.
	 * @returns {array<Id.Buffer>} Array of converted buffers.
	 */
	static to_dynamic_buffer = function()
	{
		var out_buffers = array_create(self.material_count);
		
		for (var i = 0; i < self.material_count; i++)
		{
			var temp_buffer = buffer_create_from_vertex_buffer(self.vertex_buffers[i], buffer_vbuffer, 1);
			out_buffers[i] = buffer_create(self.vertex_counts[i] * global.dynamic_batch_buffer_format_size, buffer_vbuffer, 1);
			
			repeat(self.vertex_counts[i]) //Apply transformation to each vertex.
			{
				//Vertex coords.
				buffer_write(out_buffers[i], buffer_f32, buffer_read(temp_buffer, buffer_f32));
				buffer_write(out_buffers[i], buffer_f32, buffer_read(temp_buffer, buffer_f32));
				buffer_write(out_buffers[i], buffer_f32, buffer_read(temp_buffer, buffer_f32));
				
				//UVs
				buffer_write(out_buffers[i], buffer_f32, buffer_read(temp_buffer, buffer_f32));
				buffer_write(out_buffers[i], buffer_f32, buffer_read(temp_buffer, buffer_f32));
				
				//Vertex color.
				buffer_write(out_buffers[i], buffer_u8, buffer_read(temp_buffer, buffer_u8));
				buffer_write(out_buffers[i], buffer_u8, buffer_read(temp_buffer, buffer_u8));
				buffer_write(out_buffers[i], buffer_u8, buffer_read(temp_buffer, buffer_u8));
				buffer_write(out_buffers[i], buffer_u8, buffer_read(temp_buffer, buffer_u8));
				
				//Normals
				buffer_write(out_buffers[i], buffer_f32, buffer_read(temp_buffer, buffer_f32));
				buffer_write(out_buffers[i], buffer_f32, buffer_read(temp_buffer, buffer_f32));
				buffer_write(out_buffers[i], buffer_f32, buffer_read(temp_buffer, buffer_f32));
				
				//Id
				buffer_write(out_buffers[i], buffer_f32, buffer_read(temp_buffer, buffer_f32));

			}
		}
		
		return out_buffers;
	}

	/**
	 * Sets the bounding box of this model.
	 * @param {struct.ModelBBox} bbox The bounding box to set.
	 */
	static set_bbox = function(bbox)
	{
		self.bbox = bbox;
	}

	/**
	 * Returns the bounding box of the model.
	 * @returns {struct.ModelBBox} The bounding box of the model.
	 */
	static get_bbox = function()
	{
		return self.bbox;
	}
	
	/**
	 * Sets the name of this model.
	 * @param {string} name The name to set.
	 */
	static set_name = function(name)
	{
		self.name = name;
	}
	
	/**
	 * Returns the name of the model.
	 * @returns {string} The name of the model.
	 */
	static get_name = function()
	{
		return self.name;
	}
	
	/**
	 * Free the memory used by the model.
	 */
	static destroy = function()
	{
		for (var i = 0; i < self.material_count; i++)
			vertex_delete_buffer(self.vertex_buffers[i]);
	}
	
	/**
	 * Freezes the vertex buffers of the model making rendering them faster.
	 */
	static freeze = function()
	{
		for (var i = 0; i < self.material_count; i++)
		{		
			vertex_freeze(self.vertex_buffers[i]);
		}
	}
}
