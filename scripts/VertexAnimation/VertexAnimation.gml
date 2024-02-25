// Vertex Animation Data
function VertexAnimation(anim_info) constructor
{
	/*
	"name": "anim0",
    "num_vertices": 7882,
    "num_frames": 130,
    "tex_size": 8192,
    "offset_min": -1.9254114627838135,
    "offset_max": 1.3608264923095703,
    "dist": 3.286237955093384,
    "offset_tex_name": "anim0_offset.png",
    "normal_tex_name": "anim0_normal.png"
	*/
	
	self.name = anim_info.name;
	self.loop = anim_info.loop;
	self.speed = anim_info.speed;
	self.vertex_count = anim_info.num_vertices;
	self.frame_count = anim_info.num_frames;
	self.tex_size = anim_info.tex_size;
	self.offset_min = anim_info.offset_min;
	self.offset_max = anim_info.offset_max;
	self.offset_dist = anim_info.dist;
	self.spr_offsets = sprite_add(anim_info.path + anim_info.offset_tex_name, 0, false, false, 0, 0);
	self.spr_normals = sprite_add(anim_info.path + anim_info.normal_tex_name, 0, false, false, 0, 0);
	self.tex_offsets = sprite_get_texture(self.spr_offsets, 0);
	self.tex_normals = sprite_get_texture(self.spr_normals, 0);
}

// load vertex animation
function load_vertex_animation(filename)
{
	var anims = array_create(0);
	
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
	
	// create vertex animation
	for (var i=0; i<array_length(full_info.animations); i++)
	{
		var anim_info = full_info.animations[i];
		anim_info.path = directory;
		var anim = new VertexAnimation(anim_info);
		anims[i] = anim;
	}
	
	return anims;
}