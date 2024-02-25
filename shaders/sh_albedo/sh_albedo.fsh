varying vec2 v_Texcoord;
varying vec4 v_Colour;
varying vec3 v_Position;
varying vec3 v_Normal;

uniform vec3 u_albedo;

void main()
{
	vec3 normal = normalize(v_Normal);
	vec3 lightDir = normalize(vec3(1., 1., -1.));
	
	float NdotL = (-dot(normal, lightDir) + 1.) / 2.;
	
    gl_FragColor.rgb = v_Colour.rgb * u_albedo.rgb * smoothstep(0., 1., NdotL);
	gl_FragColor.a = 1.;
}
