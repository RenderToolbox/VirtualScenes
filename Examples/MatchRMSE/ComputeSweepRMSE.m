%% Plot image RMSE vs the "lambdas" of a parameter sweep.
%   @a param recipe a recipe from BuildSweepConditions()
%   @a param imageNames cell array of imageNames from BuildSpectrumSweep()
%   @a param pixelMask optional 2D mask, true where RMSE should be taken
%
% @details
% Computes the RMSE of each multispectral image in a parameter sweep,
% relative to the first image in the sweep.  The sweep must have been
% already rendered using the given @a recipe.  @a imageNames must be a cell
% array of image names to be used for locating rendering data within the
% working folder of @a recipe.
%
% @details
% By default, computes RMSE over all image pixels.  If @a pixelMask is
% provided, it must be a 2D logical mask over the height and width of the
% @a recipe renderings.  Where @a pixelMask is true, RMSE will be
% calculated.  Other pixels will be ignored.
%
% @details
% Returns a vector of RMSE values, one for each element in @a imageNames.
%
% @details
% Usage:
%   rmses = ComputeSweepRMSE(recipe, imageNames, pixelMask)
%
% @ingroup MatchRMSE
function rmses = ComputeSweepRMSE(recipe, imageNames, pixelMask)

% locate the baseline rendering
renderings = rtbWorkingFolder('folder','renderings', 'rendererSpecific',true,'hints', recipe.input.hints);
firstOutput = fullfile(renderings, [imageNames{1} '.mat']);
firstData = load(firstOutput);

imageSize = size(firstData.multispectralImage);
if nargin < 3 || isempty(pixelMask)
    % trivial non-mask
    pixelMask = true(imageSize);
else
    % expand 2D mask to cover multi-spectral dimensions
    pixelMask = repmat(pixelMask, [1, 1, imageSize(3)]);
end

% compute RMSE vs baseline for each rendering
nRenderings = numel(imageNames);
rmses = zeros(1, nRenderings);
for ii = 1:nRenderings
    output = fullfile(renderings, [imageNames{ii} '.mat']);
    data = load(output);
    errorImage = firstData.multispectralImage - data.multispectralImage;
    
    rmses(ii) = rms(errorImage(pixelMask));
end
