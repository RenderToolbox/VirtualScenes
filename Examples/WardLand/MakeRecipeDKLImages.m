% Convert some LMS images to DKL representations.
%   @param recipe a recipe from BuildWardLandRecipe()
%   @param lmsSensitivities a Psychtoolbox colorimetric mat-file name
%   @param dklSensitivities a Psychtoolbox colorimetric mat-file name
%
% @details
% Converts some of the WardLand LMS sensor images for the given @a recipe
% to DKL sensor images and writes the DKL images to disk.  See 
% MakeRecipeMLSImages().
%
% @details
% By default, uses Psychtoolbox cone "ss2" and CIE "y2" sensitivities to
% compute the DKL images.  If @a lmsSensitivities or @a dklSensitivities
% is provided, each must be an alternative Psychtoolbox colorimetric
% mat-file to use instead.
%
% @details
% Returns the given @a recipe, updated with images saved in the "dkl"
% group.
%
% @details
% Usage:
%   recipe = MakeRecipeDKLImages(recipe, lmsSensitivities, dklSensitivities)
%
% @ingroup WardLand
function recipe = MakeRecipeDKLImages(recipe, lmsSensitivities, dklSensitivities)

if nargin < 2 || isempty(lmsSensitivities)
    lmsSensitivities = 'T_cones_ss2';
end

if nargin < 3 || isempty(dklSensitivities)
    dklSensitivities = 'T_CIE_Y2';
end

%% Get lms and skl sensitivity functions.
S = GetRecipeProcessingData(recipe, 'radiance', 'S');
lms = load(lmsSensitivities);
dkl = load(dklSensitivities);
T_lms = SplineCmf(lms.S_cones_ss2, lms.T_cones_ss2, S);
T_dkl = SplineCmf(dkl.S_CIE_Y2, dkl.T_CIE_Y2, S);

outGroup = 'dkl';

recipe = computeDKL(recipe, 'lms', outGroup, 'illumination_illumInterp_', T_lms, T_dkl);
recipe = computeDKL(recipe, 'lms', outGroup, 'illumination_illumMeanInterp_', T_lms, T_dkl);
recipe = computeDKL(recipe, 'lms', outGroup, 'reflectance_reflectance_', T_lms, T_dkl);


%% Compute DKL image and write to disk.
function recipe = computeDKL(recipe, inGroup, outGroup, namePrefix, T_lms, T_dkl)
lmsName = [namePrefix 'lms'];
lmsImage = LoadRecipeProcessingImageFile(recipe, inGroup, lmsName);

%% Convert lms image to Psychtoolbox "cal format" for processing.
nX = size(lmsImage, 2);
nY = size(lmsImage, 1);
[lmsImageCalFormat, nXCheck, nYCheck] = ImageToCalFormat(lmsImage);
if (nX ~= nXCheck || nY ~= nYCheck)
    error('Something wonky about converstion into cal format');
end

%% Subtract mean of each LMS channel as the "background".
lmsMeans = mean(lmsImageCalFormat, 2);
lsmResidualImageCalFormat = bsxfun(@minus, lmsImageCalFormat, lmsMeans);

%% Compute the DKL image.
M_LsmResidualToDKL = ComputeDKL_M(lmsMeans, T_lms, T_dkl);
dklImageCalFormat = M_LsmResidualToDKL * lsmResidualImageCalFormat;
dklImage = CalFormatToImage(dklImageCalFormat, nX, nY);

%% Scale image planes for visualization.
dklImageScaled = zeros(size(dklImage));
for ii = 1:3
    thisPlaneIn = dklImage(:,:,ii);
    thisPlaneMaxAbs = max(abs(thisPlaneIn(:)));
    thisPlaneOut = thisPlaneIn / thisPlaneMaxAbs + 0.5;
    dklImageScaled(:,:,ii) = thisPlaneOut;
end

%% Write out the the full DKL image.
format = 'mat';
recipe = SaveRecipeProcessingImageFile(recipe, outGroup, [namePrefix 'dkl'], format, dklImageScaled);

%% Write out L, M, and S channels separately.
format = 'png';
recipe = SaveRecipeProcessingImageFile(recipe, outGroup, [namePrefix 'l'], format, dklImageScaled(:,:,1));
recipe = SaveRecipeProcessingImageFile(recipe, outGroup, [namePrefix 'rg'], format, dklImageScaled(:,:,2));
recipe = SaveRecipeProcessingImageFile(recipe, outGroup, [namePrefix 'by'], format, dklImageScaled(:,:,3));
