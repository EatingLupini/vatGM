//Enumerates type of lines you can find in a .obj file.
enum OBJLineType
{
	MATERIAL_FILE,
	VERTEX,
	UV,
	NORMAL,
	USE_MATERIAL,
	FACE,
	OTHER
}

//Enumerates type of lines you can find in a .mtl file.
enum MTLLineType
{
	NEW_MATERIAL,
	OTHER
}

//Enumerates type of face format you can find in a .obj file.
enum OBJFaceFormat
{
	VERTEX_UV_NORMAL,
	VERTEX_NORMAL,
	VERTEX_UV
}

/**
 * Initializes data needed by the importer.
 */
function init_importer()
{
	//Create buffer formats.
	init_buffer_formats();
	
	//Default material. It is used as a default material when non material is assigned to a model.
	if (!variable_global_exists("default_material"))
	{
		global.default_material = new Material(sh_default); 
		global.default_material.set_texture(sprite_get_texture(tex_missing, 0));
	}
	
	if (!variable_global_exists("default_material_dynamic_batch"))
	{
		global.default_material_dynamic_batch = new Material(sh_default_dbatch); 
		global.default_material_dynamic_batch.set_texture(sprite_get_texture(tex_missing, 0));
	}
}

/**
 * Loads a model from the given file. The file should be located inside the included files folder.
 * @param {string} filename Path to the .obj of the model to load.
 * @returns {struct.Model} The model loaded from the given file.
 */
