%% Convert a Model Repository relative path to a local absolute path.
%   @param relativePath metadata.relative path as returned from ReadMetadata()
%
% @details
% Gets the local, absolute path name for a given 3D model @a relativePath.
% @a relativePath must be the relative path to a 3D model, relative to the
% VirtualScenes Toolbox model repository.  See 
% getpref('VirtualScenes', 'modelRepository').  The metadata returned from
% ReadMetadata() has a @b relative field with this kind of path.
%
% @details
% VirutalScenes scripts should always store and manipulate relative paths
% to 3D models, then use this function at the last minute before rendering
% to obtain the local absolute path.  This keeps scripts portable.
%
% @details
% Usage:
%   absolutePath = GetVirtualScenesRepositoryPath(relativePath)
%
% @ingroup VirtualScenes
function absolutePath = GetVirtualScenesRepositoryPath(relativePath)
repository = getpref('VirtualScenes', 'modelRepository');
absolutePath = fullfile(repository, relativePath);
