%% Make up some matte and Ward material descriptions.
%   @param hints struct of RenderToolbox3 options, see GetDefaultHints()
%
% @details
% Generates descriptions of various matte and ward materials for use with
% WardLand recipes.  The diffuse reflectances will be based on ColorChecker
% spectra.  See GetColorCheckerSpectra().  The specular reflectances will
% be arbitrary.
%
% @details
% If @a hints is provided, copies any necessary texture image files to the
% working "resources" folder as indicated by @a hints.workingFolder. See
% GetWorkingFolder().
%
% @details
% Returns a cell array of matte material descriptions, as from
% BuildDesription().  Also returns a cell array of ward material
% descriptions, with diffuse components corresponding to the returned matte
% materials.  Also returns a cell array of corresponding file paths to
% ColorChecker spd-files.
%
% @details
% Usage:
%   [matteMaterials, wardMaterials, filePaths] = GetWardLandMaterials(hints)
%
% @ingroup WardLand
function [matteMaterials, wardMaterials, filePaths] = GetWardLandMaterials(hints)

if nargin < 1 || isempty(hints)
    resources = [];
else
    resources = rtbWorkingFolder('folder','resources', 'hints', hints);
end

% use color checker diffuse spectra
[colorCheckerSpectra, filePaths] = GetColorCheckerSpectra();
nSpectra = numel(colorCheckerSpectra);

% use arbitrary specular spectra
specShort = linspace(0, 0.5, nSpectra);
specLong = linspace(0.5, 0, nSpectra);

% build material descriptions and copy resource files
matteMaterials = cell(1, nSpectra);
wardMaterials = cell(1, nSpectra);
for ii = 1:nSpectra
    % matte materail
    matteMaterials{ii} = BuildDesription('material', 'matte', ...
        {'diffuseReflectance'}, ...
        colorCheckerSpectra(ii), ...
        {'spectrum'});
    
    % ward material
    specularSpectrum = sprintf('300:%.1f 800:%.1f', ...
        specShort(ii), specLong(ii));
    wardMaterials{ii} = BuildDesription('material', 'anisoward', ...
        {'diffuseReflectance', 'specularReflectance'}, ...
        {colorCheckerSpectra{ii}, specularSpectrum}, ...
        {'spectrum', 'spectrum'});
    
    % resource file
    if ~isempty(resources)
        copyfile(filePaths{ii}, resources);
    end
end
