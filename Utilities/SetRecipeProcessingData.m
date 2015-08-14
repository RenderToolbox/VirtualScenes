%% Store some processing data in the recipe struct.
%   @a param recipe the recipe to update
%   @a param group string name of group to which @a data belongs
%   @a param name string name for @a itself
%   @a param data data to save
%
% @details
% Store the given @a data in a standard place within the given @a recipe,
% based on the given @a group and @a name.  This is a conveniecne function
% for putting data inside @a recipe.processing.
%
% @details
% Any data previously saved in the same @a recipe, @a group, and @a name
% will be over-written with the given @a data.
%
% @details
% Returns the given @a recipe, updated to contain the given @a data.
%
% @details
% Usage:
%   recipe = SetRecipeProcessingData(recipe, group, name, data)
%
% @ingroup Utilities
function recipe = SetRecipeProcessingData(recipe, group, name, data)

if nargin < 2 || isempty(group)
    group = 'defaultGroup';
    disp('Using default data group!');
end

if nargin < 3 || isempty(name)
    name = 'defaultName';
    disp('Using default data name!');
end

if nargin < 4 || isempty(data)
    data = [];
end

recipe.processing.(group).(name) = data;
