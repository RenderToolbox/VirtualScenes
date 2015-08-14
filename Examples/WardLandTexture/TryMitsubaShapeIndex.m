%% Try to get an object pixel mask using Mitsuba factoids.
%
% @ingroup WardLand

%% Overall Setup.
clear;
clc;

% location of packed-up recipes
projectName = 'WardLandTexture';
recipeFolder = ...
    fullfile(getpref('VirtualScenes', 'recipesFolder'), projectName);
if ~exist(recipeFolder, 'dir')
    disp(['Recipe folder not found: ' recipeFolder]);
    return;
end

% edit some batch renderer options
hints.renderer = 'Mitsuba';
hints.workingFolder = getpref('VirtualScenes', 'workingFolder');
hints.imageWidth = 640 / 2;
hints.imageHeight = 480 / 2;


%% Locate the packed-up recipe.
archiveFiles = FindFiles(recipeFolder, '\.zip$');
nScenes = numel(archiveFiles);
if nScenes < 1
    disp('Recipe  not found!');
    return;
end

recipe = UnpackRecipe(archiveFiles{1}, hints);

recipe.input.hints.renderer = hints.renderer;
recipe.input.hints.workingFolder = hints.workingFolder;
recipe.input.hints.imageWidth = hints.imageWidth;
recipe.input.hints.imageHeight = hints.imageHeight;

%% Factoid Path.
toneMapFactor = 100;
isScale = true;
filterWidth = 7;

recipe.input.hints.whichConditions = 1:3;

disp('Start Factoid Path');
tic();

recipe = MakeRecipeSceneFiles(recipe);
recipe = MakeRecipeRenderings(recipe);
recipe = MakeRecipeRGBImages(recipe, toneMapFactor, isScale);

recipe = MakeRecipeAlbedoFactoidImages(recipe, toneMapFactor, isScale);
recipe = MakeRecipeShapeIndexFactoidImages(recipe);

recipe = MakeRecipeIlluminationImages(recipe, filterWidth, toneMapFactor, isScale);
recipe = MakeRecipeBoringComparison(recipe, toneMapFactor, isScale);

factoidTime = toc();
disp('Finish Factoid Path');

%% Set images off to the side.
group = 'factoidPath';
recipe = SaveRecipeProcessingImageFile(recipe, group, 'SRGBWard', 'png', ...
    GetRecipeProcessingData(recipe, 'radiance', 'SRGBWard'));
recipe = SaveRecipeProcessingImageFile(recipe, group, 'SRGBReflectance', 'png', ...
    GetRecipeProcessingData(recipe, 'reflectance', 'SRGBReflectance'));
recipe = SaveRecipeProcessingImageFile(recipe, group, 'SRGBIllumination', 'png', ...
    GetRecipeProcessingData(recipe, 'illumination', 'SRGBIllumination'));
recipe = SaveRecipeProcessingImageFile(recipe, group, 'SRGBBoring', 'png', ...
    GetRecipeProcessingData(recipe, 'radiance', 'SRGBBoring'));
recipe = SaveRecipeProcessingImageFile(recipe, group, 'SRGBIllumMinusBoring', 'png', ...
    GetRecipeProcessingData(recipe, 'boring', 'SRGBIllumMinusBoring'));
recipe = SaveRecipeProcessingImageFile(recipe, group, 'objectIndexes', 'mat', ...
    GetRecipeProcessingData(recipe, 'mask', 'objectIndexes'));

%% Material Path.
toneMapFactor = 5;
isScale = true;
pixelThreshold = 0.01;
filterWidth = 7;

recipe.input.hints.whichConditions = [];

disp('Start Material Path');
tic();

recipe = MakeRecipeSceneFiles(recipe);
recipe = MakeRecipeRenderings(recipe);
recipe = MakeRecipeRGBImages(recipe, toneMapFactor, isScale);

