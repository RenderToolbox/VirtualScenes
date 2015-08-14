% Informal test of new TwoPointCorrelationDistribution()

clear
clc

%% Get some images.
naturalImages = '/Users/ben/Documents/Projects/UPennNaturalImages/tofu.psych.upenn.edu/zip_nxlhtvdlbb/cd16A';

imageFileRoad = fullfile(naturalImages, 'DSC_0001_LUM.mat');
imageDataRoad = load(imageFileRoad);
imageRoad = imageDataRoad.LUM_Image;

imageFileFence = fullfile(naturalImages, 'DSC_0003_LUM.mat');
imageDataFence = load(imageFileFence);
imageFence = imageDataFence.LUM_Image;

nElements = numel(imageRoad);
imageRoadScramble = zeros(size(imageRoad));
imageRoadScramble(1:nElements) = imageRoad(randperm(nElements));

imageFenceScramble = zeros(size(imageFence));
imageFenceScramble(1:nElements) = imageFence(randperm(nElements));

%% Choose some analysis and plot params.
binEdges = 0:5:200;
samplesPerBin = 5000;

nRows = 5;

set(gcf(), 'Position', [100 100 1000 1000]);
fontSize = 16;

%% Road vs Road.
subplot(nRows, 2, 1)
imshow(imageRoad, [0, max(imageRoad(:))])
title('road');
set(gca(), 'FontSize', fontSize);

subplot(nRows, 2, 2)
[inCorrelations, outCorrelations, nIn, binEdges] = ...
    TwoPointCorrelationDistribution(imageRoad, imageRoad, binEdges, samplesPerBin);
binTops = binEdges(2:end);
plot(binTops, inCorrelations, binTops, outCorrelations);
ylim([-0.2, 1])
title('road vs road');
set(gca(), 'YGrid', 'on', 'FontSize', fontSize);

%% Fence vs Fence.
subplot(nRows, 2, 3)
imshow(imageFence, [0, max(imageFence(:))])
title('fence')
set(gca(), 'FontSize', fontSize);

subplot(nRows, 2, 4)
[inCorrelations, outCorrelations, nIn, binEdges] = ...
    TwoPointCorrelationDistribution(imageFence, imageFence, binEdges, samplesPerBin);
binTops = binEdges(2:end);
plot(binTops, inCorrelations, binTops, outCorrelations);
ylim([-0.2, 1])
title('fence vs fence');
set(gca(), 'YGrid', 'on', 'FontSize', fontSize);

%% Road vs Fence.
subplot(nRows, 2, 6)
[inCorrelations, outCorrelations, nIn, binEdges] = ...
    TwoPointCorrelationDistribution(imageRoad, imageFence, binEdges, samplesPerBin);
binTops = binEdges(2:end);
plot(binTops, inCorrelations, binTops, outCorrelations);
ylim([-0.2, 1])
title('road vs fence');
set(gca(), 'YGrid', 'on', 'FontSize', fontSize);

%% Road vs Road Scramble.
subplot(nRows, 2, 7)
imshow(imageRoadScramble, [0, max(imageRoadScramble(:))])
title('road scramble')
set(gca(), 'FontSize', fontSize);

subplot(nRows, 2, 8)
[inCorrelations, outCorrelations, nIn, binEdges] = ...
    TwoPointCorrelationDistribution(imageRoad, imageRoadScramble, binEdges, samplesPerBin);
binTops = binEdges(2:end);
plot(binTops, inCorrelations, binTops, outCorrelations);
ylim([-0.2, 1])
title('road vs road scramble');
set(gca(), 'YGrid', 'on');
set(gca(), 'YGrid', 'on', 'FontSize', fontSize);

%% Fence Scramble vs Road Scramble.
subplot(nRows, 2, 9)
imshow(imageFenceScramble, [0, max(imageFenceScramble(:))])
title('fence scramble')
set(gca(), 'FontSize', fontSize);

subplot(nRows, 2, 10)
[inCorrelations, outCorrelations, nIn, binEdges] = ...
    TwoPointCorrelationDistribution(imageRoad, imageRoadScramble, binEdges, samplesPerBin);
binTops = binEdges(2:end);
plot(binTops, inCorrelations, binTops, outCorrelations);
ylim([-0.2, 1])
title('fence scramble vs road scramble');
set(gca(), 'YGrid', 'on');
set(gca(), 'YGrid', 'on', 'FontSize', fontSize);