function load_model(filename)
{
	//Initialize the importer if not done before.
	init_importer();
	
	//Check if file exists.
	if (!file_exists(filename))
		throw "File \"" + string(filename) + "\" not found.";
	
	var directory = filename_dir(filename) + "/"; //Directory of the file, needed to find .mtl files.
	var model_file = file_text_open_read(filename); //Open the model file.
	var current_material = -1;
	var material_names = -1;
	
	//Struct that will contain the data read from the file.
	var model_data =
	{
		vertices : ds_list_create(),
		uvs : ds_list_create(),
		normals : ds_list_create(),
		faces : ds_map_create(),
		material_count : 0,
		name: filename,
		bounding_box:
		{
			min : array_create(3, infinity),
			max : array_create(3, -infinity)
		}
	}
	
	//Parse the file.
	while (!file_text_eof(model_file))
	{
		var string_line = file_text_readln(model_file);
		var line = get_line_type_and_data(string_line);
		
		switch (line.type)
		{
			case OBJLineType.MATERIAL_FILE: //Load materials and create face lists.
				var material_data = load_materials(directory + line.data, model_data.faces);
				model_data.material_count = material_data.count;
				material_names = material_data.material_names;
				break;
				
			case OBJLineType.VERTEX: //Add the vertex to the vertices list.
				//model_data.vertices[| ds_list_size(model_data.vertices)] = line.data;
				ds_list_add(model_data.vertices, line.data);
				break;
				
			case OBJLineType.UV: //Add the UV coordinate to the uvs list.
				//model_data.uvs[| ds_list_size(model_data.uvs)] = line.data;
				ds_list_add(model_data.uvs, line.data);
				break;
				
			case OBJLineType.NORMAL: //Add the normal to the normals list.
				//model_data.normals[| ds_list_size(model_data.normals)] = line.data;
				ds_list_add(model_data.normals, line.data);
				break;
				
			case OBJLineType.USE_MATERIAL: //Faces after this line belongs to the last used material.
				current_material = line.data;
				break;
				
			case OBJLineType.FACE: //Add the face to the correct material.
				if (array_length(line.data) != 3) //Faces must be of 3 vertices.
					throw "All faces must have 3 vertices, found face with " + string(array_length(line.data)) + " vertices. Be sure to triangulate the mesh.";
				
				var face_list = model_data.faces[? current_material]; //Get the correct face list.
				//face_list[| ds_list_size(face_list)] = new OBJFace(line.data); //Create a new face and add it to the list.
				ds_list_add(face_list, new OBJFace(line.data));
				break;
				
			case OBJLineType.OTHER: //These type of line are not important.
				break;
		}
	}
	
	//If material count is 0 there is a problem with the .obj file.
	if (model_data.material_count == 0)
		throw "No material definition found.";
	
	//If we reached here the data is loaded correctly.
	show_debug_message(
		filename + " - Model correctly loaded."
	  + "\n\tModel vertices: " + string(ds_list_size(model_data.vertices))
	  + "\n\tModel faces: " + string(ds_map_size(model_data.faces))
	  + "\n\tModel material count: " + string(model_data.material_count)
	);
	
	//Create buffers for models. One for each material.
	var buffers = array_create(model_data.material_count);
	
	//For each material create a buffer and add the correspondig faces.
	for (var i = 0; i < model_data.material_count; i++)
	{
		var face_list = model_data.faces[? material_names[| i]]; //List of faces.
		var vertex_buffer = vertex_create_buffer(); //Vertex buffer of the material.
		
		vertex_begin(vertex_buffer, global.buffer_format);
		
		//For each face of the material.
		for (var j = 0; j < ds_list_size(face_list); j++)
		{
			var face = face_list[| j];
			
			//For each vertices of the face.
			for (var k = 0; k < 3; k++)
			{
				var vertex_indices = face.vertices[k] - 1;
				var vertices_data = model_data.vertices[| vertex_indices];
				
				//Uv and normals indices can be undefined.
				var uv_indices = face.uvs[k] == -1 ? undefined : face.uvs[k] - 1;
				var normal_indices = face.normals[k] == -1 ? undefined : face.normals[k] - 1;
				
				var uvs_data = uv_indices != undefined ? model_data.uvs[| uv_indices] : [0, 0];
				var normal_data = normal_indices != undefined ? model_data.normals[| normal_indices] : rand_ball(1);
				
				vertex_position_3d(vertex_buffer, vertices_data[0], vertices_data[1], vertices_data[2]); //Add vertex.
				vertex_texcoord(vertex_buffer, uvs_data[0], uvs_data[1]); //Add UVs
				vertex_color(vertex_buffer, c_white, 1); //Add color (this must be added because GM demands it).
				vertex_normal(vertex_buffer, normal_data[0], normal_data[1], normal_data[2]); //Add normals.
				vertex_float1(vertex_buffer, vertex_indices);
				
				//Calculate bounding box.
				model_data.bounding_box.min[0] = min(model_data.bounding_box.min[0], vertices_data[0]);
				model_data.bounding_box.min[1] = min(model_data.bounding_box.min[1], vertices_data[1]);
				model_data.bounding_box.min[2] = min(model_data.bounding_box.min[2], vertices_data[2]);
				model_data.bounding_box.max[0] = max(model_data.bounding_box.max[0], vertices_data[0]);
				model_data.bounding_box.max[1] = max(model_data.bounding_box.max[1], vertices_data[1]);
				model_data.bounding_box.max[2] = max(model_data.bounding_box.max[2], vertices_data[2]);
			}
			
		}
		
		vertex_end(vertex_buffer);
		
		buffers[i] = vertex_buffer;
	}
	
	file_text_close(model_file); //Close file.
	
	//Delete lists.
	ds_list_destroy(model_data.vertices);
	ds_list_destroy(model_data.uvs);
	ds_list_destroy(model_data.normals);
	
	for (var i = 0; i < model_data.material_count; i++)
		ds_list_destroy(model_data.faces[? material_names[| i]]);
	
	ds_list_destroy(material_names);
	ds_map_destroy(model_data.faces);
	
	//Return the loaded model.
	var bbox = new ModelBBox(model_data.bounding_box.min, model_data.bounding_box.max);
	var model = new Model(buffers, model_data.material_count);
	model.set_bbox(bbox);
	model.set_name(model_data.name);
	
	return model;
}

