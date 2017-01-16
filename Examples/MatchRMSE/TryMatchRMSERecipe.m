%% Do some paramter sweeps and match up renderings by RMSE.
%
% This script starts with a Ward Land recipe and does several rendering
% sweeps over different parameters in the 3D scene.  It computes the RMSE
% for each rendering in the sweep relative to a reference, then compares
% renderings from different parameter sweeps that came out with the same
% RMSE.
%
% For some more explanation and images, see 
%   https://github.com/DavidBrainard/RenderToolboxDevelop/wiki/Matching-RMSE-in-Ward-Land
%

clear;
clc;

wardLandArchive = '/Users/ben/Documents/Projects/RenderToolboxDevelop/VirtualScenesToolbox/Examples/MatchRMSE/Recipes/WardLand-05.zip';
matchRMSEMappings = '/Users/ben/Documents/Projects/RenderToolboxDevelop/VirtualScenesToolbox/Examples/MatchRMSE/Recipes/WardLand-05-MatchRMSEMappings.txt';

hints.renderer = 'Mitsuba';
hints.imageWidth = 640/4;
hints.imageHeight = 480/4;
hints.workingFolder = getpref('VirtualScenes', 'workingFolder');

nSteps = 20;
toneMapFactor = 100;

%% Run the original recipe far enough to obtain object pixel masks.
originalRecipe = UnpackRecipe(wardLandArchive, hints);
originalRecipe.input.hints.renderer = hints.renderer;
originalRecipe.input.hints.workingFolder = hints.workingFolder;
originalRecipe.input.hints.imageWidth = hints.imageWidth;
originalRecipe.input.hints.imageHeight = hints.imageHeight;

originalRecipe = ExecuteRecipe(originalRecipe, 1:3);

%% Prepare a "matchRmse" recipe based on the original recipe.
matchRmseRecipe = BuildMatchRMSERecipe(wardLandArchive, matchRMSEMappings, hints);

working = rtbWorkingFolder('folder','', 'hints', matchRmseRecipe.input.hints);
resources = rtbWorkingFolder('folder','resources', 'hints', matchRmseRecipe.input.hints);
images = rtbWorkingFolder('folder','images', 'rendererSpecific', true, 'hints', matchRmseRecipe.input.hints);
renderings = rtbWorkingFolder('folder', 'renderings',  'rendererSpecific', true, 'hints', matchRmseRecipe.input.hints);

%% Run a parameter sweep for object reflectance.
refSweepName = 'reflectance';
paramName = 'inserted-object-diffuse-1';
spectrumA = ResolveFilePath('mccBabel-14.spd', working);
spectrumB = ResolveFilePath('mccBabel-19.spd', working);

[spdFiles, refImageNames, refLambdas] = BuildSpectrumSweep( ...
    refSweepName, spectrumA.absolutePath, spectrumB.absolutePath, nSteps, resources);
recipe = BuildSweepConditions(matchRmseRecipe, refSweepName, paramName, spdFiles, refImageNames);
recipe = ExecuteRecipe(recipe);

%% Run a parameter sweep for illumination.
illumSweepName = 'illumination';
paramName = 'base-light-illum-1';
spectrumA = ResolveFilePath('Sun.spd', working);
spectrumB = ResolveFilePath('Sky.spd', working);
scaleB = 10;

[spdFiles, illumImageNames, illumLambdas] = BuildSpectrumSweep( ...
    illumSweepName, spectrumA.absolutePath, spectrumB.absolutePath, nSteps, resources, scaleB);
recipe = BuildSweepConditions(matchRmseRecipe, illumSweepName, paramName, spdFiles, illumImageNames);
recipe = ExecuteRecipe(recipe);

%% Run a parameter sweep for camera position.
cameraSweepName = 'camera';
paramName = 'camera-position';
offsetA = [0 0 0];
offsetB = [1 1 1]*.5;

[offsets, cameraImageNames, cameraLambdas] = BuildVectorSweep( ...
    cameraSweepName, offsetA, offsetB, nSteps);
recipe = BuildSweepConditions(matchRmseRecipe, cameraSweepName, paramName, offsets, cameraImageNames);
recipe = ExecuteRecipe(recipe);

%% Run a parameter sweep for opject scale.
scaleSweepName = 'scale';
paramName = 'object-scale-1';
scaleA = [1.201800 1.511832 1.164367];
scaleB = scaleA*1.8;

[offsets, scaleImageNames, scaleLambdas] = BuildVectorSweep( ...
    scaleSweepName, scaleA, scaleB, nSteps);
recipe = BuildSweepConditions(matchRmseRecipe, scaleSweepName, paramName, offsets, scaleImageNames);
recipe = ExecuteRecipe(recipe);

%% Make a Big Montage to compare RMSEs.
outFile = fullfile(images, 'MatchedRMSEs.png');
inFiles = cell(nSteps, 4);
for ii = 1:nSteps
    inFiles{ii, 1} = fullfile(renderings, [refImageNames{ii} '.mat']);
    inFiles{ii, 2} = fullfile(renderings, [illumImageNames{ii} '.mat']);
    inFiles{ii, 3} = fullfile(renderings, [cameraImageNames{ii} '.mat']);
    inFiles{ii, 4} = fullfile(renderings, [scaleImageNames{ii} '.mat']);
