%% Analyze the given image for some spatial statistics.
%   @param rgb 3-channel rgb representation of an image
%   @param lum 1-channel luminance representation of the same image
%   @param lms 3-channel LMS representation of the same image
%   @param corrBinEdges bins to use for two-point correlation
%   @param samplesPerCorrBin samples to use for two-point correlation analysis
%   @param histCenters bins to use for luminance histograms
%   @param doPlot whether to make a figure, or just return reduction stats
%
% @details
% Compute some arbitrary but intereseting spatial variation statistics for
% the given image.  @a rgb, @a lum, and @a lms, should all be
% representations of the same image.
%
% @details
% Makes a figure with the given images, a histogram of lum the values, and
% six two-point correlation plots for each of the L, M, and S image planes
% and their crosses.
%
% @details
% Returns a struct with some "reduction" statistics about the image
% including the mean and std of the lum values and the mean and std from
% each two-point correlation analysis.  The struct field names will
% indicate which analysis the statistics come from.  For example, "lum"
% (luminance), "SS" (LMS S vs S) and "SM" (LMS S vs M).
%
% @details
% Also returns the handle of the figure used for plotting, if any.
%
% @details
% Usage:
%   [reductions, fig] = AnalyzeSpatialStats(rgb, lum, lms, corrBinEdges, samplesPerCorrBin, doPlot)
function [reductions, fig] = AnalyzeSpatialStats(rgb, lum, lms, corrBinEdges, samplesPerCorrBin, histCenters, doPlot)

fig = [];

s = size(rgb);
diagonal = sqrt(s(1)*s(1) + s(2)*s(2));

if nargin < 4 || isempty(corrBinEdges)
    corrBinEdges = 0:5:diagonal/2;
end

if nargin < 5 || isempty(samplesPerCorrBin)
    samplesPerCorrBin = 1000;
end

if nargin < 6 || isempty(histCenters)
    histCenters = linspace(0, 5, 100);
end

if nargin < 7 || isempty(doPlot)
    doPlot = true;
end


%% Always calculate the reductions.
lum = lum ./ mean(lum(:));
lumHist = hist(lum(:), histCenters);
reductions.lumHist = calculateReductions(lumHist ./ mean(lumHist), nan, nan, histCenters, ...
    'luminance / mean', 'count / mean', 'luminance histogram');

twoPointLow = -0.2;
twoPointHigh = 1.0;
L = lms(:,:,1);
M = lms(:,:,2);
S = lms(:,:,3);
reductions.LL = calculateReductions(TwoPointCorrelationDistribution(L, L, corrBinEdges, samplesPerCorrBin), twoPointLow, twoPointHigh, corrBinEdges(2:end), ...
    'distance', '2-point corr.', 'L x L');
reductions.LS = calculateReductions(TwoPointCorrelationDistribution(L, S, corrBinEdges, samplesPerCorrBin), twoPointLow, twoPointHigh, corrBinEdges(2:end), ...
    'distance', '2-point corr.', 'L x S');
reductions.SS = calculateReductions(TwoPointCorrelationDistribution(S, S, corrBinEdges, samplesPerCorrBin), twoPointLow, twoPointHigh, corrBinEdges(2:end), ...
    'distance', '2-point corr.', 'S x S');
reductions.LM = calculateReductions(TwoPointCorrelationDistribution(L, M, corrBinEdges, samplesPerCorrBin), twoPointLow, twoPointHigh, corrBinEdges(2:end), ...
    'distance', '2-point corr.', 'L x M');
reductions.MM = calculateReductions(TwoPointCorrelationDistribution(M, M, corrBinEdges, samplesPerCorrBin), twoPointLow, twoPointHigh, corrBinEdges(2:end), ...
    'distance', '2-point corr.', 'M x M');
reductions.MS = calculateReductions(TwoPointCorrelationDistribution(M, S, corrBinEdges, samplesPerCorrBin), twoPointLow, twoPointHigh, corrBinEdges(2:end), ...
    'distance', '2-point corr.', 'M x S');

if ~doPlot
    return;
end

%% Plot a summary.
fig = figure();

subplot(4,3,1);
imshow(toneMapAndScale(rgb));
title('rgb')

subplot(4,3,2);
imshow(toneMapAndScale(lum));
title('luminance')

subplot(4,3,3);
xCoords = reductions.lumHist.xCoords;
bar(xCoords, reductions.lumHist.raw);
xlim(xCoords([1 numel(xCoords)]));
title(reductions.lumHist.titleName)
ylabel(reductions.lumHist.yName)
xlabel(reductions.lumHist.xName)

subplot(4,3,4);
mappedLms = toneMapAndScale(lms);
imshow(mappedLms(:,:,1));
title('LMS L')

subplot(4,3,5);
imshow(mappedLms(:,:,2));
title('LMS M')

subplot(4,3,6);
imshow(mappedLms(:,:,3));
title('LMS S')

reductionNames = {'LL', 'LS', 'SS', 'LM', 'MM', 'MS'};
for ii = 1:numel(reductionNames)
    name = reductionNames{ii};
    r = reductions.(name);
    
    subplot(4,3,6+ii);
    plot(r.xCoords, r.raw);
    ylim([r.low, r.high]);
    title(r.titleName);
    ylabel(r.yName);
    xlabel(r.xName);
end


% calculate reduction statis for a matrix, put them in a struct
function r = calculateReductions(x, low, high, xCoords, xName, yName, titleName)
r.raw = x;
r.xCoords = xCoords;

r.low = low;
r.high = high;
r.mean = mean(x(:));
r.std = std(x(:));

r.xName = xName;
r.yName = yName;
r.titleName = titleName;

% do simple tone mapping and scaling vor visualization
function x = toneMapAndScale(x)
xMean = mean(x(:));
xClip = 5 * xMean;
x = x ./ xClip;
x(x > 1) = 1;