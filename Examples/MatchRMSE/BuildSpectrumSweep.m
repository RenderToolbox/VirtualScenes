%% Build a parameter sweep with interpolated spd-files.
%   @param sweepName name for spectrum files and output images
%   @param spectrumA starting spd-file or other spectrum specifier
%   @param spectrumB ending spd-file or other spectrum specifier
%   @param nSteps how many steps in the sweep
%   @param outputFolder where to write new interpolated spd-files
%   @param scaleB optional scale factor to apply to @a spectrumB
%
% @details
% Computes a parameter sweep starting from @a spectrumA and ending with @a
% spectrumB, ranging over @a nSteps steps.  Each computed spectrum will be
% a linear interpolateion between @a spectrumA and @a spectrumB.  Each
% computed spectrum will be written to a new spd-file in the given @a
% outputFolder.
%
% @details
% If @a scaleB is privided, it should be a scalar to apply to @a spectrumB
% after it's read into memory, and before the sweep is computed.
%
% @details
% Returns a cell array of spd-file names which contain spectrums
% interpolated between the given @a spectrumA and @a spectrumB.  Also
% returns a cell array of image names to associate with each returned
% spectrum.  Also returns a vector of "lambda" values ranging from 0-1,
% describing the progress through the sweep for each returned spectrum.
%
% @details
% Usage:
%   [spdFiles, imageNames, lambdas] = BuildSpectrumSweep(sweepName, spectrumA, spectrumB, nSteps, outputFolder, scaleB)
%
% @ingroup MatchRMSE
function [spdFiles, imageNames, lambdas] = BuildSpectrumSweep(sweepName, spectrumA, spectrumB, nSteps, outputFolder, scaleB)

if nargin < 6 || isempty(scaleB)
    scaleB = 1;
end

% read in the original spectra
[wlsA, magsA] = ReadSpectrum(spectrumA);
[elsB, magsB] = ReadSpectrum(spectrumB);

% scale the second spectrum
magsB = magsB .* scaleB;

% write out several interpolated spectra
lambdas = linspace(0, 1, nSteps);
spdFiles = cell(nSteps, 1);
imageNames = cell(nSteps, 1);
for ii = 1:nSteps
    imageNames{ii} = sprintf('%s-%02d', sweepName, ii);
    spdFiles{ii} = sprintf('%s.spd', imageNames{ii});
    intermMags = lambdas(ii) .* magsB + (1-lambdas(ii)) .* magsA;
    rtbWriteSpectrumFile(wlsA, intermMags, fullfile(outputFolder, spdFiles{ii}));
end
