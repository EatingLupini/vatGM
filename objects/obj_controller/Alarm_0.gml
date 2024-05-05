/// @description

for (var i=0; i<instance_number(obj_prop); i++)
{
	var prop = instance_find(obj_prop, i);
	mp_grid_add_instances(navgrid, prop, true);
}

