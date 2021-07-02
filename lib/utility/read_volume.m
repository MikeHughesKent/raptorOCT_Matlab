% load_volume
%
% Load B-scan tiff stack into array. Array is (depth, x, B-scan Number)
%
% Mike Hughes
%
% Usage:
%
%     volume = read_volume(filename)
%
% filename: tif stack filename

function volume = read_volume(filename)

    info = imfinfo(filename);
    nPage = length(info);
    im = imread(filename,1);

    volume = zeros(size(im,1), size(im,2), nPage);

    for i = 1:nPage
    
        volume(:,:,i) = imread(filename,i);
    end   

end