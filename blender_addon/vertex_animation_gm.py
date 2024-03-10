# ##### BEGIN GPL LICENSE BLOCK #####
#
#  This program is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation; either version 2
#  of the License, or (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software Foundation,
#  Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
#
# ##### END GPL LICENSE BLOCK #####

# <pep8 compliant>


bl_info = {
    "name": "Vertex Animation Texture",
    "author": "Davide Modenese",
    "version": (1, 0),
    "blender": (3, 5, 1),
    "location": "View3D > Sidebar > VAT Tool Tab",
    "description": "A tool for storing per frame vertex data for use in a vertex shader. Edited for GameMaker.",
    "warning": "",
    "doc_url": "https://github.com/EatingLupini/vatGM",
    "category": "VAT Tools",
}


import bpy
import bmesh
import json


def print_debug(data):
    print(data)
    for window in bpy.context.window_manager.windows:
        screen = window.screen
        for area in screen.areas:
            if area.type == 'CONSOLE':
                override = {'window': window, 'screen': screen, 'area': area}
                bpy.ops.console.scrollback_append(override, text=str(data), type="OUTPUT")


def set_per_frame_mesh_data(context, data, objects, anim):
    """Return a list of combined mesh data per frame"""
    meshes = []
    for i in range(anim['frame_start'], anim['frame_end'] + 1):
        context.scene.frame_set(i)
        depsgraph = context.evaluated_depsgraph_get()
        bm = bmesh.new()
        for ob in objects:
            ob.modifiers["Armature"].object = bpy.data.objects[anim['name']]
            eval_object = ob.evaluated_get(depsgraph)
            me = data.meshes.new_from_object(eval_object)
            me.transform(ob.matrix_world)
            bm.from_mesh(me)
            data.meshes.remove(me)
        me = data.meshes.new("mesh")
        bm.to_mesh(me)
        bm.free()
        me.calc_normals()
        meshes.append(me)
    anim['meshes'] = meshes


def create_export_mesh_object(context, data, me):
    """Return a mesh object with correct UVs"""
    while len(me.uv_layers) < 2:
        me.uv_layers.new()
    uv_layer = me.uv_layers[1]
    uv_layer.name = "vertex_anim"
    for loop in me.loops:
        uv_layer.data[loop.index].uv = (
            (loop.vertex_index + 0.5)/len(me.vertices), 128/255
        )
    ob = data.objects.new("export_mesh", me)
    context.scene.collection.objects.link(ob)
    return ob


def get_vertex_data(data, original_mesh, anim):
    """Return lists of vertex offsets and normals from a list of mesh data"""
    original = original_mesh.vertices
    offsets = []
    offsets_range = [0, 0]  # min - max
    normals = []
    for me in reversed(anim['meshes']):
        row = []
        row_normal = []
        for v in me.vertices:
            # offsets (si potrebbe fare anche sta roba -> vec.xyz = vec.zyx)
            offset = v.co - original[v.index].co
            offset[0], offset[1] = offset[1], offset[0]  # switch axes
            offset[0] *= -1
            
            # add offset to the list
            row.append(offset)
            
            # update min-max dist
            for axis in offset:
                if axis < offsets_range[0]:
                    offsets_range[0] = axis
                if axis > offsets_range[1]:
                    offsets_range[1] = axis
            
            # normals
            x, y, z = v.normal
            x, y = y, x
            x *= -1
            row_normal.append(((x + 1) * 0.5, (y + 1) * 0.5, (z + 1) * 0.5, 1))
        
        offsets.append(row)
        normals.append(row_normal)
        
        if not me.users:
            data.meshes.remove(me)
    
    return offsets, normals, offsets_range


