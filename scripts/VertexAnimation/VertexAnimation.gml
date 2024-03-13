// Model Animations
function ModelAnimations(info) constructor
{
	/*
	"model_name": "model.obj",
    "tex_diffuse": "tex_diffuse.png",
    "num_vertices": 5588,
    "num_frames": 505.0,
    "tex_size": 8192,
    "offsets_tex_name": "anim_offset.png",
    "normals_tex_name": "anim_normal.png",
	"animations": 
	*/
	
	self.path = info.path;
	self.filename = info.model_name;
	self.tex_diffuse = info.tex_diffuse;
	self.vertex_count = info.num_vertices;
	self.frames_count = info.num_frames;
	self.tex_size = info.tex_size;
	self.spr_offsets = sprite_add(info.path + info.offsets_tex_name, 0, false, false, 0, 0);
	self.spr_normals = sprite_add(info.path + info.normals_tex_name, 0, false, false, 0, 0);
	self.tex_offsets = sprite_get_texture(self.spr_offsets, 0);
	self.tex_normals = sprite_get_texture(self.spr_normals, 0);
	self.animations = ds_map_create();
	
	// create vertex animation
	for (var i=0; i<array_length(info.animations); i++)
	{
		var anim = new VertexAnimation(info.animations[i]);
		ds_map_add(self.animations, anim.name, anim)
	}
}

// Vertex Animation Data
function VertexAnimation(anim_info) constructor
{
	/*
    "name": "idle",
    "loop": false,
    "speed": 1,
    "frame_start": 0,
    "frame_end": 153,
    "offset_min": -0.7483420968055725,
    "offset_max": 0.7136947512626648,
    "dist": 1.4620368480682373
	*/
	
	self.name = anim_info.name;
	self.loop = anim_info.loop;
	self.speed = anim_info.speed;
	self.frame_start = anim_info.frame_start;
	self.frame_end = anim_info.frame_end;
	self.offset_min = anim_info.offset_min;
	self.offset_max = anim_info.offset_max;
	self.offset_dist = anim_info.dist;
}

// load model animations
function load_model_animations(filename)
{
	// check if file exists
	if (!file_exists(filename))
		throw "File \"" + string(filename) + "\" not found.";
		
	// get directory
	var directory = filename_dir(filename) + "/";
	
	// read data
	var full_info_file = file_text_open_read(filename);
	var full_info_text = "";
	while (!file_text_eof(full_info_file))
	{
		var string_line = file_text_readln(full_info_file);
		full_info_text += string_line;
	}
	
	// parse json
	var full_info = json_parse(full_info_text);
	full_info.path = directory;
	
	// create model animations
	var model_anims = new ModelAnimations(full_info);
	
	return model_anims;
}
