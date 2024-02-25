//
// Simple passthrough vertex shader
//
attribute vec3 in_Position;                  
attribute vec2 in_TextureCoord;           
attribute vec4 in_Colour;                
attribute vec3 in_Normal;

varying vec2 v_Texcoord;
varying vec4 v_Colour;
varying vec3 v_Position;
varying vec3 v_Normal;

void main()
{
    vec4 object_space_pos = vec4(in_Position.x, in_Position.y, in_Position.z, 1.0); //Vertex position.
	
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    
    v_Colour = in_Colour;
    v_Texcoord = in_TextureCoord;
	v_Position = in_Position;
	v_Normal = (gm_Matrices[MATRIX_WORLD] * vec4(in_Normal, 0.)).xyz;;
	//v_Normal = in_Normal;
	//v_Translation = in_Translation;
}
