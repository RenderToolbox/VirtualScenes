%% Import a scene node a Collada source document to a destination document
%   @param sourceIdMap for a Collada source document, as from ReadSceneDOM()
%   @param destinationIdMap for a Collada destination document, as from ReadSceneDOM()
%   @param nodeId id for the scene node element to import
%   @param idPrefix prefix to add to the node id in the destination document
%
% @details
% Used internally by the InserteObjectRemodeler.  Copies the scene element
% with id @a nodeId from the Collada document represented by @a sourceIdMap
% to the Collada document represented by @a destinationIdMap.  To prevent
% naming conflicts, the copied element will have a new id, which includes
% the given @a idPrefix.
%
% @details
% The copied element will be a child of the <visual_scene> element in the
% destination document.
%
% @details
% Returns the id of the new node in the destination document, based on the
% given @a nodeId and and @a idPrefix.
%
% @details
% Usage:
%   newId = TransferSceneNode(sourceIdMap, destinationIdMap, nodeId, idPrefix)
%
% @ingroup InsertObjectRemodeler
function newId = TransferSceneNode(sourceIdMap, destinationIdMap, nodeId, idPrefix)

% document and element that will reveice the new scene node
docNode = destinationIdMap('document');
visualScenePath = 'document:COLLADA:library_visual_scenes:visual_scene';
visualScene = SearchScene(destinationIdMap, visualScenePath);

% copy scene node to destination and rename it
element = sourceIdMap(nodeId);
newId = [idPrefix '-' nodeId];
if ~destinationIdMap.isKey(newId)
    nodeClone = docNode.importNode(element, true);
    visualScene.appendChild(nodeClone);
    destinationIdMap(newId) = nodeClone;
end
idPath = [newId '.id'];
SetSceneValue(destinationIdMap, idPath, newId, true);
