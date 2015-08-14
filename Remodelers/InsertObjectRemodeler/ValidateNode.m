%% Should we insert the given node element from a Collada file?
%   @param objectIdMap for a Collada file, as from ReadSceneDOM()
%   @param nodeId id for one of the Collada <node> elements
%
% @details
% Used internally by the InserteObjectRemodeler.  Determines whether a
% Collada scene node should be taken from an Object model and inserted into
% a BaseScene mode.  The node must be a top-level node that points to a
% geometry element, and the geometry must have more than a few polygons (to
% exclude boring geometry like the floor and walls).
%
% @details
% Returns true, if the given @a nodeId is good for inserting.  Also returns
% the id of the geometry element that this node points to, if any.
%
% @details
% Usage:
%   [shouldInsert, geometryId] = ValidateNode(objectIdMap, nodeId)
%
% @ingroup InsertObjectRemodeler
function [shouldInsert, geometryId] = ValidateNode(objectIdMap, nodeId)

% is this a valid id?
if ~objectIdMap.isKey(nodeId)
    shouldInsert = false;
    geometryId = [];
    return;
end

% is this a top-level node?
element = objectIdMap(nodeId);
elementName = char(element.getNodeName);
if ~strcmp(elementName, 'node')
    shouldInsert = false;
    geometryId = [];
    return;
end

% is this a geometry node?
geometryPath = [nodeId ':instance_geometry.url'];
geometryId = GetSceneValue(objectIdMap, geometryPath);
if isempty(geometryId)
    shouldInsert = false;
    geometryId = [];
    return;
end
geometryId = geometryId(geometryId ~= '#');

% does the geometry's polylist have enough stuff in it?
polylistPath = [geometryId ':mesh:polylist.count'];
polylistCount = GetSceneValue(objectIdMap, polylistPath);
if isempty(polylistCount) || StringToVector(polylistCount) < 10
    shouldInsert = false;
    return;
end

% this node checks out
shouldInsert = true;