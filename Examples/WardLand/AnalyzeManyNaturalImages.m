%% Look at arbitrary but interesting spatial stats for UPenn natural images.
%
% You can configure a few parameters at the top of this script.
%
% @ingroup WardLand

%% Overall Setup.
clear;
clc;

%% Get some images.
naturalImages = '/Users/ben/Documents/Projects/UPennNaturalImages/tofu.psych.upenn.edu/zip_nxlhtvdlbb/';

% use aux info files to identify sets of related images
matchPattern = '_AUX\.mat$';
allImageFiles = FindFiles(naturalImages, matchPattern);
nImages = numel(allImageFiles);

% pick some repeatably-randomly
randomSeed = 42;
nPicks = 119;
rng(randomSeed);
pickInds = randi(nImages, [1, nPicks]);

names = cell(1, nPicks);
rgbFiles = cell(1, nPicks);
lumFiles = cell(1, nPicks);
lmsFiles = cell(1, nPicks);
for ii = 1:nPicks
    jj = pickInds(ii);
    imageFile = allImageFiles{jj};
    
    info = load(imageFile);
    
    names{ii} = [info.Image.cd '_' info.Image.name];
    
    [imagePath, imageBase, imageExt] = fileparts(imageFile);
    rgbFiles{ii} = fullfile(imagePath, [info.Image.name '_RGB.mat']);
    lumFiles{ii} = fullfile(imagePath, [info.Image.name '_LUM.mat']);
    lmsFiles{ii} = fullfile(imagePath, [info.Image.name '_LMS.mat']);
end


%% Set analysis params.
cropHeight = 480;
cropWidth = 640;

% easier to read plots
set(0, 'DefaultAxesFontSize', 14)

figureFolder = fullfile( ...
    getpref('VirtualScenes', 'recipesFolder'), ...
    'NaturalImages', ...
    'Figures');

%% Analyze each packed up recipe.

reductions = cell(1, nPicks);
for ii = 1:nPicks
    % load image data
    rgbData = load(rgbFiles{ii});
    rgbFull = rgbData.RGB_Image();
    
    lumData = load(lumFiles{ii});
    lumFull = lumData.LUM_Image;
    
    lmsData = load(lmsFiles{ii});
    lmsFull = lmsData.LMS_Image;
    
    % crop images in center
    cropOffsetY = round((size(rgbFull, 1) - cropHeight) / 2);
    cropOffsetX = round((size(rgbFull, 2) - cropWidth) / 2);
    cropYInds = cropOffsetY+(1:cropHeight);
    cropXInds = cropOffsetX+(1:cropWidth);
    rgb = rgbFull(cropYInds, cropXInds, :);
    lum = lumFull(cropYInds, cropXInds);
    lms = lmsFull(cropYInds, cropXInds, :);
    
    % run spatial statistics analysis
    [reductions{ii}, fig] = AnalyzeSpatialStats(rgb, lum, lms);
    
    % save figures for later
    set(fig, ...
        'PaperPositionMode', 'auto', ...
        'Position', [100 100 1000 1000], ...
        'Name', names{ii});
    drawnow();
    figureFile = fullfile(figureFolder, [names{ii} '.fig']);
    WriteImage(figureFile, fig);
    pngFile = fullfile(figureFolder, [names{ii} '.png']);
    saveas(fig, pngFile);
    close(fig);
end

%% Show a grand summary across packed up recipes.
fig = SummarizeSpatialStats(reductions);
figName = sprintf('Summary of %d natural images (seed=%d)', nPicks, randomSeed);
set(fig, ...
    'PaperPositionMode', 'auto', ...
    'Position', [100 100 1000 1100], ...
    'Name', figName);
figureFile = fullfile(figureFolder, 'aaa-natural-summary.fig');
WriteImage(figureFile, fig);
pngFile = fullfile(figureFolder, 'aaa-natural-summary.png');
saveas(fig, pngFile);
