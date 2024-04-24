//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main()
{
    //gl_FragColor = v_vColour * texture2D(gm_BaseTexture, v_vTexcoord);
	
	vec2 position = vec2(0.5);
	vec4 color = vec4(vec3(0.0), 1.0);
	vec4 baseColor = vec4(1.0, 0.0, 0.0, 1.0);
	
	float radius = 16.0;
	float borderThickness = 4.0;
	
	float d = length(v_vTexcoord - position);
	float alpha = 1.0 - step(0.5, d);
	gl_FragColor = vec4((1.0 - step(0.4, d)) * vec3(0.0, 0.68, 0.94), alpha);
	
	//float t1 = 1.0 - smoothstep(radius - borderThickness, radius, d);
	//float t2 = 1.0 - smoothstep(radius, radius+borderThickness, d);
	//gl_FragColor = vec4(mix(color.rgb, baseColor.rgb, t1), t2);
	
	//float t1 = 1.0 - smoothstep(0.0, borderThickness, abs(radius-d));
	//gl_FragColor = vec4(vec3(t1), 1.0);
}
