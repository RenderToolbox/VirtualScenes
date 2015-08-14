%% Simple utility for writing out image files.
%   @param fileName the name of the image file to write
%   @param imageData image data to pass to imwrite()
%
% @details
% This is a simple wrapper for the built-in imwrite() function.  In case
% @a fileName contains a path that doesn't exist yet, this function creates
% the path.
%
% @details
% If @a fileName has the 'mat' extension, writes image data using save()
% instead of imwrite().
%
% @details
% If @a fileName has the 'fig' extension, writes figure data using
% savefig() instead of imwrite().
%
% @details
% Returns the given file name, which can be handy and reduce typing in the
% calling function.
%
% @details
% Usage:
%   fileName = WriteImage(fileName, imageData)
%
% @ingroup Utilities
function fileName = WriteImage(fileName, imageData)
[filePath, fileBase, fileExt] = fileparts(fileName);
if ~isempty(filePath) && ~exist(filePath, 'dir')
    mkdir(filePath);
end

if ischar(imageData) && exist(imageData, 'file')
    copyfile(imageData, fileName);
    return;
end

if strcmp('.mat', fileExt)
    save(fileName, 'imageData');
elseif strcmp('.fig', fileExt)
    savefig(imageData, fileName);
else
    imwrite(imageData, fileName);
end
