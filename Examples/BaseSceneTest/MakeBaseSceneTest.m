%% Construct and render a recipe to test a BaseScene.
%
% Use this script as a quick test of a tamed BaseScene added to the
% Virtual Scenes Toolbox Model Repository.
%
% Edit the top of this script with the name of the BaseScene to test.
%
% @ingroup BaseSceneTest

%% Overall configuration.
clear;
clc;

% choose the base scene
baseSceneName = 'Mill';
sceneMetadata = ReadMetadata(baseSceneName);

% batch renderer options
hints = GetDefaultHints();
hints.renderer = 'Mitsuba';
hints.recipeName = [baseSceneName 'Test'];
hints.imageHeight = 480;
hints.imageWidth = 640;
hints.workingFolder = getpref('VirtualScenes', 'workingFolder');

ChangeToWorkingFolder(hints);
resources = GetWorkingFolder('resources', false, hints);

toneMapFactor = getpref('VirtualScenes', 'toneMapFactor');
isScale = getpref('VirtualScenes', 'toneMapScale');

defaultMappings = fullfile( ...
    VirtualScenesRoot(), 'MiscellaneousData', 'DefaultMappings.txt');
mappingsFile = [hints.recipeName '-Mappings.txt'];

%% Choose lighting.

% a plain white light
whiteArea = BuildDesription('light', 'area', ...
    {'intensity'}, ...
    {'300:1 800:1'}, ...
    {'spectrum'});

lights = cell(1, numel(sceneMetadata.lightIds));
[lights{:}] = deal(whiteArea);

%% Choose non-dark ColorChecker material resources.
[colorCheckerSpectra, filePaths] = GetColorCheckerSpectra();

nonDark = setdiff(1:24, [8 16 20 24]);
colorCheckerSpectra = colorCheckerSpectra(nonDark);
filePaths = filePaths(nonDark);

nColorCheckers = numel(colorCheckerSpectra);
colorCheckerMaterials = cell(1, nColorCheckers);
for ii = 1:nColorCheckers
    % matte materail
    colorCheckerMaterials{ii} = BuildDesription('material', 'matte', ...
        {'diffuseReflectance'}, ...
        colorCheckerSpectra(ii), ...
        {'spectrum'});
    
    % resource file
    copyfile(filePaths{ii}, resources);
end

nMaterials = numel(sceneMetadata.materialIds);
colorCheckerIndices = 1 + mod((1:nMaterials) - 1, nColorCheckers);
materials = colorCheckerMaterials(colorCheckerIndices);


%% Copy in the parent scene file resource.
modelAbsPath = GetVirtualScenesRepositoryPath(sceneMetadata.relativePath);
[modelPath, modelFile, modelExt] = fileparts(modelAbsPath);

parentSceneFile = fullfile(resources, [modelFile, modelExt]);
parentSceneFile = rtbGetWorkingRelativePath(parentSceneFile, 'hints', hints);

if exist(parentSceneFile, 'file')
    delete(parentSceneFile);
end
copyfile(modelAbsPath, parentSceneFile);

%% Write a mappings file.
configs = getpref('VirtualScenes', 'rendererConfigs');
conf = configs.(hints.renderer);
confStyle = conf.full;

AppendMappings(defaultMappings, mappingsFile, ...
    conf.ids, confStyle.descriptions, ...
    confStyle.blockName, 'config');
AppendMappings(mappingsFile, mappingsFile, ...
    sceneMetadata.lightIds, lights, 'Generic', 'lights');
AppendMappings(mappingsFile, mappingsFile, ...
    sceneMetadata.materialIds, materials, 'Generic', 'materials');

%% Assemble a recipe.
executive = { ...
    @rtbMakeRecipeSceneFiles, ...
    @rtbMakeRecipeRenderings, ...
    @(recipe)rtbMakeRecipeMontage(recipe, 'toneMapFactor', toneMapFactor, 'isScale', isScale)};

recipe = rtbNewRecipe( ...
    'executive', executive, ...
    'parentSceneFile', parentSceneFile, ...
    'mappingsFile', mappingsFile, ...
    'hints', hints);

%% Render and view.
recipe = rtbExecuteRecipe(recipe);
