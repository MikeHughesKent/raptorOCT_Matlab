% get_num_frames
% Mike Hughes
%
% Returns number of frames either in a volume or a tif stack
function nFrames = get_num_frames(filename)

   if isstring(filename)
        info = imfinfo(filename);
        nFrames = length(info);
   else
        nFrames = size(filename,3);
   end
    
end