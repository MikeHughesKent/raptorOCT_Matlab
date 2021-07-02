% Reads an OCT volume from a multipage 16bt TIF file. Assumes volume is (x,y,depth).
% Mike Hughes

function volume = read_volume_16bit(filename)

    % Get no. of images
    info = imfinfo(filename);
    nImages = length(info);
    
    % Get image size
    testIm = imread(filename, 1);
    xSize = size(testIm,1);
    ySize = size(testIm,2);
    
    % For speed, predefine array
    volume = uint16(zeros(xSize, ySize, nImages));
       
    % Read all images
    for iFrame = 1:nImages
        volume(:,:,iFrame) = imread(filename, iFrame);
    end

end