%% Get a list of tesxture image files.
%   @param whichImages optional indices to select specific images
%
% @details
% Searches for image files in the VirtualScenesToolbox "Textures" folder.
% Returns the names of files found there, sorted alphabetically.
%
% @details
% If @a whichImages is provided, it must be an array of indices used to
% select the images by alphabetical ranks.
%
% @details
% Returns a cell array of texture image file names.  Also returns a
% corresponding cell array of local, absolute path names for the same
% files.
%
% @details
% Usage:
%   [fileNames, fullPaths] = GetTextureImages(whichImages)
%
% @ingroup VirtualScenes
function [fileNames, fullPaths] = GetTextureImages(whichImages)

if nargin < 1 || isempty(whichImages)
    whichImages = [];
end

% locate the data files
textureFolder = fullfile(VirtualScenesRoot(), 'MiscellaneousData', 'Textures');
exrs = FindFiles(textureFolder, '\.exr$');
jpgs = FindFiles(textureFolder, '\.jpg$');
fullPaths = cat(2, exrs, jpgs);

% get file names withouth paths
nImages = numel(fullPaths);
fileNames = cell(1, nImages);
for ii = 1:numel(fullPaths)
    [filePath, nameBase, nameExt] = fileparts(fullPaths{ii});
    fileNames{ii} = [nameBase, nameExt];
end

% sort by file name
[fileNames, order] = sort(fileNames);
fullPaths = fullPaths(order);

% choose specific images
if ~isempty(whichImages)
    fileNames = fileNames(whichImages);
    fullPaths = fullPaths(whichImages);
end