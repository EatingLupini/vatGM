/// @description

#region RESET MOUSE POSITION

if (!is_paused and window_has_focus())
	display_mouse_set(display_get_width() * 0.5, display_get_height() * 0.5);

#endregion

