%% Locate, unpack, and execute many WardLand recipes created earlier.
%
% Use this script to render many archived recipes created earlier, using
% MakeManyWardLandRecipes.
%
% You can configure a few recipe parameters at the top of this script.
% The values will apply to all generated recipes.  For example, you can
% change the output image size here, when you execute the recipes.  You
% don't have to generate new recipes to change the image size.
%
% @ingroup WardLand

%% Overall Setup.
clear;
clc;

% location of packed-up recipes
projectName = 'WardLandDatabase';
recipeFolder = fullfile(getpref('VirtualScenes', 'recipesFolder'), projectName, 'Originals');
if ~exist(recipeFolder, 'dir')
    disp(['Recipe folder not found: ' recipeFolder]);
end

% location of renderings
renderingFolder = fullfile(getpref('VirtualScenes', 'recipesFolder'), projectName, 'Rendered');

% edit some batch renderer options
hints.renderer = 'Mitsuba';
hints.workingFolder = getpref('VirtualScenes', 'workingFolder');
hints.imageWidth = 640;
hints.imageHeight = 480;

%% Locate and render each packed-up recipe.

archiveFiles = rtbFindFiles('root', recipeFolder, 'filter', '\.zip$');
nScenes = numel(archiveFiles);
for ii = 1:nScenes
    % get the recupe
    recipe = UnpackRecipe(archiveFiles{ii}, hints);
    
    % modify rendering options
    recipe.input.hints.renderer = hints.renderer;
    recipe.input.hints.workingFolder = hints.workingFolder;
    recipe.input.hints.imageWidth = hints.imageWidth;
    recipe.input.hints.imageHeight = hints.imageHeight;
    
    % render and proceed after errors
    try
        recipe = ExecuteRecipe(recipe, [], true);
    catch err
        disp(err.message)
        continue;
    end
    
    % save the results in a separate folder
    [archivePath, archiveBase, archiveExt] = fileparts(archiveFiles{ii});
    renderedArchiveFile = fullfile(renderingFolder, [archiveBase archiveExt]);
    excludeFolders = {'temp'};
    PackUpRecipe(recipe, renderedArchiveFile, excludeFolders);
end
