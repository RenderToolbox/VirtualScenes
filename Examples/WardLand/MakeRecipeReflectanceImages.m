%% Compute the "refelctance" images for a WardLand recipe.
%   @param recipe a recipe struct from BuildWardLandRecipe()
%   @param filterWidth width of sliding average to fill gaps in object mask
%   @param toneMapFactor passed to MakeMontage()
%   @param isScale passed to MakeMontage()
%
% @details
% Uses results from MakeRecipeRGBImages() and MakeRecipeObjectMasks() to
% compute "reflectance" images for the given WardLand @a recipe.
%
% @details
% Returns the given @a recipe, updated with reflectance image data saved
% in the "reflectance" group.
%
% @details
% Usage:
%   recipe = MakeRecipeReflectanceImages(recipe, filterWidth, toneMapFactor, isScale)
%
% @ingroup WardLand
function recipe = MakeRecipeReflectanceImages(recipe, filterWidth, toneMapFactor, isScale)

if nargin < 2 || isempty(filterWidth)
    filterWidth = 5;
end

if nargin < 3 || isempty(toneMapFactor)
    toneMapFactor = 100;
end

if nargin < 4 || isempty(isScale)
    isScale = true;
end

%% Get rendering spectral sampling.

% should have been filled in by MakeRecipeRGBImages()
S = GetRecipeProcessingData(recipe, 'radiance', 'S');
wls = MakeItWls(S);
nWls = numel(wls);
spacing = S(2);

%% Convert materials in scene to multi-spectral pixels ("spexels").
nMaterials = numel(recipe.processing.allSceneMatteMaterials);
diffuseSpexels = zeros(nMaterials, nWls);
specularSpexels = zeros(nMaterials, nWls);
for ii = 1:nMaterials
    diffuseMaterial = recipe.processing.allSceneMatteMaterials{ii};
    diffuseSpexels(ii, :) = extractMaterialSpexel( ...
        diffuseMaterial, 'diffuseReflectance', spacing, wls);
    
    wardMaterial = recipe.processing.allSceneWardMaterials{ii};
    specularSpexels(ii, :) = extractMaterialSpexel( ...
        wardMaterial, 'specularReflectance', spacing, wls);
end

%% Look up the spexel for each pixel in the material index mask.

% should have been filled in by MakeRecipeObjectMasks()
materialIndexMask = LoadRecipeProcessingImageFile(recipe, 'mask', 'materialIndexes');
maskSize = size(materialIndexMask);

imageSize = maskSize;
imageSize(3) = nWls;

fatMask = repmat(materialIndexMask, [1, 1, nWls]);
diffuseRaw = zeros(imageSize);
specularRaw = zeros(imageSize);
for ii = 1:nMaterials
    isMaterial = fatMask == ii;
    nIsMaterial = sum(isMaterial(:));
    if nIsMaterial > 0
        nSpexels = nIsMaterial/nWls;
        diffuseRaw(isMaterial(:)) = repmat(diffuseSpexels(ii,:), nSpexels, 1);
        specularRaw(isMaterial(:)) = repmat(specularSpexels(ii,:), nSpexels, 1);
    end
end

%% Fill in gaps in reflectance images by sliding local average.
diffuseInterp = SmoothOutGaps(diffuseRaw, materialIndexMask, filterWidth);
specularInterp = SmoothOutGaps(specularRaw, materialIndexMask, filterWidth);

%% Make sRGB representations.
diffuseRawSRGB = uint8(rtbMultispectralToSRGB(diffuseRaw, S, 'toneMapFactor', toneMapFactor, 'isScale', isScale));
diffuseInterpSRGB = uint8(rtbMultispectralToSRGB(diffuseInterp, S, 'toneMapFactor', toneMapFactor, 'isScale', isScale));
specularRawSRGB = uint8(rtbMultispectralToSRGB(specularRaw, S, 'toneMapFactor', toneMapFactor, 'isScale', isScale));
specularInterpSRGB = uint8(rtbMultispectralToSRGB(specularInterp, S, 'toneMapFactor', toneMapFactor, 'isScale', isScale));

%% Save images.
group = 'reflectance';
format = 'mat';
recipe = SaveRecipeProcessingImageFile(recipe, group, 'diffuseRaw', format, diffuseRaw);
recipe = SaveRecipeProcessingImageFile(recipe, group, 'diffuseInterp', format, diffuseInterp);
recipe = SaveRecipeProcessingImageFile(recipe, group, 'specularRaw', format, specularRaw);
recipe = SaveRecipeProcessingImageFile(recipe, group, 'specularInterp', format, specularInterp);

recipe = SaveRecipeProcessingImageFile(recipe, group, 'reflectance', format, diffuseInterp);

format = 'png';
recipe = SaveRecipeProcessingImageFile(recipe, group, 'SRGBDiffuseRaw', format, diffuseRawSRGB);
recipe = SaveRecipeProcessingImageFile(recipe, group, 'SRGBDiffuseInterp', format, diffuseInterpSRGB);
recipe = SaveRecipeProcessingImageFile(recipe, group, 'SRGBSpecularRaw', format, specularRawSRGB);
recipe = SaveRecipeProcessingImageFile(recipe, group, 'SRGBSpecularInterp', format, specularInterpSRGB);

recipe = SaveRecipeProcessingImageFile(recipe, group, 'SRGBReflectance', format, diffuseInterpSRGB);

%% Dig out the spectrum from a WardLand material description.
function spexel = extractMaterialSpexel(material, propertyName, spacing, spexelWls)
propertyNames = {material.properties.propertyName};
isProperty = strcmp(propertyNames, propertyName);
property = material.properties(isProperty);
[wls, mags] = SparseSpectrumToRegular(property.propertyValue, spacing);
spexel = SplineRaw(wls', mags', spexelWls);
