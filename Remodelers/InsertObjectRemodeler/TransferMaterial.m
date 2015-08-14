%% Import a material from a Collada source document to a destination document
%   @param sourceIdMap for a Collada source document, as from ReadSceneDOM()
%   @param destinationIdMap for a Collada destination document, as from ReadSceneDOM()
%   @param materialId id for the material to import
%   @param idPrefix prefix to add to the node id in the destination document
%   @param nodeId for previously transferred scene node
%   @param geometryId for previously transferred geometry node
%
% @details
% Used internally by the InserteObjectRemodeler.  Copies the scene element
% with id @a materialId from the Collada document represented by @a
% sourceIdMap to the Collada document represented by @a destinationIdMap.
% To prevent naming conflicts, the copied element will have a new id, which
% includes the given @a idPrefix.
%
% @details
% The copied element will be a child of the <library_materials> element in
% the destination document.  The elements with id @a nodeId and @a
% geometryId will be updated to point to use the new id.
%
% @details
% Returns the id of the new material in the destination document, based on
% the given @a materialId and and @a idPrefix.
%
% @details
% Usage:
%   newId = TransferMaterial(sourceIdMap, destinationIdMap, materialId, idPrefix, nodeId, geometryId)
%
% @ingroup InsertObjectRemodeler
function newId = TransferMaterial(sourceIdMap, destinationIdMap, materialId, idPrefix, nodeId, geometryId)

% document and element that will reveice the geometry
docNode = destinationIdMap('document');
libraryMaterialsPath = 'document:COLLADA:library_materials';
libraryMaterials = SearchScene(destinationIdMap, libraryMaterialsPath);

% copy material to destination and rename it
newId = [idPrefix '-' materialId];
if ~destinationIdMap.isKey(newId)
    materialClone = docNode.importNode(sourceIdMap(materialId), true);
    libraryMaterials.appendChild(materialClone);
    destinationIdMap(newId) = materialClone;
end
idPath = [newId '.id'];
SetSceneValue(destinationIdMap, idPath, newId, true);

namePath = [newId '.name'];
materialName = GetSceneValue(destinationIdMap, namePath);
newMaterialName = [idPrefix '-' materialName];
SetSceneValue(destinationIdMap, namePath, newMaterialName, true);

% patch up multiple references to the material
refPath = [nodeId ':instance_geometry:bind_material:technique_common:instance_material.symbol'];
SetSceneValue(destinationIdMap, refPath, newId, true);
refPath = [nodeId ':instance_geometry:bind_material:technique_common:instance_material.target'];
SetSceneValue(destinationIdMap, refPath, ['#' newId], true);
refPath = [geometryId ':mesh:polylist.material'];
SetSceneValue(destinationIdMap, refPath, newId, true);
