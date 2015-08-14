%% Generate a batch of blobbies to insert into scenes.
%
% This produces new Blobbie 3D models in the Virtual Scenes Toolbox Model
% Repository and registers them with WriteMetadata().
%
% This has already been run and saved.  You don't need to run it again.
% But it's still here as an example of how to generate blobbies and how to
% register 3D models with WriteMetadata().
%

clear;
clc;

%% Configuration for the Blender-Python script.
blender = '/Applications/Blender-2.68a/blender.app/Contents/MacOS/blender';
blobbieScript = '/Users/ben/Documents/Projects/RenderToolboxDevelop/Blobbies/PythonScripts/IsolatedBlobbie.py';
toolboxDirectory = fullfile(RenderToolboxRoot(), 'Utilities', 'BlenderPython');
exportsDirectory = fullfile(getpref('VirtualScenes', 'modelRepository'), 'Objects', 'Models');
objectName = 'Blobbie';
blobbieSubdivisions = 6;

%% Unique parameter values for each blobbie.
nBlobbies = 5;

angleX = -pi + 2*pi * rand([1, nBlobbies]);
angleY = -pi + 2*pi * rand([1, nBlobbies]);
angleZ = -pi + 2*pi * rand([1, nBlobbies]);
frequencyX = -12 + 24 * rand([1, nBlobbies]);
frequencyY = -12 + 24 * rand([1, nBlobbies]);
frequencyZ = -12 + 24 * rand([1, nBlobbies]);
gainX = 5/1000 + 10/1000 * rand([1, nBlobbies]);
gainY = 5/1000 + 10/1000 * rand([1, nBlobbies]);
gainZ = 5/1000 + 10/1000 * rand([1, nBlobbies]);

%% Make the batch of blobbies.
for ii = 1:nBlobbies
    sceneName = sprintf('%s-%02d', objectName, ii);
    
    % execute Blender-Python script
    command = sprintf(['%s --background ', ...
        '--python %s -- ', ...
        '--toolboxDirectory %s ', ...
        '--exportsDirectory %s ', ...
        '--sceneName %s ', ...
        '--objectName %s ', ...
        '--blobbieSubdivisions %d ', ...
        '--angleX %f --angleY %f --angleZ %f ', ...
        '--frequencyX %f --frequencyY %f --frequencyZ %f ', ...
        '--gainX %f --gainY %f --gainZ %f'], ...
        blender, ...
        blobbieScript, ...
        toolboxDirectory, ...
        exportsDirectory, ...
        sceneName, ...
        objectName, ...
        blobbieSubdivisions, ...
        angleX(ii), angleY(ii), angleZ(ii), ...
        frequencyX(ii), frequencyY(ii), frequencyZ(ii), ...
        gainX(ii), gainY(ii), gainZ(ii));
    
    disp('command: ')
    disp(command)
    [status, result] = unix(command);
    disp('status: ')
    disp(status)
    disp('result: ')
    disp(result)
    
    % register metadata in Virtual Scenes repository
    modelPath = fullfile(exportsDirectory, [sceneName '.dae']);
    materialIds = GetSceneElementIds(modelPath);
    metadata = WriteMetadata(sceneName, [], [], [], materialIds);
    readMetadata = ReadMetadata(sceneName);
    assert(isequal(metadata, readMetadata))
end
