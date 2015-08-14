%% Analyze Virtual Scene renderings for shape index factoids.
%   @param recipe a recipe struct from BuildWardLandRecipe()
%
% @details
% Uses the first generated scene file for the given WardLand @a recipe to
% compute an object pixel mask, based on Mitsuba's "shapeIndex" factoid.
%
% @details
% Returns the given @a recipe, updated with object pixel masks data saved
% in the "mask" group.
%
% @details
% Usage:
%   recipe = MakeRecipeShapeIndexFactoidImages(recipe)
%
% @ingroup WardLand
function recipe = MakeRecipeShapeIndexFactoidImages(recipe)

%% Get the first scene file.
relativeSceneFile = recipe.rendering.scenes{1}.mitsubaFile;
sceneFile = GetWorkingAbsolutePath(relativeSceneFile, recipe.input.hints);

%% Invoke Mitsuba for the "shapeIndex" factoid.
mitsuba = getpref('Mitsuba');
mitsuba.app = getpref('VirtualScenes', 'rgbMitsubaApp');

factoids = {'shapeIndex'};
format = 'rgb';

% invoke once with "single sampling" to get an answer in every pixel
singleSampling = true;
[status, result, newScene, exrOutput, factoidOutput] = ...
    RenderMitsubaFactoids(sceneFile, [], [], [], ...
    factoids, format, recipe.input.hints, mitsuba, singleSampling);
shapeIndexes = factoidOutput.shapeIndex.data(:,:,1);

% invoke again without "single sampling" to detect object borders
singleSampling = false;
[status, result, newScene, exrOutput, factoidOutput] = ...
    RenderMitsubaFactoids(sceneFile, [], [], [], ...
    factoids, format, recipe.input.hints, mitsuba, singleSampling);
shapeIndexesBlurred = factoidOutput.shapeIndex.data(:,:,1);

%% Determine object masks and coverage.
isGood = mod(shapeIndexes, 1) == 0;
shapeIndexMask = 1 + shapeIndexes;
shapeIndexMask(~isGood) = 0;

isGood = mod(shapeIndexesBlurred, 1) == 0;
shapeCoverage = zeros(size(shapeIndexes), 'uint8');
shapeCoverage(isGood) = 255;

%% Give each shape a color.
colorMap = [0 0 0; 255*lines(max(shapeIndexMask(:)))];
objects = zeros(recipe.input.hints.imageHeight, recipe.input.hints.imageWidth, 3, 'uint8');
objects(:) = colorMap(1 + shapeIndexMask, :);

%% Save mask images.
group = 'mask';
recipe = SaveRecipeProcessingImageFile(recipe, group, 'shapeIndexes', 'mat', shapeIndexMask);
recipe = SaveRecipeProcessingImageFile(recipe, group, 'shapeCoverage', 'png', shapeCoverage);
recipe = SaveRecipeProcessingImageFile(recipe, group, 'shapeObjects', 'png', objects);

recipe = SaveRecipeProcessingImageFile(recipe, group, 'objectIndexes', 'mat', shapeIndexMask);
recipe = SaveRecipeProcessingImageFile(recipe, group, 'objectCoverage', 'png', shapeCoverage);
recipe = SaveRecipeProcessingImageFile(recipe, group, 'objects', 'png', objects);