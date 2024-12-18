varying vec3 vertex_position;
varying vec2 uvs;
varying vec3 normal;
varying vec4 vertex_color;

uniform vec3 u_albedo;

void main()
{
	vec3 normal = normalize(normal);
	vec3 light_direction = normalize(vec3(1., 1., -1.));
	float NdotL = (-dot(normal, light_direction) + 1.) / 2.;
	
    gl_FragColor.rgb = vertex_color.rgb * texture2D(gm_BaseTexture, uvs).rgb * smoothstep(0., 1., NdotL);
	gl_FragColor.a = 1.;
}
