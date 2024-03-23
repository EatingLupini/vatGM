/// @description

model_info = models[? "skybox"];
inst = model_info[MODEL].new_instance();
inst.set_material(0, new TextureMaterial(sh_texture, model_info[TEXTURE], 0));

