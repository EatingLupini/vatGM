function TextureMaterialAnim(texture, subimg, anim_manager) : TextureMaterial(sh_vat, texture, subimg) constructor
{
	self.anim_manager = anim_manager;
	
	static on_apply = function()
	{
		self.anim_manager.step();
		self.anim_manager.set_shader_params();
	}
}

