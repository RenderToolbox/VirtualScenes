%% Convert a VirutalScenes relative path to a local absolute path.
%   @param relativePath a relative path inside the VirutalScenes toolbox
%
% @details
% Gets the local, absolute path name for a a file inside the VirtualScenes
% toolbox distribution.  @a relativePath must be the relative path to a
% file, relative to the VirtualScenes Toolbox code distribution.  See 
% VirtualScenesRoot().
%
% @details
% VirutalScenes scripts should always store and manipulate relative paths
% to VirtualScenes files, then use this function at the last minute before
% rendering to obtain the local absolute path.  This keeps scripts
% portable.
%
% @details
% Usage:
%   absolutePath = GetVirtualScenesPath(relativePath)
%
% @ingroup VirtualScenes
function absolutePath = GetVirtualScenesPath(relativePath)
absolutePath = fullfile(VirtualScenesRoot(), relativePath);