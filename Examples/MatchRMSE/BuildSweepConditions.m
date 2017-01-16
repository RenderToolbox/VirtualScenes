%% Modify a MatchRMSE recipe to sweep over a named parameter.
%   @param recipe a recipe from BuildMatchRMSERecipe()
%   @param sweepName name for the new conditions file
%   @param paramName name of a broken-out parameter from BuildMatchRMSERecipe()
%   @param paramValues cell array of values to use for paramName
%   @param imageNames cell array of output image names, one for each element of in @aparamValues
%
% @details
% Modifies the given @a recipe to perform a rendering sweep over the given
% @a paramName, using the values and output image names in the given @a
% paramValues and @a imageNames.  The new recipe will use a new conditions
% file, with a name based on @a sweepName.
%
% @details
% Returns a new recipe based on the given @a recipe, which will perform a
% rendering sweep over the given parameter.
%
% @details
% Usage:
%   recipe = BuildSweepConditions(recipe, sweepName, paramName, paramValues, imageNames)
%
% @ingroup MatchRMSE
function recipe = BuildSweepConditions(recipe, sweepName, paramName, paramValues, imageNames)

% get the original parameter names and values
working = rtbWorkingFolder('folder','', 'hints', recipe.input.hints);
conditionsFile = ResolveFilePath(recipe.input.conditionsFile, working);
[varNames, varValues] = ParseConditions(conditionsFile.absolutePath);

% make a row for each value in paramValues
nSteps = numel(paramValues);
newValues = repmat(varValues, nSteps, 1);

% insert the new paramValues and imageNames
isParam = strcmp(varNames, paramName);
newValues(:,isParam) = paramValues;

isImageName = strcmp(varNames, 'imageName');
newValues(:,isImageName) = imageNames;

% write the new conditions file and wire it up
newConditionsFile = fullfile(working, [sweepName '-Conditions.txt']);
rtbWriteConditionsFile(newConditionsFile, varNames, newValues);
recipe.input.conditionsFile = newConditionsFile;
