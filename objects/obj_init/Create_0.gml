/// @description

// global vars
globalvar dt, gspd, models;

dt = 0;
gspd = 1;

// init animations
init_animations();

// load assets
#macro MODEL	0
#macro TEXTURE	1
#macro ANIMS	2

/*
// zombie
var model_zombie = load_buffer_model("test/model.buf")
model_zombie.freeze();
var spr_tex_zombie = sprite_add("test/world_war_zombie_diffuse.png", 0, true, false, 0, 0);
var anims_zombie = load_model_animations("test/info.json");
*/

// zombie
var model_zombie = load_buffer_model("zombie/model.buf")
model_zombie.freeze();
// RICORDA DI SPECCHIARE LA TEXTURE ORIZZONTALMENTE
var spr_tex_zombie = sprite_add("zombie/tex_diffuse.png", 0, true, false, 0, 0);
var anims_zombie = load_model_animations("zombie/info.json");

/*
// archer
var model_archer = load_model("archer/model.obj");
model_archer.freeze();
var spr_tex_archer = sprite_add("archer/tex_diffuse.png", 0, true, false, 0, 0);
var anims_archer = load_model_animations("archer/info.json");
*/

// knight
var model_knight = load_model("knight/model.obj");
model_knight.freeze();
var spr_tex_knight = sprite_add("knight/tex_diffuse.png", 0, true, false, 0, 0);
var anims_knight = load_model_animations("knight/info.json");

models = ds_map_create();
ds_map_add(models, "zombie", [model_zombie, spr_tex_zombie, anims_zombie]);
//ds_map_add(models, "archer", [model_archer, spr_tex_archer, anims_archer]);
ds_map_add(models, "knight", [model_knight, spr_tex_knight, anims_knight]);


// debug
//show_debug_overlay(true);

// go to test room
room_goto(rm_test);
