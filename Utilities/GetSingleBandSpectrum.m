%% Make a spectrum string with special magnitude in a single band.
%   @param wls list of spectrum wavelengths as from MakeItWls()
%   @param whichBand index into @a wls indicating a single spectrum band
%   @param background spectrum magnitude to assign outside the indicated band
%   @param inBand spectrum magnitude to assign inside the indicated band
%
% @details
% Creates a spectrum string with a special magnitude in a single band.  The
% new string will span the same range as the wavelengths in @a wls.  The
% spectrum band indicated by @a whichBand will have spectral magnitude
% given by @a inBand.  The rest of the spectrum will have the magnitude
% given by @a background.
%
% @details
% The width of the single spectrum band will be about 1nm.
%
% @details
% Returns spectrum string based on the given parameters.  For example, the
% following spectrum string has a special magnitude in a 1nm band located
% at 550nm:
%   300:0 549:0 550:42 551:0 800:0
%
% @details
% Usage:
%   spectrumString = GetSingleBandSpectrum(wls, whichBand, background, inBand)
%
% @ingroup VirtualScenes
function spectrumString = GetSingleBandSpectrum(wls, whichBand, background, inBand)
low = wls(1);
target = wls(whichBand);
high = wls(end);
leftFlank = target-1;
rightFlank = target+1;
spectrumString = sprintf('%d:%d %d:%d %d:%d %d:%d %d:%d', ...
    low, background, ...
    leftFlank, background, ...
    target, inBand, ...
    rightFlank, background, ...
    high, background);
