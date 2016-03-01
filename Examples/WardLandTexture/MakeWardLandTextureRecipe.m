%% Construct and archive Ward Land texture recipes.
%
% You can use this script to generate a packed-up recipe.
% You should not need to run this script very often.
%
% You can configure various recipe parameters at the top of this script.
%
% Randomly generates a WardLand recipe and archives it in the VirtualScenes
% Toolbox recipes folder.  See getpref('VirtualScenes', 'recipesFolder').
%
% To execute the archived recipe, use ExecuteWardLandTextureRecipe.
%
% @ingroup WardLand

%% Overall configuration.
clear;
clc;

% batch renderer options
hints.renderer = 'Mitsuba';
hints.workingFolder = getpref('VirtualScenes', 'workingFolder');
hints.isPlot = false;

defaultMappings = fullfile( ...
    VirtualScenesRoot(), 'MiscellaneousData', 'DefaultMappings.txt');

% virutal scenes options for inserted objects
scaleMin = 0.25;
scaleMax = 2.0;
rotMin = 0;
rotMax = 359;

% where to save new recipes
projectName = 'WardLandTexture';
recipeFolder = ...
    fullfile(getpref('VirtualScenes', 'recipesFolder'), projectName);
if (~exist(recipeFolder, 'dir'))
    mkdir(recipeFolder);
end

%% Choose how many recipes to make and from what components.
nObjectsPerScene = 5;
nLightsPerScene = 2;

baseSceneSet = { ...
    'IndoorPlant', ...
    'Warehouse', ...
    'CheckerBoard'};

objectSet = { ...
    'Barrel', ...
    'Blobbie-01', ...
    'Blobbie-02', ...
    'Blobbie-03', ...
    'Blobbie-04', ...
    'Blobbie-05', ...
    'ChampagneBottle', ...
    'RingToy', ...
    'SmallBall', ...
    'Xylophone', ...
    };

lightSet = { ...
    'BigBall', ...
    'SmallBall', ...
    'Panel', ...
    };

%% Build a recupe from the sets above.

hints.recipeName = projectName;
ChangeToWorkingFolder(hints);

% make sure Ward Land resources are available to this recipe
[matteMaterials, wardMaterials] = GetWardLandMaterials(hints);
lightSpectra = GetWardLandIlluminantSpectra(6500, 3000, [4000 12000], 20, hints);

% choose a random base scene for this recipe
baseScene = baseSceneSet{randi(numel(baseSceneSet), 1)};

% choose objects, materials, lights, and spectra for this recipe
choices = GetWardLandChoices(baseScene, ...
    objectSet, nObjectsPerScene, ...
    lightSet, nLightsPerScene, ...
    scaleMin, scaleMax, rotMin, rotMax, ...
    matteMaterials, wardMaterials, lightSpectra);

% assemble the recipe
recipe = BuildWardLandRecipe(defaultMappings, choices, [], [], hints);

% add an executive funciton for Mitsuba's "albedo" factoid


% archive it
%   only include the resources subfolder
archiveFile = fullfile(recipeFolder, hints.recipeName);
excludeFolders = {'scenes', 'renderings', 'images', 'temp'};
PackUpRecipe(recipe, archiveFile, excludeFolders);