end

[bigSrgb, bigRaw, bigScale] = MakeMontage(inFiles, outFile, toneMapFactor, true);

%% Plot RMSEs vs lambdas and a target RMSE.
useMask = false;
if useMask
    plotTitle = 'RMSE under mask';
    intrinsicsObjectIndex = 10;
    intrinsicsPixelMask = originalRecipe.processing.materialIndexMask == intrinsicsObjectIndex;
    targetRmse = 1.75e-3;
else
    plotTitle = 'RMSE global';
    intrinsicsPixelMask = [];
    targetRmse = 1.75e-3;
end

refRmses = ComputeSweepRMSE(recipe, refImageNames, intrinsicsPixelMask);
illumRmses = ComputeSweepRMSE(recipe, illumImageNames, intrinsicsPixelMask);
cameraRmses = ComputeSweepRMSE(recipe, cameraImageNames, intrinsicsPixelMask);
scaleRmses = ComputeSweepRMSE(recipe, scaleImageNames, intrinsicsPixelMask);

figure();
plot(refLambdas, refRmses, ...
    illumLambdas, illumRmses, ...
    cameraLambdas, cameraRmses, ...
    scaleLambdas, scaleRmses, ...
    'LineStyle', 'none', 'Marker', '.');
line([0 1], [1 1]*targetRmse, 'LineStyle', '--', 'Marker', 'none');
legend(refSweepName, illumSweepName, cameraSweepName, scaleSweepName, 'target');
ylabel(plotTitle);
xlabel('lambda');
set(gca(), ...
    'YLim', [0 0.01], ...
    'FontSize', 16);

%% Pick renderings closest to the target RMSE.
[m, refIndex] = min(abs(refRmses - targetRmse));
refRenderings = { ...
    fullfile(renderings, [refImageNames{1} '.mat']); ...
    fullfile(renderings, [refImageNames{refIndex} '.mat'])};
refImage = fullfile(images, [refImageNames{refIndex} '.png']);
refSrgb = MakeMontage(refRenderings, refImage, toneMapFactor, bigScale);

[m, illumIndex] = min(abs(illumRmses - targetRmse));
illumRenderings = { ...
    fullfile(renderings, [illumImageNames{1} '.mat']); ...
    fullfile(renderings, [illumImageNames{illumIndex} '.mat'])};
illumImage = fullfile(images, [illumImageNames{illumIndex} '.png']);
illumSrgb = MakeMontage(illumRenderings, illumImage, toneMapFactor, bigScale);

[m, cameraIndex] = min(abs(cameraRmses - targetRmse));
cameraRenderings = { ...
    fullfile(renderings, [cameraImageNames{1} '.mat']); ...
    fullfile(renderings, [cameraImageNames{cameraIndex} '.mat'])};
cameraImage = fullfile(images, [cameraImageNames{cameraIndex} '.png']);
cameraSrgb = MakeMontage(cameraRenderings, cameraImage, toneMapFactor, bigScale);

[m, scaleIndex] = min(abs(scaleRmses - targetRmse));
scaleRenderings = { ...
    fullfile(renderings, [scaleImageNames{1} '.mat']); ...
    fullfile(renderings, [scaleImageNames{scaleIndex} '.mat'])};
scaleImage = fullfile(images, [scaleImageNames{scaleIndex} '.png']);
scaleSrgb = MakeMontage(scaleRenderings, scaleImage, toneMapFactor, bigScale);

figure();

subplot(1,4,1);
imshow(uint8(refSrgb));
title(refSweepName)
xlabel(sprintf('%s = %0.5f\nlambda = %.2f', plotTitle, refRmses(refIndex), refLambdas(refIndex)));
set(gca(), ...
    'XTick', [], ...
    'YTick', [0.5, 1.5]*hints.imageHeight, ...
    'YTickLabel', {'reference', 'target'}, ...
    'Visible', 'on', ...
    'FontSize', 16);

subplot(1,4,2);
imshow(uint8(illumSrgb));
title(illumSweepName)
xlabel(sprintf('%s = %0.5f\nlambda = %.2f', plotTitle, illumRmses(illumIndex), illumLambdas(illumIndex)));
set(gca(), ...
    'FontSize', 16);

subplot(1,4,3);
imshow(uint8(cameraSrgb));
title(cameraSweepName)
xlabel(sprintf('%s = %0.5f\nlambda = %.2f', plotTitle, cameraRmses(cameraIndex), cameraLambdas(cameraIndex)));
set(gca(), ...
    'FontSize', 16);

subplot(1,4,4);
imshow(uint8(scaleSrgb));
title(scaleSweepName)
xlabel(sprintf('%s = %0.5f\nlambda = %.2f', plotTitle, scaleRmses(scaleIndex), scaleLambdas(scaleIndex)));
set(gca(), ...
    'FontSize', 16);

figPos = get(gcf(), 'Position');
figPos(3) = figPos(3)*2.5;
set(gcf(), 'Position', figPos);