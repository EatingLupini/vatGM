/// @description

// SELECTION
if (is_selecting)
{
	draw_set_color(c_blue);
	draw_set_alpha(0.1);
	draw_rectangle(sel_screen_start[X], sel_screen_start[Y], sel_screen_end[X], sel_screen_end[Y], false);
	draw_set_alpha(0.8);
	draw_rectangle(sel_screen_start[X], sel_screen_start[Y], sel_screen_end[X], sel_screen_end[Y], true);
	
}

// DEBUG
draw_set_color(c_white);
draw_text(32, 32,	"current_time: " + string(current_time * 0.001) + "\n" +
					"dt: " + string_replace_all(string_format(dt, 5, 4), " ", "") + "\n" +
					"fps: " + string(fps) + "\n" +
					"fps_real: " + string(fps_real) + "\n" +
					"gspd: " + string(gspd) + "\n" +
					"screen_w: " + string(window_get_width()) + "\n" +
					"screen_h: " + string(window_get_height())
					);

