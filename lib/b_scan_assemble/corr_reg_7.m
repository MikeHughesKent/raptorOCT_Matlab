% corr_reg_7
%
% Mike Hughes, Applied Optics Group, University of Kent, 2021
% m.r.hughes@kent.ac.uk
% http://research.kent.ac.uk/applied-optics
%
% Used to calculate in-plane and out-of-plane motion between OCT B-scans
% in a stack. In-plane (x and y) shifts are determined by normalised
% cross correlation. Out-of-plane (z) shift is determoned by speckle
% decorrelation. 
%
% Beginning with reference frame, subsequent frames are registered
% using normxcorr. ROIs are extracted from reference and subsequent frames, 
% filtered to remove noise and image structure (leaving speckle pattern) 
% and masked to remove specularities. The correlation between the two
% images is then computed. If correlation drops below threshold, this is 
% recorded and current frame becomes new reference frames. The current 
% frame number is added to the 'frame' vector.
%
% Also estimates overshoot (from how far below threshold correlation is) to
% figure out true position of current frame, stored in 'framePos'.
%
% Position of ROIs is relative to the detected top surface of the reference
% frame.
% 
% Usage:
%
%    [frame, framePos, corrVal, topSurf, xShift, yShift, xPos, yPos,
%    correlRecord] = corr_reg_7(filename, startIm, endIm, surfFilterSize, 
%                               highPassFilterSize, smoothFilterSize, 
%                               roiHeight, roiWidth, roiOffset, corrThresh)
% Parameters:
%  filename           : Either tif stack filename or 3D array in memory
%  startIm            : First image in file/array to use
%  endIm              : Last each in file/array to use (-1 = all)
%  surfFilterSize     : Size of smoothing filter used in surface detection 
%  highPassFilterSize : Size of mean filter used to remove structure
%  smoothFilterSize   : Size of Gaussian filter used to supress noise
%  maskThresh         : Threshold for specularity mask (multiple of mean)
%  roiHeight          : Vertical size of ROI used to calculate correlation
%  roiWidth           : Horizontal size of ROI used to calculate correlation
%  roiOffset          : Vertical position of top of ROI relative to detected
%                       surface
%  corrThresh         : Decorrelation beyond which considered a new frame
%   
%
% Returns:
%
% frame               : Vector of frame numbers of B-scans roughly equally 
%                       spaced in out-of-plane distance.
% framePos            : Vector of estimated true out-of-plane positions that 
%                       each frame in framePos should be at.
% corrVal             : Vector of correlation of each frame in 'frame'
%                       with previous frame in 'frame'. 
% topSurf             : Vector of estimated top surface position of each 
%                       image in 'frame'.
% xShift              : Vector of lateral shifts of each frame in 'frame' relative
%                       to previous.
% yShift              : Vector of depth shifts of each frame in 'frame' relative
%                       to previous.
% xPos                : Vector of estimated lateral (in plane) shift of each
%                       frame in 'frame' relative to first frame.
% yPos                : Vector of estimated depth shift of each
%                       frame in 'frame' _relative to _previous frame's
%                       detected top surface_.
% correlRecord        : Correlation of each frame in stack relative to
%                       last reference frame.

