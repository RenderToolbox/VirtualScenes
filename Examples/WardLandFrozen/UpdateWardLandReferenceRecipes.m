%% Locate, unpack, update, and pack up WardLand reference recipes.
%
% This script was used to update the accompanying WardLand reference
% recipes after they were created. You should not need to run this script
% again.  It is included for reference.
%
% To execute the reference recipes, use ExecuteWardLandReferenceRecipes.
%
% To make new WardLand recipes, use MakeManyWardLandRecipes.
%
% @ingroup WardLand

clear;
clc;

% locate the packed-up recipes
recipesFolder = fullfile( ...
    VirtualScenesRoot(), 'Examples', 'WardLandFrozen', 'Recipes');

% edit some batch renderer options
hints.renderer = 'Mitsuba';
hints.workingFolder = getpref('VirtualScenes', 'workingFolder');
montageScaleFactor = getpref('VirtualScenes', 'montageScaleFactor');
montageScaleMethod = getpref('VirtualScenes', 'montageScaleMethod');

% execute only basic rendering
simpleExecutive = { ...
    @MakeRecipeSceneFiles, ...
    @MakeRecipeRenderings, ...
    @MakeRecipeMontage};

%% Plant and barrel.
archive = fullfile(recipesFolder, 'PlantAndBarrel.zip');
plantAndBarrel = UnpackRecipe(archive, hints);
plantAndBarrel.input.executive = simpleExecutive;
PackUpRecipe(plantAndBarrel, archive);

%% Warehouse with near and areas of interest.
archive = fullfile(recipesFolder, 'NearFarWarehouse.zip');
nearFarWarehouse = UnpackRecipe(archive, hints);
nearFarWarehouse.input.executive = simpleExecutive;
PackUpRecipe(nearFarWarehouse, archive);

%% Flat checkerboard with no inserted objects.
archive = fullfile(recipesFolder, 'Mondrian.zip');
mondrian = UnpackRecipe(archive, hints);
mondrian.input.executive = simpleExecutive;
PackUpRecipe(mondrian, archive);

%% Checkerboard with many inserted blobbie objects.
archive = fullfile(recipesFolder, 'Blobbies.zip');
blobbies = UnpackRecipe(archive, hints);
blobbies.input.executive = simpleExecutive;
PackUpRecipe(blobbies, archive);
