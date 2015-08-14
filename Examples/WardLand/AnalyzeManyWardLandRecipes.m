%% Locate, unpack, and execute many WardLand recipes created earlier.
%
% Use this script to analyze many archived recipes rendered earlier, using
% RenderManyWardLandRecipes.
%
% You can configure a few recipe parameters at the top of this script.
%
% @ingroup WardLand

%% Overall Setup.
clear;
clc;

% location of packed-up recipes
projectName = 'WardLandDatabase';
recipeFolder = fullfile(getpref('VirtualScenes', 'recipesFolder'), projectName, 'Rendered');
if ~exist(recipeFolder, 'dir')
    disp(['Recipe folder not found: ' recipeFolder]);
end

% location of saved figures
figureFolder = fullfile(getpref('VirtualScenes', 'recipesFolder'), projectName, 'Figures');

% edit some batch renderer options
hints.renderer = 'Mitsuba';
hints.workingFolder = getpref('VirtualScenes', 'workingFolder');

% analysis params
toneMapFactor = 10;
isScale = true;
filterWidth = 7;
lmsSensitivities = 'T_cones_ss2';

% easier to read plots
set(0, 'DefaultAxesFontSize', 14)

%% Analyze each packed up recipe.
archiveFiles = FindFiles(recipeFolder, '\.zip$');
nRecipes = numel(archiveFiles);

reductions = cell(1, nRecipes);
for ii = 1:nRecipes
    % get the recipe
    recipe = UnpackRecipe(archiveFiles{ii}, hints);
    ChangeToWorkingFolder(recipe.input.hints);
    
    % run basic recipe analysis functions
    recipe = MakeRecipeRGBImages(recipe, toneMapFactor, isScale);
    recipe = MakeRecipeAlbedoFactoidImages(recipe, toneMapFactor, isScale);
    recipe = MakeRecipeShapeIndexFactoidImages(recipe);
    recipe = MakeRecipeIlluminationImages(recipe, filterWidth, toneMapFactor, isScale);
    recipe = MakeRecipeLMSImages(recipe, lmsSensitivities);
    
    % run spatial statistics analysis
    rgb = LoadRecipeProcessingImageFile(recipe, 'radiance', 'SRGBWard');
    rgb = double(rgb);
    xyz = LoadRecipeProcessingImageFile(recipe, 'radiance', 'XYZWard');
    lum = double(xyz(:,:,2));
    lms = LoadRecipeProcessingImageFile(recipe, 'lms', 'radiance_ward_lms');
    [reductions{ii}, fig] = AnalyzeSpatialStats(rgb, lum, lms);
    
    % save figures for later
    set(fig, ...
        'PaperPositionMode', 'auto', ...
        'Position', [100 100 1000 1000], ...
        'Name', sprintf('%d: %s', ii, recipe.input.hints.recipeName));
    drawnow();
    figureFile = fullfile(figureFolder, [recipe.input.hints.recipeName '.fig']);
    WriteImage(figureFile, fig);
    pngFile = fullfile(figureFolder, [recipe.input.hints.recipeName '.png']);
    saveas(fig, pngFile);
    close(fig);
end

%% Show a grand summary across packed up recipes.
fig = SummarizeSpatialStats(reductions);
figName = sprintf('Summary of %d recipes', nRecipes);
set(fig, ...
    'PaperPositionMode', 'auto', ...
    'Position', [100 100 1000 1100], ...
    'Name', figName);
figureFile = fullfile(figureFolder, 'aaa-wardland-summary.fig');
WriteImage(figureFile, fig);
pngFile = fullfile(figureFolder, 'aaa-wardland-summary.png');
saveas(fig, pngFile);
