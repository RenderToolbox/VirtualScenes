%% Make an m x n montage from RGB image files.
%   @param fileName file name for the new montage
%   @param images m x n cell array of images (each element a file name or RGB data)
%   @param names m x n cell array of image labels
%   @param scaleFactor how much to scale the final montage (it might be large)
%   @param scaleMethod how exactly to scale the montage
%
% @details
% Combines the given m x n @a images into a new image and writes the image
% to @a fileName.  If @a names is provided, it must be an m x n cell array
% of labels to write in each panel of the montage.  @a scaleFactor and @a
% scaleMethod are passed to imresize() to scale the whole output montage.
% This is useful if the montage turns out to be very large.
%
% @details
% Returns the file name of the new montage image file, which should be
% equal to the given @a fileName.
%
% @details
% Usage:
%   fileName = MakeImageMontage(fileName, images, names, scaleFactor, scaleMethod)
%
% @ingroup VirtualScenes
function fileName = MakeImageMontage(fileName, images, names, scaleFactor, scaleMethod)

if nargin < 1 || isempty(fileName)
    fileName = 'montage.png';
end

if nargin < 3 || isempty(names)
    names = cell(size(images));
end

if nargin < 4 || isempty(scaleFactor)
    scaleFactor = [];
end

if nargin < 5 || isempty(scaleMethod)
    scaleMethod = 'lanczos3';
end

bigMontage = [];
rows = size(images, 1);
columns = size(images, 2);
for ii = 1:rows
    for jj = 1:columns
        panelData = images{ii,jj};
        
        if isempty(panelData)
            continue;
        end
        
        if ischar(panelData) && 2 == exist(panelData, 'file')
            panel = imread(panelData);
        else
            panel = panelData;
        end
        
        % load the next panel
        panelDepth = size(panel, 3);
        panelWidth = size(panel, 2);
        panelHeight = size(panel, 1);
        
        % grayscale to RGB
        if 1 == panelDepth
            panel = repmat(panel, [1, 1, 3]);
        end
        
        % first time, initialize the whole montage image
        if isempty(bigMontage)
            gridWidth = panelWidth;
            gridHeight = panelHeight;
            montageHeight = rows * panelHeight;
            montageWidth = columns * panelWidth;
            bigMontage = zeros(montageHeight, montageWidth, 3, 'uint8');
        end
        
        % copy in the panel
        xOffset = (jj-1) * gridWidth;
        yOffset = (ii-1) * gridHeight;
        xRange = xOffset + (1:panelWidth);
        yRange = yOffset + (1:panelHeight);
        bigMontage(yRange, xRange, :) = panel;
        
        panelName = names{ii,jj};
        if ~ischar(panelName) || 5 ~= exist('insertText')
            continue;
        end
        
        % write a name for this panel
        bigMontage = insertText( ...
            bigMontage, [xOffset, yOffset] + 1, panelName);
    end
end

% scale the big montage?
if ~isempty(scaleFactor) && 1 ~= scaleFactor
    bigMontage = imresize(bigMontage, scaleFactor, scaleMethod);
end

% finally out to disk
imwrite(bigMontage, fileName);