/**
 * Saves the given model buffer to the given file for fast loading.
 * @param {struct.Model} model Model to save to file.
 * @param {string} filename Path of the file to save the model into.
 */
function save_model(model, filename)
{
	//Initialize the importer if not done before.
	init_importer();
	
	var file = file_text_open_write(filename);
	
	file_text_write_real(file, model.material_count); //Write number of materials.
	file_text_writeln(file);
	file_text_write_string(file, base64_encode(json_stringify(model.get_bbox().get_raw()))); //Write bounding box.
	file_text_writeln(file);
	
	//Write buffers.
	for (var i = 0; i < model.material_count; i++)
	{
		var buffer = buffer_create_from_vertex_buffer(model.vertex_buffers[i], buffer_vbuffer, 1);
		file_text_write_string(file, buffer_base64_encode(buffer, 0, buffer_get_size(buffer)));
		file_text_writeln(file);
	}
	
	file_text_close(file);
}

/**
 * Loads a model buffer from the given file. The file should be located inside the included files folder.
 * @param {string} filename Path to the model buffer file to load.
 * @returns {struct} The model loaded from the buffer.
 */
function load_buffer_model(filename)
{	
	//Initialize the importer if not done before.
	init_importer();
	
	//Check if file exists.
	if (!file_exists(filename))
		throw "File \"" + string(filename) + "\" not found.";
	
	var file = file_text_open_read(filename);
	
	var material_count = real(file_text_readln(file)); //Read number of materials.
	var bbox_json = base64_decode(file_text_readln(file));
	var bbox = json_parse(bbox_json); //Read bounding box.
	var vertex_buffers = array_create(material_count);
	
	//Read buffers.
	for (var i = 0; i < material_count; i++)
	{
		var buffer = buffer_base64_decode(file_text_readln(file));
		vertex_buffers[i] = vertex_create_buffer_from_buffer(buffer, global.buffer_format);
	}
	
	file_text_close(file);
	
	var model = new Model(vertex_buffers, material_count);
	model.set_bbox(new ModelBBox(bbox[0], bbox[1]));
	model.set_name(filename_name(filename));
	
	return model;
}

/**
 * Extrapolates the line type (vertex, normal, uvs, face, ecc..) and its data from the given line.
 * @param {string} line The line to parse.
 * @returns {struct} A struct containing the type and the data extrapolated from the file.
 */
function get_line_type_and_data(line)
{
	var line_data = 
	{
		type : OBJLineType.OTHER,
		data : ""
	}
	
	if (string_count("mtllib ", line) > 0) //Material file.
	{
		line_data.type = OBJLineType.MATERIAL_FILE;
		line_data.data = string_strip(string_replace(line, "mtllib ", ""));
	}
	else if (string_count("v ", line) > 0) //Vertex data.
	{
		line_data.type = OBJLineType.VERTEX;
		line_data.data = string_split_number(string_strip(string_replace(line, "v ", "")), " ");
	}
	else if (string_count("vt ", line) > 0) //UV data.
	{
		line_data.type = OBJLineType.UV;
		line_data.data = string_split_number(string_strip(string_replace(line, "vt ", "")), " ");
	}
	else if (string_count("vn ", line) > 0) //Normal data.
	{
		line_data.type = OBJLineType.NORMAL;
		line_data.data = string_split_number(string_strip(string_replace(line, "vn ", "")), " ");
	}
	else if (string_count("usemtl ", line) > 0) //Current material data.
	{
		line_data.type = OBJLineType.USE_MATERIAL;
		line_data.data = string_strip(string_replace(line, "usemtl ", ""));
	}
	else if (string_count("f ", line) > 0) //Face data.
	{
		line_data.type = OBJLineType.FACE;
		line_data.data = string_split(string_strip(string_replace(line, "f ", "")), " ");
	}

	return line_data;
	
}

/**
 * Parses the given material file and retreives the material names and count. It also create entries in the given material map.
 * @param {string} filename The path to the material file.
 * @param {id.dsmap<id.dslist>} material_map The map that will contain the entries of the materials.
 * @returns {struct} Struct containing material names and count.
 */
