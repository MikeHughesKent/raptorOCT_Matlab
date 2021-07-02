% Example reconstruction of 3D OCT volume and fluorescence image
% from 1 axis-scanning probe based OCT/fluorescence imaging.
%
% Mike Hughes, m.r.hughes@kent.ac.uk
%
% Used to generate elements of Figure 5 of
%    Marques et al.,
%    "Endoscopic en-face optical coherence tomography and 
%     fluorescence imaging using a double-clad optical fiber 
%     and correlation-based probe tracking"
%
% Please refer to the paper for detailed descriptions of the code
% and cite the paper when re-using significant portions of the code.

clear
addpath('..\lib\utility');
addpath('..\lib\b_scan_assemble');

% Filenames
filename = '..\example data\lung tissue\lung_tissue_OCT.tif';
fluorFilename = '..\example data\lung tissue\lung_tissue_fluor.tif';
enFaceOutFilename = '..\output\lung_tissue_enface.tif';
fluorOutFilename = '..\output\lung_tissue_fluorescence.tif';
startIm = 1;    
endIm = -1;              %-1 means all

% B-Scan Assembly Method Parameters
roiHeight = 100;         % Vertical size of ROI
roiWidth = 180;          % Lateral size of ROI
roiOffset = 0;           % Vertical distance from detected surface to top of ROI
roiPos = -1;             % Horizontal position of ROI, -1 = centre
surfFilterSize = 30;     % Size of smoothing filter in pixels for surface detect    
highPassFilterSize = 5;  % Size of mean filter used to remove structure
smoothFilterSize = 1.5;  % Size of Gaussian smoothing filte to remove noise
surfaceSmooth = 10;      % Surface height smoothing
maskThresh = 5;          % Mask pixels > this times mean   

% En face image depth to display (below estimated surface height)
displayDepth = 20;

% Pre-measured parameters
corrThresh = .5;       % Decorrelation threshold
decorDistance = 10.4;  % Measured distance to fall to correlation of corrThresh, microns
latPixelSize = 9.5;    % Lateral pixel size, microns


% Make sure images have corrected aspect ratio
stretch = decorDistance \ latPixelSize;


% Read in datasets       
rawVolume = double(read_volume_16bit(filename));
rawFluor = double(imread(fluorFilename));
      

% Registration
[frame, framePos, corrVal, topSurf, xShift, yShift, xPos, yPos] = corr_reg_7(rawVolume, startIm, endIm, surfFilterSize, highPassFilterSize, smoothFilterSize, maskThresh, roiHeight, roiWidth, roiOffset, corrThresh);


% Fluorescence
fluorIm = build_fluor(rawFluor, frame, xPos);
fluorIm = interp_fluor(fluorIm, framePos, stretch);

        
        
% Volume with B-scan depth correction and global tilt correction
[volume, surfaceHeight] = build_volume_flat(rawVolume, frame, xPos, topSurf, surfaceSmooth, surfFilterSize);
volume = interp_volume(volume, framePos, stretch);
enFace = enface_from_volume(volume, surfaceHeight + displayDepth);
enFaceDisplay = imadjust(enFace / max(enFace(:)));

% Uncomment to save images and whole volume
% mkdir('..\output');
% imwrite(to8bit(enFace), enFaceOutFilename); 
% imwrite(to8bit(fluorIm), fluorOutFilename); 
% save_volume_16bit(volume, ['..\output\tissue_volume.tif']);


figure(1)
subplot(1,2,1); imagesc(enFaceDisplay); colormap(gray); axis equal;
subplot(1,2,2); imagesc(fluorIm); colormap(gray); axis equal;

