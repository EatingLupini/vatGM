/**
 * Return an array containing quaternion values obtained converting the given euler angles.
 * @param {real} pitch X angle in radians.
 * @param {real} yaw Y angle in radians.
 * @param {real} roll Z angle in radians.
 * @returns {array<real>} Values of the quaternion.
 */
function quaternion_set_euler(pitch, yaw, roll) 
{
	var cx = dcos(pitch / 2);
	var cy = dcos(yaw / 2);
	var cz = dcos(roll / 2);

	var sx = dsin(pitch / 2);
	var sy = dsin(yaw / 2);
	var sz = dsin(roll / 2);
	
	var quat = array_create(4);
	quat[0] = cy * sx * cz + sy * cx * sz;
	quat[1] = sy * cx * cz - cy * sx * sz;
	quat[2] = cy * cx * sz - sy * sx * cz;
	quat[3] = cy * cx * cz + sy * sx * sz;

	return quat;
}

/*///@description					Transforms a vector using the given matrix
///@param	{Vec4} vect			The vector to transform
///@param	{Matrix} mat		The matrix used for transformation
///@return	{Vec4}*/
/**
 * Transforms a vector using the given matrix.
 * @param {array<real>} vect Vector to transform.
 * @param {array<real>} mat Matrix for the transformation.
 * @returns {array<real>} The transformend vector.
 */
function vec_transform(vect, mat)
{
	
	var mtx = mat
	var vec_0 = vect[0];
	var vec_1 = vect[1];
	var vec_2 = vect[2];
	var vec_3 = vect[3];

	vect[3] =
	    vec_0 * mtx[3]+
	    vec_1 * mtx[7]+
	    vec_2 * mtx[11]+
	    vec_3 * mtx[15];
	vect[2] =
	    vec_0 * mtx[2]+
	    vec_1 * mtx[6]+
	    vec_2 * mtx[10]+
	    vec_3 * mtx[14];
	vect[1] =
	    vec_0 * mtx[1]+
	    vec_1 * mtx[5]+
	    vec_2 * mtx[9]+
	    vec_3 * mtx[13];
	vect[0] =
	    vec_0 * mtx[0]+
	    vec_1 * mtx[4]+
	    vec_2 * mtx[8]+
	    vec_3 * mtx[12];
    
	return vect;

}
