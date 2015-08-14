%% Locate, unpack, and execute WardLand reference recipes created earlier.
%
% Use this script to render a few archived reference recipes created
% earlier, using MakeWardLandReferenceRecipes.
%
% You can run this script any time to re-render the set of WardLand
% reference recipes.  These results should not change over time.
%
% @ingroup WardLand

% Use this script to render several accompanying packed-up recipes.

%% Basic Setup.
clear;
clc;

% locate the packed-up recipes
recipesFolder = fullfile( ...
    VirtualScenesRoot(), 'Examples', 'WardLandFrozen', 'Recipes');

% edit some batch renderer options
hints.renderer = 'Mitsuba';
hints.workingFolder = getpref('VirtualScenes', 'workingFolder');
hints.imageWidth = 640/4;
hints.imageHeight = 480/4;

%% Choose how to execute the recipes.
toneMapFactor = 100;
isScale = true;

executive = { ...
    @MakeRecipeSceneFiles, ...
    @MakeRecipeRenderings, ...
    @(recipe)MakeRecipeRGBImages(recipe, toneMapFactor, isScale), ...
    };

%% Plant and barrel.
archive = fullfile(recipesFolder, 'PlantAndBarrel.zip');
plantAndBarrel = UnpackRecipe(archive, hints);
plantAndBarrel.input.hints.renderer = hints.renderer;
plantAndBarrel.input.hints.workingFolder = hints.workingFolder;
plantAndBarrel.input.hints.imageWidth = hints.imageWidth;
plantAndBarrel.input.hints.imageHeight = hints.imageHeight;

plantAndBarrel.input.executive = executive;
plantAndBarrel = ExecuteRecipe(plantAndBarrel);

%% Warehouse with near and areas of interest.
archive = fullfile(recipesFolder, 'NearFarWarehouse.zip');
nearFarWarehouse = UnpackRecipe(archive, hints);
nearFarWarehouse.input.hints.renderer = hints.renderer;
nearFarWarehouse.input.hints.workingFolder = hints.workingFolder;
nearFarWarehouse.input.hints.imageWidth = hints.imageWidth;
nearFarWarehouse.input.hints.imageHeight = hints.imageHeight;

nearFarWarehouse.input.executive = executive;
nearFarWarehouse = ExecuteRecipe(nearFarWarehouse);

%% Flat checkerboard with no inserted objects.
archive = fullfile(recipesFolder, 'Mondrian.zip');
mondrian = UnpackRecipe(archive, hints);
mondrian.input.hints.renderer = hints.renderer;
mondrian.input.hints.workingFolder = hints.workingFolder;
mondrian.input.hints.imageWidth = hints.imageWidth;
mondrian.input.hints.imageHeight = hints.imageHeight;

mondrian.input.executive = executive;
mondrian = ExecuteRecipe(mondrian);

%% Checkerboard with many inserted blobbie objects.
archive = fullfile(recipesFolder, 'Blobbies.zip');
blobbies = UnpackRecipe(archive, hints);
blobbies.input.hints.renderer = hints.renderer;
blobbies.input.hints.workingFolder = hints.workingFolder;
blobbies.input.hints.imageWidth = hints.imageWidth;
blobbies.input.hints.imageHeight = hints.imageHeight;

blobbies.input.executive = executive;
blobbies = ExecuteRecipe(blobbies);
