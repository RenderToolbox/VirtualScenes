%% Assemble processed images into a handy montage.
%   @param recipe a recipe from BuildWardLandRecipe()
%   @param scaleFactor a scalar for the montage size (could be large)
%   @param scaleMethod a filtering method like (box)
%
% @details
% Combines several of the WardLand rendered and processed images for the
% given @a recipe into a large summary montage.  Panels in the montage will
% be labeled.
%
% @details
% @a scaleFactor and @a scaleMethod can be used to scale entire montage,
% for example if it would be very large.  The default scale factor and
% filtering method are from getpref('VirtualScenes', 'montageScaleFactor')
% and getpref('VirtualScenes', 'montageScaleMethod').
%
% @details
% Returns the given @a recipe, updated with a new montage images folder.
%
% @details
% Usage:
%   recipe = MakeRecipeImageMontage(recipe, scaleFactor, scaleMethod)
%
% @ingroup WardLand
function recipe = MakeRecipeImageMontage(recipe, scaleFactor, scaleMethod)

if nargin < 2 || isempty(scaleFactor)
    scaleFactor = getpref('VirtualScenes', 'montageScaleFactor');
end

if nargin < 3 || isempty(scaleMethod)
    scaleMethod = getpref('VirtualScenes', 'montageScaleMethod');
end

%% Choose images to assemble.
srgbWard = GetWorkingAbsolutePath(GetRecipeProcessingData( ...
    recipe, 'radiance', 'SRGBWard'), recipe.input.hints);
srgbMatte = GetWorkingAbsolutePath(GetRecipeProcessingData( ...
    recipe, 'radiance', 'SRGBMatte'), recipe.input.hints);
srgbSpecular = GetWorkingAbsolutePath(GetRecipeProcessingData( ...
    recipe, 'radiance', 'SRGBSpecular'), recipe.input.hints);
objects = GetWorkingAbsolutePath(GetRecipeProcessingData( ...
    recipe, 'mask', 'objects'), recipe.input.hints);
reflectance = GetWorkingAbsolutePath(GetRecipeProcessingData( ...
    recipe, 'reflectance', 'SRGBReflectance'), recipe.input.hints);
dklL = GetWorkingAbsolutePath(GetRecipeProcessingData( ...
    recipe, 'dkl', 'reflectance_reflectance_l'), recipe.input.hints);
boring = GetWorkingAbsolutePath(GetRecipeProcessingData( ...
    recipe, 'radiance', 'SRGBBoring'), recipe.input.hints);
illum = GetWorkingAbsolutePath(GetRecipeProcessingData( ...
    recipe, 'illumination', 'SRGBIllumInterp'), recipe.input.hints);
illumMean = GetWorkingAbsolutePath(GetRecipeProcessingData( ...
    recipe, 'illumination', 'SRGBIllumMeanInterp'), recipe.input.hints);

images = { ...
    srgbWard, srgbMatte, srgbSpecular; ...
    objects, reflectance, dklL; ...
    boring, illum, illumMean; ...
    };


%% Choose a name for each panel.
names = { ...
    'main radiance', 'diffuse radiance', 'specular radiance'; ...
    'objects', 'reflectance', 'reflectance dkl L'; ...
    'boring radiance', 'illumination', 'mean illumination', ...
    };

%% Write out a big montage.
imageFolder = GetWorkingFolder('images', true, recipe.input.hints);
recipe.processing.montage = MakeImageMontage( ...
    fullfile(imageFolder, 'montage.png'), images, names, scaleFactor, scaleMethod);
