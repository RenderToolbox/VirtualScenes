%% Get a list of ColorChecker spectra files.
%   @param whichSquares optional indices in 1:24 to select specific spectra
%
% @details
% Searches the RenderToolbox3 code distribution for Macbeth ColorChecker
% spectrum files in the "RenderData" subfolder.  Returns the names of files
% found there, sorted by ColorChecker chart square numbers (starting with 1
% in the upper left, first counting down, then counting to the right).
%
% @details
% If @a whichSquares is provided, it must be an array of indices used to
% select the spectra for specific ColorChecker chart squares.  The valid
% indices are 1:24.
%
% @details
% Returns a cell array of ColorChecker spectrum spd-file names.  Also
% returns a corresponding cell array of local, absolute path names for the
% spd-files.
%
% @details
% Usage:
%   [fileNames, fullPaths] = GetColorCheckerSpectra(whichSquares)
%
% @ingroup VirtualScenes
function [fileNames, fullPaths] = GetColorCheckerSpectra(whichSquares)

if nargin < 1 || isempty(whichSquares)
    whichSquares = 1:24;
end

% locate the data files
spectrumFolder = fullfile( ...
    RenderToolboxRoot(), 'RenderData', 'Macbeth-ColorChecker');
fullPaths = FindFiles(spectrumFolder, 'mccBabel-\d+.spd');
nSquares = numel(fullPaths);
fileNames = cell(1, nSquares);
squareNumber = zeros(1, nSquares);
for ii = 1:numel(fullPaths)
    [filePath, nameBase, nameExt] = fileparts(fullPaths{ii});
    fileNames{ii} = [nameBase, nameExt];
    squareNumber(ii) = sscanf(nameBase(10:end), '%f');
end

% sort them by square number
fileNames(squareNumber) = fileNames;
fullPaths(squareNumber) = fullPaths;

% choose specific squares
fileNames = fileNames(whichSquares);
fullPaths = fullPaths(whichSquares);
