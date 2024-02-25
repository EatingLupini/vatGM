function TextureMaterialAnim(texture, subimg, anim) : TextureMaterial(sh_vat, texture, subimg) constructor
{
	self.anim = anim;
	
	static on_apply = function()
	{
		self.anim.step();
		self.anim.set_shader_params();
	}
}

