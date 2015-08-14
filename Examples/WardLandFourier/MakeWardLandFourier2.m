%% Locate WardLand renderings and do *more* spatial frequency analysis.
%
% This script performs spatial frequency analysis on luminance images from
% WardLand recipes.
%
% You should run this script after you've already executed some WardLand
% renderings, as with ExecuteWardLandReferenceRecipes.
%
% You can edit some parameters at the top of this script to change things
% like which recipe and renderer to get data for.
%
% @ingroup WardLand

%% Overall Setup.
clear;
clc;

% locate the renderings
hints.renderer = 'Mitsuba';
hints.workingFolder = getpref('VirtualScenes', 'workingFolder');

% for sRGB conversion
toneMapFactor = 100;
isScale = true;

% for frequency distribution analysis by rings
nBands = 25;

% for plotting
commonParams = {'LineWidth', 2};
lineParams = { ...
    {'Color', [1 0 0], commonParams{:}}, ...
    {'Color', [1 .5 0], commonParams{:}}, ...
    {'Color', [.75 0 0], commonParams{:}}, ...
    {'Color', [.75 .5 0], commonParams{:}}, ...
    {'Color', [1 1 1] * 0, commonParams{:}}, ...
    {'Color', [1 1 1] * .17, commonParams{:}}, ...
    {'Color', [1 1 1] * .33, commonParams{:}}, ...
    {'Color', [1 1 1] * .5, commonParams{:}}, ...
    };

%% Compare 4 natural images to 4 WardLand scenes.

% ward land scenes
hints.recipeName = 'Blobbies';
blobbiesStruct = WardLandRenderingFourierStruct(hints, 'ward', 'blobbies', toneMapFactor, isScale);

hints.recipeName = 'PlantAndBarrel';
plantStruct = WardLandRenderingFourierStruct(hints, 'ward', 'plant', toneMapFactor, isScale);

hints.recipeName = 'NearFarWarehouse';
warehouseStruct = WardLandRenderingFourierStruct(hints, 'ward', 'warehouse', toneMapFactor, isScale);

hints.recipeName = 'Mondrian';
mondrianStruct = WardLandRenderingFourierStruct(hints, 'ward', 'mondrian', toneMapFactor, isScale);

% natural images
cropSize = size(mondrianStruct.grayscale);

naturalImages = '/Users/ben/Documents/Projects/UPennNaturalImages/tofu.psych.upenn.edu/zip_nxlhtvdlbb/cd16A';
roadStruct = NaturalImageFourierStruct(naturalImages, 'DSC_0001', 'road', cropSize);
fenceStruct = NaturalImageFourierStruct(naturalImages, 'DSC_0003', 'fence', cropSize);

naturalImages = '/Users/ben/Documents/Projects/UPennNaturalImages/tofu.psych.upenn.edu/zip_nxlhtvdlbb/cd45A';
farStruct = NaturalImageFourierStruct(naturalImages, 'DSC_0003', 'mound far', cropSize);
nearStruct = NaturalImageFourierStruct(naturalImages, 'DSC_0069', 'mound near', cropSize);

% collect em all
naturalImageStructs = [ ...
    blobbiesStruct, ...
    plantStruct, ...
    warehouseStruct, ...
    mondrianStruct, ...
    roadStruct, ...
    fenceStruct, ...
    farStruct, ...
    nearStruct];

% analyze and plot
naturalImageStructs = AnalyzeFourierStruct(naturalImageStructs, nBands);
naturalImageStructs = PlotFourierStruct(naturalImageStructs, [], [], lineParams);
naturalImageStructs = SummarizeFourierStruct(naturalImageStructs, [], [], lineParams);

%% Compare 4 illumination and reflectance images.

imageName = 'diffuse-interp.png';

hints.recipeName = 'Blobbies';
blobbiesIllumStruct = WardLandImageFourierStruct(hints, 'illumination', imageName, 'blobbies illum');
blobbiesReflectStruct = WardLandImageFourierStruct(hints, 'reflectance', imageName, 'blobbies reflect');

hints.recipeName = 'PlantAndBarrel';
plantIllumStruct = WardLandImageFourierStruct(hints, 'illumination', imageName, 'plant illum');
plantReflectStruct = WardLandImageFourierStruct(hints, 'reflectance', imageName, 'plant reflect');

hints.recipeName = 'NearFarWarehouse';
warehouseIllumStruct = WardLandImageFourierStruct(hints, 'illumination', imageName, 'warehouse illum');
warehouseReflectStruct = WardLandImageFourierStruct(hints, 'reflectance', imageName, 'warehouse reflect');

hints.recipeName = 'Mondrian';
mondrianIllumStruct = WardLandImageFourierStruct(hints, 'illumination', imageName, 'mondrian illum');
mondrianReflectStruct = WardLandImageFourierStruct(hints, 'reflectance', imageName, 'mondrian reflect');

% collect em all
illumImageStructs = [ ...
    blobbiesIllumStruct, ...
    plantIllumStruct, ...
    warehouseIllumStruct, ...
    mondrianIllumStruct, ...
    blobbiesReflectStruct, ...
    plantReflectStruct, ...
    warehouseReflectStruct, ...
    mondrianReflectStruct];

% analyze and plot
illumImageStructs = AnalyzeFourierStruct(illumImageStructs, nBands);
illumImageStructs = PlotFourierStruct(illumImageStructs, [], [], lineParams);
illumImageStructs = SummarizeFourierStruct(illumImageStructs, [], [], lineParams);

%% Compare 4 DKL b-y and r-g images.

imageNameBY = 'diffuseReflectanceInterp-by.png';
imageNameRG = 'diffuseReflectanceInterp-rg.png';

hints.recipeName = 'Blobbies';
blobbiesBYStruct = WardLandImageFourierStruct(hints, 'dkl', imageNameBY, 'blobbies by');
blobbiesRGStruct = WardLandImageFourierStruct(hints, 'dkl', imageNameRG, 'blobbies rg');

hints.recipeName = 'PlantAndBarrel';
plantBYStruct = WardLandImageFourierStruct(hints, 'dkl', imageNameBY, 'plant by');
plantRGStruct = WardLandImageFourierStruct(hints, 'dkl', imageNameRG, 'plant rg');

hints.recipeName = 'NearFarWarehouse';
warehouseBYStruct = WardLandImageFourierStruct(hints, 'dkl', imageNameBY, 'warehouse by');
warehouseRGStruct = WardLandImageFourierStruct(hints, 'dkl', imageNameRG, 'warehouse rg');

hints.recipeName = 'Mondrian';
mondrianBYStruct = WardLandImageFourierStruct(hints, 'dkl', imageNameBY, 'mondrian by');
mondrianRGStruct = WardLandImageFourierStruct(hints, 'dkl', imageNameRG, 'mondrian rg');

% collect em all
dklImageStructs = [ ...
    blobbiesBYStruct, ...
    plantBYStruct, ...
    warehouseBYStruct, ...
    mondrianBYStruct, ...
    blobbiesRGStruct, ...
    plantRGStruct, ...
    warehouseRGStruct, ...
    mondrianRGStruct];

% analyze and plot
dklImageStructs = AnalyzeFourierStruct(dklImageStructs, nBands);
dklImageStructs = PlotFourierStruct(dklImageStructs, [], [], lineParams);
dklImageStructs = SummarizeFourierStruct(dklImageStructs, [], [], lineParams);
