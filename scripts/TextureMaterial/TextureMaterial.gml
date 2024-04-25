function TextureMaterial(shader, texture, subimg, params=undefined) : Material(shader) constructor
{
	self.base_texture = sprite_get_texture(texture, subimg);
	self.params = params ?? {
		cull: cull_counterclockwise,
		texrep: true
	};
	
	static on_apply = function()
	{
		gpu_set_cullmode(self.params.cull);
		gpu_set_texrepeat(self.params.texrep);
	}
}

