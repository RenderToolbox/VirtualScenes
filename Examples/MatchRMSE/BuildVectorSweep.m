%% Build a parameter sweep with interpolated vector elements.
%   @param sweepName name for output images
%   @param vectorA starting vector
%   @param vectorB ending vector
%   @param nSteps how many steps in the sweep
%
% @details
% Computes a parameter sweep starting from @a vectorA and ending with @a
% vectorB, ranging over @a nSteps steps.  Each returned vector will be a
% linear interpolateion between @a vectorA and @a vectorB.
%
% @details
% Returns a cell array of vectors interpolated between the given @a vectorA
% and @a vectorB.  Also returns a cell array of image names to associate
% with each returned vector.  Also returns a vector of "lambda" values
% ranging from 0-1, describing the progress through the sweep for each
% returned vector.
%
% @details
% Usage:
%   [vectors, imageNames, lambdas] = BuildVectorSweep(sweepName, vectorA, vectorB, nSteps)
%
% @ingroup MatchRMSE
function [vectors, imageNames, lambdas] = BuildVectorSweep(sweepName, vectorA, vectorB, nSteps)

% read in the original vectors
magsA = StringToVector(vectorA);
magsB = StringToVector(vectorB);

% compute several interpolated vectors
lambdas = linspace(0, 1, nSteps);
vectors = cell(nSteps, 1);
imageNames = cell(nSteps, 1);
for ii = 1:nSteps
    imageNames{ii} = sprintf('%s-%02d', sweepName, ii);
    interpMags = lambdas(ii) .* magsB + (1-lambdas(ii)) .* magsA;
    vectors{ii} = VectorToString(interpMags);
end
