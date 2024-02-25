/// @description

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
	anim.change_animation(anims_info[2], function(a, b) {
		return a + b;
	});
}

if (keyboard_check_pressed(ord("U")))
{
	anim.change_animation(anims_info[1], function(a, b) {
		return a + b;
	});
}

if (keyboard_check_pressed(ord("I")))
{
	anim.set_animation(anims_info[0]);
}

if (keyboard_check_pressed(ord("O")))
	anim.set_animation(anims_info[2]);

