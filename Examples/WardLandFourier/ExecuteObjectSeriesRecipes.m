%% Locate Object Series Recipes, render, and do Fourier analysis.
%
% This script performs spatial frequency analysis on luminance images from
% Object Series recipes.
%
% You should run this script after you've already created recipes using
% MakeObjectSeriesRecipes().
%
% You can edit some parameters at the top of this script to change things
% like the imgae size to render.
%
% @ingroup WardLand

%% Rendering Setup.
clear;
clc;

% location of packed-up recipes
projectName = 'ObjectSeries';
recipeFolder = ...
    fullfile(getpref('VirtualScenes', 'recipesFolder'), projectName);
if ~exist(recipeFolder, 'dir')
    disp(['Recipe folder not found: ' recipeFolder]);
end

% edit some batch renderer options
hints.renderer = 'Mitsuba';
hints.workingFolder = getpref('VirtualScenes', 'workingFolder');
hints.imageWidth = 640/4;
hints.imageHeight = 480/4;

%% Locate and render each packed-up recipe.
archiveFiles = FindFiles(recipeFolder, '\.zip$');
nRecipes = numel(archiveFiles);
recipes = cell(1, nRecipes);
for ii = 1:nRecipes
    recipes{ii} = UnpackRecipe(archiveFiles{ii}, hints);
    recipes{ii}.input.hints.renderer = hints.renderer;
    recipes{ii}.input.hints.workingFolder = hints.workingFolder;
    recipes{ii}.input.hints.imageWidth = hints.imageWidth;
    recipes{ii}.input.hints.imageHeight = hints.imageHeight;
    recipes{ii} = ExecuteRecipe(recipes{ii});
end


%% Analysis Setup.

% for sRGB conversion
toneMapFactor = 100;
isScale = true;

% for frequency distribution analysis by rings
nBands = 25;

%% Make "Fourier Structs" that can be analyzed unifoirmly.
fourierCell = cell(1, nRecipes);
lineProps = cell(1, nRecipes);
for ii = 1:nRecipes
    hints = recipes{ii}.input.hints;    
    fourierCell{ii} = WardLandRenderingFourierStruct( ...
        hints, 'ward', hints.recipeName, toneMapFactor, isScale);
    lineProps{ii} = recipes{ii}.processing.lineProps;
end

fourierStructs = [fourierCell{:}];

%% Do spatial frequency analysis on all the structs.
fourierStructs = AnalyzeFourierStruct(fourierStructs, nBands);

%% Plot results for all the structs.
[fourierStructs, plotFig] = PlotFourierStruct(fourierStructs, [], [], lineProps);
[fourierStructs, summaryFig] = SummarizeFourierStruct(fourierStructs, [], [], lineProps);