def merge_vertex_data(animations, tex_size):
    offsets_final = []
    normals_final = []
    
    for anim in reversed(animations):
        offset_min = anim['offset_min']
        dist = anim['dist']

        offsets = anim['offsets']
        normals = anim['normals']

        # https://blender.stackexchange.com/questions/643/is-it-possible-to-create-image-data-and-save-to-a-file-from-a-script
        for j in range(len(offsets)):
            offsets_row = offsets[j]
            normals_row = normals[j]
            for i in range(len(offsets_row)):
                offsets_vert = offsets_row[i]
                normals_vert = normals_row[i]
                for axis in offsets_vert:
                    axis_norm = (axis - offset_min) / dist
                    offsets_final.append(axis_norm)
                offsets_final.append(1)
                normals_final.extend(normals_vert)
            # fill the row with transparent pixels
            missing_pixels = [0, 0, 0, 0] * (tex_size - len(offsets_row))
            offsets_final.extend(missing_pixels)
            normals_final.extend(missing_pixels)
    
    #fill the image with transparent pixels
    missing_pixels = [0] * (tex_size*tex_size*4 - len(offsets_final))
    offsets_final[0:0] = missing_pixels
    normals_final[0:0] = missing_pixels
    
    return offsets_final, normals_final


def bake_vertex_data(data, offsets, normals, size):
    """Stores vertex offsets and normals in seperate image textures"""
    width, height = size, size
    offset_texture = data.images.new(
        name="offsets",
        width=width,
        height=height,
        alpha=True,
        #float_buffer=True
    )
    offset_texture.pixels = offsets
    
    # ---- DEBUG ----
    #offset_texture_16bit = data.images.new(
    #    name="offsets_16bit",
    #    width=width,
    #    height=height,
    #    alpha=True,
    #    float_buffer=True
    #)
    #offset_texture_16bit.pixels = offsets
    # ---------------
    
    normal_texture = data.images.new(
        name="normals",
        width=width,
        height=height,
        alpha=True
    )
    normal_texture.pixels = normals
    
    return offset_texture, normal_texture


def write_mesh(path, filename):
    fp = path + filename
    
    # ---- BUG ---- somehow it exports two meshes
    # select mesh to export
    bpy.ops.object.select_all(action="DESELECT")
    # "export_mesh" is the name at row 81
    bpy.data.objects["export_mesh"].select_set(True)
  
    # actual export
    bpy.ops.export_scene.obj(
        filepath=fp,
        check_existing=True,
        use_selection=True,
        use_mesh_modifiers=True,
        use_uvs=True,
        use_normals=True,
        use_triangles=True,
        axis_forward='-X',
        axis_up='Z'
    )


def write_textures(textures, path, filenames):
    offset_texture, normal_texture = textures
    
    # write offset texture
    offset_texture.filepath_raw = path + filenames[0]
    offset_texture.file_format = 'PNG'
    offset_texture.save()
    
    # write normal texture
    normal_texture.filepath_raw = path + filenames[1]
    normal_texture.file_format = 'PNG'
    normal_texture.save()


def write_json(info, path):
    with open(path + "info.json", "w") as outfile:
        json.dump(info, outfile, indent=4)


def test_data(selected_obj):
    print_debug("selected_obj: " + str(selected_obj))
    selected_obj.modifiers["Armature"].object = bpy.data.objects["run_back"]

    for scene in bpy.data.scenes:
        for ob in scene.objects:
            # print_debug(ob)
            if (ob.animation_data is not None and ob.animation_data.action is not None):
                print_debug("ARM: " + ob.name)
                print_debug("ARM: " + str(ob.animation_data.action.frame_range.x))
                print_debug("ARM: " + str(ob.animation_data.action.frame_range.y))


def get_all_animations(scene):
    anims = list()
    frame_count = 0
    for ob in scene.objects:
        is_valid_ob = ob.animation_data is not None and \
                        ob.animation_data.action is not None and \
                        ob.type == 'ARMATURE'
        if (is_valid_ob):
            f_start = ob.animation_data.action.frame_range.x
            f_end = ob.animation_data.action.frame_range.y
            frame_count += f_end - f_start + 1

            anims.append({
                'name': ob.name,
                'frame_start': int(f_start),
                'frame_end': int(f_end)
            })
    
    return anims, frame_count


