%% Get root folder of the VirtualScenes Toolbox.
%
% @details
% Returns the root folder of this VirtualScenes Toobox installation.  This
% is the same folder as the parent of the Utilities folder where this
% function is located.
%
% @details
% Usage:
%   function rootPath = VirtualScenesRoot()
%
% @ingroup VirtualScenes
function rootPath = VirtualScenesRoot()
filePath = mfilename('fullpath');
lastSeps = find(filesep() == filePath, 2, 'last');
rootPath = filePath(1:(lastSeps(1) - 1));
