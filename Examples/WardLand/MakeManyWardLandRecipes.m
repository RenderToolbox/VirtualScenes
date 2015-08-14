%% Construct and archive a set of many Ward Land recipes.
%
% You can use this script to generate the a large set of packed-up recipes.
% You should not need to run this script very often.
%
% You can configure various recipe parameters at the top of this script.
% The values will apply to all generated recipes.
%
% Randomly generates a number of WardLand recipes and archives the recipes
% in the VirtualScenes Toolbox recipes folder.  See
% getpref('VirtualScenes', 'recipesFolder').
%
% To execute the archived recipes, use ExecuteManyWardLandRecipes.
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
projectName = 'WardLandDatabase';
recipeFolder = fullfile(getpref('VirtualScenes', 'recipesFolder'), projectName, 'Originals');
if (~exist(recipeFolder, 'dir'))
    mkdir(recipeFolder);
end

%% Choose how many recipes to make and from what components.
baseSceneSet = { ...
    'CheckerBoard', ...
    'IndoorPlant', ...
    'Library', ...
    'Mill', ...
    'TableChairs', ...
    'Warehouse'};

objectSet = { ...
    'Barrel', ...
    'BigBall', ...
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

%% Build multiple recipes based on the sets above.
objectConditions = 4:8;
lightConditions = 0:3;

nSceneConditions = numel(baseSceneSet);
nObjectConditions = numel(objectConditions);
nLightConditions = numel(lightConditions);
nRecipes = nSceneConditions * nObjectConditions * nLightConditions;

for ss = 1:nSceneConditions
    baseScene = baseSceneSet{ss};
    
    for oo = 1:nObjectConditions
        nObjects = objectConditions(oo);
        
        for ll = 1:nLightConditions
            nLights = lightConditions(ll);
            
            recipeName = sprintf('%s-%02d-Obj-%02d-Illum', baseScene, nObjects, nLights);
            hints.recipeName = recipeName;
            ChangeToWorkingFolder(hints);
            
            % copy resources into this recipe working folder
            [textureIds, textures, matteTextured, wardTextured, filePaths] = ...
                GetWardLandTextureMaterials(3:6, hints);
            [matteMacbeth, wardMacbeth] = GetWardLandMaterials(hints);
            lightSpectra = GetWardLandIlluminantSpectra(6500, 3000, [4000 12000], 20, hints);
            
            % choose a 50/50 mix of textured and Macbeth materials
            nPick = 10;
            textureInds = randi(numel(matteTextured), [1 nPick]);
            macbethInds = randi(numel(matteMacbeth), [1 nPick]);
            matteMaterials = cat(2, matteTextured(textureInds), matteMacbeth(macbethInds));
            wardMaterials = cat(2, wardTextured(textureInds), wardMacbeth(macbethInds));
            
            % choose objects, materials, lights, and spectra
            choices = GetWardLandChoices(baseScene, ...
                objectSet, nObjects, ...
                lightSet, nLights, ...
                scaleMin, scaleMax, rotMin, rotMax, ...
                matteMaterials, wardMaterials, lightSpectra);
            
            % assemble the recipe
            recipe = BuildWardLandRecipe( ...
                defaultMappings, choices, textureIds, textures, hints);
            
            % archive it
            archiveFile = fullfile(recipeFolder, hints.recipeName);
            excludeFolders = {'scenes', 'renderings', 'images', 'temp'};
            PackUpRecipe(recipe, archiveFile, excludeFolders);
        end
    end
end
