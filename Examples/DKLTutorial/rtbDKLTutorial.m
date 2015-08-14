%% Convert an LMS image to a luminance and chromatic modulation color space.
%
% This is a brief example of how to transform LMS images into DKL images.
%
% 10/22/14  dhb  Wrote it.
%

%% Clear, close
clear; close all;

%% Load up cone and luminance functions
S = [400 10 31];
load T_cones_ss2
T_cones = SplineCmf(S_cones_ss2,T_cones_ss2,S);
load T_CIE_Y2
T_Y = SplineCmf(S_CIE_Y2,T_CIE_Y2,S);

%% We'll need a hyperspectral image to convert.
% Here we'll just generate a simulated image
nX = 10; nY = 20; nPixels = nX*nY;
nWls = S(3);
hyperImage = CalFormatToImage(rand(nWls,nPixels),nX,nY);

%% Convert image to cal format so as to do conversion using PTB routines
[hyperImageCalFormat,nXCheck,nYCheck] = ImageToCalFormat(hyperImage);
if (nX ~= nXCheck || nY ~= nYCheck)
    error('Something wonky about converstion into cal format');
end

%% Convert to LMS respresentation
coneImageCalFormat = T_cones*hyperImageCalFormat;

%% The conversion requires a background.  I think it's fine to use the
% image mean as the background value, computed separately for each image
coneMean = mean(coneImageCalFormat,2);

% Convert to cone increments
coneIncImageCalFormat = bsxfun(@minus,coneImageCalFormat,coneMean);

%% Do the conversion to DKL space.
%
% Get the conversion matrix
M_ConeIncToDKL = ComputeDKL_M(coneMean,T_cones,T_Y);
DKLImageCalFormat = M_ConeIncToDKL*coneIncImageCalFormat;
DKLImage = CalFormatToImage(DKLImageCalFormat,nX,nY);

%% Scale the DKL image
% The three plans of the DKL image correspond roughly to
% luminance (plane 1), red-green chromatic (plane 2), and
% blue-yellow chromatic (plane 3).  The three axes are not,
% however, scaled in an interesting way relative to each other.
%
% We map each plane to a grayscale image with mean at 0.5 and
% into the range 0-1.
DKLImageScaled = zeros(size(DKLImage));
figure; clf;
for i = 1:3
    thisPlaneIn = DKLImage(:,:,i);
    thisPlaneMaxAbs = max(abs(thisPlaneIn(:)));
    thisPlaneOut = thisPlaneIn/thisPlaneMaxAbs + 0.5;
    DKLImageScaled(:,:,i) = thisPlaneOut;
    
    % Show each scaled plane as a grayscale image
    subplot(1,3,i);
    imshow(thisPlaneOut);
end
