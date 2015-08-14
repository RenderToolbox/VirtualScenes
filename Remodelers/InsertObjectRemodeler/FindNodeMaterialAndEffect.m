%% Look for the material and effect references contained in a Collada node.
%   @param objectIdMap for a Collada file, as from ReadSceneDOM()
%   @param nodeId id for one of the Collada <node> elements
%
% @details
% Used internally by the InserteObjectRemodeler.  Starting from the <node>
% element identified by @a nodeId, looks for a reference to a material
% element.  If there is at least one material reference, takes the first
% one.  Then from the material element, looks for a reference to an effect
% element.
%
% @details
% If found, returns the id of the material element and the id of the effect
% element that were referenced from the <node> element with id @a nodeId.
%
% @details
% Usage:
%   [materialId, effectId] = FindNodeMaterialAndEffect(objectIdMap, nodeId)
%
% @ingroup InsertObjectRemodeler
function [materialId, effectId] = FindNodeMaterialAndEffect(objectIdMap, nodeId)

% find node materials
materialsPath = [nodeId ':instance_geometry:bind_material:technique_common'];
materialsElement = SearchScene(objectIdMap, materialsPath);
materialReferences = GetElementChildren(materialsElement, 'instance_material');
if isempty(materialReferences)
    materialId = [];
    effectId = [];
    return;
end

% take the first material found
firstMaterial = materialReferences{1};
materialAttribute = GetElementAttributes(firstMaterial, 'target');
materialId = char(materialAttribute.getTextContent());
materialId = materialId(materialId ~= '#');

% get the effect referenced by the material
effectPath = [materialId ':instance_effect.url'];
effectId = GetSceneValue(objectIdMap, effectPath);
if (isempty(effectId))
    materialId = [];
    effectId = [];
    return;
end
effectId = effectId(effectId ~= '#');
