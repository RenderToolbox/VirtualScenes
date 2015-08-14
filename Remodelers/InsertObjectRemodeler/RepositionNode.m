%% Move the given node to a new position.
%   @param objectIdMap for a Collada file, as from ReadSceneDOM()
%   @param nodeId id for one of the Collada <node> elements
%   @param position for the node: [x y z], or the id of another node to mimic
%   @param rotation for the node: [ax ay az], or the id of another node to mimic
%   @param scale for the node: [x y z], or the id of another node to mimic
%
% @details
% Used internally by the InserteObjectRemodeler.  Modifies the spatial
% transformations for the Colada <node> element specified by @a nodeId.
%
% @details
% @a position may be a vector of the form [x y z], to be added to the
% current translation of the @a nodeId node.  Or, it may be the id of
% a different <node> element, in which case the @a nodeId node will use the
% same translation as the @a position node.
%
% @details
% @a rotation may be a vector of the form [x y z], to be set as the
% absolute rotation used by the @a nodeId node.  Or, it may be the id of
% a different <node> element, in which case the @a nodeId node will use the
% same rotation as the @a position node.
%
% @details
% @a scale may be a vector of the form [x y z], to be multiplied with the
% current scale used by the @a nodeId node.  Or, it may be the id of 
% a different <node> element, in which case the @a nodeId node will use the
% same scale as the @a position node.
%
% @details
% Returns nothing.
%
% @details
% Usage:
%   RepositionNode(objectIdMap, nodeId, position, rotation, scale)
%
% @ingroup InsertObjectRemodeler
function RepositionNode(objectIdMap, nodeId, position, rotation, scale)

if isnumeric(position) || ~objectIdMap.isKey(position)
    %% Apply given transformations.
    
    % increment position
    translatePath = [nodeId ':translate|sid=location'];
    SetSceneValue(objectIdMap, translatePath, position, true, '+=');
    
    % set absolute rotation
    rotation = StringToVector(rotation);
    aX = VectorToString([1 0 0 rotation(1)]);
    aY = VectorToString([0 1 0 rotation(2)]);
    aZ = VectorToString([0 0 1 rotation(3)]);
    rotatePath = [nodeId ':rotate|sid=rotationX'];
    SetSceneValue(objectIdMap, rotatePath, aX, true, '=');
    rotatePath = [nodeId ':rotate|sid=rotationY'];
    SetSceneValue(objectIdMap, rotatePath, aY, true, '=');
    rotatePath = [nodeId ':rotate|sid=rotationZ'];
    SetSceneValue(objectIdMap, rotatePath, aZ, true, '=');
    
    % multiply scale
    scalePath = [nodeId ':scale|sid=scale'];
    SetSceneValue(objectIdMap, scalePath, scale, true, '*=');
    return
end

% get all the transformations from another node
translatePath = [position ':translate|sid=location'];
rotatePath = [position ':rotate|sid=rotationX'];
rotateYPath = [position ':rotate|sid=rotationY'];
rotateZPath = [position ':rotate|sid=rotationZ'];
scalePath = [position ':scale|sid=scale'];

translate = GetSceneValue(objectIdMap, translatePath);
rotateX = GetSceneValue(objectIdMap, rotatePath);
rotateY = GetSceneValue(objectIdMap, rotateYPath);
rotateZ = GetSceneValue(objectIdMap, rotateZPath);
scale = GetSceneValue(objectIdMap, scalePath);

% set all the transformations on the target node
translatePath = [nodeId ':translate|sid=location'];
rotatePath = [nodeId ':rotate|sid=rotationX'];
rotateYPath = [nodeId ':rotate|sid=rotationY'];
rotateZPath = [nodeId ':rotate|sid=rotationZ'];
scalePath = [nodeId ':scale|sid=scale'];

SetSceneValue(objectIdMap, translatePath, translate, true);
SetSceneValue(objectIdMap, rotatePath, rotateX, true);
SetSceneValue(objectIdMap, rotateYPath, rotateY, true);
SetSceneValue(objectIdMap, rotateZPath, rotateZ, true);
SetSceneValue(objectIdMap, scalePath, scale, true);
