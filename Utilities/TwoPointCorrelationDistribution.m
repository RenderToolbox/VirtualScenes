%% Compute a two point correlation distribution for given 2D images.
%   @param imageA an m x n image matrix
%   @param imageB am m x n image matrix, may be same as @a imageA
%   @param binEdges bins for grouping pairs of points by distance
%   @param samplesPerBin how many correlation samples to take per bin
%   @param objectMask an m x n image identifying objects in @a imageA
%
% @details
% Computes a two point correlation distribution between @a imageA and @a
% imageB.  If image @a is equal to @a imageB, then this will indicate
% spatial variation within @a imageA itself.
%
% @details
% The distribution will be computed by choosing pairs of points, one in @a
% imageA and one in @a imageB.  Pairs will be grouped in bins according to
% their distance apart.  Within each bin, the correlation will be computed
% between the sequence of "A" pixel values and the sequence of "B" pixel
% values.
%
% @details
% By default, the distribution will be computed over 10 bins evenly spaced
% in the interval [0 d], where d is the half-diagonal of @a imageA.  If @a
% binEdges is provided, it must be an array of p+1 bin edges to use for p
% bins.
%
% @details
% By default, 100 point pairs will be sampled per bin.  If @a samplesPerBin
% is provided it may be a scalar number of samples to use for all bins
% instead.  Or, it may be an array of p sample counts to use, one for each
% bin described by @a binEdges.
%
% @a details
% Here is how the sampling strategy works for each bin:
%   - Choose the x-value value in @a imageA from a uniform distribution
%   based on the image width.
%   - Choose the y-value value in @a imageA from a uniform distribution
%   based on the image height.
%   - Choose a radius value based on the bin's edges.
%   - Choose an orientation value from a uniform distribution about the
%   unit circle.
%   - Compute the x-value and y-value in @a imageB based on the x-value and
%   y-value in @a imageA, displaced by the chosen radius and orientation.
%   - Clip the x-value and y-value in @a imageB so they don't exceed the
%   image boundaries.
%   .
%
% @details
% This sampling strategy is designed to obey exactly the specified @a
% binEdges and numbers of @a samplesPerBin.  It provides for uniform
% coverage of @a imageA.  As a practical efficiency, some of the points in
% @a imageB will be clipped to the image edges.  This means that @a
% imageB will be over-sampled near its edges.  This should only be
% significant when the point in @a imageA is close to an image edge,
% or when the distance between points is large (i.e. large values in @a
% binEdges).
%
% @details
% If @a objectMask is provided, it must be an m x n image matrix where the
% pixel values indicate the identities of objects "seen" in @a imageA.
% This will be used to distinguish between "in correlations", where the
% pair of sample points is contained within a single object, and "out
% correlations" where the pair of sample points spans two or more objects.
%
% @details
% If @a objectMask is omitted, all correlations will be treated as "in
% correlations".
%
% @details
% Returns an array of p "in correlation" values, one for each bin.  Also
% returns an corresponding array of p "out correlations".  Also returns an
% array of counts, how many of the @a samplesPerBin contributed to "in
% correlations" (the rest were "out").  Finally, returns an array of p+1
% bin edges which may be the same as the given @a binEdges.
%
% @details
% Usage:
%   [inCorrelations, outCorrelations, nIn, binEdges] = ...
%       TwoPointCorrelationDistribution(imageA, imageB, binEdges, samplesPerBin, objectMask)
%
% @ingroup Utilities
function [inCorrelations, outCorrelations, nIn, binEdges] = ...
    TwoPointCorrelationDistribution(imageA, imageB, binEdges, samplesPerBin, objectMask)

imageHeight = size(imageA, 1);
imageWidth = size(imageA, 2);

if nargin < 3 || isempty(binEdges)
    imageDiagonal = sqrt(imageHeight^2 + imageWidth^2);
    binEdges = linspace(0, imageDiagonal/2, 11);
end
nBins = numel(binEdges) - 1;

if nargin < 4 || isempty(samplesPerBin)
    samplesPerBin = 100 * ones(1, nBins);
elseif isscalar(samplesPerBin)
    samplesPerBin = samplesPerBin * ones(1, nBins);
end

if nargin < 5 || isempty(objectMask)
    objectMask = zeros(imageHeight, imageWidth);
end

inCorrelations = zeros(1, nBins);
outCorrelations = zeros(1, nBins);
nIn = zeros(1, nBins);
for ii = 1:nBins
    % basic bin info
    nSamples = samplesPerBin(ii);
    binLow = binEdges(ii);
    binHigh = binEdges(ii+1);
    binWidth = binHigh - binLow;
    
    % random samples each with 4 dof
    xA = imageWidth * rand(1, nSamples);
    yA = imageHeight * rand(1, nSamples);
    radius = binLow + binWidth * rand(1, nSamples);
    theta = 2 * pi() * rand(1, nSamples);
    
    % rough locations in imageB
    xB = xA + radius .* cos(theta);
    yB = yA + radius .* sin(theta);
    
    % clip imageB locations to image edges
    xB(xB > imageWidth) = imageWidth;
    xB(xB < 1) = 1;
    yB(yB > imageHeight) = imageHeight;
    yB(yB < 1) = 1;
    
    % round all the locations to indexes
    xA = ceil(xA);
    yA = ceil(yA);
    xB = ceil(xB);
    yB = ceil(yB);
    
    % get the pixel value sequenes for A and B
    crossSelectA = imageA(yA, xA);
    crossSelectB = imageB(yB, xB);
    diagonalIndices = 1:(nSamples+1):(nSamples^2);
    pixelsA = crossSelectA(diagonalIndices);
    pixelsB = crossSelectB(diagonalIndices);
    
    % get object identity sequences for A and B
    crossSelectA = objectMask(yA, xA);
    crossSelectB = objectMask(yB, xB);
    objectsA = crossSelectA(diagonalIndices);
    objectsB = crossSelectB(diagonalIndices);
    
    % separate sequences by "in" and "out"
    isIn = objectsA == objectsB;
    
    % compute "in" and "out" correlations
    inCorrelations(ii) = corr2(pixelsA(isIn), pixelsB(isIn));
    outCorrelations(ii) = corr2(pixelsA(~isIn), pixelsB(~isIn));
    nIn(ii) = sum(isIn);
end
