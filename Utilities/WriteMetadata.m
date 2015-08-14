%% Write metadata for a VirtualScenes base scene or object.
%   @param modelName the name of a VirtualScenes model like "RingToy"
%   @param objectBox 3x2 bounding box for inserting objects in scene
%   @param lightBox 3x2 bounding box for inserting lights in scene
%   @param lightExcludeBox 3x2 bounding box for @b not inserting lights in scene
%   @param materialIds cell array of string ids for scene materials
%   @param lightIds cell array of string ids for scene light meshes
%
% @details
% Writes a mat-file of metadata for a 3D Collada model in the VirtualScenes
% ModelRepository.  This effectively registers (or re-registers) a 3D model
% for use with the VirtualScenes Toolbox.
%
% @details
% @a modelName must be the name that scripts and toolbox functions and
% scripts will use to refer to the model, for example "RingToy".  This must
% correspond to the name of a Collada file in the VirtualScenes Toolbox
% ModelRepository, such as 
% 'VirtualScenesToolbox/ModelRepository/Objects/Models/RingToy.dae'.
%
% @details
% @a objectBox should be a matrix of the form 
% [minX maxX; minY maxY; minZ, maxZ].  This describes the bounding box
% where it makes sense to insert random objects into the 3D model.
%
% @details
% @a lightBox should be a matrix like @objectBox of the form 
% [minX maxX; minY maxY; minZ, maxZ].  This describes the bounding box
% where it makes sense to insert random lights into the 3D model.
%
% @details
% @a lightExcludeBox should be a matrix like @objectBox of the form 
% [minX maxX; minY maxY; minZ, maxZ].  This describes the bounding box
% where it @b does @b not make sense to insert random lights into the 3D 
% model.  @a lightExcludeBox must be totally contained by @a lightBox.
%
% @details
% @a materialIds must be a cell array of string ids for scene materials,
% for example, {'Floor-material', 'Material1-material', ...}.  These will
% be the materials that VirtualScenes scripts and toolbox functions can
% modify automatically.
%
% @details
% @a lightIds should a cell array of string ids for scene mesh objets, 
% for example, {'CeilingLight-mesh', 'WindowLight-mesh', ...}.  These
% meshes will be the objects that VirtualScenes scripts and toolbox
% functions can "bless" automatically as area lights.
%
% @details
% Writes or replaces a mat-file in the VirtualScenes model repository, at
% either 'VirtualScenesToolbox/ModelRepository/Objects' or 
% 'VirtualScenesToolbox/ModelRepository/BaseScenes'.
%
% @details
% Returns the struct metadata that was written to the mat-file in the
% repository.
%
% @details
% Usage:
%   metadata = WriteMetadata(modelName, objectBox, lightBox, lightExcludeBox, materialIds, lightIds)
%
% @ingroup VirtualScenes
function metadata = WriteMetadata(modelName, objectBox, lightBox, ...
    lightExcludeBox, materialIds, lightIds)
metadata = [];

% check the bounding volumes
if nargin < 2 || ~isnumeric(objectBox) || ~isequal([3 2], size(objectBox))
    defaultVolume = '[-1 1; -1 1; -1 1]';
    warning('VirtualScenes:BadObjectBox', ...
        '\nUsing default objectBox, %s', defaultVolume);
    objectBox = eval(defaultVolume);
end

if nargin < 3 || ~isnumeric(lightBox) || ~isequal([3 2], size(lightBox))
    defaultVolume = '[-10 10; -10 10; -10 10]';
    warning('VirtualScenes:BadLightBox', ...
        '\nUsing default lightBox, %s', defaultVolume);
    lightBox = eval(defaultVolume);
end

if nargin < 4 || ~isnumeric(lightExcludeBox) || ~isequal([3 2], size(lightExcludeBox))
    defaultVolume = '[-1 1; -1 1; -1 1]';
    warning('VirtualScenes:BadLightExcludeBox', ...
        '\nUsing default lightExcludeBox, %s', defaultVolume);
    lightExcludeBox = eval(defaultVolume);
end

% check for known material ids
if nargin < 5 || ~iscell(materialIds) || isempty(materialIds)
    warning('VirtualScenes:NoMaterialIds', ...
        '\nUsing default material Ids, %s', ...
        '{''Material01-material'', ..., ''Material10-material''}');
    materialIds = cell(1, 10);
    for ii = 1:numel(materialIds)
        materialIds{ii} = sprintf('Material%02d-material', ii);
    end
end

% check for known light ids
if nargin < 6
    lightIds = {};
end

% locate the model file
colladaFile = [modelName '.dae'];
repository = getpref('VirtualScenes', 'modelRepository');
fileInfo = ResolveFilePath(colladaFile, repository);

if ~fileInfo.isRootFolderMatch
    warning('VirtualScenes:NoSuchModel', ...
        'Could not find model named "%s" in %s', modelName, repository);
    return;
end

fprintf('\nFound model:\n  %s\n', fileInfo.absolutePath);

% pack up the metadata
metadata = struct( ...
    'name', {modelName}, ...
    'relativePath', {fileInfo.resolvedPath}, ...
    'objectBox', {objectBox}, ...
    'lightBox', {lightBox}, ...
    'lightExcludeBox', {lightExcludeBox}, ...
    'materialIds', {materialIds}, ...
    'lightIds', {lightIds});

% choose where to write the metadata
if IsPathPrefix('BaseScenes', metadata.relativePath)
    metadataPath = fullfile(repository, 'BaseScenes');
else
    metadataPath = fullfile(repository, 'Objects');
end
metadataFile = fullfile(metadataPath, [modelName '.mat']);

fprintf('\nWriting metadata:\n  %s\n', metadataFile);
save(metadataFile, 'metadata');
