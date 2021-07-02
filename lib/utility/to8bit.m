% Converts image to 8 bit
% Mike Hughes
function out = to8bit(in)

   out = uint8(double(in) ./ max(double(in(:))) * 255);

end