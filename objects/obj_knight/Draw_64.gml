/// @description

// dir
/*
var vdir = keyboard_check(ord("S")) - keyboard_check(ord("W"));
var hdir = keyboard_check(ord("D")) - keyboard_check(ord("A"));
draw_text(256, 32, string("hdir: {0}\nvdir: {1}", hdir, vdir));
draw_text(256, 64, string("cam_local_dir_x: {0}\ncam_local_dir_y: {1}",
			obj_camera.local_dir.x, obj_camera.local_dir.y));
*/

// anims
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
draw_text(512, 32, dstr);
