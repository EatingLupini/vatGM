/**
 * Material used to render a model. If there is no need to pass uniforms to the shader this struct can be used as is,
 * if yes this struct can be extended to have parameters (such as the color of the model) and the method on_apply, that is called 
 * when the material is applied, can be overridden so that uniforms can be passed to the shader.
 * Also this struct does not have a base texture and it is set to -1 by default, the method set_texture(...) is used to assign the texture to it.
 * @param {Asset.GMShader} shader Shader used by the material.
 */
function Material(shader) constructor
{
	self.shader = shader;
	self.base_texture = pointer_null;
	
	/**
	 * Assigns the given texture to the material.
	 * @param {pointer.texture} texture Texture that will be assigned to the material.
	 */
	static set_texture = function(texture)
	{
		self.base_texture = texture;
	}

	/**
	 * This method is called just before the model is rendered and before the function shader_set(...), 
	 * it is used to pass uniforms to the shader.
	 */
	static on_apply = function() 
	{
	}
}

/**
 * This function is called to apply the material before the model is rendered. It is automatically called, and 
 * there is no need to call it manually.
 * @param {any*} material Material that will be applied.
 */
function material_apply(material)
{
	shader_set(material.shader);
	material.on_apply();
}