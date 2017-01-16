%% Make a formatted "Fourier Struct" based on a WardLand computed image.
%   @param hints recipe.input.hints as returned from ExecuteManyWardLandRecipes()
%   @param folderName recipe "images" subfolder like "illumination"
%   @param imageName image file name like "diffuse-interp.png"
%   @param structName optional name for the new Fourier Struct
%
% @details
% The given @a hints should be the recipe.input.hints from a WardLand
% recipe struct which has already been executed, as with
% ExecuteManyWardLandRecipes() or ExecuteWardLandReferenceRecipes().  This
% funciton will extract an image from the recipe and build a
% formatted "Fourier Struct" which can be analyzed with
% AnalyzeFourierStruct() and visualized with PlotFourierStruct().
%
% @details
% Returns a new "Fourier Struct" array based on the given @a hints, @a
% folderName, and @a imageName.
%
% @details
% Usage:
%   fourierStruct = WardLandImageFourierStruct(hints, folderName, imageName, structName)
%
% @ingroup WardLand
function fourierStruct = WardLandImageFourierStruct(hints, folderName, imageName, structName)

if nargin < 4 || isempty(structName)
    structName = [hints.recipeName ' ' folderName ' ' imageName];
end

images = rtbWorkingFolder('folder','images', 'rendererSpecific', true, 'hints', hints);

fourierStruct.name = structName;
imageFile = rtbFindFiles('root', fullfile(images, folderName), 'filter', imageName, 'exactMatch', true);
fourierStruct.rgb = imread(imageFile{1});

% convert images rgb to grayscale luminance
if 3 == size(fourierStruct.rgb, 3)
    [rgbCalFormat,m,n] = ImageToCalFormat(fourierStruct.rgb);
    xyzCalFormat = SRGBPrimaryToXYZ(double(rgbCalFormat));
    xyz = CalFormatToImage(xyzCalFormat, m, n);
    fourierStruct.grayscale = xyz(:,:,2);
else
    fourierStruct.grayscale = double(fourierStruct.rgb);
end

fourierStruct.results = [];
