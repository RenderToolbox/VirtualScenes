%% Invoke an RGB version of Mitsuba to extract non-radiance scene factoids.
%   @param sceneFile a Mitsuba XML scene file
%   @param integratorId string id of the <integrator> scene element
%   @param filmId string id of the <film> scene element
%   @param samplerId string id of the <sampler> scene element
%   @param factoids cell array of names of factoids to extract
%   @param factoidFormat mitsuba pixel format for factoids, like 'rgb'
%   @param hints struct of RenderToolbox3 options, see GetDefaultHints()
%   @param mitsuba struct of Mitsuba configuration, see getpref('Mitsuba')
%   @param singleSampling whether to reduce sampling and pixel filtering
%
% @details
% Modifies a copy of the given Mitsuba @a sceneFile to instruct Mitsuba to
% instruct scene "factoids" instead of rendering radiance data.  The
% factoids represent "ground truth" about the scene rather than ray tracing
% samples.
%
% @details
% @a integratorId, @a filmId, and @a samplerId must be the string "id"
% attributes for the <integrator>, <film>, and <sampler> elements of the
% given @a sceneFile.  These are required when modifying the scene to
% produce factoids instead of radiance data.  The default @a integratorId
% is 'integrator'.  The default @a filmId is 'Camera-camera_film'. The
% default @a samplerId is 'Camera-camera_sampler'.
%
% @details
% Mitsuba supports a few different ground-truth factoids. @a factiods must
% be a cell array containing some or all of the following factoid names:
%   - @b 'position' - absolute position of the object under each pixel
%   - @b 'relPosition' - camera-relative position of the object under each pixel
%   - @b 'distance' - distance to camera of the object under each pixel
%   - @b 'geoNormal' - surface normal at the surface under each pixel
%   - @b 'shNormal' - surface normal at the surface under each pixel, interpolated for shading
%   - @b 'uv' - texture mapping UV coordinates at the surface under each pixel
%   - @b 'albedo' - diffuse reflectance of the object under each pixel
%   - @b 'shapeIndex' - integer identifier for the object under each pixel
%   - @b 'primIndex' - integer identifier for the triangle or other primitive under each pixel
%
% @details
% By default, gets all factoid outputs in 'rgb' pixel format.  If @a
% factoidFormat is provided, it must be a Mitsuba pixel format to use
% instead, such as 'spectrum'.
%
% @details
% @a hints may be a struct with RenderToolbox3 as returned from
% GetDefaultHints().  If @a hints is omitted, default options are used.
%
% @details
% @a mitsuba may be a struct with options for invoking Mitsuba, as returned
% from getpref('Mitsuba').  Some Mitsuba factoids only work when Mitsuba
% was build in 3-channel RGB mode.  So @a mitsuba should point to an RGB
% build of the renderer.
%
% @details
% By default, uses the same pixel sampling and image reconstruction
% filtering specified in the given @a sceneFile.  If @a singleSampling is
% true, reduces sampling to one sample per pixel and uses a simple "box"
% filter for image reconstruction.
%
% @details
% Returns the status code and command line result from invoking Mitsuba.
% Also returns the file name of the modified copy of the given @a
% sceneFile.  Also returns the file name of the OpenEXR data returned from
% Mitsuba.  Finally, returns a struct of factoid data, with one field per
% factoid name specified in @a factoids.
%
% @details
% Usage:
%   function [status, result, newScene, exrOutput, factoidOutput] = ...
%   RenderMitsubaFactoids(sceneFile, integratorId, filmId, samplerId, ...
%   factoids, factoidFormat, hints, mitsuba, singleSampling)
%
% @ingroup VirtualScenes
function [status, result, newScene, exrOutput, factoidOutput] = ...
    RenderMitsubaFactoids(sceneFile, integratorId, filmId, samplerId, ...
    factoids, factoidFormat, hints, mitsuba, singleSampling)


status = [];
result = [];
exrOutput = [];

if nargin < 2 || isempty(integratorId)
    integratorId = 'integrator';
end

if nargin < 3 || isempty(filmId)
    filmId = 'Camera-camera_film';
