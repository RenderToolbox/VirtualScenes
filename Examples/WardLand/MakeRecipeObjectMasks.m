%% Analyze Virtual Scene renderings for inserted object pixel masks.
%   @param recipe a recipe struct from BuildWardLandRecipe()
%   @param pixelThreshold optional mask "conservativeness", default 0.1
%
% @details
% Uses the "mask" renderings for the given WardLand @a recipe to compute an
% object pixel mask, indicating which object is located behind each image
% pixel.  These masks shoudld apply to all WardLand recipe renderings,
% including "ward", "matte", "mask", and "boring" renderings.
%
% @details
% Returns the given @a recipe, updated with object pixel masks data saved
% in the "mask" group.
%
% @details
% Usage:
%   recipe = MakeRecipeObjectMasks(recipe, pixelThreshold)
%
% @ingroup WardLand
function recipe = MakeRecipeObjectMasks(recipe, pixelThreshold)

if nargin < 2 || isempty(pixelThreshold)
    pixelThreshold = 0.1;
end

%% Find the mask renderings.
nRenderings = numel(recipe.rendering.radianceDataFiles);
isMask = false(1, nRenderings);
for ii = 1:nRenderings
    dataFile = recipe.rendering.radianceDataFiles{ii};
    isMask(ii) = ~isempty(regexp(dataFile, 'mask-\d+\.mat$', 'once'));
end
maskDataFiles = recipe.rendering.radianceDataFiles(isMask);

%% Using the first rendering as template for the object mask.
rendering = load(maskDataFiles{1});
imageSize = size(rendering.multispectralImage);
materialIndexMask = zeros(imageSize(1), imageSize(2), 'uint8');

%% Stack up all mask renderings like a very deep multi-spectral image.
grandMultispectralImage = zeros(imageSize(1), imageSize(2), 0);
nPages = numel(maskDataFiles);
for pp = 1:nPages    
    rendering = load(dataFile);
    grandMultispectralImage = cat(3, grandMultispectralImage, rendering.multispectralImage);
end

%% Identify objects by the spectrum in each pixel.
for ii = 1:imageSize(1)
    for jj = 1:imageSize(2)
        pixelSpectrum = squeeze(grandMultispectralImage(ii,jj,:));
        isHigh = pixelSpectrum > max(pixelSpectrum)*pixelThreshold;
        if sum(isHigh) == 1
            whichBand = find(isHigh, 1, 'first');
            materialIndexMask(ii,jj) = whichBand;
        end
    end
end

%% Summarize the "gaps" where we couldn't tell which object is there.
materialCoverage = zeros(imageSize(1), imageSize(2), 'uint8');
materialCoverage(materialIndexMask > 0) = 255;

%% Save mask images.
group = 'mask';
recipe = SaveRecipeProcessingImageFile(recipe, group, 'materialIndexes', 'mat', materialIndexMask);
recipe = SaveRecipeProcessingImageFile(recipe, group, 'materialCoverage', 'png', materialCoverage);

recipe = SaveRecipeProcessingImageFile(recipe, group, 'objectIndexes', 'mat', materialIndexMask);
recipe = SaveRecipeProcessingImageFile(recipe, group, 'objectCoverage', 'png', materialCoverage);
