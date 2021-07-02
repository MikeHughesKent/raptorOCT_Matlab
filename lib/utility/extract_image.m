% extract_image
% Mike Hughes, Applied Optics Group, University of Kent
%
% Helper function that allows functions to deal either with tif stacks
% or stacks of images in memory, extacting BScan number 'iImage'
% If filename is a string then it is treated as tif file, otherwise
% it is assumed to be a 3D array, (depth, xPixel, BScanNumber).

function im = extract_image(filename, iImage)

    if isstring(filename)
        useFile = 1;
    else
        useFile = 0;
    end

    if useFile
        im = double(imread(filename,iImage));
    else
        im = filename(:,:,iImage);
    end
       
end