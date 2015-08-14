%% Access some processing data in the recipe struct.
%   @a param recipe the recipe to update
%   @a param group string name of group to which data belongs
%   @a param name string name for data itself
%
% @details
% Access previously stored data frmo a standard place within the given @a
% recipe, based on the given @a group and @a name.  This is a conveniecne
% function for getting data from @a recipe.processing.
%
% @details
% Returns the the data located under the given @arecipe, @a group, and @a
% name, or the empty [] if there is no such data.
%
% @details
% Usage:
%   data = GetRecipeProcessingData(recipe, group, name)
%
% @ingroup Utilities
function data = GetRecipeProcessingData(recipe, group, name)

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
    data = [];
    return;
end

if ~isfield(recipe.processing.(group), name)
    disp(['No such data name: ', name]);
    data = [];
    return;
end

data = recipe.processing.(group).(name);
