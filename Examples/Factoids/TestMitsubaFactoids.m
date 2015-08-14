%% Sandbox for playing with factoids and Mitsuba's field integrator.
%
% The Mitsuba renderer is able to return various "ground truth" data about
% scene objects as seen by each output image pixel.  We call these
% "factoids".  See RenderMitsubaFactoids().
%
% This is a brief demonstration using the Ward Land "Plant and Barrel"
% scene. 
%

clear;
clc;

% get a frozen scene
recipesFolder = fullfile( ...
    VirtualScenesRoot(), 'Examples', 'WardLandFrozen', 'Recipes');
archive = fullfile(recipesFolder, 'PlantAndBarrel.zip');

hints.renderer = 'Mitsuba';
hints.workingFolder = getpref('VirtualScenes', 'workingFolder');

hints.whichConditions = 1;

% unpack the recipe and generate its scene files.
recipe = UnpackRecipe(archive, hints);
recipe.input.hints.workingFolder = hints.workingFolder;
recipe.input.hints.isCaptureCommandResults = false;
recipe = ExecuteRecipe(recipe, 1);

%% Render the scene for factoids.

% choose a scene file for factoids
sceneFile = recipe.rendering.scenes{1}.mitsubaFile;

ChangeToWorkingFolder(recipe.input.hints);
[status, result, newScene, exrOutput, factoidOutput] = ...
    RenderMitsubaFactoids( ...
    sceneFile, [], [], [], [], [], recipe.input.hints);

%% Display the factoids.
factoids = fieldnames(factoidOutput);
for ii = 1:numel(factoids)
    factoid = factoids{ii};
    data = factoidOutput.(factoid).data;
    
    % assume channels come out alphabetically BGR instead of usual RGB
    data = flip(data, 3);
    
    subplot(3,3,ii);
    scale = max(data(:));
    imshow(data ./ scale);
    title(factoid);
end