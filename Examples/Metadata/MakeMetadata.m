%% Test writing and reading metadata for a few models.
%
% This script re-writes all of the 3D models in the Virtual Scenes Toolbox
% Model Repository, and verifies that if can read back the same data.
%
% This script has already been run and you don't need to run it again,
% unless you know what you're doing and you want to modify the repository.
%
% This scrip is here as documentation of the repository, and as an example
% of how to read and write repository metadata.
%

clear;
clc;
repository = getpref('VirtualScenes', 'modelRepository');

%% IndoorPlant base scene
modelName = 'IndoorPlant';
objectBox = [-6 2; -2 2; 0 6];
lightBox = [-6 15; -15 2; 0 15];
lightExcludeBox = [-6 6; -12 2; 0 7];
modelPath = fullfile(repository, 'BaseScenes', 'Models', 'IndoorPlant.dae');
materialIds = GetSceneElementIds(modelPath, '\w+-material$');
lightIds = { ...
    'CeilingLight-mesh', ...
    'HighRearLight-mesh', ...
    'LowRearLight-mesh', ...
    };
metadata = WriteMetadata(modelName, objectBox, lightBox, lightExcludeBox, materialIds, lightIds);
readMetadata = ReadMetadata(modelName);
assert(isequal(metadata, readMetadata))

%% Warehouse base scene
modelName = 'Warehouse';
objectBox = [-12 -2; -3 6; 0 3];
lightBox = [-20 20; -20 20; 0 20];
lightExcludeBox = [-13 4; -7 7; 0 7];
modelPath = fullfile(repository, 'BaseScenes', 'Models', 'Warehouse.dae');
materialIds = GetSceneElementIds(modelPath, '\w+-material$');
lightIds = { ...
    'Sun-mesh', ...
    'Sky-mesh', ...
    };
metadata = WriteMetadata(modelName, objectBox, lightBox, lightExcludeBox, materialIds, lightIds);
readMetadata = ReadMetadata(modelName);
assert(isequal(metadata, readMetadata))

%% CheckerBoard base scene
modelName = 'CheckerBoard';
objectBox = [-3 3; -3 3; 1 3];
lightBox = [-20 20; -20 20; 0 20];
lightExcludeBox = [-10 10; -10 10; 0 12];
modelPath = fullfile(repository, 'BaseScenes', 'Models', 'CheckerBoard.dae');
materialIds = GetSceneElementIds(modelPath, '\w+-material$');
lightIds = { ...
    'TopLeftLight-mesh', ...
    'RightLight-mesh', ...
    'BottomLight-mesh', ...
    };
metadata = WriteMetadata(modelName, objectBox, lightBox, lightExcludeBox, materialIds, lightIds);
readMetadata = ReadMetadata(modelName);
assert(isequal(metadata, readMetadata))

%% Library base scene
modelName = 'Library';
objectBox = [-2.2 2.5; -1.5 7; -1.2 2.3];
lightBox = [-10 7; -20 20; -1.2 9];
lightExcludeBox = [-3 3; -8 8; -1.2 5];
modelPath = fullfile(repository, 'BaseScenes', 'Models', 'Library.dae');
materialIds = GetSceneElementIds(modelPath, '\w+-material$');
lightIds = { ...
    'AreaLight01-mesh', ...
    'AreaLight02-mesh', ...
    };
metadata = WriteMetadata(modelName, objectBox, lightBox, lightExcludeBox, materialIds, lightIds);
readMetadata = ReadMetadata(modelName);
assert(isequal(metadata, readMetadata))

%% Library base scene
modelName = 'TableChairs';
objectBox = [-13 5; -5 15; 1 10];
lightBox = [-14 15; -15 15; 1 10];
lightExcludeBox = [-13 15; -14 15; 1 10];
modelPath = fullfile(repository, 'BaseScenes', 'Models', 'TableChairs.dae');
materialIds = GetSceneElementIds(modelPath, '\w+-material$');
lightIds = { ...
    'WindowAreaLight-mesh', ...
    'DoorAreaLight-mesh', ...
    'InsideAreaLight-mesh', ...
    };
metadata = WriteMetadata(modelName, objectBox, lightBox, lightExcludeBox, materialIds, lightIds);
readMetadata = ReadMetadata(modelName);
assert(isequal(metadata, readMetadata))

