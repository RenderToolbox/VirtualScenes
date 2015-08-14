%% Convert a sparse spectrum string to an evenly spaced spectrum.
%   @param sparse a spectrum string like '400:0 450:1 700:0'
%   @param spacing desired spectrum sampling in the new spectrum string
%
% @details
% Converts a spectrum string @a sparse, which specifies magnitudes at
% irregular intervals, to a new spectrum which specifies magnitudes
% at regular intervals specified in @a spacing.
%
% @details
% For example, the spectrum string '400:0 450:1 700:0' is sparse because it
% specifies wavelengths at irregular intervals 400, 450, and 700.  This
% function will convert the spectrum to a similar spectrum string by
% filling in missing wavelengths.  For example, with @a spacing 50 the
% spectrum string above would become
% '400:0 450:1 500:0 550:0 600:0 650:0 700:0'
%
% @details
% The new spectrum is not generally equivalent to the given @a
% sparse spectrum.  But the new spectrum will have regular sampling,
% which allows resampling with Psychtoolox functions like SplineRaw(), etc.
%
% @details
% Returns an array of regularly-spaced wavelengths for the new spectrum.
% Also returns an array of magnitudes, one for each wavelength.
%
% @details
% Usage:
%   [denseWls, denseMags] = SparseSpectrumToRegular(sparse, spacing)
%
% @ingroup VirtualScenes
function [denseWls, denseMags] = SparseSpectrumToRegular(sparse, spacing)

if nargin < 2 || isempty(spacing)
    spacing = 1;
end

[sparseWls, sparseMags] = ReadSpectrum(sparse);
denseWls = sparseWls(1):spacing:sparseWls(end);
denseMags = zeros(size(denseWls));
jj = 1;
currentMag = 0;
for ii = 1:numel(denseWls)
    if denseWls(ii) >= sparseWls(jj)
        currentMag = sparseMags(jj);
        jj = jj + 1;
    end
    denseMags(ii) = currentMag;
end
