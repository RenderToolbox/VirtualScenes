%% Compute the "albedo" factoid images for a WardLand recipe.
%   @param recipe a recipe struct from BuildWardLandRecipe()
%   @param toneMapFactor passed to MakeMontage()
%   @param isScale passed to MakeMontage()
%
% @details
% Uses Mitsuba and results from MakeRecipeSceneFiles() to compute the
% "albedo" factoid for the "matte" condition in the given WardLand @a
% recipe.
%
% @details
% Returns the given @a recipe, updated with albedo image data saved
% in the "albedo" and "reflectance" groups.
%
% @details
% Usage:
%   recipe = MakeRecipeAlbedoFactoidImages(recipe, toneMapFactor, isScale)
%
% @ingroup WardLand
function recipe = MakeRecipeAlbedoFactoidImages(recipe, toneMapFactor, isScale)

if nargin < 2 || isempty(toneMapFactor)
    toneMapFactor = 100;
end

if nargin < 3 || isempty(isScale)
    isScale = true;
end

%% Get the "matte" scene file.
nScenes = numel(recipe.rendering.scenes);
for ii = 1:nScenes
    scene = recipe.rendering.scenes{ii};
    if strcmp('matte', scene.imageName)
        relativeSceneFile = scene.mitsubaFile;
        break;
    end
end

sceneFile = GetWorkingAbsolutePath(relativeSceneFile, recipe.input.hints);

%% Invoke Mitsuba for the "albedo" factoid.
mitsuba = getpref('Mitsuba');
factoids = {'albedo'};

[status, result, newScene, exrOutput, factoidOutput] = ...
    RenderMitsubaFactoids(sceneFile, [], [], [], ...
    factoids, 'spectrum', recipe.input.hints, mitsuba);

[wls, S, order] = GetWlsFromSliceNames(factoidOutput.albedo.channels);
albedo = factoidOutput.albedo.data(:,:,order);


%% Make sRGB representations.
albedoSRGB = uint8(MultispectralToSRGB(albedo, S, toneMapFactor, isScale));

%% Save images.
group = 'albedo';
format = 'mat';
recipe = SaveRecipeProcessingImageFile(recipe, group, 'albedo', format, albedo);
recipe = SaveRecipeProcessingImageFile(recipe, 'reflectance', 'reflectance', format, albedo);

format = 'png';
recipe = SaveRecipeProcessingImageFile(recipe, group, 'SRGBAlbedo', format, albedoSRGB);
recipe = SaveRecipeProcessingImageFile(recipe, 'reflectance', 'SRGBReflectance', format, albedoSRGB);

