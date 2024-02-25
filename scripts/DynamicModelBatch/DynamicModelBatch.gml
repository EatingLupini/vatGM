#macro MAX_BATCH_SIZE 1024

/**
 * A DynamicModelBatch is used to draw a dynamic model (that does move) multiple times with a single draw call,
 * thus largely increasing performances.
 * @param {struct.Model} model The model you want a dinamyc batch to be created from.
 */
function DynamicModelBatch(model) constructor
{
	self.model = model;
	self.batch_size = 0; //Current size of the batch.
	self.transforms = ds_list_create(); //List of transforms.
	
	//Trasformation arrays.
	self.translations = array_create(0);
	self.scales = array_create(0);
	self.rotations = array_create(0);
	
	//Create vertex buffers.
	self.model_buffer_sizes = array_create(model.material_count);
	self.vertex_buffers =  array_create(model.material_count);
	
	//Create material array.
	self.materials = array_create(model.material_count, global.default_material_dynamic_batch);
	
	//Get vertex buffers of the model as buffers.
	self.model_buffers = model.to_dynamic_buffer();
	
	for (var i = 0; i < model.material_count; i++)
	{		
		self.model_buffer_sizes[i] = buffer_get_size(self.model_buffers[i]);
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
	 * @returns {struct.DynamicTransform} The dynamic transform used for accessing the transform.
	 */
	static add = function(x, y, z, rotx, roty, rotz, xscale, yscale, zscale)
	{
		if (self.batch_size > MAX_BATCH_SIZE)
			throw "Maximum batch size reached.";
		
		var index = self.batch_size;
		var transform = new DynamicTransform(x, y, z, rotx, roty, rotz, xscale, yscale, zscale, index, self);
		self.transforms[| index] = transform;
		self.batch_size++;
		
		array_resize(self.translations, self.batch_size * 3);
		array_resize(self.rotations, self.batch_size * 4);
		array_resize(self.scales, self.batch_size * 3);
		self.translations[index * 3] = transform.x;
		self.translations[index * 3 + 1] = transform.y;
		self.translations[index * 3 + 2] = transform.z;
		self.rotations[index * 4] = transform.quaternion[0];
		self.rotations[index * 4 + 1] = transform.quaternion[1];
		self.rotations[index * 4 + 2] = transform.quaternion[2];
		self.rotations[index * 4 + 3] = transform.quaternion[3];
		self.scales[index * 3] = transform.xscale;
		self.scales[index * 3 + 1] = transform.yscale;
		self.scales[index * 3 + 2] = transform.zscale;
		
		return transform;
	}
	
	/**
	 * Removes the given transform from the batch. After calling this function the buffer needs to be built and froze.
	 * @param {struct.DynamicTransform} t Transform that will be removed from the batch.
	 */
	static remove = function(t)
	{
		//Temp array for shifting the values.
		var tmp_translation = array_create(self.batch_size * 3);
		var tmp_scale = array_create(self.batch_size * 3);
		var tmp_rot = array_create(self.batch_size * 4);
		array_copy(tmp_translation, 0, self.scales, 0, self.batch_size * 3);
		array_copy(tmp_scale, 0, self.scales, 0, self.batch_size * 3);
		array_copy(tmp_rot, 0, self.scales, 0, self.batch_size * 4);
		
		//Shift the values of the arrays by 1.
		array_copy(self.translations, t.index * 3, tmp_translation, (t.index + 1) * 3, self.batch_size * 3 - (t.index + 1) * 3);
		array_copy(self.scales, t.index * 3, tmp_scale, (t.index + 1) * 3, self.batch_size * 3 - (t.index + 1) * 3);
		array_copy(self.rotations, t.index * 4, tmp_rot, (t.index + 1) * 4, self.batch_size * 4 - (t.index + 1) * 4);
		
		//Resize the arrays
		self.batch_size--;
		array_resize(self.translations, self.batch_size * 3);
		array_resize(self.scales, self.batch_size * 3);
		array_resize(self.rotations, self.batch_size * 4);
		
		//Remove the transform from the list and shift indexes of other transforms.
		ds_list_delete(self.transforms, t.index);
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
		
		//Rebuild each material vertex buffer.
		for (var i = 0; i < self.model.material_count; i++)
		{
			//Delete the vertex buffer, this will be rebuilt.
			vertex_delete_buffer(self.vertex_buffers[i]);
			
			//Create a temp buffer that will be converted into vertex buffer and a temp buffer used to store transformed meshes.
			var temp_buffer = buffer_create(self.model_buffer_sizes[i] * self.batch_size, buffer_vbuffer, 1);
			var transformed_buffer = buffer_create(self.model_buffer_sizes[i], buffer_vbuffer, 1);
			
			//For each transform.
			for (var j = 0; j < self.batch_size; j++)
			{			
				//Copy the model buffer to the temp buffer
				buffer_copy(self.model_buffers[i], 0, self.model_buffer_sizes[i], transformed_buffer, 0);
				
				//Apply transformation onto the temp buffer.
				repeat(self.model.vertex_counts[i]) //Apply transformation to each vertex.
				{
					buffer_seek(transformed_buffer, buffer_seek_relative, global.buffer_format_size);
					buffer_write(transformed_buffer, buffer_f32, j);
				}
				
				//Return to the start of the buffer.
				buffer_seek(transformed_buffer, buffer_seek_start, 0); 
				
				//Copy the batch buffer to the temp buffer.
				buffer_copy(transformed_buffer, 0, self.model_buffer_sizes[i], temp_buffer, j * self.model_buffer_sizes[i]);
			
			}
			
			//Create the buffer from the temp buffer.
			self.vertex_buffers[i] = vertex_create_buffer_from_buffer(temp_buffer, global.dynamic_batch_buffer_format);
			
			//Delete the temp buffers.
			buffer_delete(temp_buffer); 
			buffer_delete(transformed_buffer);
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
			material_apply(self.materials[i]);
			
			//Pass the transformations to the shader.
			shader_set_uniform_f_array(shader_get_uniform(self.materials[i].shader, "translations"), self.translations);
			shader_set_uniform_f_array(shader_get_uniform(self.materials[i].shader, "scales"), self.scales);
			shader_set_uniform_f_array(shader_get_uniform(self.materials[i].shader, "rotations"), self.rotations);
			
			vertex_submit(self.vertex_buffers[i], pr_trianglelist, self.materials[i].base_texture);
			shader_reset();
		}
	}
	
	/**
	 * Renders the batch without materials.
	 * @param {pointer.texture} [texture]=pointer_null  Id of the texture to use (pointer_null for none).
	 */	
	static render_without_materials = function(texture = pointer_null)
	{
		if (self.batch_size <= 0)
			return;
		
		for (var i = 0; i < self.model.material_count; i++)
		{
			//Pass the transformations to the shader.
			shader_set_uniform_f_array(shader_get_uniform(self.materials[i].shader, "translations"), self.translations);
			shader_set_uniform_f_array(shader_get_uniform(self.materials[i].shader, "scales"), self.scales);
			shader_set_uniform_f_array(shader_get_uniform(self.materials[i].shader, "rotations"), self.rotations);
			
			vertex_submit(self.vertex_buffers[i], pr_trianglelist, texture);
		}
	}
	
	/**
	 * Free the memory used by the batch.
	 */
	static destroy = function()
	{
		for (var i = 0; i < self.model.material_count; i++)
		{		
			vertex_delete_buffer(self.vertex_buffers[i]);
			buffer_delete(self.model_buffers[i]);
		}
	}
}

function DynamicTransform(x, y, z, rotx, roty, rotz, xscale, yscale, zscale, index, batch) constructor
{
	self.index = index;
	self.batch = batch;
	self.x = x;
	self.y = y;
	self.z = z;
	self.quaternion = quaternion_set_euler(rotx, roty, rotz);
	self.xscale = xscale;
	self.yscale = yscale;
	self.zscale = zscale;
	
	static set_pos = function(x, y, z)
	{
		self.x = x;
		self.y = y;
		self.z = z;
		
		self.batch.translations[self.index * 3] = self.x;
		self.batch.translations[self.index * 3 + 1] = self.y;
		self.batch.translations[self.index * 3 + 2] = self.z;
	}
	
	static set_rot = function(rotx, roty, rotz)
	{
		self.quaternion = quaternion_set_euler(rotx, roty, -rotz);

		self.batch.rotations[self.index * 4] = self.quaternion[0];
		self.batch.rotations[self.index * 4 + 1] = self.quaternion[1];
		self.batch.rotations[self.index * 4 + 2] = self.quaternion[2];
		self.batch.rotations[self.index * 4 + 3] = self.quaternion[3];
	}
	
	static set_scale = function(xscale, yscale, zscale)
	{
		self.xscale = xscale;
		self.yscale = yscale;
		self.zscale = zscale;
		
		self.batch.scales[self.index * 3] = self.xscale;
		self.batch.scales[self.index * 3 + 1] = self.yscale;
		self.batch.scales[self.index * 3 + 2] = self.zscale;
	}
	
}