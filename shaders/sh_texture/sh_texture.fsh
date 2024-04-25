varying vec3 vertex_position;
varying vec2 uvs;
varying vec3 normal;
varying vec4 vertex_color;

void main()
{
	vec3 normal = normalize(normal);
	vec3 light_direction = normalize(vec3(1., 1., -1.));
	float NdotL = (-dot(normal, light_direction) + 1.) / 2.;
	
	vec4 texCol = texture2D(gm_BaseTexture, uvs);
	
	if (texCol.a == 0.0)
		discard;
	
    gl_FragColor.rgb = vertex_color.rgb * texCol.rgb * smoothstep(0., 1., NdotL);
	gl_FragColor.a = 1.0;
}
