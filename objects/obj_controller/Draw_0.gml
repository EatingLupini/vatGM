/// @description

// SELECTION
if (is_selecting or ds_list_size(list_selected) > 0)
{
	var l = ds_list_size(list_selected);
	for (var i=0; i<l; i++)
	{
		var ent = list_selected[| i];
		draw_sprite(spr_selection, 0, ent.x, ent.y);
	}
}
