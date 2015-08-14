%% Write a block of formatted mappings text to the given file.
%   @param fid a file descriptor from fopen().
%   @param comment any comment to write before the formatted text
%   @param blockName a recognized mappings block name like 'Generic'
%   @param elementInfo a struct array with elements from BuildDesription()
%
% @details
% Writes a formatted block of mappings file syntax to the file at @a fid.
% The block may be preceeded by any comment line as given in @a comment.  
% The block must have a recognized type name, for example 'Generic',
% 'Mitsuba', or 'PBRT-path'.
%
% @details
% @a elementInfo must be a struct array of data describing the content of
% the mappings block.  The elements of @a elementInfo must be formatted
% like the outputs of BuildDesription().  Each element will contain the id,
% categoty, and type of a scene element, as well as properties of each
% element.
%
% @details
% Usage:
%   WriteMappingsBlock(fid, comment, blockName, elementInfo)
%
% @ingroup VirtualScenes
function WriteMappingsBlock(fid, comment, blockName, elementInfo)
fprintf(fid, '\n\n%% %s\n', comment);
fprintf(fid, '%s {\n', blockName);
for ii = 1:numel(elementInfo)
    fprintf(fid, '    %s:%s:%s\n', elementInfo(ii).id, ...
        elementInfo(ii).category, elementInfo(ii).type);
    for jj = 1:numel(elementInfo(ii).properties)
        prop = elementInfo(ii).properties(jj);
        fprintf(fid, '    %s:%s.%s = %s\n', elementInfo(ii).id, ...
            prop.propertyName, prop.valueType, prop.propertyValue);
    end
    fprintf(fid, '\n');
end
fprintf(fid, '}\n');
