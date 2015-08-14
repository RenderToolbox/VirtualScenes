%% Compute a Frequency Distribution for a fftshift() image.
%   @param fftShiftImage a fft2() image, shifted so 0 frequency is centered
%   @param nBins how many bins to use in the distribution.
%
% @details
% Computes a frequency distribution for the given @a fftShiftImage.  @a
% fftShiftImage should contain the Fourier transform of some image as,
% computed by fft2(), with the 0-frequency pixel shifted to the center of
% the image, as by fftshift().
%
% @details
% For each frequency bin, considers the "ring" of pixels in @a
% fftShiftImage that are located near the corresponding frequency
% "radius" from the center pixel.  Computes the mean amplitude and
% frequency/radius within each ring.
%
% @details
% This function only reports on fft amplitudes in @a fftShiftImage. It
% ignores the phase component.  Since the rings are symmetric about the
% center, it also ignores orientation.
%
% @details
% Returns a vector with @a nBins elements, where each element is the mean
% amplitude found in a frequency ring.  Also returns a vector containing
% the mean frequency within each ring.
%
% @details
% Usage:
%   [amplitudes, frequencies] = FourierDistribution(fftShiftImage, nBins)
%
% @ingroup Utilities
function [amplitudes, frequencies] = FourierDistribution(fftShiftImage, nBins)

if nargin < 2 || isempty(nBins)
    nBins = 10;
end

% figure out the range of possible frequencies
height = size(fftShiftImage, 1);
width = size(fftShiftImage, 2);
maxFreq = ceil(radiusFromCenter(height, width, 1, 1));

% set up frequency rings
ringCenters = linspace(0, maxFreq, nBins);
ringCounts = zeros(1, nBins);
ringAmplitudeSums = zeros(1, nBins);
ringFrequencySums = zeros(1, nBins);

% assign each image pixel to a ring
for ii = 1:height
    for jj = 1:width
        % the amplitude in this pixel
        amplitude = abs(fftShiftImage(ii, jj));
        
        % the radius from center of this pixel
        frequency = radiusFromCenter(height, width, ii, jj);
                
        % assign this pixel to a ring
        [m, ringIndex] = min(abs(frequency - ringCenters));
        ringCounts(ringIndex) = ringCounts(ringIndex) + 1;
        ringAmplitudeSums(ringIndex) = ringAmplitudeSums(ringIndex) + amplitude;
        ringFrequencySums(ringIndex) = ringFrequencySums(ringIndex) + frequency;
    end
end

% compute ring mean frequencies and amplitudes
amplitudes = ringAmplitudeSums ./ ringCounts;
frequencies = ringFrequencySums ./ ringCounts;

function r = radiusFromCenter(height, width, ii, jj)
r = sqrt((ii - height/2)^2 + (jj - width/2)^2);
