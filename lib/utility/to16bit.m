% Converts image to 16 bit integer, allowing for negative value and 
% using full range of 16 bits.
% Mike Hughes
function out = to16bit(in)

   out = in - min(in(:));
   out = uint16(double(out) ./ max(double(out(:))) * (2^16 - 1));

end