%% Here are some guidelines for taming wild Blender scenes.
%
% The overall goal is to clean up Blender files and export Collada files
% that are easy to work with in RenderToolbox3.
%
% Part one is remove Blender things that don't make sense for
% RenderToolbox3.  These are things like animations, constraints, and
% modifiers that can't survive the Collada export process or have no
% meaning for physycally based renderers.
%
% Part two is remodel things into a "tame" form so that our scripts know
% what to expect and how to modify scenes automatically.
%
% Part three is making a metadata "manifest" that our VirtualScenes scripts
% can find.
%
% The Blender work includes:
%   - All objects, meshes, and materials should use plain ASCII names.  Our
%   Collada parsing tools and renderers can't handle extended characters.
%   - All objects, meshes, and materials should use CamelCase names without
%   punctuation.  Names can have numbers at the end like MyThing01,
%   MyThing02.
%   - Each object should usually contain one mesh.  The object and mesh
%   should have the same name.
%   - Each mesh should usually have one material assigned.  The material
%   can have a different name from the mesh, so that materials can be
%   shared.
%   - Each "whole object" should have its own material assigned, to
%   facilitate analysis.  For example, two distinct objects that make up
%   one whole table should have the same material assigned.  But two
%   identical soda bottles located in different places should have distinct
%   materials assigned.
%   - All lights should be converted to meshes, which will later be
%   "blessed" as area lights.
%   _ All objects should have normals recalculated to make sure they face
%   outwards.  This is especially important for lights!
%   - Objects should not have Blender constraints on them.
%   - Objects should not have Blender modifiers on them.  These should be
%   removed, or "applied" to make the modifications part of the mesh data.
%   - Objects can't use Blender curves or Blender text.  Only meshes will
%   get exported properly.
%   - Objects should have all transformations "applied" to their mesh data 
%   so that they can be rotated and scaled predictably (Object -> Apply).
%   - The camera object (if any) should be named "Camera"
%   - The camera object's Transform must have Scale = [1 1 1]
%   - The Blender file should not "pack" any external data like textures.
%   External data should be unpacked into separate files, and will be
%   ignored.
%
% This Blender work can be really slow and tedious, especially if you
% rename each object by hand.  Often it makes sense to rename objects in
% groups with sequence numbers.  Blender Python integration can really help
% wiht this.  See below for some little scripts that can automate this
% work.
%
% Finally, export the Blender scene to a Collada (.dae) file.  In the lower
% left of the export dialog, choose Collada Options: Transformation Type
% TransRotLoc.  "TransRotLoc" gives RenderToolbox3 separate translation,
% rotation, and scale transformations to work with, instead of one combined
% 4x4 matrix.  Save the Blender and Collada files in the VitualScenes
% repository.
%
% The Metadata work includes:
%   - Determine the list of all material ids used in the Collada scene.
%   These should be the same as the names used in Blender, plus the suffix
%   "-material".
%   - Determine the list of all light ids used in the Collada scene.  These
%   should be the same as the names used in Blender, plus the suffix
%   "-mesh" (remember, all lights muse be modeled are meshes to be blessed
%   as area lights).
%   - Determine an approximate bounding volume where it makes sense to
%   insert objects into the scene.  This should be a
%   coordinate-axis-aligned box like [minX maxX minY maxY minZ maxZ]
%   - Determine an approximate bounding volume where it makes sense to
%   insert lights into the scene.  This should be a
%   coordinate-axis-aligned box like [minX maxX minY maxY minZ maxZ]
%   - Determine an approximate bounding volume where it DOES NOT make sense
%   to insert lights into the scene.  This should be a
%   coordinate-axis-aligned box like [minX maxX minY maxY minZ maxZ]
%   - Write a metadata file for the new scene using WriteMetadata().  See
%   TestMetadata.m for examples.
%
% Blender Python Sripts
%
% Here are some scripts which can automate tedious and difficult Blender
% work.  To run these in Belnder, choose "Python Console" from the menu in
% the bottom left corner of any Blender pane.  Paste in the code then hit
% the "Run Script" button in the Python Console.
%
% In order to read Python results and errors, you might have to launch
% Blender from the command line.  On OS X you might run a command like
% this:
% @code
% /Applications/Blender-2.73a/blender.app/Contents/MacOS/blender
% @endcode
%
% This script will rename all the currently selected objects (hold shift
% and left click multiple objects).  All the objects will have the same
% base name, plus a sequence number.  Change the base name "MyBaseName" to
% whatever you want.
% @code
% import bpy
% count = 0
% for obj in bpy.context.selected_objects:
%     count += 1
%     newName = "MyBaseName{:0>2d}".format(count)
%     obj.name = newName
%     obj.data.name = newName
% @endcode
%
% This script will convert a 2D planar object to a 3D solid object.  This
% is useful when you want the object to be viewable from all sides.  It
% will only solidify objects that start with a given prefix, "Grass" in the
% example below.  Edit this prefix to solidify the objects you want.
% @code
% import bpy
% for obj in bpy.context.scene.objects:
%     if obj.type == 'MESH' and obj.name.startswith("Grass"):
%         bpy.context.scene.objects.active = obj
%         for modifier in obj.modifiers:
%             obj.modifiers.remove(modifier)
%         bpy.ops.object.modifier_add(type='SOLIDIFY')
%         obj.modifiers["Solidify"].thickness = .04
%         bpy.ops.object.modifier_apply(modifier='Solidify', apply_as='DATA')
% @endcode
%
% This script will clean up object vertices and normals to make sure all
% the normals face outwards.
% @code
% import bpy
% for obj in bpy.context.scene.objects:
%     if obj.type == 'MESH':
%         bpy.context.scene.objects.active = obj
%         bpy.ops.object.transform_apply(location=False)
%         bpy.ops.object.mode_set(mode='EDIT')
%         bpy.ops.mesh.select_all(action='SELECT')
%         bpy.ops.mesh.remove_doubles()
%         bpy.ops.mesh.normals_make_consistent(inside=False)
%         bpy.ops.object.editmode_toggle()        
% @endcode
