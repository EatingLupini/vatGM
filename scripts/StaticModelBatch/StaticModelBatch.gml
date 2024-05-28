/**
 * A StaticModelBatch is used to draw a static model (that does not move) multiple times with a single draw call,
 * thus largely increasing performances.
 * @param {struct.Model} model The model you want a static batch to be created from.
 */
function StaticModelBatch(model) constructor
{
	self.model = model;
	self.batch_size = 0; //Current size of the batch.
	self.transforms = ds_list_create(); //List of transforms.
	self.bbox = undefined; //Batch bounding box.
	
	//Create vertex buffers.
	self.model_buffer_sizes = array_create(model.material_count);
	self.vertex_buffers =  array_create(model.material_count);
	self.vertex_counts = array_create(model.material_count);
	
	//Create material array.
	self.materials = array_create(model.material_count, global.default_material);
	
	//Get vertex buffers of the model as buffers.
	self.model_buffer = model.to_buffer();
	
	for (var i = 0; i < model.material_count; i++)
	{		
		self.model_buffer_sizes[i] = buffer_get_size(self.model_buffer[i]);
		self.vertex_buffers[i] = vertex_create_buffer();
	}
	
	/**
	 * Assigns the given materials to the DynamicModelBatch.
	 * @param {array} materials Array of material to assign to the StaticModelBatch.
	 */
	static set_materials = function(materials)
	{
		for (var i = 0; i < array_length(materials) && i < self.model.material_count; i++)
			self.materials[i] = materials[i];
	}
	
	/**
	 * Assigns the given materials to the given index of the array of materials.
	 * @param {real} index Index of the material in the material array.
	 * @param {struct.Material} material Material to assign to the given index position.
	 */
	static set_material = function(index, material)
	{
		self.materials[index] = material;
	}
	
	/**
	 * Returns the array of materials of the batch.
	 * @returns {array<struct.Material>} The array of materials of the batch.
	 */
	static get_materials = function()
	{
		return self.materials;
	}
	
	/**
	 * Returns the material with the given index.
	 * @param {any*} index Index of the material to retreive.
	 * @param {struct.Material} material The material with the given index.
	 */
	static get_material = function(index, material)
	{
		self.materials[index] = material;
	}
	
	/**
	 * Adds a new model to the batch with the given transformations. After calling this function the buffer needs to be built and froze.
	 * @param {real} x X coordinates of the model.
	 * @param {real} y Y coordinates of the model.
	 * @param {real} z Z coordinates of the model.
	 * @param {real} rotx Rotation of the model in the x axis.
	 * @param {real} roty Rotation of the model in the y axis.
	 * @param {real} rotz Rotation of the model in the z axis.
	 * @param {real} xscale Scale of the model in the x axis.
	 * @param {real} yscale Scale of the model in the y axis.
	 * @param {real} zscale Scale of the model in the z axis.
	 * @returns {struct.StaticTransform} The static transform used for accessing the transform.
	 */
	static add = function(x, y, z, rotx, roty, rotz, xscale, yscale, zscale)
	{
		var index = self.batch_size;
		var transform = new StaticTransform(x, y, z, rotx, roty, rotz, xscale, yscale, zscale, index);
		self.transforms[| index] = transform;
		self.batch_size++;
		
		return transform;
	}
	
	/**
	 * Removes the given transform from the batch. After calling this function the buffer needs to be built and froze.
	 * @param {struct.StaticTransform} transform Transform that will be removed from the batch.
	 */
	static remove = function(transform)
	{
		//Remove the transform from the list and shift indexes of other transforms.
		ds_list_delete(self.transforms, transform.index);
		self.batch_size--;
		for (var i = 0;  i < self.batch_size; i++)
			self.transforms[| i].index = i;
	}
	
	/**
	 * Builds the vertex buffers of the batch, making it possible to be rendered.
	 * This function is quite expensive with a large number of transforms and should not be used in a step event.
	 * If you need to add/remove large number of object I suggest the use of object pools.
	 */
	static build = function()
	{
		if (self.batch_size <= 0)
			return;
			
		var bounding_box =
		{
			min : array_create(3, infinity),
			max : array_create(3, -infinity)
		};
		
		//Rebuild each material vertex buffer.
		for (var i = 0; i < self.model.material_count; i++)
		{
			//Calculate vertex count.
			self.vertex_counts[i] = self.model.vertex_counts[i] * self.batch_size;
			
			//Delete the vertex buffer, this will be rebuilt.
			vertex_delete_buffer(self.vertex_buffers[i]);
			
			//Create a temp buffer that will be converted into vertex buffer and a temp buffer used to store transformed meshes.
			var temp_buffer = buffer_create(self.model_buffer_sizes[i] * self.batch_size, buffer_vbuffer, 1);
			var transformed_buffer = buffer_create(self.model_buffer_sizes[i], buffer_vbuffer, 1);
			
			//For each transform.
			for (var j = 0; j < self.batch_size; j++)
			{
				var transform = self.transforms[| j];
				
				//Copy the model buffer to the temp buffer
				buffer_copy(self.model_buffer[i], 0, self.model_buffer_sizes[i], transformed_buffer, 0);
				
				//Apply transformation onto the temp buffer.
				repeat(self.model.vertex_counts[i]) //Apply transformation to each vertex.
				{
					//buffer_seek(transformed_buffer, buffer_seek_relative, 3 * 4 + 2 * 4 + 4 + 3 * 4);
					
					//Read vertex coords.
					var vx = buffer_peek(transformed_buffer, buffer_tell(transformed_buffer), buffer_f32);
					var vy = buffer_peek(transformed_buffer, buffer_tell(transformed_buffer) + 4, buffer_f32);
					var vz = buffer_peek(transformed_buffer, buffer_tell(transformed_buffer) + 8, buffer_f32);
					
					//Transform vertex coords.
					var vertex = [vx, vy, vz, 1.0]; 
					vertex = vec_transform(vertex, transform.transform_matrix);
					
					//Calculate new bounding box.
					bounding_box.min[0] = min(bounding_box.min[0], vertex[0]);
					bounding_box.min[1] = min(bounding_box.min[1], vertex[1]);
					bounding_box.min[2] = min(bounding_box.min[2], vertex[2]);
					bounding_box.max[0] = max(bounding_box.max[0], vertex[0]);
					bounding_box.max[1] = max(bounding_box.max[1], vertex[1]);
					bounding_box.max[2] = max(bounding_box.max[2], vertex[2]);
					
					//Write transformed vertex coords.
					buffer_write(transformed_buffer, buffer_f32, vertex[0]);
					buffer_write(transformed_buffer, buffer_f32, vertex[1]);
					buffer_write(transformed_buffer, buffer_f32, vertex[2]);
					
					//Skip UVs and Vertex Color
					buffer_seek(transformed_buffer, buffer_seek_relative, 2 * 4 + 4); 
					
					//Read normal.
					vx = buffer_peek(transformed_buffer, buffer_tell(transformed_buffer), buffer_f32);
					vy = buffer_peek(transformed_buffer, buffer_tell(transformed_buffer) + 4, buffer_f32);
					vz = buffer_peek(transformed_buffer, buffer_tell(transformed_buffer) + 8, buffer_f32);
					
					//Transform normal.
					var normal = [vx, vy, vz, 0.0];
					normal = vec_transform(normal, transform.transform_matrix);
					
					//Write transformed normal.
					buffer_write(transformed_buffer, buffer_f32, normal[0]);
					buffer_write(transformed_buffer, buffer_f32, normal[1]);
					buffer_write(transformed_buffer, buffer_f32, normal[2]);
					
					//Read vertex index
					var vid = buffer_peek(transformed_buffer, buffer_tell(transformed_buffer), buffer_f32);
					
					//Write vertex index
					buffer_write(transformed_buffer, buffer_f32, vid);
				}
				
				//Retutn to the start of the buffer.
				buffer_seek(transformed_buffer, buffer_seek_start, 0); 
				
				//Copy the batch buffer to the temp buffer.
				buffer_copy(transformed_buffer, 0, self.model_buffer_sizes[i], temp_buffer, j * self.model_buffer_sizes[i]);
			
			}
			
			//Create the buffer from the temp buffer.
			self.vertex_buffers[i] = vertex_create_buffer_from_buffer(temp_buffer, global.buffer_format);
			
			//Delete the temp buffers.
			buffer_delete(temp_buffer); 
			buffer_delete(transformed_buffer);
			
			//Assign new bounding box.
			self.set_bbox(new ModelBBox(bounding_box.min, bounding_box.max));
		}
		
	}
	
	/**
	 * Freezes the vertex buffers of the batch making rendering them faster.
	 */
	static freeze = function()
	{
		if (self.batch_size <= 0)
			return;
		
		for (var i = 0; i < self.model.material_count; i++)
		{		
			vertex_freeze(self.vertex_buffers[i]);
		}
	}
	
	/**
	 * Renders the batch using the assigned materials.
	 */
	static render = function()
	{
		if (self.batch_size <= 0)
			return;
		
		for (var i = 0; i < self.model.material_count; i++)
		{
			material_apply(materials[i]);
			vertex_submit(self.vertex_buffers[i], pr_trianglelist, materials[i].base_texture);
			shader_reset();
		}
	}
	
	/**
	 * Renders the batch without materials.
	 * @param {array<pointer.texture>} [textures]=[]  Id of the texture to use ([] for none).
	 */	
	static render_without_materials = function(textures = [])
	{
		/*
		if (self.batch_size <= 0)
			return;
		
		for (var i = 0; i < self.model.material_count; i++)
			vertex_submit(self.vertex_buffers[i], pr_trianglelist, texture);
		*/
		
		if (self.batch_size <= 0)
			return;
		
		if (array_length(textures) == 0)
		{
			vertex_submit(self.vertex_buffers[0], pr_trianglelist, -1);
			return;
		}
		
		for (var i = 0; i < self.model.material_count; i++)
			vertex_submit(self.vertex_buffers[i], pr_trianglelist, textures[i]);
	}
	
	/**
	 * Sets the bounding box of this batch.
	 * @param {struct.ModelBBox} bbox The bbox to set.
	 */
	static set_bbox = function(bbox)
	{
		self.bbox = bbox;
	}

	/**
	 * Returns the bounding box of this model batch.
	 * @returns {struct.ModelBBox} The bbox of the batch.
	 */
	static get_bbox = function()
	{
		return self.bbox;
	}
	
	/**
	 * Free the memory used by the batch.
	 */
	static destroy = function()
	{
		for (var i = 0; i < self.model.material_count; i++)
		{		
			vertex_delete_buffer(self.vertex_buffers[i]);
			buffer_delete(self.model_buffer[i]);
		}
	}
}

function StaticTransform(x, y, z, rotx, roty, rotz, xscale, yscale, zscale, index) constructor
{
	self.x = x;
	self.y = y;
	self.z = z;
	self.rotx = rotx;
	self.roty = roty;
	self.rotz = rotz;
	self.xscale = xscale;
	self.yscale = yscale;
	self.zscale = zscale;
	self.index = index;
	
	self.transform_matrix = matrix_build(self.x, self.y, self.z, self.rotx, self.roty, self.rotz, self.xscale, self.yscale, self.zscale);
	
	static set_pos = function(x, y, z)
	{
		self.x = x;
		self.y = y;
		self.z = z;
	}
	
	static set_rot = function(rotx, roty, rotz)
	{
		self.rotx = rotx;
		self.roty = roty;
		self.rotz = rotz;
	}
	
	static set_scale = function(xscale, yscale, zscale)
	{
		self.xscale = xscale;
		self.yscale = yscale;
		self.zscale = zscale;
	}
	
}