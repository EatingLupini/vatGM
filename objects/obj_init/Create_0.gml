/// @description

// global vars
globalvar dt, gspd, is_paused, models;

dt = 0;
gspd = 1;
is_paused = false;

// debug
//show_debug_overlay(true);

// other
#macro WORLD_UNIT		32

// coo
#macro X				0
#macro Y				1

// model
#macro MODEL			0
#macro TEXTURE			1
#macro ANIMS			2

// batch
#macro BATCH			0
#macro V_INDEX			1
#macro A_MANAGER		2

// knight status
#macro ST_IDLE			0
#macro ST_WALK			1
#macro ST_RUN			2
#macro ST_TURN			3
#macro ST_ATTACK		4
#macro ST_BLOCK			5

// cam view type
#macro VT_FREE			0
#macro VT_THIRD			1
#macro VT_FIXED			2


// LOAD ASSETS
// castle
var model_skybox = load_model("skybox/model.obj");
model_skybox.freeze();
var arr_tex_skybox = [texture_add("skybox/tex_diffuse.png")];

// knight
var model_knight = load_model("knight_sword/model.obj");
//model_knight.freeze();
var arr_tex_knight = [texture_add("knight_sword/tex_diffuse.png")];
var anims_knight = load_model_animations("knight_sword/info.json");

// castle
var model_castle = load_model("castle/model.obj");
model_castle.freeze();
var arr_tex_castle = [
	texture_add("castle/tex_bricks.png"),
	texture_add("castle/tex_planks.png"),
	texture_add("castle/tex_stones.png"),
	texture_add("castle/tex_stones_painted.png"),
];

// tree
var model_tree = load_model("trees/tree1/model.obj");
model_tree.freeze();
var arr_tex_tree = [
	texture_add("trees/tree1//tex_wood.jpg"),
	texture_add("trees/tree1//tex_leaves.png"),
];


models = ds_map_create();
ds_map_add(models, "skybox", [model_skybox, arr_tex_skybox, undefined]);
ds_map_add(models, "knight", [model_knight, arr_tex_knight, anims_knight]);
ds_map_add(models, "castle", [model_castle, arr_tex_castle, undefined]);
ds_map_add(models, "tree", [model_tree, arr_tex_tree, undefined]);


// GOTO TEST ROOM
room_goto(rm_test);
