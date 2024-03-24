/// @description

draw_set_color(c_white);
draw_text(32, 32,	"current_time: " + string(current_time * 0.001) + "\n" +
					"dt: " + string_replace_all(string_format(dt, 5, 4), " ", "") + "\n" +
					"fps: " + string(fps) + "\n" +
					"fps_real: " + string(fps_real) + "\n" +
					"gspd: " + string(gspd)
					);
