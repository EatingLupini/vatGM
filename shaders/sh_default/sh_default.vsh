attribute vec3 in_Position;                  
attribute vec2 in_TextureCoord;           
attribute vec4 in_Colour;                
attribute vec3 in_Normal;
attribute float in_Index;

varying vec3 vertex_position;
varying vec2 uvs;
varying vec3 normal;
varying vec4 vertex_color;
varying vec3 camera_light_direction;

void main()
{
	 //Vertex position.
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position, 1.);
    
    //Vertex data.
	vertex_position = in_Position; //Position.
    vertex_color = in_Colour; //Color.
    uvs = in_TextureCoord; //UVs.
	normal = (gm_Matrices[MATRIX_WORLD] * vec4(in_Normal, 0.)).xyz; //Normal.
	camera_light_direction = (gm_Matrices[MATRIX_VIEW] * normalize(vec4(1., 1., -1., 0.))).xyz;
}
