% build_volume_flat
% Mike Hughes, Applied Optics Group, University of Kent
% m.r.hughes@kent.ac.uk  http://research.kent.ac.uk/applied-optics
%
% Assemble volume from irregularly space B-scan stack using 
% pre-calculated equally spaced frame indices. Also takes the x and y
% shifts for each frame and uses these to correctly position frames
% within volume, and corrects a global tilt.
%
% Usage:
%
%     [volumeOut, surfaceHeight, tilt, surfaceSimple] = build_volume_flat(volumeIn, frames, xPos, yPos, ySmooth, filterSize )
% 
%  volumeIn   : raw OCT volume  (depth, lateral, BScan No.)
%  frame      : vector of frame numbers to use to generate volume
%  xPos       : vector of x shifts for each used frame
%  yPos       : vector of y shifts for each used frame
%  filterSize : size of filter used for edge detection
%  ySmooth    : y shifts are smoothed with a mean filter of this size

function [volumeOut, surfaceHeight, tilt, surfaceSimple] = build_volume_flat(volumeIn, frames, xPos, yPos, ySmooth, filterSize)

  
      
    % For convenience
    filterSize = 4;
    lateralDim = 2;
    depthDim = 1;
    scanDim = 3;
    numLateralPoints = size(volumeIn,lateralDim);
    numScans =  size(volumeIn,scanDim);  % The B-scans
    numDepthPoints = size(volumeIn,depthDim);
        
    % Build a volume with corection for depth of surface of each B-scan but
    % without the lateral shift. (Because we want to detect the tilt of the
    % probe which doesn't change with lateral shift)
    xPosNull = zeros(length(xPos),1);
    volumeSurfFlat = build_volume_with_shifts(volumeIn,frames, xPosNull, yPos, ySmooth);
      
    % Run through each lateral position, extract a B-scan perpendicular
    % to the actual B-scans which were acquired and calculate the average
    % surface height for that lateral position
    surfaceSimple = zeros(numLateralPoints, 1);
    for ii = 1:numLateralPoints        
        slice = squeeze(volumeSurfFlat(:, ii,:));
        surfaceSimple(ii) = find_top_surface2(slice, filterSize);
    end
  
    % Fit line to surface position
    fit = polyfit(1:numLateralPoints, surfaceSimple',1);
    tilt = -fit(1);
    tiltShift = -round((1:numLateralPoints) * tilt * -1);
      
    % Adjust the raw volume to correct tilt
    depthOffset = min(tiltShift);
    newNumDepthPoints = numDepthPoints + max(tiltShift) - min(tiltShift);
    
    volumeTilted = zeros(newNumDepthPoints, numLateralPoints, numScans);
    for ii = 1:numLateralPoints
            im = squeeze(volumeIn(:, ii, :)); 
            volumeTilted(-depthOffset +  tiltShift(ii) + 1:-depthOffset +  tiltShift(ii) + numDepthPoints  ,  ii,:) = im;
    end
        
    clear volumeIn;  % save memory
    
    % Correct lateral shifts and depth changes
    [volumeOut, surfaceHeight] = build_volume_with_shifts(volumeTilted, frames, xPos, yPos, ySmooth);
        
    % Average surface height
    surfaceHeight = round(surfaceHeight + tilt * numLateralPoints/2);
        
end