%% Render the CubanSphere with a texture and get Albedo at each pixel.

%% Choose example files, make sure they're on the Matlab path.
clear;
clc

parentSceneFile = 'CubanSphere.dae';
conditionsFile = 'CubanSphereTexturedConditions.txt';
mappingsFile = 'CubanSphereTexturedMappings.txt';

%% Choose batch renderer options.
hints.whichConditions = 7;
hints.imageWidth = 320;
hints.imageHeight = 240;

hints.renderer = 'Mitsuba';

hints.recipeName = mfilename();
ChangeToWorkingFolder(hints);

%% Render with Mitsuba.
nativeSceneFiles = MakeSceneFiles( ...
    parentSceneFile, conditionsFile, mappingsFile, hints);

radianceDataFiles = BatchRender(nativeSceneFiles, hints);
radianceData = load(radianceDataFiles{1});
spectralRadiance = radianceData.multispectralImage;

%% Render again to get albedo factoid.
sceneFile = nativeSceneFiles{1}.mitsubaFile;
factoids = {'albedo'};
mitsuba = getpref('Mitsuba');
[status, result, newScene, exrOutput, factoidOutput] = ...
    RenderMitsubaFactoids( ...
    sceneFile, [], [], [], factoids, 'spectrum', hints, mitsuba);

[wls, S, order] = GetWlsFromSliceNames(factoidOutput.albedo.channels);
spectralAlbedo = factoidOutput.albedo.data(:,:,order);

%% Compute the "illumination" image.
spectralIllumination = spectralRadiance ./ spectralAlbedo;
spectralIllumination(~isfinite(spectralIllumination)) = 0;

toneMapFactor = 10;
isScale = true;

rgbIllumination = MultispectralToSRGB( ...
    spectralIllumination, S, toneMapFactor, isScale);

rgbRadiance = MultispectralToSRGB( ...
    spectralRadiance, radianceData.S, toneMapFactor, isScale);

rgbAlbedo = MultispectralToSRGB( ...
    spectralAlbedo, S, toneMapFactor, isScale);

%% Take a look.
subplot(2,2,1)
imshow(uint8(rgbRadiance));
title('radiance')

subplot(2,2,2)
imshow(uint8(rgbAlbedo));
title('albedo')

subplot(2,2,3)
imshow(uint8(rgbIllumination));
title('illumination')
