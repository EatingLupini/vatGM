/// @description

// DEBUG
draw_set_color(c_white);
draw_text(512, 32,	"current_time: " + string(current_time * 0.001) + "\n" +
					"dt: " + string_replace_all(string_format(dt, 5, 4), " ", "") + "\n" +
					"fps: " + string(fps) + "\n" +
					"fps_real: " + string(fps_real) + "\n" +
					"gspd: " + string(gspd) + "\n" +
					"screen_w: " + string(window_get_width()) + "\n" +
					"screen_h: " + string(window_get_height()) + "\n" +
					"list_selected: " + string(ds_list_size(list_selected))
					);

// SELECTION
if (is_selecting)
{
	draw_set_color(c_blue);
	draw_set_alpha(0.1);
	draw_rectangle(sel_screen_start[X], sel_screen_start[Y], sel_screen_end[X], sel_screen_end[Y], false);
	draw_set_alpha(0.8);
	draw_rectangle(sel_screen_start[X], sel_screen_start[Y], sel_screen_end[X], sel_screen_end[Y], true);
}

// MINIMAP
if (is_minimap_enabled)
{
	var f = 8;
	draw_set_color(c_blue);
	
	// room
	draw_rectangle(0, 0, room_width / f, room_height / f, false);
	
	// selection
	if ((sel_screen_end[X] >= sel_screen_start[X] and sel_screen_end[Y] >= sel_screen_start[Y]) or
		(sel_screen_end[X] <= sel_screen_start[X] and sel_screen_end[Y] <= sel_screen_start[Y]))
	{
		sel_world_v[0] = screen_to_world(sel_screen_start[X], sel_screen_start[Y], cam.view_mat, cam.proj_mat);
		sel_world_v[1] = screen_to_world(sel_screen_end[X], sel_screen_start[Y], cam.view_mat, cam.proj_mat);
		sel_world_v[2] = screen_to_world(sel_screen_end[X], sel_screen_end[Y], cam.view_mat, cam.proj_mat);
		sel_world_v[3] = screen_to_world(sel_screen_start[X], sel_screen_end[Y], cam.view_mat, cam.proj_mat);
	}
	else
	{
		sel_world_v[0] = screen_to_world(sel_screen_start[X], sel_screen_end[Y], cam.view_mat, cam.proj_mat);
		sel_world_v[1] = screen_to_world(sel_screen_end[X], sel_screen_end[Y], cam.view_mat, cam.proj_mat);
		sel_world_v[2] = screen_to_world(sel_screen_end[X], sel_screen_start[Y], cam.view_mat, cam.proj_mat);
		sel_world_v[3] = screen_to_world(sel_screen_start[X], sel_screen_start[Y], cam.view_mat, cam.proj_mat);
	}
	
	draw_primitive_begin(pr_trianglefan);
	for (var i=0; i<array_length(sel_world_v); i++)
		draw_vertex_color(sel_world_v[i][X] / f, sel_world_v[i][Y] / f, c_red, 1);
	draw_primitive_end();
	
	// objects
	for (var i=0; i<instance_number(obj_knight); i++)
	{
		var ii = instance_find(obj_knight, i);
		if (ii.is_selected)
		{
			draw_set_color(c_yellow);
			draw_circle(ii.x / f, ii.y / f, 16 / f, false);
		}
		else
		{
			draw_set_color(c_black);
			draw_circle(ii.x / f, ii.y / f, 16 / f, false);
		}
	}
	
	// camera
	var cam_points = [
		screen_to_world(0, 0, cam.view_mat, cam.proj_mat),
		screen_to_world(display_get_gui_width(), 0, cam.view_mat, cam.proj_mat),
		screen_to_world(display_get_gui_width(), display_get_gui_height(), cam.view_mat, cam.proj_mat),
		screen_to_world(0, display_get_gui_height(), cam.view_mat, cam.proj_mat),
		screen_to_world(0, 0, cam.view_mat, cam.proj_mat)
	];
	draw_primitive_begin(pr_linestrip);
	for (var i=0; i<array_length(cam_points); i++)
		draw_vertex_color(cam_points[i][X] / f, cam_points[i][Y] / f, c_white, 1);
	draw_primitive_end();
}


/*
// DEBUG POINT IN QUAD
var points = [
	[200, 200],
	[400, 200],
	[400, 400],
	[100, 400]
];
draw_set_color(c_red);
draw_primitive_begin(pr_trianglefan);
for (var i=0; i<array_length(points); i++)
	draw_vertex_color(points[i][X], points[i][Y], c_red, 1);
draw_primitive_end();

if (point_in_quad(window_mouse_get_x(), window_mouse_get_y(), points))
	draw_set_color(c_white);
else
	draw_set_color(c_blue);
draw_circle(window_mouse_get_x(), window_mouse_get_y(), 2, false);
*/

