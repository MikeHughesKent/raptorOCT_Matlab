% interp_fluor
% Mike Hughes, Applied Optics Group, University of Kent
% m.r.hughes@kent.ac.uk  http://research.kent.ac.uk/applied-optics
%
% Interpolates fluorescence images using estimated frame positions. Also
% applies a stretch to ensure square pixels.
%
% Usage:
%
%     imInterp = interp_fluor(im, framePos, stretch)
%
%   volumeSimple : a volume created from one of the build_volume functions
%                  (i.e. without interpolation)
%   linePos      : desired position of each frame in volume (can be
%                  non-integer)
%   stretch      : image will be stretched in the out of plane (y) direction
%                  by this factor. It should be the ratio of out-of-plane 
%                  pixel size to the lateral pixel size.

function imInterp = interp_fluor(im, linePos, stretch)

    linePos = linePos * stretch;
    newYSize = round(max(linePos));
    interpPts = 1:newYSize;
    imInterp = interp1(linePos, im, interpPts);
    
end