% filter_image
% Mike Hughes, Applied Optics Group, University of Kent
% m.r.hughes@kent.ac.uk  http://research.kent.ac.uk/applied-optics
%
% Filters image to highlight speckle pattern, used for correlation analysis

function imFilt = filter_image(im, highPassFilterSize, smoothFilterSize)

    % Removes image structure
    if highPassFilterSize < 0
        imFilt = im;
    else
        imFilt = im - imfilter(im, ones(highPassFilterSize,highPassFilterSize)/highPassFilterSize^2);
    end
    
    % Removes noise
    if smoothFilterSize > 0
        imFilt = imfilter(imFilt, fspecial('Gaussian',ceil(smoothFilterSize * 6),smoothFilterSize));
    end

end