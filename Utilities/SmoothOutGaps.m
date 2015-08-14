%% Smooth out the gaps in an image by taking a sliding median.
%   @param rawImage any m x n x p image
%   @param gapMask an m x n mask with zeros indicating gaps in @a rawImage
%   @param filterWidth width in pixels of a square sliding filter.
%
% @details
% Passes a sliding square window of width @a filterWidth over the given @a
% rawImage.  For each pixel where @a gapMask is zero, attempts to "smooth
% out" the gap by replacing the pixel value with the mean pixel value under
% the sliding window.  Uses MeanUnderMask() to compute the median.
%
% @details
% Returns a new m x n x p image based on @a rawImage, but with gap pixels
% replaced with the median of nearby non-gap pixels.
%
% @details
% Usage:
%   smoothImage = SmoothOutGaps(rawImage, gapMask, filterWidth)
%
% @ingroup VirtualScenes
function smoothImage = SmoothOutGaps(rawImage, gapMask, filterWidth)
imageSize = size(rawImage);
height = imageSize(1);
width = imageSize(2);

isGap = gapMask == 0;
windowMask = zeros(height, width);

% compute smooth image with sliding window
halfWindow = ceil(filterWidth/2);
smoothImage = rawImage;
for ii = 1:height
    for jj = 1:width
        if gapMask(ii,jj) > 0
            % no gap here
            continue;
        end
        
        % choose window area
        windowYMin = max(ii - halfWindow, 1);
        windowYMax = min(ii + halfWindow, height);
        windowXMin = max(jj - halfWindow, 1);
        windowXMax = min(jj + halfWindow, width);
        
        % make a mask to average over
        windowMask(:) = 0;
        windowMask(windowYMin:windowYMax, windowXMin:windowXMax) = 1;
        windowMask(isGap) = 0;
        
        % get the mean under the mask
        [maskMean, maskMedian] = MeanUnderMask(rawImage, windowMask);
        
        % smooth out that gap!
        if isempty(maskMedian) || any(isnan(maskMedian))
            smoothImage(ii, jj, :) = 0;
        else
            smoothImage(ii, jj, :) = maskMedian;
        end
    end
end
