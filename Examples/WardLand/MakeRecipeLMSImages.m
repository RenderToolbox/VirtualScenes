%% Convert some illumination and reflectance images to LMS representations.
%   @param recipe a recipe from BuildWardLandRecipe()
%   @param sensitivities a Psychtoolbox colorimetric mat-file name
%
% @details
% Convert some of the WardLand illumination images for the given @a
% recipe to LMS sensor images and writes the LMS images to disk.
%
% @details
% By default, uses Psychtoolbox "ss2" cone sensor sensitivities to compute
% the sensor images.  If @a sensitivities is provided, it must be an
% alternative Psychtoolbox colorimetric mat-file to use instead.
%
% @details
% Returns the given @a recipe, updated with images saved in the "lms"
% group.
%
% @details
% Usage:
%   recipe = MakeRecipeLMSImages(recipe, sensitivities)
%
% @ingroup WardLand
function recipe = MakeRecipeLMSImages(recipe, sensitivities)

if nargin < 2 || isempty(sensitivities)
    sensitivities = 'T_cones_ss2';
end

outGroup = 'lms';

recipe = computeLMS(recipe, 'radiance', outGroup, 'ward', sensitivities);
recipe = computeLMS(recipe, 'illumination', outGroup, 'illumInterp', sensitivities);
recipe = computeLMS(recipe, 'illumination', outGroup, 'illumMeanInterp', sensitivities);
recipe = computeLMS(recipe, 'reflectance', outGroup, 'reflectance', sensitivities);


%% Compute LMS sensor image and write to disk.
function recipe = computeLMS(recipe, inGroup, outGroup, name, sensitivities)
multispectral = LoadRecipeProcessingImageFile(recipe, inGroup, name);
S = GetRecipeProcessingData(recipe, 'radiance', 'S');
lmsImage = MultispectralToSensorImage(multispectral, S, sensitivities);

%% Scale image planes for visualization.
lmsMax = max(lmsImage(:));
lmsL = lmsImage(:,:,1) ./ lmsMax;
lmsM = lmsImage(:,:,2) ./ lmsMax;
lmsS = lmsImage(:,:,3) ./ lmsMax;

%% Write out the the full LMS image.
namePrefix = [inGroup '_' name '_'];
format = 'mat';
recipe = SaveRecipeProcessingImageFile(recipe, outGroup, [namePrefix 'lms'], format, lmsImage);

%% Write out L, M, and S channels separately.
format = 'png';
recipe = SaveRecipeProcessingImageFile(recipe, outGroup, [namePrefix 'l'], format, lmsL);
recipe = SaveRecipeProcessingImageFile(recipe, outGroup, [namePrefix 'm'], format, lmsM);
recipe = SaveRecipeProcessingImageFile(recipe, outGroup, [namePrefix 's'], format, lmsS);
