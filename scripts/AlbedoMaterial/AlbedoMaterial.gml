function AlbedoMaterial(shader, albedo) : Material(shader) constructor
{
	self.albedo = albedo;
	self.param_albedo = shader_get_uniform(self.shader, "u_albedo");
	
	static set_albedo = function(albedo)
	{
		self.albedo = albedo;
	}
	
	static on_apply = function()
	{
		shader_set_uniform_f(param_albedo, self.albedo[0], self.albedo[1], self.albedo[2]);
	}
}