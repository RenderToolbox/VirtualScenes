%% Append mappings blocks to a mappings file.
%   @param fileIn the original mappings file to start with
%   @param fileOut new mappings file to write (may be same as @a fileIn)
%   @param ids cell array of scene element ids as from ReadSceneDom()
%   @param descriptions cell array of element descriptions as from BuildDesription()
%   @param blockName a mappings block name like "Generic"
%   @param comment any comment to write with the mappings block
%
% @details
% Appends a block of formatted mappings syntax to the given @a fileIn
% RenderToolbox3 mappings file and writes the result to @a fileOut.  The
% mappings block will be preceeded by any given @a comment and will start
% with the given  @a blockName.
%
% @details
% The contents of the mappings block will describe n scene elements, as
% specified in @a ids and @a descriptions, which each must have n elements.
% Each element of @a ids must specifiy a specific instance of a scene
% element, like a particular light or object.  Each corresponding element
% of @a descriptions must describe the type and properties of the element.
%
% @details
% Elements of @a descriptions must use the standard format provided by
% BuildDescription().
%
% @details
% Returns the name of the new mappings file written, which should be the
% same as the given @a fileOut.
%
% @details
% Usage:
%   fileOut = AppendMappings(fileIn, fileOut, ids, descriptions, blockName, comment)
%
% @ingroup VirtualScenes
function fileOut = AppendMappings(fileIn, fileOut, ids, descriptions, blockName, comment)

if nargin < 2 || isempty(fileOut)
    fileOut = fileIn;
end

if nargin < 3 || ~iscell(ids) || isempty(ids)
    return;
end
nElements = numel(ids);

if nargin < 4 || ~iscell(descriptions) || isempty(descriptions)
    warning('VirtualScenes:NoDescriptions', 'No element descriptions provided, aborting.');
    return;
end

if nargin < 5 || isempty(blockName)
    blockName = 'Generic';
end

if nargin < 6 || isempty(comment)
    comment = '';
end

% pack up mappings data to write as formatted text
elementInfo = [descriptions{:}];
for ii = 1:nElements
    elementInfo(ii).id = ids{ii};
end

% copy over the original file
if exist(fileIn, 'file') && ~strcmp(fileIn, fileOut)
    copyfile(fileIn, fileOut);
end

% append mappings text to the output file
try
    fid = fopen(fileOut, 'a');
    WriteMappingsBlock(fid, comment, blockName, elementInfo);
    fclose(fid);
    
catch err
    fclose(fid);
    rethrow(err);
end
