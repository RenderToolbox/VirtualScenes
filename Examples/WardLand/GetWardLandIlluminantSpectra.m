%% Make up some illuminant spectra.
%   @param mean mean for CIE daylight temperature
%   @param std standard deviation for CIE daylight temperature
%   @param range [low high] clipping range for CIE daylight temperature
%   @param nSpectra number of spectra to generate
%   @param hints struct of RenderToolbox3 options, see GetDefaultHints()
%
% @details
% Generates descriptions of area light sources, with randomly chosen CIE
% Daylight spectra.
%
% @details
% Writes any necessary spectrum definition spm-files to the working
% "resources" folder as indicated by hints.workingFolder. See
% GetWorkingFolder().
%
% @details
% Returns a cell array of area light descriptions, as from
% BuildDesription().  Also returns a corresponding cell array of spd-file
% names.
%
% @details
% Usage:
%   [spectra, spdFiles] = GetWardLandIlluminantSpectra(mean, std, range, nSpectra, hints)
%
% @ingroup WardLand
function [spectra, spdFiles] = GetWardLandIlluminantSpectra(mean, std, range, nSpectra, hints)

if nargin < 1 || isempty(mean)
    mean = 6500;
end

if nargin < 2 || isempty(std)
    std = 3000;
end

if nargin < 3 || isempty(range)
    range = [4000 12000];
end

if nargin < 4 || isempty(nSpectra)
    nSpectra = 10;
end

if nargin < 5 || isempty (hints)
    resources = '';
else
    resources = GetWorkingFolder('resources', false, hints);
end

% choose random illuminant temperatures
%   re-pick when temps go out of range
temps = normrnd(mean, std, [1, nSpectra]);
outOfRange = temps > range(2) | temps < range(1);
attempts = 100;
while any(outOfRange) && attempts > 0
    temps(outOfRange) = normrnd(mean, std, [1, sum(outOfRange)]);
    outOfRange = temps > range(2) | temps < range(1);
    attempts = attempts - 1;
end
temps = round(temps);

% generate the spectrum for each temperature
cieData = load('B_cieday');
spectra = cell(1, nSpectra);
spdFiles = cell(1, nSpectra);
for ii = 1:nSpectra
    spd = GenerateCIEDay(temps(ii), cieData.B_cieday);
    wls = SToWls(cieData.S_cieday);
    
    spdName = sprintf('CIE-%dK.spd', temps(ii));
    spectra{ii} = BuildDesription('light', 'area', ...
        {'intensity'}, ...
        {spdName}, ...
        {'spectrum'});
    
    spdFiles{ii} = fullfile(resources, spdName);
    if ~isempty(resources)
        WriteSpectrumFile(wls, spd, spdFiles{ii});
    end
end

