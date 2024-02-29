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

var model_temp = load_model("test/model.obj");
model_temp.freeze();
var spr_tex_temp = sprite_add("test/world_war_zombie_diffuse.png", 0, true, false, 0, 0);
var anim_temp = load_vertex_animation("test/info.json");

models = ds_map_create();
ds_map_add(models, "zombie", [model_temp, spr_tex_temp, anim_temp]);

// debug
//show_debug_overlay(true);

// go to test room
room_goto(rm_test);
