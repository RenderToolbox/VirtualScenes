%% Convert recipe multi-spectral renderings to sRGB representations.
%   @param recipe a recipe from BuildWardLandRecipe()
%   @param toneMapFactor passed to MakeMontage()
%   @param isScale passed to MakeMontage()
%
% @details
% Processes several WardLand multi-spectral renderings and makes sRGB
% representations of them.  @a toneMapFactor and @a isScale affect scaling
% of the sRGB images.  See MultispectralToSRGB() and XYZToSRGB().
%
% @details
% Saves sRGB images in the "radiance" processing group.  See
% SaveRecipeProcessingImageFile().
%
% @details
% Usage:
%   recipe = MakeRecipeRGBImages(recipe, toneMapFactor, isScale)
%
% @ingroup WardLand
function recipe = MakeRecipeRGBImages(recipe, toneMapFactor, isScale)

if nargin < 2 || isempty(toneMapFactor)
    toneMapFactor = 100;
end

if nargin < 3 || isempty(isScale)
    isScale = true;
end

%% Load scene renderings.
nRenderings = numel(recipe.rendering.radianceDataFiles);
maskDataFiles = {};
for ii = 1:nRenderings
    dataFile = recipe.rendering.radianceDataFiles{ii};
    if ~isempty(strfind(dataFile, 'matte.mat'))
        matteDataFile = dataFile;
    elseif ~isempty(strfind(dataFile, 'ward.mat'))
        wardDataFile = dataFile;
    elseif ~isempty(strfind(dataFile, 'boring.mat'))
        boringDataFile = dataFile;
    elseif ~isempty(regexp(dataFile, 'mask-\d+\.mat$', 'once'));
        maskDataFiles{end+1} = dataFile;
    end
end

%% Get multi-spectral and sRGB radiance images.
wardRendering = load(wardDataFile);
wardRadiance = wardRendering.multispectralImage;

matteRendering = load(matteDataFile);
matteRadiance = matteRendering.multispectralImage;

boringRendering = load(boringDataFile);
boringRadiance = boringRendering.multispectralImage;

specularRadiance = wardRadiance - matteRadiance;

S = wardRendering.S;
[wardSRGB, wardXYZ] = toRgbAndXyz(wardRadiance, S, toneMapFactor, isScale);
[matteSRGB, matteXYZ] = toRgbAndXyz(matteRadiance, S, toneMapFactor, isScale);
[boringSRGB, boringXYZ] = toRgbAndXyz(boringRadiance, S, toneMapFactor, isScale);
[specularSRGB, specularXYZ] = toRgbAndXyz(specularRadiance, S, toneMapFactor, isScale);

nMaskRenderings = numel(maskDataFiles);
maskSRGB = cell(1, nMaskRenderings);
maskXYZ = cell(1, nMaskRenderings);
for ii = 1:nMaskRenderings
    maskRendering = load(maskDataFiles{ii});
    maskRadiance = maskRendering.multispectralImage;
    [maskSRGB{ii}, maskXYZ{ii}] = toRgbAndXyz(maskRadiance, S, toneMapFactor, isScale);
end

%% Save images to disk.
group = 'radiance';
format = 'png';
recipe = SaveRecipeProcessingImageFile(recipe, group, 'SRGBWard', format, wardSRGB);
recipe = SaveRecipeProcessingImageFile(recipe, group, 'SRGBMatte', format, matteSRGB);
recipe = SaveRecipeProcessingImageFile(recipe, group, 'SRGBBoring', format, boringSRGB);
recipe = SaveRecipeProcessingImageFile(recipe, group, 'SRGBSpecular', format, specularSRGB);

format = 'mat';
recipe = SaveRecipeProcessingImageFile(recipe, group, 'XYZWard', format, wardXYZ);
recipe = SaveRecipeProcessingImageFile(recipe, group, 'XYZMatte', format, matteXYZ);
recipe = SaveRecipeProcessingImageFile(recipe, group, 'XYZBoring', format, boringXYZ);
recipe = SaveRecipeProcessingImageFile(recipe, group, 'XYZSpecular', format, specularXYZ);

for ii = 1:nMaskRenderings
    maskName = sprintf('SRGBMask%d', ii);
    recipe = SaveRecipeProcessingImageFile(recipe, group, maskName, 'png', maskSRGB{ii});
    maskName = sprintf('XYZMask%d', ii);
    recipe = SaveRecipeProcessingImageFile(recipe, group, maskName, 'mat', maskXYZ{ii});
end

recipe = SetRecipeProcessingData(recipe, group, 'S', S);
recipe = SaveRecipeProcessingImageFile(recipe, group, 'ward', 'mat', wardRadiance);
recipe = SaveRecipeProcessingImageFile(recipe, group, 'matte', 'mat', matteRadiance);
recipe = SaveRecipeProcessingImageFile(recipe, group, 'specular', 'mat', specularRadiance);


%% Get uint8 versions of sRGB and XYZ images.
function [srgbUint, xyz] = toRgbAndXyz(radiance, S, toneMapFactor, isScale)
[srgb, xyz] = MultispectralToSRGB(radiance, S, toneMapFactor, isScale);
srgbUint = uint8(srgb);
