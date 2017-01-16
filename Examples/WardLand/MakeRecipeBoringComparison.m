%% Compare virtual scene "boring" rendering vs illumination images.
%   @param recipe a recipe from BuildWardLandRecipe()
%	@param toneMapFactor passed to MakeMontage()
%   @param isScale passed to MakeMontage()
%
% @details
% For the given WardLand @a recipe, compares the "boring" rendering to the
% computed diffuse illumination image.  These images should be similar,
% except for the effects of interreflections.
%
% @details
% Returns the given @a recipe, updated with comparison image data saved
% in the "boring" group.
%
% @details
% Usage:
%   recipe = MakeRecipeBoringComparison(recipe, toneMapFactor, isScale)
%
% @ingroup WardLand
function recipe = MakeRecipeBoringComparison(recipe, toneMapFactor, isScale)

if nargin < 2 || isempty(toneMapFactor)
    toneMapFactor = 100;
end

if nargin < 3 || isempty(isScale)
    isScale = true;
end

%% Load scene renderings.
nRenderings = numel(recipe.rendering.radianceDataFiles);
for ii = 1:nRenderings
    dataFile = recipe.rendering.radianceDataFiles{ii};
    if ~isempty(strfind(dataFile, 'boring.mat'))
        boringDataFile = dataFile;
        break;
    end
end
boringRendering = load(boringDataFile);
boringRadiance = boringRendering.multispectralImage;
S = boringRendering.S;

%% Get the interpolated illumination image.
illumination = LoadRecipeProcessingImageFile(recipe, 'illumination', 'illumination');

%% Scale images and take the diff.
boringMean = mean(boringRadiance(:));
boringScaled = boringRadiance ./ boringMean;

illumMean = mean(illumination(~isnan(illumination(:))));
illumScaled = illumination ./ illumMean;

boringMinusIllum = boringScaled - illumScaled;
illumMinusBoring = illumScaled - boringScaled;

%% Make sRGB representations.
boringMinusIllumSRGB = uint8(rtbMultispectralToSRGB(boringMinusIllum, S, 'toneMapFactor', toneMapFactor, 'isScale', isScale));
illumMinusBoringSRGB = uint8(rtbMultispectralToSRGB(illumMinusBoring, S, 'toneMapFactor', toneMapFactor, 'isScale', isScale););

%% Write out analysis images to disk.
group = 'boring';
format = 'mat';
recipe = SaveRecipeProcessingImageFile(recipe, group, 'boringMinusIllum', format, boringMinusIllum);
recipe = SaveRecipeProcessingImageFile(recipe, group, 'illumMinusBoring', format, illumMinusBoring);

format = 'png';
recipe = SaveRecipeProcessingImageFile(recipe, group, 'SRGBBoringMinusIllum', format, boringMinusIllumSRGB);
recipe = SaveRecipeProcessingImageFile(recipe, group, 'SRGBIllumMinusBoring', format, illumMinusBoringSRGB);
