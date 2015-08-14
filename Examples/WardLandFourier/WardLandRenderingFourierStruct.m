%% Make a formatted "Fourier Struct" based on a WardLand rendering.
%   @param hints recipe.input.hints as returned from ExecuteManyWardLandRecipes()
%   @param conditionname WardLand condition name like "ward" or "boring"
%   @param structName optional name for the new Fourier Struct
%   @param toneMapFactor optional tone mapping passed to MultispectralToSRGB()
%   @param isScale optional gamma correction passed to MultispectralToSRGB()
%
% @details
% The given @a hints should be the recipe.input.hints from a WardLand
% recipe struct which has already been executed, as with
% ExecuteManyWardLandRecipes() or ExecuteWardLandReferenceRecipes().  This
% funciton will extract a rendering from the recipe and build a
% formatted "Fourier Struct" which can be analyzed with
% AnalyzeFourierStruct() and visualized with PlotFourierStruct().
%
% @details
% Returns a new "Fourier Struct" array based on the given @a hints and @a
% conditionName.
%
% @details
% Usage:
%   fourierStruct = WardLandRenderingFourierStruct(hints, conditionName, structName, toneMapFactor, isScale)
%
% @ingroup WardLand
function fourierStruct = WardLandRenderingFourierStruct(hints, conditionName, structName, toneMapFactor, isScale)

if nargin < 2 || isempty(conditionName)
    conditionName = 'ward';
end

if nargin < 3 || isempty(structName)
    structName = [hints.recipeName ' ' conditionName ' Lum'];
end

if nargin < 4 || isempty(toneMapFactor)
    toneMapFactor = 100;
end

if nargin < 5 || isempty(isScale)
    isScale = true;
end

renderings = GetWorkingFolder('renderings', true, hints);

fourierStruct.name = structName;
rendering = FindFiles(renderings, [conditionName '\.mat$']);
data = load(rendering{1});
[fourierStruct.rgb, xyz] = MultispectralToSRGB( ...
    data.multispectralImage, data.S, toneMapFactor, isScale);
fourierStruct.grayscale = xyz(:,:,2);
fourierStruct.results = [];
