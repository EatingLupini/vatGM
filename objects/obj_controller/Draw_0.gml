/// @description

// SELECTION
if (is_selecting)
{
	// https://forum.gamemaker.io/index.php?threads/how-to-read-a-gml-buffer-inside-of-a-shader-gms-1-4.95635/post-575772
	// ...
	shader_set(sh_selection);
	draw_sprite(spr_selection, 0, 0, 0);
	shader_reset();
}
