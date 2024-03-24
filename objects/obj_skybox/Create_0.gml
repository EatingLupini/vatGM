/// @description

model_info = models[? "skybox"];
inst = model_info[MODEL].new_instance();
for (var i=0; i<array_length(model_info[TEXTURE]); i++)
	inst.set_material(i, new TextureMaterial(undefined, model_info[TEXTURE][i], 0));

