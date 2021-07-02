% remove_outlier_pixels
% Windows an image to remove specularities and saturation arifacts.
%
% Mike Hughes, Applied Optics Group, University of Kent, 2021
% m.r.hughes@kent.ac.uk  http://research.kent.ac.uk/applied-optics
%
% Returns a mask (1 to remove, 0 to keep) and copy of image with
% removed pixels set to 0.
%
% im         : input image
% multiplier : The larger this is the less sensive the removal is
% dilateSize : Mask if dilated by the disk of this size.


function [imOut, maskDil, mask] = remove_outlier_pixels(im, multiplier, dilateSize)

        me = median(im(:));
        maxValue = me * multiplier;
        
        mask = (im>maxValue);
        maskDil = imdilate(mask, strel('disk', dilateSize));
        
        imOut = im;
        imOut(~maskDil) = 0;
         
end