%% Import an effect from a Collada source document and make it matte.
%   @param sourceIdMap for a Collada source document, as from ReadSceneDOM()
%   @param destinationIdMap for a Collada destination document, as from ReadSceneDOM()
%   @param effectId id for the effect to import
%   @param idPrefix prefix to add to the node id in the destination document
%   @param materialId id for a previously transferred material
%
% @details
% Used internally by the InserteObjectRemodeler.  Copies the scene element
% with id @a effectId from the Collada document represented by @a
% sourceIdMap to the Collada document represented by @a destinationIdMap.
% To prevent naming conflicts, the copied element will have a new id, which
% includes the given @a idPrefix.
%
% @details
% The copied element will be a child of the <library_effects> element in
% the destination document.  The element with id @a materialId will be
% updated to point to use the new id.
%
% @details
% The @a effectId element will only be shallow-copied into the destination
% document.  Its type will be automatically changed to matte / Lambertian
% and it will have a default red RGB reflectance.
%
% @details
% Returns the id of the new effect in the destination document, based on
% the given @a effectId and and @a idPrefix.
%
% @details
% Usage:
%   newId = TransferEffectAsMatte(sourceIdMap, destinationIdMap, effectId, idPrefix, materialId)
%
% @ingroup InsertObjectRemodeler
function newId = TransferEffectAsMatte(sourceIdMap, destinationIdMap, effectId, idPrefix, materialId)

% document and element that will reveice the geometry
docNode = destinationIdMap('document');
libraryEffectsPath = 'document:COLLADA:library_effects';
libraryEffects = SearchScene(destinationIdMap, libraryEffectsPath);

% copy effect to destination and rename it
newId = [idPrefix '-' effectId];
if ~destinationIdMap.isKey(newId)
    effectClone = docNode.importNode(sourceIdMap(effectId), false);
    libraryEffects.appendChild(effectClone);
    destinationIdMap(newId) = effectClone;
    
    % make it a basic Lambertian/matte effect
    profile = CreateElementChild(effectClone, 'profile_COMMON');
    technique = CreateElementChild(profile, 'technique');
    technique.setAttribute('sid', 'common');
    lambert = CreateElementChild(technique, 'lambert');
    diffuse = CreateElementChild(lambert, 'diffuse');
    colorElement = CreateElementChild(diffuse, 'color');
    colorElement.setAttribute('sid', 'diffuse');
    colorElement.setTextContent('1 0 0');
end
idPath = [newId '.id'];
SetSceneValue(destinationIdMap, idPath, newId, true);
refPath = [materialId ':instance_effect.url'];
SetSceneValue(destinationIdMap, refPath, ['#' newId], true);