recipe = MakeRecipeObjectMasks(recipe, pixelThreshold);
recipe = MakeRecipeReflectanceImages(recipe, filterWidth, toneMapFactor, isScale);

recipe = MakeRecipeIlluminationImages(recipe, filterWidth, toneMapFactor, isScale);
recipe = MakeRecipeBoringComparison(recipe, toneMapFactor, isScale);

materialTime = toc();
disp('Finish Material Path');

%% Set images off to the side.
group = 'materialPath';
recipe = SaveRecipeProcessingImageFile(recipe, group, 'SRGBWard', 'png', ...
    GetRecipeProcessingData(recipe, 'radiance', 'SRGBWard'));
recipe = SaveRecipeProcessingImageFile(recipe, group, 'SRGBReflectance', 'png', ...
    GetRecipeProcessingData(recipe, 'reflectance', 'SRGBReflectance'));
recipe = SaveRecipeProcessingImageFile(recipe, group, 'SRGBIllumination', 'png', ...
    GetRecipeProcessingData(recipe, 'illumination', 'SRGBIllumination'));
recipe = SaveRecipeProcessingImageFile(recipe, group, 'SRGBBoring', 'png', ...
    GetRecipeProcessingData(recipe, 'radiance', 'SRGBBoring'));
recipe = SaveRecipeProcessingImageFile(recipe, group, 'SRGBIllumMinusBoring', 'png', ...
    GetRecipeProcessingData(recipe, 'boring', 'SRGBIllumMinusBoring'));
recipe = SaveRecipeProcessingImageFile(recipe, group, 'objectIndexes', 'mat', ...
    GetRecipeProcessingData(recipe, 'mask', 'objectIndexes'));

%% Build a montage to compare paths.
imageFolder = GetWorkingFolder('images', false, recipe.input.hints);
montageName = fullfile(imageFolder, 'factoid-vs-material.png');

colorMap = [0,0,0; 255*lines()];
factoidIndexes = 1 + LoadRecipeProcessingImageFile(recipe, 'factoidPath', 'objectIndexes');
materialIndexes = 1 + LoadRecipeProcessingImageFile(recipe, 'materialPath', 'objectIndexes');

factoidObjects = zeros(hints.imageHeight, hints.imageWidth, 3);
factoidObjects(:) = colorMap(factoidIndexes, :);

materialObjects = zeros(hints.imageHeight, hints.imageWidth, 3);
materialObjects(:) = colorMap(materialIndexes, :);

images = { ...
    LoadRecipeProcessingImageFile(recipe, 'factoidPath', 'SRGBWard'), LoadRecipeProcessingImageFile(recipe, 'materialPath', 'SRGBWard'); ...
    factoidObjects, materialObjects; ...
    LoadRecipeProcessingImageFile(recipe, 'factoidPath', 'SRGBReflectance'), LoadRecipeProcessingImageFile(recipe, 'materialPath', 'SRGBReflectance'); ...
    LoadRecipeProcessingImageFile(recipe, 'factoidPath', 'SRGBIllumination'), LoadRecipeProcessingImageFile(recipe, 'materialPath', 'SRGBIllumination'); ...
    LoadRecipeProcessingImageFile(recipe, 'factoidPath', 'SRGBBoring'), LoadRecipeProcessingImageFile(recipe, 'materialPath', 'SRGBBoring'); ...
    LoadRecipeProcessingImageFile(recipe, 'factoidPath', 'SRGBIllumMinusBoring'), LoadRecipeProcessingImageFile(recipe, 'materialPath', 'SRGBIllumMinusBoring'); ...
    };

names = { ...
    sprintf('factoid path (%ds)', round(factoidTime)), sprintf('material path (%ds)', round(materialTime)); ...
    'shape index factoid', 'our material indexes'; ...
    'albedo factoid', 'our reflectance'; ...
    'illum', 'illum'; ...
    'boring', 'boring'; ...
    'illum - boring', 'illum - boring'; ...
    };

MakeImageMontage(montageName, images, names);
