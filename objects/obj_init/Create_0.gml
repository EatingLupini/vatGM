/// @description

// global vars
globalvar dt, gspd, is_paused, models;

dt = 0;
gspd = 1;
is_paused = false;

// init animations
init_animations();

// load assets
#macro MODEL			0
#macro TEXTURE			1
#macro ANIMS			2

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

/*
// zombie
var model_zombie = load_buffer_model("zombie/model.buf")
model_zombie.freeze();
// RICORDA DI SPECCHIARE LA TEXTURE VERTICALMENTE
var spr_tex_zombie = sprite_add("zombie/tex_diffuse.png", 0, true, false, 0, 0);
var anims_zombie = load_model_animations("zombie/info.json");
*/

/*
// archer
var model_archer = load_model("archer/model.obj");
model_archer.freeze();
var spr_tex_archer = sprite_add("archer/tex_diffuse.png", 0, true, false, 0, 0);
var anims_archer = load_model_animations("archer/info.json");
*/

// knight
var model_knight = load_model("knight_sword/model.obj");
model_knight.freeze();
var spr_tex_knight = sprite_add("knight_sword/tex_diffuse.png", 0, true, false, 0, 0);
var anims_knight = load_model_animations("knight_sword/info.json");

models = ds_map_create();
//ds_map_add(models, "zombie", [model_zombie, spr_tex_zombie, anims_zombie]);
//ds_map_add(models, "archer", [model_archer, spr_tex_archer, anims_archer]);
ds_map_add(models, "knight", [model_knight, spr_tex_knight, anims_knight]);


// debug
//show_debug_overlay(true);

// go to test room
room_goto(rm_test);
