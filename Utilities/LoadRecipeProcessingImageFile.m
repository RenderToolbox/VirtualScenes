%% Load some image data previously saved as part of a recipe.
%   @a param recipe the recipe to update
%   @a param group string name of group to which data belongs
%   @a param name string name for data itself
%
% @details
% Loads the image data from a standard place within the given @a
% recipe struct and working folder, based on the given @a group and @a
% name.  This is a conveniecne function for reading image data within a
% recipe's working folder, based on bookkeeping within @a
% recipe.processing.
%
% @details
% Reads an image file from the "images" subfolder of the working folder for
% the given @a recipe.  Usually uses imread().  The image file has the
% 'mat', extension, uses load() instead.
%
% @details
% Returns image data found under the given @a recipe, @a group, and @a
% name, or the empty [] if there was no such data.
%
% @details
% Usage:
%   imageData = LoadRecipeProcessingImageFile(recipe, group, name)
%
% @ingroup Utilities
function imageData = LoadRecipeProcessingImageFile(recipe, group, name)

if nargin < 2 || isempty(group)
    group = 'defaultGroup';
    disp('Using default data group!');
end

if nargin < 3 || isempty(name)
    name = 'defaultName';
    disp('Using default data name!');
end

if ~isfield(recipe.processing, group)
    disp(['No such data group: ', group]);
    imageData = [];
    return;
end

if ~isfield(recipe.processing.(group), name)
    disp(['No such data name: ', name]);
    imageData = [];
    return;
end

% where is the image located?
relativeFileName = GetRecipeProcessingData(recipe, group, name);
imageFileName = rtbWorkingAbsolutePath(relativeFileName, 'hints', recipe.input.hints);

if ~exist(imageFileName, 'file')
    disp(['Image file not found: ', imageFileName]);
    imageData = [];
    return;
end

% load the image
[filePath, fileBase, fileExt] = fileparts(imageFileName);
if strcmp('.mat', fileExt)
    loaded = load(imageFileName);
    imageData = loaded.imageData;
else
    imageData = imread(imageFileName);
end
