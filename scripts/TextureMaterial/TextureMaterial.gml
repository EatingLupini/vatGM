function TextureMaterial(shader, texture, subimg) : Material(shader) constructor
{
	self.base_texture = sprite_get_texture(texture, subimg);
	
	static on_apply = function()
	{
	}
}