% build_volume_with_shifts
% Mike Hughes, Applied Optics Group, University of Kent
% m.r.hughes@kent.ac.uk  http://research.kent.ac.uk/applied-optics
%
% Assemble volume from irregularly space B-scan stack using 
% pre-calculated equally spaced frame indices. Also takes the x and y
% shifts for each frame and uses these to correctly position frames
% within volume.
%
% Usage:
%
%     volume = build_volume(filename, frame, xPos, yPos, ySmooth)
%
%   filename: tif stack filename or 3D array
%   frame   : vector of frame numbers to use to generate volume
%   xPos    : vector of x shifts for each used frame
%   yPos    : vector of y shifts for each used frame
%   ySmooth : y shifts are smoothed with a mean filter of this size

function [volume, topSurface] = build_volume_with_shifts(filename, frame, xPos, yPos, ySmooth)


    yPos = -yPos;
    yPos = round(movmean(yPos,ySmooth));

    % Figure out the size of the resulting volume, taking into 
    % account all the shifts
    im = extract_image(filename,1);
    xSize = size(im,2) + max(xPos) - min(xPos);
    ySize = size(im,1) + max(yPos) - min(yPos);
    xOffset = -min(xPos) + 1;
    yOffset = -min(yPos) + 1; 
    volume = zeros(ySize, xSize, length(frame));

    
    % Add in each frame
    for i = 1:length(frame)
        im = extract_image(filename, frame(i));
        volume(yOffset + yPos(i):yOffset + yPos(i) + size(im,1) - 1 , ...
               xOffset + xPos(i):xOffset + xPos(i) + size(im,2) - 1 , ...
               i) = im;
    end   

    % This is the estimate of the pixel line in the volume where the top
    % surface should be
    topSurface = max(abs(yPos));
    
end