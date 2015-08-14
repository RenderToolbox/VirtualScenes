%% Set up render toolbox config. for the docker envoronment.
%
% This script is will set up Matlab config to match the environment in our
% mistuba-docker Docker container.
%
% @ingroup VirtualScenes

disp('')
disp('Configuring RenderToolbox3 for Docker.')
disp('')

%% Set the userpath.
userFolder = '/home/rtb/MATLAB';
if ~exist(userFolder, 'dir')
    mkdir(userFolder);
end
userpath(userFolder);

%% RenderToolbox3.
InitializeRenderToolbox(true);

myFolder = fullfile(GetUserFolder(), 'render-toolbox');
setpref('RenderToolbox3', 'workingFolder', myFolder);

if ispref('Mitsuba')
    rmpref('Mitsuba');
end

adjustmentsFile = fullfile(RenderToolboxRoot(), ...
    'RendererPlugins', 'Mitsuba', 'MitsubaDefaultAdjustments.xml');

radiometricScaleFactor = 0.0795827427;

myMistubaExecutable = '/home/rtb/mitsuba-multi/mitsuba';
myMistubaImporter = '/home/rtb/mitsuba-multi/mtsimport';
myMistubaApp = '';

setpref('Mitsuba', 'adjustments', adjustmentsFile);
setpref('Mitsuba', 'radiometricScaleFactor', radiometricScaleFactor);
setpref('Mitsuba', 'app', myMistubaApp);
setpref('Mitsuba', 'executable', myMistubaExecutable);
setpref('Mitsuba', 'importer', myMistubaImporter);

%% Dynamic Library path.
setpref('RenderToolbox3', 'libPath', '/home/rtb/mitsuba-multi');

%% VirtualScenesToolbox.

prefName = 'VirtualScenes';
if ispref(prefName)
    rmpref(prefName);
end

repository = fullfile(VirtualScenesRoot(), 'ModelRepository');
setpref(prefName, 'modelRepository', repository);

setpref(prefName, 'recipesFolder', ...
    fullfile(GetUserFolder(), 'virtual-scenes', 'recipe-archives'));

setpref(prefName, 'workingFolder', ...
    fullfile(GetUserFolder(), 'virtual-scenes', 'working'));

setpref(prefName, 'toneMapFactor', 100);
setpref(prefName, 'toneMapScale', true);
setpref(prefName, 'pixelThreshold', 0.01);
setpref(prefName, 'filterWidth', 7);
setpref(prefName, 'lmsSensitivities', 'T_cones_ss2');
setpref(prefName, 'dklSensitivities', 'T_CIE_Y2');

setpref(prefName, 'montageScaleFactor', 1);
setpref(prefName, 'montageScaleMethod', 'lanczos3');

setpref(prefName, 'rgbMitsubaApp', '/home/rtb/mitsuba-rgb/mitsuba');

%% Typical Mappings used to configure Mitsuba
integratorId = 'integrator';
samplerId = 'Camera-camera_sampler';
configs.Mitsuba.ids = {integratorId, samplerId};

% Mitsuba "full" rendering config
fullIntegrator = BuildDesription('integrator', 'path', ...
    {'maxDepth'}, ...
    {'10'}, ...
    {'integer'});
fullSampler = BuildDesription('sampler', 'ldsampler', ...
    {'sampleCount'}, ...
    {'512'}, ...
    {'integer'});
configs.Mitsuba.full.descriptions = {fullIntegrator, fullSampler};
configs.Mitsuba.full.blockName = 'Mitsuba';

% Mitsuba "quick" rendering config
quickIntegrator = BuildDesription('integrator', 'direct', ...
    {'shadingSamples'}, ...
    {'32'}, ...
    {'integer'});
quickSampler = BuildDesription('sampler', 'ldsampler', ...
    {'sampleCount'}, ...
    {'32'}, ...
    {'integer'});
configs.Mitsuba.quick.descriptions = {quickIntegrator, quickSampler};
configs.Mitsuba.quick.blockName = 'Mitsuba';
