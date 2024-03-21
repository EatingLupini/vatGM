// Utils

function angle_lerp(current, target, amount)
{
	var angle_diff = angle_difference(current, target);
	target = current - angle_diff;
	return lerp(current, target, amount);
}

function vec2_rotate(v, ang)
{
	var ics = v[0] * dcos(ang) + v[1] * dsin(ang);
	var ips = - v[0] * dsin(ang) + v[1] * dcos(ang);
	return [ics, ips];
}