class OBJECT_OT_ProcessAnimMeshes(bpy.types.Operator):
    """Store combined per frame vertex offsets and normals for all
    selected mesh objects into seperate image textures"""
    bl_idname = "object.process_anim_meshes"
    bl_label = "Process"
    
    bpy.types.WindowManager.export_anim_name = bpy.props.StringProperty(
        default="anim",
        name="Animation Name",
        description="Animation name used in the json file.")
    bpy.types.WindowManager.export_mesh_toggle = bpy.props.BoolProperty(default=True)
    bpy.types.WindowManager.export_textures_toggle = bpy.props.BoolProperty(default=True)
    bpy.types.WindowManager.export_json_toggle = bpy.props.BoolProperty(default=True)

    directory: bpy.props.StringProperty(
        name="Directory",
        description="Where I will save my stuff",
        options={"HIDDEN"}
        )
    filter_folder: bpy.props.BoolProperty(
        default=True,
        options={"HIDDEN"}
        )
    
    @property
    def allowed_modifiers(self):
        return [
            'ARMATURE', 'CAST', 'CURVE', 'DISPLACE', 'HOOK',
            'LAPLACIANDEFORM', 'LATTICE', 'MESH_DEFORM',
            'SHRINKWRAP', 'SIMPLE_DEFORM', 'SMOOTH',
            'CORRECTIVE_SMOOTH', 'LAPLACIANSMOOTH',
            'SURFACE_DEFORM', 'WARP', 'WAVE',
        ]

    @classmethod
    def poll(cls, context):
        ob = context.active_object
        return ob and ob.type == 'MESH' and ob.mode == 'OBJECT'

    def execute(self, context):
        ob = context.object
        wm = context.window_manager
        data = bpy.data

        objects = [ob for ob in context.selected_objects if ob.type == 'MESH']
        vertex_count = sum([len(ob.data.vertices) for ob in objects])
        animations, frame_count = get_all_animations(context.scene)
        
        print_debug(f"Verteces count: {vertex_count}")
        print_debug(f"Animations count: {len(animations)}")
        print_debug(f"Frames count: {frame_count}")
        
        for ob in objects:
            for mod in ob.modifiers:
                if mod.type not in self.allowed_modifiers:
                    self.report(
                        {'ERROR'},
                        f"Objects with {mod.type.title()} modifiers are not allowed!"
                    )
                    return {'CANCELLED'}
        if vertex_count > 8192:
            self.report(
                {'ERROR'},
                f"Vertex count of {vertex_count :,}, execedes limit of 8,192!"
            )
            return {'CANCELLED'}
        if frame_count > 8192:
            self.report(
                {'ERROR'},
                f"Frame count of {frame_count :,}, execedes limit of 8,192!"
            )
            return {'CANCELLED'}
        if wm.export_json_toggle and wm.export_anim_name == "":
            self.report(
                {'ERROR'},
                f"Animation name is empty!"
            )
        
        # export data
        info = dict()
        info['animations'] = []
        
        # get pose mesh
        mesh = ob.data
        export_mesh_data = mesh.copy()
        export_mesh_data.transform(ob.matrix_world)

        # add stats to info
        num_vertices = len(export_mesh_data.vertices)
        num_max = max(num_vertices, frame_count)
        tex_size = 1;
        while tex_size < num_max:
            tex_size *= 2;
        info['num_vertices'] = num_vertices
        info['num_frames'] = frame_count
        info['tex_size'] = tex_size

        # create and write export mesh
        if wm.export_mesh_toggle:
            # create
            print_debug("Creating mesh...")
            create_export_mesh_object(context, data, export_mesh_data)
            print_debug("Done.")
            
            # write
            print_debug("Writing mesh...")
            mesh_filename = "model.obj"
            write_mesh(self.directory, mesh_filename)
            print_debug("Done.")
            
            # add model filename to info
            info['model_name'] = mesh_filename

        # create and write textures
        if wm.export_textures_toggle:
            print_debug("Writing texture...")
            frame_start = 0
            # loop through all animations found
            for anim in animations:
                # get per frame mesh
                set_per_frame_mesh_data(context, data, objects, anim)

                # anim info
                anim_info = dict()
                anim_info['name'] = anim['name']
                anim_info['loop'] = False
                anim_info['speed'] = 1
                
                # get data
                offsets_tex, normals_tex = None, None
                offsets, normals, offsets_range = get_vertex_data(data, export_mesh_data, anim)
                anim['offsets'] = offsets
                anim['normals'] = normals
                anim['offset_min'] = offsets_range[0]
                anim['offset_max'] = offsets_range[1]
                anim['dist'] = offsets_range[1] - offsets_range[0]

                # add offsets_range and dist_max to info
                anim_info['frame_start'] = frame_start
                anim_info['frame_end'] = frame_start + len(anim['meshes']) - 1
                anim_info['offset_min'] = offsets_range[0]
                anim_info['offset_max'] = offsets_range[1]
                anim_info['dist'] = offsets_range[1] - offsets_range[0]

                # add anim info
                info['animations'].append(anim_info)

                # next frame start
                frame_start += len(anim['meshes'])

            # create
            offsets_final, normals_final = merge_vertex_data(animations, tex_size)
            offsets_tex, normals_tex = bake_vertex_data(data, offsets_final, normals_final, tex_size)
                
            # write
            text_filenames = [
                wm.export_anim_name + "_offset.png",
                wm.export_anim_name + "_normal.png"
                ]
            write_textures([offsets_tex, normals_tex], self.directory, text_filenames)
            
            # add texture data to info
            info['offsets_tex_name'] = text_filenames[0]
            info['normals_tex_name'] = text_filenames[1]
            print_debug("Done.")
        
        # write json
        if wm.export_json_toggle and (wm.export_mesh_toggle or wm.export_textures_toggle):
            print_debug("Writing json...")
            write_json(info, self.directory)
            print_debug("Done.")
        
        print_debug("FINISHED")
        
        return {'FINISHED'}
    
    def invoke(self, context, event):
        # Open browser, take reference to 'self' read the path to selected
        # file, put path in predetermined self fields.
        # See: https://docs.blender.org/api/current/bpy.types.WindowManager.html#bpy.types.WindowManager.fileselect_add
        context.window_manager.fileselect_add(self)
        
        # Tells Blender to hang on for the slow user input
        return {'RUNNING_MODAL'}


