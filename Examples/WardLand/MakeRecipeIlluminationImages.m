%% Compute the "illumination" images for a WardLand recipe.
%   @param recipe a recipe struct from BuildWardLandRecipe()
%   @param filterWidth width of sliding average to fill gaps in object mask
%   @param toneMapFactor passed to MakeMontage()
%   @param isScale passed to MakeMontage()
%
% @details
% Uses results from MakeRecipeRGBImages(), MakeRecipeReflectanceImages(),
% and MakeRecipeAlbedoFactoidImages() to compute "illumination" images for
% the given WardLand @a recipe.
%
% @details
% Returns the given @a recipe, updated with reflectance image data saved
% in the "illumination" group.
%
% @details
% Usage:
%   recipe = MakeRecipeIlluminationImages(recipe, filterWidth, toneMapFactor, isScale)
%
% @ingroup WardLand
function recipe = MakeRecipeIlluminationImages(recipe, filterWidth, toneMapFactor, isScale)

if nargin < 2 || isempty(filterWidth)
    filterWidth = 5;
end

if nargin < 3 || isempty(toneMapFactor)
    toneMapFactor = 100;
end

if nargin < 4 || isempty(isScale)
    isScale = true;
end

%% Load scene renderings.
nRenderings = numel(recipe.rendering.radianceDataFiles);
for ii = 1:nRenderings
    dataFile = recipe.rendering.radianceDataFiles{ii};
    if ~isempty(strfind(dataFile, 'matte.mat'))
        matteDataFile = dataFile;
    end
end


%% Get radiance data.
matteRendering = load(matteDataFile);
matteRadiance = matteRendering.multispectralImage;
imageSize = size(matteRadiance);

S = GetRecipeProcessingData(recipe, 'radiance', 'S');
wls = MakeItWls(S);
nWls = numel(wls);

%% Get reflectance and object mask data.
reflectance = LoadRecipeProcessingImageFile(recipe, 'reflectance', 'reflectance');
objectIndexMask = LoadRecipeProcessingImageFile(recipe, 'mask', 'objectIndexes');


%% "Divide out" reflectances from radiance to leave illumination.
illumRaw = matteRadiance ./ reflectance;

% avoid infinities
illumRaw(reflectance == 0) = 0;

%% Take mean illumination within each object.
illumMeanRaw = zeros(imageSize);

fatMask = repmat(objectIndexMask, [1, 1, nWls]);
objectMask = zeros(size(objectIndexMask));

nMaterials = numel(recipe.processing.allSceneMatteMaterials);
for ii = 1:nMaterials
    objectMask(:) = 0;
    objectMask(objectIndexMask == ii) = 1;
    nIsObject = sum(objectMask(:));
    if nIsObject > 0
        isMaterial = fatMask == ii;
        diffuseMeanIllum = MeanUnderMask(illumRaw, objectMask);
        illumMeanRaw(isMaterial(:)) = repmat(diffuseMeanIllum, nIsObject, 1);
    end
end

%% Smooth out gaps between objects if necessary.
objectCoverage = LoadRecipeProcessingImageFile(recipe, 'mask', 'objectCoverage');
illumInterp = SmoothOutGaps(illumRaw, objectCoverage, filterWidth);
illumMeanInterp = SmoothOutGaps(illumMeanRaw, objectCoverage, filterWidth);


%% Make sRGB representations.
illumRawSRGB = uint8(rtbMultispectralToSRGB(illumRaw, S, 'toneMapFactor', toneMapFactor, 'isScale', isScale));
illumInterpSRGB = uint8(rtbMultispectralToSRGB(illumInterp, S, 'toneMapFactor', toneMapFactor, 'isScale', isScale));

illumMeanRawSRGB = uint8(rtbMultispectralToSRGB(illumMeanRaw, S, 'toneMapFactor', toneMapFactor, 'isScale', isScale));
illumMeanInterpSRGB = uint8(rtbMultispectralToSRGB(illumMeanInterp, S, 'toneMapFactor', toneMapFactor, 'isScale', isScale));


%% Save images.
group = 'illumination';
format = 'mat';
recipe = SaveRecipeProcessingImageFile(recipe, group, 'illumRaw', format, illumRaw);
recipe = SaveRecipeProcessingImageFile(recipe, group, 'illumInterp', format, illumInterp);
recipe = SaveRecipeProcessingImageFile(recipe, group, 'illumMeanRaw', format, illumMeanRaw);
recipe = SaveRecipeProcessingImageFile(recipe, group, 'illumMeanInterp', format, illumMeanInterp);

recipe = SaveRecipeProcessingImageFile(recipe, group, 'illumination', format, illumInterp);

format = 'png';
recipe = SaveRecipeProcessingImageFile(recipe, group, 'SRGBIllumRaw', format, illumRawSRGB);
recipe = SaveRecipeProcessingImageFile(recipe, group, 'SRGBIllumInterp', format, illumInterpSRGB);
recipe = SaveRecipeProcessingImageFile(recipe, group, 'SRGBIllumMeanRaw', format, illumMeanRawSRGB);
recipe = SaveRecipeProcessingImageFile(recipe, group, 'SRGBIllumMeanInterp', format, illumMeanInterpSRGB);

recipe = SaveRecipeProcessingImageFile(recipe, group, 'SRGBIllumination', format, illumInterpSRGB);

