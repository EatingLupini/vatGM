/// @description

/*
anim_manager.sample_num = 30.0;
if (point_distance_3d(x, y, 0, obj_camera.pl_x, obj_camera.pl_y, obj_camera.pl_z) >= 128)
{
	anim_manager.sample_num = 1.0;
}
*/

// ROT
if (keyboard_check(ord("Z")))
{
	rot_z -= 2;
	rot_z %= 360;
}
if (keyboard_check(ord("X")))
{
	rot_z += 2;
	rot_z %= 360;
}

// ANIMS
if (keyboard_check_pressed(ord("Y")))
{
	anim_manager.change_animation(anims_info[2], function(a, b) {
		return a + b;
	});
}

if (keyboard_check_pressed(ord("U")))
{
	anim_manager.change_animation(anims_info[1], function(a, b) {
		return a + b;
	});
}

if (keyboard_check_pressed(ord("I")))
{
	anim_manager.set_animation(anims_info[0]);
}

if (keyboard_check_pressed(ord("O")))
	anim_manager.set_animation(anims_info[2]);