function [frame, framePos, corrVal, topSurf, xShift, yShift, xPos, yPos, correlRecord] = corr_reg_7(filename, startIm, endIm, surfFilterSize, highPassFilterSize, smoothFilterSize, maskThresh, roiHeight, roiWidth, roiOffset, corrThresh)


    % Handle endIm == -1;
    nFrames = get_num_frames(filename);
    if endIm < 0; endIm = nFrames; end
    endIm = min(endIm, nFrames);
    
   
    
    % We always use the first frame
    cFrame = 1;
    frame(cFrame) = startIm; 
    corrVal(cFrame) = 0;
    xShift(cFrame) = 0;
    yShift(cFrame) = 0;
    framePos(cFrame) = 1;
    framePos(cFrame) = 1;
    
    

    for iIm = startIm:endIm
    
        % Load images
        im = extract_image(filename, iIm);

        % Left hand co-ord of ROI
        leftROI = floor((size(im,2) - roiWidth) /2);

        % Bandpass filter
        imFilt = filter_image(im, highPassFilterSize, smoothFilterSize);
        
        % If this is not the first image than we know where 
        % top surface is so pull out the ROI and do correlation
        if iIm > startIm
           
            % Extract the roi used as a template
            roiFilt = imcrop(imFilt, [leftROI, surfaceSimple + roiOffset, roiWidth - 1, roiHeight - 1]);
            roi = imcrop(im, [leftROI, surfaceSimple + roiOffset, roiWidth - 1, roiHeight - 1]);
                                  
            % The cross-correlation. We find the peak from the cross correlation of
            % the unfiltered images, and the value from the correlation of
            % the filtered images
            xc = normxcorr2e(roi, refIm, 'valid');
            [~, peakLocation] = max(xc(:));
            [peakY2, peakX2] = ind2sub([size(xc,1), size(xc,2)], peakLocation);
            xSh = peakX2 - (size(xc,2) - 1) / 2;
            ySh = peakY2 - (surfaceSimple + roiOffset);
                     
            dilateSize = highPassFilterSize;  % Mask needs to be this size to mask out blurred specularities due to HP Filter
            compRegion = imcrop(circshift(refImFilt,[-ySh,-xSh]), [leftROI, surfaceSimple + roiOffset, roiWidth - 1, roiHeight - 1]);

            [~,maskCrop] = remove_outlier_pixels(roi, maskThresh, dilateSize);
            
            % Convert the ROIs and mask to vectors so we can remove masked elements
            roiFiltV = roiFilt(:);
            maskV = maskCrop(:);
            roiFiltVMasked = roiFiltV(~maskV);
            compRegionV = compRegion(:);
            compRegionVMasked = compRegionV(~maskV);
            
            % The correlation for out-of-plane motion            
            correl = corr(roiFiltVMasked, compRegionVMasked);
           
            correlRecord(iIm - startIm + 1) = correl;
                        
            
            debug = 0;
            if debug 
                figure(100);
                subplot(2,3,1); imagesc(im); colormap(gray);
                subplot(2,3,2); imagesc(roi); colormap(gray);
                subplot(2,3,3); imagesc(imFilt); colormap(gray);
                subplot(2,3,4); imagesc(roiFilt); colormap(gray);
                subplot(2,3,5); imagesc(~maskCrop); colormap(gray);
                subplot(2,3,6); imagesc(roiFilt.*(~maskCrop));
                drawnow();
                fprintf('Frame %1f, Correlation %1.2f, Used Frame: %1f \n', iIm, correl, cFrame);
            end
            
          
            
           
            % If correlation is low enough so that we we think we have
            % moved to the next line...
            if correl < corrThresh  
                
                corrBelow = (corrThresh - correl);
                estShift = 1 + corrBelow / (1 - corrThresh);
                              
                cFrame = cFrame + 1;             % We have found another B scan
                
                frame(cFrame) = iIm;             % Record this for later reocon
                framePos(cFrame) = framePos(cFrame - 1) + estShift;
              
                corrVal(cFrame) = correl;        % Not needed for recon, store for info
                topSurf(cFrame) = surfaceSimple; % Not needed for recon, store for info
                   
                % Store shifts detected by norm XC
                xShift(cFrame) = xSh;
                yShift(cFrame) = ySh;

            end
        end
    
        % If this is a reference image, we find the top surface
        % so we know where a good region of interest is.
        if iIm == startIm || correl < corrThresh   
          
            % Find top surface
            newSurface = find_top_surface2(im, surfFilterSize);
            if ~isnan(newSurface)
                surfaceSimple = newSurface;
            end
            if iIm == startIm 
                topSurf(1) = surfaceSimple;         % Not needed for recon, store for info
            end
            
            % Select this as the new reference image
            refImFilt = imFilt;
            refIm = im;

        end    
    end
    
    try
    xPos = cumsum(xShift);
    yPos = cumsum(yShift);
    catch % If we don't have any frames used this would lead to error
        xPos = 0;
        yPos = 0;
    end
    
    
end

