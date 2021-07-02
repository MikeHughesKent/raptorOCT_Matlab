% enface_from_volume
% Mike Hughes, Applied Optics Group, University of Kent, 2019
% m.r.hughes@kent.ac.uk  http://research.kent.ac.uk/applied-optics
%
% Pulls out an en face slice from an OCT volume. This can either be
% a single slice or an average over a depth range.
%
% enFace = enface_from_volume(volume, depth)
%
%   volume : 3D array (depth, x, y)
%   depth  : vector, returns average over these depths.

function enFace = enface_from_volume(volume, depth)

    enFace = squeeze(mean(volume(depth,:,:),1))';

end
