%% Scan for the ids of elements in the given Collada file.
%   @param colladaFile a 3D model Collada .dae file
%   @param idPattern optional regular expression for selecting ids
%
% @details
% Reads the given @a colladaFile into memory and scans the document
% elements to find their ids.  If @a idPattern, is provided, it must be a
% regular expression to compare to each id.  Only ids that match @A
% idPattern will be returned.
%
% @details
% Returns a cell array of element ids found in the given @a colladaFile.
%
% @details
% Usage:
%   ids = GetSceneElementIds(colladaFile, idPattern)
%
% @ingroup VirtualScenes
function ids = GetSceneElementIds(colladaFile, idPattern)

if nargin < 2 || isempty(idPattern)
    idPattern = '\w+-material$';
end

[docNode, idMap] = ReadSceneDOM(colladaFile);
allIds = idMap.keys();
nIds = numel(allIds);
isMaterial = false(1, numel(nIds));
for ii = 1:nIds
    isMaterial(ii) = ~isempty(regexp(allIds{ii}, idPattern, 'once'));
end
ids = allIds(isMaterial);
