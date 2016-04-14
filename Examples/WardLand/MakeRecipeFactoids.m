%% Use an RGB build of Mitsuba to record recipe scene factoids.
%   @param recipe a recipe from BuildWardLandRecipe()
%   @param singleSampling whether to reduce sampling and pixel filtering
%
% @details
% Uses an RGB build of the Mitsuba renderer to compute recipe "factoids"
% about the given WardLand @a recipe.  See RenderMitsubaFactoids().
%
% @details
% By default, uses the same pixel sampling and image reconstruction
% filtering specified in the recipe's first generated scene file.  If @a
% singleSampling is true, reduces sampling to one sample per pixel and uses
% a simple "box" filter for image reconstruction.
%
% @details
% Returns the given @a recipe, updated with new factoids in the "factoid"
% group.
%
% @details
% Usage:
%   recipe = MakeRecipeFactoids(recipe, singleSampling)
%
% @ingroup WardLand
function recipe = MakeRecipeFactoids(recipe, singleSampling)

if nargin < 2 || isempty(singleSampling)
    singleSampling = false;
end

if ~strcmp(recipe.input.hints.renderer, 'Mitsuba')
    return;
end

% locate the first recipe scene file
relativeSceneFile = recipe.rendering.scenes{1}.mitsubaFile;
sceneFile = GetWorkingAbsolutePath(relativeSceneFile, recipe.input.hints);

% invoke RGB mitsuba to gather scene factoids under each pixel
[status, result, newScene, exrOutput, factoidOutput] = ...
    RenderMitsubaFactoids(sceneFile, '', '', '', {}, 'rgb', ...
    recipe.input.hints, [], singleSampling);

recipe = SetRecipeProcessingData(recipe, 'factoid', 'status', status);
recipe = SetRecipeProcessingData(recipe, 'factoid', 'result', result);
recipe = SetRecipeProcessingData(recipe, 'factoid', 'newScene', newScene);
recipe = SetRecipeProcessingData(recipe, 'factoid', 'exrOutput', exrOutput);
recipe = SetRecipeProcessingData(recipe, 'factoid', 'factoidOutput', factoidOutput);
