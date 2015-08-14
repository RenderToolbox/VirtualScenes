%% Render Recipes as a standalone Matlab executable.
%   @param fetchCommand unix() command to fetch recipes into @a
%   recipeFolder
%   @param inputFolder folder that contains recipes to execute
%   @param outputFolder folder to receive executed recipes
%   @param pushCommand unix() command to publish recipes from @a
%   outputFolder
%
% @details
% Expects 5 parameters from the command line.  These tell us how to get set
% up for recipe execution, which recipes to execute, and what to do with
% the recipes after we've executed them.
%
% @details
% We can run this on a local workstation.  In that case, we can probably
% omit @a fetchCommand, and @a pushCommand.  We would just
% look for recipes contained in @a inputFolder, execute each one, and save
% the output in @A outputFolder.
%
% @details
% What we really want is to run this from a standalone Matlab executable on
% a compute cluster, like Amazon EC2.  In this case, we need @a
% fetchCommand and @a pushCommand to exchange files.  For example, we might
% fetch recipes from Amazon S3, execute them, then publish them back to S3.
%
% @details
% Attempts to capture command window and error messages with the diary()
% function.  The diary file will be named "recipe-executor-log.txt" and
% written to the given @a outputFolder.
%
% @details
% Usage as a regular function in Matlab:
%   function RecipeExecutor(fetchCommand, inputFolder, outputFolder, pushCommand)
%
% Sample usage as a standalone on the command line:
%   ./run_RecipeExecutor.sh /Applications/MATLAB/MATLAB_Compiler_Runtime/v84 fetchCommand inputFolder outputFolder pushCommand
%
function RecipeExecutor(fetchCommand, inputFolder, outputFolder, pushCommand)

%% Include these functions for Matlab Compiler.
% batch renderer
%#function MakeRecipeRenderings, MakeRecipeSceneFiles, MakeRecipeMontage

% renderer plugins
%#function RTB_VersionInfo_PBRT, RTB_Render_PBRT, RTB_ImportCollada_PBRT, RTB_DataToRadiance_PBRT, RTB_ApplyMappings_PBRT
%#function RTB_VersionInfo_Mitsuba, RTB_Render_Mitsuba, RTB_ImportCollada_Mitsuba, RTB_DataToRadiance_Mitsuba, RTB_ApplyMappings_Mitsuba
%#function RTB_VersionInfo_SampleRenderer, RTB_Render_SampleRenderer, RTB_ImportCollada_SampleRenderer, RTB_DataToRadiance_SampleRenderer, RTB_ApplyMappings_SampleRenderer

% remodeler plugins
%#function RTB_BeforeAll_SampleRemodeler, RTB_AfterCondition_SampleRemodeler, RTB_BeforeCondition_SampleRemodeler
%#function RTB_BeforeAll_MaterialSphere, RTB_BeforeCondition_MaterialSphere
%#function RTB_BeforeCondition_InsertObjectRemodeler

%% Args.
if nargin < 1 || isempty(fetchCommand)
    fetchCommand = '';
end

if nargin < 2 || isempty(inputFolder)
    inputFolder = pwd();
end

if nargin < 3 || isempty(outputFolder)
    outputFolder = fullfile(inputFolder, 'output');
end

if nargin < 4 || isempty(pushCommand)
    pushCommand = '';
end

%% Start Logging.
if (~exist(outputFolder, 'dir'))
    mkdir(outputFolder);
end
diaryFile = fullfile(outputFolder, 'recipe-executor-log.txt');
diary(diaryFile);

disp(['RecipeExecutor starting at ' datestr(now)])
fetchCommand
inputFolder
outputFolder
pushCommand

%% Configure the environment (hardcoded for now).
RecipeExecutorConfig;

%% Fetch files as needed.
if ~isempty(fetchCommand)
    disp(['Running fetch command: ' fetchCommand])
    [fetchStatus, fetchResult] = unix(fetchCommand)
end

%% Execute from inputFolder and save to outputFolder.
archiveFiles = FindFiles(inputFolder, '\.zip$');
nRecipes = numel(archiveFiles);
disp(sprintf('Found %d recipes in input folder %s', nRecipes, inputFolder))
for ii = 1:nRecipes
    disp(sprintf('Recipe %d of %d', ii, nRecipes))
    
    % render and proceed after errors
    try
        % get the recipe
        disp(['Unpacking recipe: ' archiveFiles{ii}])
        recipe = UnpackRecipe(archiveFiles{ii});
        
        % execute recipe
        disp(['Executing recipe: ' recipe.input.hints.recipeName])
        recipe = ExecuteRecipe(recipe, [], true);
        
    catch err
        disp(sprintf('Error executing recipe %d of %d', ii, nRecipes))
        disp(err.getReport())
    end
    
    % pack up the results even if there were errors
    try
        % pack up the results
        [archivePath, archiveBase, archiveExt] = fileparts(archiveFiles{ii});
        renderedArchiveFile = fullfile(outputFolder, [archiveBase archiveExt]);
        disp(['Packing up recipe: ' renderedArchiveFile])
        excludeFolders = {'temp'};
        PackUpRecipe(recipe, renderedArchiveFile, excludeFolders);
        
    catch err
        disp(sprintf('Error packing up recipe %d of %d', ii, nRecipes))
        disp(err.getReport())
    end
end

%% Push files as needed.
if ~isempty(pushCommand)
    disp(['Running push command: ' pushCommand])
    [pushStatus, pushResult] = unix(pushCommand)
end
