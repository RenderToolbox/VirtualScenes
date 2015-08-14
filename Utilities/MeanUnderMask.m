% Take the mean of a multi-spectral image under a 2D mask.
%   @param rawImage any m x n x p image
%   @param mask an m x n mask with non-zeros indicating a region of @a rawImage
%
% @details
% Computes the mean and median of some pixels in the given multi-spectral
% @a rawImage.  Non-zero elements of @a mask select the region over which
% the mean and median should be computed.
%
% @details
% The mean and median are computed separately for each of the p
% multi-spectral dimensions of rawImage.
%
% @details
% Returns the p-element mean pixel found in @a rawImage under @a mask.
% Also returns the p-element median pixel.
%
% @details
% Usage:
%   [meanPixel, medianPixel] = MeanUnderMask(rawImage, mask)
%
% @ingroup VirtualScenes
function [meanPixel, medianPixel] = MeanUnderMask(rawImage, mask)
imageSize = size(rawImage);
height= imageSize(1);
width = imageSize(2);
depth = imageSize(3);
sliceSize = height*width;

% does the mask have any area?
maskIndices = find(mask ~= 0);
if isempty(maskIndices)
    meanPixel = [];
    medianPixel = [];
    return;
end

% extrude the mask into the image depth and get 1D indices
nSamples = numel(maskIndices);
sampleIndices = repmat(maskIndices, [1, depth]);
cornerIndices = 1:sliceSize:numel(rawImage);
cornerOffsets = repmat(cornerIndices-1, [nSamples, 1]);
sampleIndices = sampleIndices + cornerOffsets;

% pick out the pixels under the mask
imageSample = zeros(nSamples, depth);
imageSample(:) = rawImage(sampleIndices);

% calculate pixel statistics
meanPixel = mean(imageSample, 1);
medianPixel = median(imageSample, 1);
