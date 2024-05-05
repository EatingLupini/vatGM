/// @description

image_speed = 0;
xspd = 0;
yspd = 0;
zspd = 0;

self[$ "z"] ??= 0;
self[$ "params"] ??= undefined;

inst = model_info[MODEL].new_instance();
for (var i=0; i<array_length(model_info[TEXTURE]); i++)
	inst.set_material(i, new TextureMaterial(sh_texture, model_info[TEXTURE][i], 0, params));
