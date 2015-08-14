%% Set up machine-specific Virtual Scenes configuration
%
% This script is intended as a template only.  You should make a copy of
% this script and save it in a folder separate from Virtual Scenes.  You
% should customize that copy with values that are specific to your machine.
%
% The goal of this script is to set Matlab preference values that
% you want to use for your machine.  These include file paths where
% Virtual Scenes should look for BaseScenes, Objects, and Lights, image
% processing default parameters, and where to write ouptut files.
%
% When you first install Virtual Scenes, you should copy this script,
% customize it, and run it.  You can run it again, any time you want to
% make sure your Virtual Scenes preferences are correct.
%
% @ingroup VirtualScenes

% clear out any old preferences
prefName = 'VirtualScenes';
if ispref(prefName)
    rmpref(prefName);
end

% 3D model locations
repository = fullfile(VirtualScenesRoot(), 'ModelRepository');
setpref(prefName, 'modelRepository', repository);

% where to save recipe archives
setpref(prefName, 'recipesFolder', ...
    fullfile(GetUserFolder(), 'virtual-scenes', 'recipe-archives'));

% where to put the RenderToolbox3 working folder
setpref(prefName, 'workingFolder', ...
    fullfile(GetUserFolder(), 'virtual-scenes', 'working'));

% image processing defaults
setpref(prefName, 'toneMapFactor', 100);
setpref(prefName, 'toneMapScale', true);
setpref(prefName, 'pixelThreshold', 0.01);
setpref(prefName, 'filterWidth', 7);
setpref(prefName, 'lmsSensitivities', 'T_cones_ss2');
setpref(prefName, 'dklSensitivities', 'T_CIE_Y2');

% scaling for large montages
setpref(prefName, 'montageScaleFactor', 1);
setpref(prefName, 'montageScaleMethod', 'lanczos3');

% alternate RGB version of Mitsuba
setpref(prefName, 'rgbMitsubaApp', '/Applications/Mitsuba-RGB.app');

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

%% Typical Mappings used to configure PBRT
integratorId = 'integrator';
samplerId = 'sampler';
configs.PBRT.ids = {integratorId, samplerId};

% PBRT "full" rendering config
fullIntegrator = BuildDesription('SurfaceIntegrator', 'path', ...
    {'maxdepth'}, ...
    {'1'}, ...
    {'integer'});
fullSampler = BuildDesription('Sampler', 'lowdiscrepancy', ...
    {'pixelsamples'}, ...
    {'8'}, ...
    {'integer'});
configs.PBRT.full.descriptions = {fullIntegrator, fullSampler};
configs.PBRT.full.blockName = 'PBRT';

% Mitsuba "quick" rendering config
quickIntegrator = BuildDesription('SurfaceIntegrator', 'directlighting', ...
    {'maxdepth'}, ...
    {'1'}, ...
    {'integer'});
quickSampler = BuildDesription('Sampler', 'lowdiscrepancy', ...
    {'pixelsamples'}, ...
    {'8'}, ...
    {'integer'});
configs.PBRT.quick.descriptions = {quickIntegrator, quickSampler};
configs.PBRT.quick.blockName = 'PBRT';

setpref(prefName, 'rendererConfigs', configs);
