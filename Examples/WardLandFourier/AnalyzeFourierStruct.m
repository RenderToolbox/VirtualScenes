%% Do Fourier analysis on data in a "Fourier Struct" array.
%   @param fourierStruct "Fourier Struct" as from WardLandToFourierStruct()
%   @param nBins how many frequency bins to use, passed to FourierDistribution()
%
% @details
% For each element of the given @a fourierStruct struct array, does spatial
% frequency analysis and fills in computation results.
%
% @details
% Returns the given @a fourierStruct with each element updated.
%
% @details
% Usage:
%   fourierStruct = AnalyzeFourierStruct(fourierStruct, nBands)
%
% @ingroup WardLand
function fourierStruct = AnalyzeFourierStruct(fourierStruct, nBands)

if nargin < 2 || isempty(nBands)
    nBands = 10;
end

nTodo = numel(fourierStruct);
for ii = 1:nTodo
    % get input image
    grayscale = fourierStruct(ii).grayscale;
    
    % do Fourier transform
    fourierTransform = fft2(grayscale);
    fourierMean = fourierTransform(1,1);
    fourierCentered = fftshift(fourierTransform);
    fourierNormalized = fourierCentered ./ fourierMean;
    
    % get the frequency distribution by rings
    [amplitudes, frequencies] = FourierDistribution(fourierNormalized, nBands);
    
    % save computations
    results.fourierMean = fourierMean;
    results.fourierNormalized = fourierNormalized;
    results.amplitudes = amplitudes;
    results.frequencies = frequencies;
    
    fourierStruct(ii).results = results;
end
