% find_top_surface2
% Locates top surface in B-scan using thresholding, and morpholigical
% operations.
%
% Mike Hughes, Applied Optics Group, University of Kent, 2020.
% m.r.hughes@kent.ac.uk  http://research.kent.ac.uk/applied-optics
%
%            im : image
%       filterS : size of structuring element
% surfaceSimple : single value, estimate of surface position
%       surface : array, estimate of surface for each A scan
%     imB, imF  : intermediate steps of image processing for debug

function [surfaceSimple, surface, imB, imF] = find_top_surface2(im, filterS)
  
    multiFactor = 2;  
    
    % Binarise image
    imB = imbinarize(im, mean(im(:))* multiFactor);

    % Use morphological operators to remove holes
    se = strel('disk',filterS);
    imF = imclose(imB, se);
    imF = imopen(imF, se);

    % For each line, surface is first '1'
    surface = zeros(size(im,2),1);
    for i = 1:size(im,2)
        p = find(imF(:,i),1);
        if size(p) == 1
            surface(i) = p;
        else
            surface(i) = -1;
        end
    end
    
    % Average surface height, only use instances where surface found
    surfaceSimple = round(median(surface(surface >0)));
    
    % Debug
     %figure(1);imagesc(imB);colormap('gray'); drawnow

     % on; plot(surface,'r'); drawnow()
   
end