class VIEW3D_PT_VertexAnimation(bpy.types.Panel):
    """Creates a Panel in 3D Viewport"""
    bl_label = "Vertex Animation"
    bl_idname = "VIEW3D_PT_vertex_animation"
    bl_space_type = 'VIEW_3D'
    bl_region_type = 'UI'
    bl_category = "VAT Tools"
    
    def draw(self, context):
        layout = self.layout
        layout.use_property_split = True
        layout.use_property_decorate = False
        scene = context.scene
        wm = context.window_manager
        
        col = layout.column(align=True)
        col.prop(wm, "export_anim_name", text="Name")
        col.prop(scene, "frame_start", text="Frame Start")
        col.prop(scene, "frame_end", text="End")
        col.prop(scene, "frame_step", text="Step")
        col.prop(wm, "export_mesh_toggle", text="Export Mesh")
        col.prop(wm, "export_textures_toggle", text="Export Textures")
        col.prop(wm, "export_json_toggle", text="Export Json")
        
        row = layout.row()
        row.operator("object.process_anim_meshes")
        
        # https://blender.stackexchange.com/questions/117787/how-to-create-toggle-button-use-python-in-blender
        # https://blender.stackexchange.com/questions/14738/use-filemanager-to-select-directory-instead-of-file


def register():
    bpy.utils.register_class(OBJECT_OT_ProcessAnimMeshes)
    bpy.utils.register_class(VIEW3D_PT_VertexAnimation)


def unregister():
    bpy.utils.unregister_class(OBJECT_OT_ProcessAnimMeshes)
    bpy.utils.unregister_class(VIEW3D_PT_VertexAnimation)


if __name__ == "__main__":
    register()
