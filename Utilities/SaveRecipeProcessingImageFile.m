%% Save some image data as part of a recipe.
%   @a param recipe the recipe to update
%   @a param group string name of group to which @a data belongs
%   @a param name string name for @a itself
%   @a param imageFormat format of the image to save
%   @a param imageData matrix of image data
%
% @details
% Saves the given @a imageData in a standard place within the given @a
% recipe struct and working folder, based on the given @a group, @a name,
% and @a imageFormat.  This is a conveniecne function for writing image
% data within a recipe's working folder, and keeping track of the image
% within @a recipe.processing.
%
% @details
% Writes an image file in the "images" subfolder of the working folder for
% the given @a recipe.  Usually passes @a imageFormat and @a imageData
% directly to imwrite().  If @a imageFormat is 'mat', passes imageData to
% save() instead.
%
% @details
% Any image previously saved with the same @a recipe, @a group, and @a name
% will be over-written to point to the given @a imageData. 
%
% @details
% Returns the given @a recipe, updated to point to a file that contains the
% given @a imageData.
%
% @details
% Usage:
%   recipe = SaveRecipeProcessingImageFile(recipe, group, name, data)
%
% @ingroup Utilities
function recipe = SaveRecipeProcessingImageFile(recipe, group, name, imageFormat, imageData)

if nargin < 2 || isempty(group)
    group = 'defaultGroup';
    disp('Using default data group!');
end

if nargin < 3 || isempty(name)
    name = 'defaultName';
    disp('Using default data name!');
end

if nargin < 4 || isempty(imageFormat)
    imageFormat = 'mat';
    disp('Using default image format!');
end

if nargin < 5 || isempty(imageData)
    imageData = [];
end

% where to write the image
imagesFolder = rtbWorkingFolder('folder','images', 'rendererSpecific', true, 'hints', recipe.input.hints);
imageFileName = fullfile(imagesFolder, group, [name '.' imageFormat]);

% write out the image file
WriteImage(imageFileName, imageData);

% put a reference in the recipe struct
relativeFileName = rtbGetWorkingRelativePath(imageFileName, 'hints', recipe.input.hints);
recipe = SetRecipeProcessingData(recipe, group, name, relativeFileName);
