%% Construct and archive recipes with a series of inserted objects.
%
% You can use this script to generate a series of packed up WardLand
% recipes.  All the recipes will use a common base scene.  They will vary
% in the number of objects inserted and the scale of objects inserted.
%
% Archives the recipes in the VirtualScenes Toolbox recipes folder.  See
% getpref('VirtualScenes', 'recipesFolder').
%
% @ingroup WardLand

%% Overall configuration.
clear;
clc;

% which base scene to use
baseScene = 'IndoorPlant';

% how to construct series by number and scale of objects
objectCountSeries = [0, 6, 12];
objectScaleSeries = [0.5 1, 2];

% how to visualize series later
lineColors = lines(numel(objectCountSeries));
objectCountLineProps = { ...
    {'Color', lineColors(1,:)}, ...
    {'Color', lineColors(2,:)}, ...
    {'Color', lineColors(3,:)}, ...
    };
objectScaleLineProps = { ...
    {'LineWidth', 1, 'LineStyle', '-'}, ...
    {'LineWidth', 2, 'LineStyle', '--'}, ...
    {'LineWidth', 4, 'LineStyle', ':'}, ...
    };

% batch renderer options
hints.renderer = 'Mitsuba';
hints.workingFolder = getpref('VirtualScenes', 'workingFolder');
hints.isPlot = false;

defaultMappings = fullfile( ...
    VirtualScenesRoot(), 'MiscellaneousData', 'DefaultMappings.txt');

% virutal scenes options for inserted objects
rotMin = 0;
rotMax = 359;

% where to save new recipes
projectName = 'ObjectSeries';
recipeFolder = ...
    fullfile(getpref('VirtualScenes', 'recipesFolder'), projectName);
if (~exist(recipeFolder, 'dir'))
    mkdir(recipeFolder);
end

%% Choose which objects to insert
objectSet = { ...
    'Barrel', ...
    'Blobbie-01', ...
    'ChampagneBottle', ...
    'RingToy', ...
    'SmallBall', ...
    'Xylophone', ...
    };

%% Make a template of WardLand choices to modify below.
[matteMaterials, wardMaterials] = GetWardLandMaterials(hints);
lightSpectra = GetWardLandIlluminantSpectra(6500, 3000, [4000 12000], 20, hints);

templateChoices = GetWardLandChoices(baseScene, ...
    objectSet, objectCountSeries(end), ...
    {}, 0, ...
    0, 1, rotMin, rotMax, ...
    matteMaterials, wardMaterials, lightSpectra);

%% Build a recipe for each object count and each scale min and max.
nCountSeries = numel(objectCountSeries);
nScaleSeries = numel(objectScaleSeries);
for cc = 1:nCountSeries
    nInserted = objectCountSeries(cc);
    
    % modify the template with the specified number of objects
    choices = templateChoices;
    choices.insertedObjects.names = choices.insertedObjects.names(1:nInserted);
    choices.insertedObjects.positions = choices.insertedObjects.positions(1:nInserted);
    choices.insertedObjects.rotations = choices.insertedObjects.rotations(1:nInserted);
    choices.insertedObjects.scales = choices.insertedObjects.scales(1:nInserted);
    choices.insertedObjects.matteMaterialSets = choices.insertedObjects.matteMaterialSets(1:nInserted);
    choices.insertedObjects.wardMaterialSets = choices.insertedObjects.wardMaterialSets(1:nInserted);
    
    for ss = 1:nScaleSeries
        % modify the template with the specified object scale
        scaleXYZ = [1 1 1] * objectScaleSeries(ss);
        [choices.insertedObjects.scales{1:nInserted}] = deal(scaleXYZ);
        
        % start a new recipe
        hints.recipeName = sprintf('%s-%do-%ds', ...
            baseScene, cc, ss);
        ChangeToWorkingFolder(hints);
        
        % copy resources into this recipe's folder
        [matteMaterials, wardMaterials] = GetWardLandMaterials(hints);
        lightSpectra = GetWardLandIlluminantSpectra(6500, 3000, [4000 12000], 20, hints);
        
        % assemble the recipe
        recipe = BuildWardLandRecipe(defaultMappings, choices, [], [], hints);
        
        % remember some series parameters
        recipe.processing.choices = choices;
        
        % remember how to visually identify this recipe
        recipe.processing.lineProps = ...
            cat(2, objectCountLineProps{cc}, objectScaleLineProps{ss});
        
        % archive it
        %   only include the resources subfolder
        archiveFile = fullfile(recipeFolder, hints.recipeName);
        excludeFolders = {'scenes', 'renderings', 'images', 'temp'};
        PackUpRecipe(recipe, archiveFile, excludeFolders);
    end
end