function load_materials(filename, material_map)
{
	//Check if file exists.
	if (!file_exists(filename))
		throw "Material file \"" + string(filename) + "\" not found. Be sure the .mtl file of the model is in the same folder as the .obj file.";
	
	var material_file = file_text_open_read(filename);
	var count = 0; //Current material count.
	var material_names = ds_list_create();
	
	//Read the file.
	while (!file_text_eof(material_file))
	{
		var string_line = file_text_readln(material_file);
		
		if (string_count("newmtl ", string_line) > 0) //Material definition line.
		{
			var material_name = string_strip(string_replace(string_line, "newmtl ", ""));
			material_map[? material_name] = ds_list_create();
			material_names[| ds_list_size(material_names)] = material_name;
			count++;
		}
	}
	
	file_text_close(material_file);
	return 
	{
		count : count,
		material_names : material_names
	};
}

function string_split(str, delimiter)
{
	var output = [];
	var len = string_length(str);
	var word = "";
	
	for (var i = 1; i < len + 1; i++)
	{
		var char = string_char_at(str, i);
		
		if (char == "\n")
			continue;
		
		if (char != delimiter)
			word += char;
		else
		{
			array_resize(output, array_length(output) + 1);
			output[array_length(output) - 1] = word;
			word = "";
		}
	}
	
	array_resize(output, array_length(output) + 1);
	output[array_length(output) - 1] = word;
	
	return output;
}

function string_split_number(str, delimiter)
{
	var output = [];
	var len = string_length(str);
	var word = "";
	
	for (var i = 1; i < len + 1; i++)
	{
		var char = string_char_at(str, i);
		
		if (char == "\n")
			continue;
		
		if (char != delimiter)
			word += char;
		else
		{
			array_resize(output, array_length(output) + 1);
			output[array_length(output) - 1] = real(word);
			word = "";
		}
	}
	
	array_resize(output, array_length(output) + 1);
	output[array_length(output) - 1] = real(word);
	
	return output;
}

function string_strip(str)
{	
	while (string_char_at(str, 1) == " " || string_char_at(str, 1) == "\n" || string_char_at(str, 1) == "\r")
		str = string_delete(str, 1, 1);
	
	while (string_char_at(str, string_length(str)) == " " || string_char_at(str, string_length(str)) == "\n" || string_char_at(str, string_length(str)) == "\r")
		str = string_delete(str, string_length(str), 1);
	
	return str;
}

function OBJFace(data) constructor
{	
	self.vertices = [array_length(data)];
	self.uvs = [array_length(data)];
	self.normals = [array_length(data)];
	
	var format;
	
	//Check face format.
	if (string_count("//", data[0]) > 0)
		format = OBJFaceFormat.VERTEX_NORMAL;
	else if (string_count("/", data[0]) == 2)
		format = OBJFaceFormat.VERTEX_UV_NORMAL;
	else
	{
		format = OBJFaceFormat.VERTEX_UV;
		show_debug_message("WARNING: Face format has no normal definition. Randomizing normal.");
	}
	
	for (var i = 0; i < array_length(data); i++)
	{
		var face_data = string_split(data[i], "/");
		
		switch (format)
		{
			case OBJFaceFormat.VERTEX_UV_NORMAL:
				self.vertices[i] = real(face_data[0]);
				self.uvs[i] = real(face_data[1]);
				self.normals[i] = real(face_data[2]);
				break;
			
			case OBJFaceFormat.VERTEX_UV:
				self.vertices[i] = real(face_data[0]);
				self.uvs[i] = real(face_data[1]);
				self.normals[i] = -1;
				break;
				
			case OBJFaceFormat.VERTEX_NORMAL:
				self.vertices[i] = real(face_data[0]);
				self.uvs[i] = -1;
				self.normals[i] = real(face_data[2]);
				break;
		}
	}
}