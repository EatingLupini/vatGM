varying vec3 vertex_position;
varying vec2 uvs;
varying vec3 normal;
varying vec4 vertex_color;
varying vec3 camera_light_direction;

void main()
{
	vec4 model_color = texture2D(gm_BaseTexture, uvs);//vec3(0.7, 0., 0.7);
	vec3 normal = normalize(normal);
	vec3 static_light_direction = normalize(vec3(1., 1., -1.));
	vec3 camera_light_direction = normalize(camera_light_direction);
	
	float ambient = 0.4;
	float ndotl_static_light = (-dot(normal, static_light_direction) + 1.) * .3;
	float ndotl_camera_light = (-dot(normal, camera_light_direction) + 1.) * .3;

	float light = ambient + max(ndotl_static_light, ndotl_camera_light);
	
    gl_FragColor.rgb = model_color.rgb * vertex_color.rgb * vec3(smoothstep(0., 1., light));
	gl_FragColor.a = 1.;
}
