% interp_volume
% Mike Hughes, Applied Optics Group, University of Kent
% m.r.hughes@kent.ac.uk  http://research.kent.ac.uk/applied-optics
%
% Interpolates volume using estimated frame positions.
%
% Usage:
%
%     volume = interp_volume(volumeSimple, framePos, stretch)
%
%   volumeSimple : a volume created from one of the build_volume functions
%                  (i.e. without interpolation)
%   framePos     : desired position of each frame in volume (can be
%                  non-integer)
%   stretch      : images will be strectched in the out of plane direction
%                  by this factor. It should be the ratio of out-of-plane 
%                  pixel size to the lateral pixel size.

function volume = interp_volume(volumeSimple, framePos, stretch)

    nLateralPoints = size(volumeSimple,2);
    nDepthPoints = size(volumeSimple,1);
    framePos = framePos * stretch;
    
    newYSize = round(max(framePos));
    interpPts = 1:newYSize;
    volume = zeros(nDepthPoints, nLateralPoints, newYSize);
   
    for x = 1: nLateralPoints
            oldVals = squeeze(volumeSimple(:,x,:))';
            newLine = interp1(framePos, oldVals, interpPts);
            volume(:,x,:) = newLine';
    end
    
end