/// @description

// draw sel
if (is_selected)
{
	var pos = world_to_screen(x, y, z +64, obj_camera.view_mat, obj_camera.proj_mat);
	draw_set_color(c_aqua);
	draw_circle(pos[X], pos[Y], 8, false);
}

// DEBUG
if (is_controlled)
{
	var dstr = "";
	for (var i=0; i<array_length(anim_manager.play_anims); i++)
	{
		var play_anim = anim_manager.play_anims[i];
		dstr += play_anim.anim.name + "\n";
		dstr += "  loop: " + string(play_anim.anim.loop) + "\n";
		dstr += "  speed: " + string(play_anim.anim.speed) + "\n";
		dstr += "  frames: " + string(play_anim.anim.frame_end - play_anim.anim.frame_start) + "\n";
		dstr += "  time: " + string(play_anim.time) + "\n";
		dstr += "  blend: " + string(play_anim.get_blend()) + "\n";
	}
	draw_text(display_get_gui_width() - 160, 32, dstr);
}
