// Utils

function angle_lerp(current, target, amount)
{
	var angle_diff = angle_difference(current, target);
	target = current - angle_diff;
	return lerp(current, target, 1 - power(amount, dt));
}

function vec2_rotate(v, ang)
{
	var ics = v[0] * dcos(ang) + v[1] * dsin(ang);
	var ips = - v[0] * dsin(ang) + v[1] * dcos(ang);
	return [ics, ips];
}

/// @description screen_raycast(x, y, view_mat, proj_mat)
/// @param x
/// @param y
/// @param view_mat
/// @param proj_mat
/*
Transforms a 2D coordinate (in window space) to a 3D vector.
Returns an array of the following format:
[dx, dy, dz, ox, oy, oz]
where [dx, dy, dz] is the direction vector and [ox, oy, oz] is the origin of the ray.

Works for both orthographic and perspective projections.

Script created by TheSnidr
(slightly modified by @dragonitespam)
(https://www.youtube.com/watch?v=F1G9Qgf1JNY)
*/
function screen_raycast(x, y, view_mat, proj_mat)
{
	var mx = 2 * (x / window_get_width() - .5) / proj_mat[0];
	var my = 2 * (y / window_get_height() - .5) / proj_mat[5];
	var camX = - (view_mat[12] * view_mat[0] + view_mat[13] * view_mat[1] + view_mat[14] * view_mat[2]);
	var camY = - (view_mat[12] * view_mat[4] + view_mat[13] * view_mat[5] + view_mat[14] * view_mat[6]);
	var camZ = - (view_mat[12] * view_mat[8] + view_mat[13] * view_mat[9] + view_mat[14] * view_mat[10]);

	if (proj_mat[15] == 0)
	{    //This is a perspective projection
	    return [view_mat[2]  + mx * view_mat[0] + my * view_mat[1],
	            view_mat[6]  + mx * view_mat[4] + my * view_mat[5],
	            view_mat[10] + mx * view_mat[8] + my * view_mat[9],
	            camX,
	            camY,
	            camZ];
	}
	else
	{    //This is an ortho projection
	    return [view_mat[2],
	            view_mat[6],
	            view_mat[10],
	            camX + mx * view_mat[0] + my * view_mat[1],
	            camY + mx * view_mat[4] + my * view_mat[5],
	            camZ + mx * view_mat[8] + my * view_mat[9]];
	}
}

/// @description screen_to_world(x, y, view_mat, proj_mat)
/// @param x
/// @param y
/// @param view_mat
/// @param proj_mat
/*
Transform a 2D coordinate (in window space) to a 2D coordinate (in world space) of a plane (z=0) 
*/
function screen_to_world(x, y, view_mat, proj_mat)
{
	var raycast = screen_raycast(x, y, view_mat, proj_mat);
	var fx = raycast[0] * raycast[5] / -raycast[2] + raycast[3];
	var fy = raycast[1] * raycast[5] / -raycast[2] + raycast[4];
	return [fx, fy];
}


// POINT IN QUADRILATERAL
function point_in_halfplane(quad, i, px, py)
{
	var v1 = quad[i % 4];
	var v2 = quad[(i+1) % 4];
	var v3 = quad[(i+2) % 4];
	
	// edge case
	if (v1[X] == v2[X])
		v1[X] += 0.01;
	
	var m = (v1[Y] - v2[Y]) / (v1[X] - v2[X]);
	var q = v1[Y] - m * v1[X];
	
	var halfplane = py >= m * px + q;
	
	if (v3[Y] > m * v3[X] + q)
		return halfplane;
	else
		return !halfplane;
}

function point_in_quad(px, py, quad)
{
	return point_in_halfplane(quad, 0, px, py) and
			point_in_halfplane(quad, 1, px, py) and
			point_in_halfplane(quad, 2, px, py) and
			point_in_halfplane(quad, 3, px, py);
}

/*
function get_eq(x1, y1, x2, y2)
{
	var m = (y1 - y2) / (x1 - x2);
	var q = y1 - m * x1;
	return [m, q];
}

function get_ud(quad, i, px, py, ud)
{
	var v1 = quad[i % 4];
	var v2 = quad[(i+1) % 4];
	var eq = get_eq(v1[X], v1[Y], v2[X], v2[Y]);
	if (ud)
		return py > eq[0] * px + eq[1];
	else
		return py < eq[0] * px + eq[1];
}

function half_plane(quad, i, px, py)
{
	var v1 = quad[i % 4];
	var v2 = quad[(i+1) % 4];
	var v3 = quad[(i+2) % 4];
	var eq = get_eq(v1[X], v1[Y], v2[X], v2[Y]);
		
	if (get_ud(quad, i, v3[X], v3[Y], true))
		return py >= eq[0] * px + eq[1];
	else if (get_ud(quad, i, v3[X], v3[Y], false))
		return py <= eq[0] * px + eq[1];
}

function point_in_quad(px, py, quad)
{
	return half_plane(quad, 0, px, py) and
			half_plane(quad, 1, px, py) and
			half_plane(quad, 2, px, py) and
			half_plane(quad, 3, px, py);
}
*/

