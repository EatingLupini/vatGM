/**
 * Instance of model, it rappresent a rendable model with materials.
 * @param {struct.Model} model The model of this instance.
 */
function ModelInstance(model) constructor
{
	self.model = model;
	
	//Create material array and set default material.
	self.materials = array_create(self.model.material_count, global.default_material);

	/**
	 * Assigns the given materials to the instance.
	 * @param {array<struct.Material>} materials Array of material to assign to the instance.
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
	 * Returns the array of materials of the instance.
	 * @returns {array<struct.Material>} The array of materials of the instance.
	 */
	static get_materials = function()
	{
		return self.materials;
	}
	
	/**
	 * Returns the material with the given index.
	 * @param {real} index The id of the material to retreive.
	 * @param {struct.Material} material The material with the given id.
	 */
	static get_material = function(index, material)
	{
		self.materials[index] = material;
	}
	
	/**
	 * Renders the instance using the assigned materials.
	 */
	static render = function()
	{
		for (var i = 0; i < self.model.material_count; i++)
		{
			material_apply(self.materials[i]);
			self.model.render(i, self.materials[i].base_texture);
			shader_reset();
		}
	}
	
	/**
	 * Renders the instance without materials.
	 * @param {array<pointer.texture>} [texture]=[] Ids of the texture to use ([] for none).
	 */	
	static render_without_materials = function(textures = [])
	{
		if (array_length(textures) > 0)
		{
			for (var i = 0; i < array_length(textures); i++)
				self.model.render(i, textures[i]);
			return;
		}
		
		self.model.render(i, -1);
	}
}
