% build_fluor
% Mike Hughes, Applied Optics Group, University of Kent
% m.r.hughes@kent.ac.uk  http://research.kent.ac.uk/applied-optics
%
% Assemble fluorescence image from irregularly spaced image (in y direction)
% using pre-calculated equally spaced line indices. Also takes the x 
% shifts for each line and uses these to correctly position each line
% within image. Does not correct for frame positions (interpolation
% method), this is handled by subsequently calling interp_fluor.
%
% Usage:
%
%     [fluorOut] = build_fluor(fluorIn, line, xPos)
%
%   fluorIn : inout image
%   lines    : List of line indices to use.
%   xPos    : vector of x shifts for each used line 

function [fluorOut] = build_fluor(fluorIn, lines, xPos)


    % Figure out the size of the resulting volume, taking into 
    % account all the shifts, and create blank image
    xSize = size(fluorIn,2) + max(xPos) - min(xPos);
    ySize = length(lines);
    xOffset = -min(xPos) + 1;
    fluorOut = zeros(ySize, xSize);
    
    % Add in each line
    for i = 1:length(lines)
        if lines(i) <= size(fluorIn,1)
            fluorOut(i, xOffset + xPos(i):xOffset + xPos(i) + size(fluorIn,2) - 1) = fluorIn(lines(i),:);
        end
    end   

       
end