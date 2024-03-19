/// @description

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

draw_text(256, 32, string("current_anim: {0}", list_anims_name[current_anim]));
draw_text(512, 32, dstr);