end

if nargin < 4 || isempty(samplerId)
    samplerId = 'Camera-camera_sampler';
end

if nargin < 5 || isempty(factoids)
    factoids = {'position', 'relPosition', 'distance', 'geoNormal', ...
        'shNormal', 'uv', 'albedo', 'shapeIndex', 'primIndex'};
end

if nargin < 6 || isempty(factoidFormat)
    factoidFormat = 'rgb';
end

if nargin < 7 || isempty(hints)
    hints = GetDefaultHints();
else
    hints = GetDefaultHints(hints);
end

if nargin < 8 || isempty(mitsuba)
    mitsuba = getpref('MitsubaRGB');
end

if nargin < 9 || isempty(singleSampling)
    singleSampling = false;
end

%% Modify the input file.
[docNode, idMap] = ReadSceneDOM(sceneFile);

% change the integrator into a "multichannel" composite integrator
integratorTypePath = {integratorId, '.type'};
SetSceneValue(idMap, integratorTypePath, 'multichannel', true);

% change the film to hdr type and openexr format
filmTypePath = {filmId, '.type'};
SetSceneValue(idMap, filmTypePath, 'hdrfilm', true);
filmFormatPath = {filmId, ':string|name=fileFormat', '.value'};
SetSceneValue(idMap, filmFormatPath, 'openexr', true);

% add a nested integrator for each factoid
% use "factoid" attributes to distinguish different integrators
formatList = '';
nameList = '';
for ii = 1:numel(factoids)
    factoidName = factoids{ii};
    
    % nested integrator
    integratorTypePath = {integratorId, ...
        [':integrator|name=' factoidName], '.type'};
    SetSceneValue(idMap, integratorTypePath, 'field', true);
    integratorPath = {integratorId, ...
        [':integrator|name=' factoidName], ':string|name=field', '.value'};
    SetSceneValue(idMap, integratorPath, factoidName, true);
    
    % build up lists of factoid channel info
    formatList = [formatList factoidFormat ', '];
    nameList = [nameList factoidName ', '];
end

% output channel format
channelFormatPath = {filmId, ':string|name=pixelFormat', '.value'};
SetSceneValue(idMap, channelFormatPath, formatList(1:end-2), true);

% output channel name
channelNamePath = {filmId, ':string|name=channelNames', '.value'};
SetSceneValue(idMap, channelNamePath, nameList(1:end-2), true);

% reduce sampling and reconstruction filtering?
if singleSampling
    sampleCountPath = {samplerId, ':integer|name=sampleCount', '.value'};
    SetSceneValue(idMap, sampleCountPath, '1', true);
    
    filterTypePath = {filmId, ':rfilter', '.type'};
    SetSceneValue(idMap, filterTypePath, 'box', true);
end

% write a new scene file
[scenePath, sceneBase, sceneExt] = fileparts(sceneFile);
newScene = fullfile(scenePath, [sceneBase '-factoids' sceneExt]);
WriteSceneDOM(newScene, docNode);

%% Render the factoid scene.
hints.isPlot = false;
renderer = RtbMitsubaRenderer(hints);
renderer.mitsuba = mitsuba;
[status, result, exrOutput] = renderer.renderToExr(newScene);

%% Get the factoid output
[sliceInfo, data] = ReadMultichannelEXR(exrOutput);

% group data slices by factoid name
factoidOutput = struct();
factoidSize = size(data);
for ii = 1:numel(sliceInfo)
    split = find(sliceInfo(ii).name == '.');
    factoidName = sliceInfo(ii).name(1:split-1);
    channelName = sliceInfo(ii).name(split+1:end);
    
    if ~isfield(factoidOutput, factoidName)
        factoidOutput.(factoidName).data = ...
            zeros(factoidSize(1), factoidSize(2), 0);
        factoidOutput.(factoidName).channels = {};
    end
    
    slice = data(:,:,ii);
    factoidOutput.(factoidName).data(:,:,end+1) = slice;
    factoidOutput.(factoidName).channels{end+1} = channelName;
end

