%% Pick an XYZ position between two bounding boxes.
%   @param innerBound bounding box [xMin xMax; yMin yMax; zMin zMax]
%   @param outerBound enclosing bounding box [xMin xMax; yMin yMax; zMin zMax]
%   @param normalizedPosition [x y z] position with values in [0 1]
%
% @details
% Chooses a position in the region described by @a innerPostion and
% @a outerPosition, where @a innerPosition must be totally contained within
% outerPosition.  The chosen position will lie within the bounding box
% described by @a outerBound, but not within the bounding box described by
% @a innerBound.
%
% The given @a normalizedPosition must have values in the range 0 - 1.  It
% is used to choose x, y, and z, positions along the range of possible
% positoins in the donut between @a innerBound and @a outerBound.
%
% @details
% Returns a position vector of the form [x y z].
%
% @details
% Usage:
%   position = GetRandomPosition(innerBound, outerBound, normalizedPosition)
%
% @ingroup VirtualScenes
function position = GetDonutPosition(innerBound, outerBound, normalizedPosition)
x = positionInDonut(innerBound(1,:), outerBound(1,:), normalizedPosition(1));
y = positionInDonut(innerBound(2,:), outerBound(2,:), normalizedPosition(2));
z = positionInDonut(innerBound(3,:), outerBound(3,:), normalizedPosition(3));
position = [x y z];

%% Value in donut region between inner and outer, part-way-along.
%   outer(1)-------inner(1)        inner(2)-----------------outer(2)
function p = positionInDonut(inner, outer, part)

% how wide is the space of possible outcomes?
outerSpan = outer(2) - outer(1);
innerSpan = inner(2) - inner(1);
positionSpan = outerSpan - innerSpan;

% choose p "part way along" in the space of outcomes
p = positionSpan * part;

% shift p into the outer range
p = p + outer(1);

if p > inner(1)
    % shift p past the inner range
    p = p + innerSpan;
end
