% Converts image to 8 bit, allows for negative values and uses
% imadjust to adjust dynamic range.
% Mike Hughes
function out = to8bit2(in)

   out = in - min(in(:));
   out = double(out) ./ max(double(out(:)));
   out = imadjust(out);
   out = uint8(out * 255);

end