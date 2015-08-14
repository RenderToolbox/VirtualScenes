%% Make up some textured matte and Ward material descriptions.
%   @param whichImages optional indices to select specific images
%   @param hints struct of RenderToolbox3 options, see GetDefaultHints()
%
% @details
% Generates descriptions of various textured matte and ward materials for
% use with WardLand recipes.  The diffuse reflectances will be based on
% images in the VirtualScenesToolbox "Textures" folder.  See
% GetTextureImages().  The specular reflectances will be arbitrary.
%
% @details
% If @a hints is provided, copies any necessary texture image files to the
% working "resources" folder as indicated by @a hints.workingFolder. See
% GetWorkingFolder().
%
% @details
% Returns a cell array of texture ids that should be used with the returned
% texture descriptions.  Also returns a cell array of texture desriptions,
% as from BuildDesription(). Also returns a cell array of matte meterial
% descriptions with diffuse reflectance taken from the corresponding textures.
% Also returns a corresponding cell array or Ward material descriptions
% with the same diffuse reflectance and arbitrary specular reflectance.
% Finally, returns a cell array of corresponding file paths to texture
% image files.
%
% @details
% Usage:
%   [textureIDs, textures, matteMaterials, wardMaterials, filePaths] = GetWardLandTextureMaterials(whichImages, hints)
%
% @ingroup WardLand
function [textureIds, textures, matteMaterials, wardMaterials, filePaths] = GetWardLandTextureMaterials(whichImages, hints)

if nargin < 1 || isempty(whichImages)
    whichImages = [];
end

if nargin < 2 || isempty(hints)
    resources = [];
else
    resources = GetWorkingFolder('resources', false, hints);
end

% use color checker diffuse spectra
[textureImages, filePaths] = GetTextureImages(whichImages);
nImages = numel(textureImages);

% use arbitrary specular spectra
specShort = linspace(0, 0.5, nImages);
specLong = linspace(0.5, 0, nImages);

% build texture and material descriptions and copy resource files
textureIds = cell(1, nImages);
textures = cell(1, nImages);
matteMaterials = cell(1, nImages);
wardMaterials = cell(1, nImages);
for ii = 1:nImages
    % texture id
    textureIds{ii} = sprintf('texture%d', ii);
    
    % texture description
    textures{ii} = BuildDesription('spectrumTexture', 'bitmap', ...
        {'filename'}, ...
        textureImages(ii), ...
        {'string'});
    
    % matte materail
    matteMaterials{ii} = BuildDesription('material', 'matte', ...
        {'diffuseReflectance'}, ...
        textureIds(ii), ...
        {'texture'});
    
    % ward material
    specularSpectrum = sprintf('300:%.1f 800:%.1f', ...
        specShort(ii), specLong(ii));
    wardMaterials{ii} = BuildDesription('material', 'anisoward', ...
        {'diffuseReflectance', 'specularReflectance'}, ...
        {textureIds{ii}, specularSpectrum}, ...
        {'texture', 'spectrum'});
    
    % resource file
    if ~isempty(resources)
        copyfile(filePaths{ii}, resources);
    end
end
