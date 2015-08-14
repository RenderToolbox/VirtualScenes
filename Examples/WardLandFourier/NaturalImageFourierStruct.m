%% Make a formatted "Fourier Struct" based on a WardLand computed image.
%   @param folderName folder that contains a UPenn Natural Image
%   @param imageName base name (no extension) of a UPenn Natural Image
%   @param structName optional name for the new Fourier Struct
%   @param cropSize optional [h w] to crop from the natural image center
%
% @details
% Extracts a UPenn Natural Image located in the given @a folderName with
% base name @a imageName.  The @a imageName should not contain any
% extension.  For example, use 'DCS_0001'.  Don't use 'DCS_0001.JPG' or
% 'DCS_0001_LUM.mat'. Builds a formatted "Fourier Struct" which can be
% analyzed with AnalyzeFourierStruct() and visualized with
% PlotFourierStruct().
%
% @details
% Returns a new "Fourier Struct" array based on the given @a folderName and
% @a imageName.
%
% @details
% Usage:
%   fourierStruct = NaturalImageFourierStruct(folderName, imageName, structName, cropSize)
%
% @ingroup WardLand
function fourierStruct = NaturalImageFourierStruct(folderName, imageName, structName, cropSize)

if nargin < 4 || isempty(structName)
    structName = imageName;
end

fourierStruct.name = structName;

lumImage = fullfile(folderName, [imageName '_LUM.mat']);

lumData = load(lumImage);
dataSize = size(lumData.LUM_Image);

if nargin < 4 || isempty(cropSize)
    cropSize = dataSize;
end

remainders = dataSize - cropSize;
starts = 1 + floor(remainders ./ 2);
ends = starts + cropSize - 1;

fourierStruct.grayscale = lumData.LUM_Image(starts(1):ends(1), starts(2):ends(2));
fourierStruct.rgb = 255 * fourierStruct.grayscale / max(fourierStruct.grayscale(:));
fourierStruct.results = [];
