//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int u_num_ent;
uniform sampler2D u_sel_ent;

void main()
{
	vec2 position = vec2(512.0);
	vec2 position2 = vec2(768.0);
	
	vec2 roomSize = vec2(4096.0);
	
	vec3 color = vec3(0.0, 0.68, 0.94);
	vec3 colorBorder = vec3(0.0, 0.32, 0.64);
	
	float radius = 16.0;
	float borderThickness = 4.0;
	
	float texSize = 32.0;
	float d = 4096.0;
	
	for (int pos=0; pos<u_num_ent; pos++)
	{
		float i = mod(float(pos), texSize) / texSize;
		float j = floor(float(pos) / texSize) / texSize;
		vec4 position = texture2D(u_sel_ent, vec2(i, j));
		float cd = length(v_vTexcoord * roomSize - position.xy);
		if (cd < d)
			d = cd;
	}
	
	float visible = 1.0 - step(radius, d);
	gl_FragColor = vec4(mix(color, colorBorder, step(radius - borderThickness, d)), 0.8 * visible);
}
