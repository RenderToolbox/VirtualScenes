%% Import geometry from a Collada source document to a destination document
%   @param sourceIdMap for a Collada source document, as from ReadSceneDOM()
%   @param destinationIdMap for a Collada destination document, as from ReadSceneDOM()
%   @param geometryId id for the geometry to import
%   @param idPrefix prefix to add to the node id in the destination document
%   @param nodeId for previously transferred scene node
%
% @details
% Used internally by the InserteObjectRemodeler.  Copies the scene element
% with id @a geometryId from the Collada document represented by @a
% sourceIdMap to the Collada document represented by @a destinationIdMap.
% To prevent naming conflicts, the copied element will have a new id, which
% includes the given @a idPrefix.
%
% @details
% The copied element will be a child of the <library_geometries> element in
% the destination document.  The element with id @a nodeId will be updated
% to point to use the new id.
%
% @details
% Returns the id of the new geometry in the destination document, based on
% the given @a geometryId and and @a idPrefix.
%
% @details
% Usage:
%   newId = TransferGeometry(sourceIdMap, destinationIdMap, geometryId, idPrefix, nodeId)
%
% @ingroup InsertObjectRemodeler
function newId = TransferGeometry(sourceIdMap, destinationIdMap, geometryId, idPrefix, nodeId)

% document and element that will reveice the geometry
docNode = destinationIdMap('document');
libraryGeometriesPath = 'document:COLLADA:library_geometries';
libraryGeometries = SearchScene(destinationIdMap, libraryGeometriesPath);

% copy geometry to destination and rename it
newId = [idPrefix '-' geometryId];
if ~destinationIdMap.isKey(newId)
    geometryClone = docNode.importNode(sourceIdMap(geometryId), true);
    libraryGeometries.appendChild(geometryClone);
    destinationIdMap(newId) = geometryClone;
end
idPath = [newId '.id'];
SetSceneValue(destinationIdMap, idPath, newId, true);
refPath = [nodeId ':instance_geometry.url'];
SetSceneValue(destinationIdMap, refPath, ['#' newId], true);