%% Mill base scene
modelName = 'Mill';
objectBox = [-15 0; -10 0; 0 10];
lightBox = [-20 0; -10 10; 10 20];
lightExcludeBox = [-20 -20; -10 -10; 10 10];
modelPath = fullfile(repository, 'BaseScenes', 'Models', 'Mill.dae');
materialIds = GetSceneElementIds(modelPath, '\w+-material$');
lightIds = { ...
    'SkyLight-mesh', ...
    'SunLight-mesh', ...
    };
metadata = WriteMetadata(modelName, objectBox, lightBox, lightExcludeBox, materialIds, lightIds);
readMetadata = ReadMetadata(modelName);
assert(isequal(metadata, readMetadata))

%% Barrel object
modelName = 'Barrel';
modelPath = fullfile(repository, 'Objects', 'Models', 'Barrel.dae');
materialIds = GetSceneElementIds(modelPath, '\w+-material$');
metadata = WriteMetadata(modelName, [], [], [], materialIds);
readMetadata = ReadMetadata(modelName);
assert(isequal(metadata, readMetadata))

%% ChampagneBottle object
modelName = 'ChampagneBottle';
modelPath = fullfile(repository, 'Objects', 'Models', 'ChampagneBottle.dae');
materialIds = GetSceneElementIds(modelPath, '\w+-material$');
metadata = WriteMetadata(modelName, [], [], [], materialIds);
readMetadata = ReadMetadata(modelName);
assert(isequal(metadata, readMetadata))

%% RingToy object
modelName = 'RingToy';
modelPath = fullfile(repository, 'Objects', 'Models', 'RingToy.dae');
materialIds = GetSceneElementIds(modelPath, '\w+-material$');
metadata = WriteMetadata(modelName, [], [], [], materialIds);
readMetadata = ReadMetadata(modelName);
assert(isequal(metadata, readMetadata))

%% Xylophone object
modelName = 'Xylophone';
modelPath = fullfile(repository, 'Objects', 'Models', 'Xylophone.dae');
materialIds = GetSceneElementIds(modelPath, '\w+-material$');
metadata = WriteMetadata(modelName, [], [], [], materialIds);
readMetadata = ReadMetadata(modelName);
assert(isequal(metadata, readMetadata))

%% Camera Flash object
modelName = 'CameraFlash';
modelPath = fullfile(repository, 'Objects', 'Models', 'CameraFlash.dae');
materialIds = GetSceneElementIds(modelPath, '\w+-material$');
lightIds = GetSceneElementIds(modelPath, '\w+-mesh$');
metadata = WriteMetadata(modelName, [], [], [], materialIds, lightIds);
readMetadata = ReadMetadata(modelName);
assert(isequal(metadata, readMetadata))

%% Big Ball light
modelName = 'BigBall';
modelPath = fullfile(repository, 'Objects', 'Models', 'BigBall.dae');
materialIds = GetSceneElementIds(modelPath, '\w+-material$');
lightIds = GetSceneElementIds(modelPath, '\w+-mesh$');
metadata = WriteMetadata(modelName, [], [], [], materialIds, lightIds);
readMetadata = ReadMetadata(modelName);
assert(isequal(metadata, readMetadata))

%% Snmall Ball light
modelName = 'SmallBall';
modelPath = fullfile(repository, 'Objects', 'Models', 'SmallBall.dae');
materialIds = GetSceneElementIds(modelPath, '\w+-material$');
lightIds = GetSceneElementIds(modelPath, '\w+-mesh$');
metadata = WriteMetadata(modelName, [], [], [], materialIds, lightIds);
readMetadata = ReadMetadata(modelName);
assert(isequal(metadata, readMetadata))

%% Panel light
modelName = 'Panel';
modelPath = fullfile(repository, 'Objects', 'Models', 'Panel.dae');
materialIds = GetSceneElementIds(modelPath, '\w+-material$');
lightIds = GetSceneElementIds(modelPath, '\w+-mesh$');
metadata = WriteMetadata(modelName, [], [], [], materialIds, lightIds);
readMetadata = ReadMetadata(modelName);
assert(isequal(metadata, readMetadata))
