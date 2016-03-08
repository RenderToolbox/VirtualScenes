%% Pick a random position between two bounding boxes.
%   @param innerBound bounding box [xMin xMax; yMin yMax; zMin zMax]
%   @param outerBound enclosing bounding box [xMin xMax; yMin yMax; zMin zMax]
%
% @details
% Chooses a random position in the region described by @a innerPostion and
% @a outerPosition, where @a innerPosition must be totally contained within
% outerPosition.  The chosen position will lie within the bounding box
% described by @a outerBound, but not within the bounding box described by
% @a innerBound.
%
% @details
% The x, y, and z components of the position are chosen independently and
% uniform-randomly.
%
% @details
% Returns a position vector of the form [x y z].
%
% @details
% Usage:
%   position = GetRandomPosition(innerBound, outerBound)
%
% @ingroup VirtualScenes
function position = GetRandomPosition(innerBound, outerBound)
position = GetDonutPosition(innerBound, outerBound, rand(1,3));
