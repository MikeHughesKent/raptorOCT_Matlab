% Example generation of plot of B-scan decorrelation with out-of-plane  
% movement from single-axis scanning endoscopic OCT probe.
%
% Mike Hughes, m.r.hughes@kent.ac.uk
%
% Used to generate elements of Figure 3 of
%    Marques et al.,
%    "Endoscopic en-face optical coherence tomography and 
%     fluorescence imaging using a double-clad optical fiber 
%     and correlation-based probe tracking"
%
% Please refer to the paper for detailed descriptions of the code
% and cite the paper when re-using significant portions of the code.

clear
addpath('..\lib\utility');
addpath('..\lib\b_scan_assemble');

% B-Scan Assembly Method Parameters
roiHeight = 100;         % Vertical size of ROI
roiWidth = 180;          % Lateral size of ROI
roiOffset = 0;           % Vertical distance from detected surface to top of ROI
roiPos = -1;             % Horizontal position of ROI, -1 = centre
surfFilterSize = 30;     % Size of smoothing filter in pixels for surface detect    
highPassFilterSize = 5;  % Size of mean filter used to remove structure
smoothFilterSize = 1.5;  % Size of Gaussian smoothing filte to remove noise
maskThresh = 5;          % Mask pixels > this times mean   

movingFile = '..\example data\tissue velocity\tissue_0500ups_correlation.tif';
staticFile = '..\example data\tissue velocity\tissue_static.tif';

% Load in OCT B-scans
movingVol = double(read_volume_16bit(movingFile));
staticVol = double(read_volume_16bit(staticFile));

% Which images to use for static correlation analysis
staticRefIm = 1;
nStaticRuns = 20;

% Which images to use for moving correlation analysis
startIm = 1;
maxStep = 30;
nRuns = 50;

% Experimental parameters
OCTFrameRate = 250; %Hz
scanSpeed = 500;    %um/s

% Convert frame rate and known scan speed to motion between frames
OCTFrameTime = 1/ OCTFrameRate; %s
frameSeparation = scanSpeed * OCTFrameTime; %um


%% -- Measure decorrelation due to random noise (i.e. probe not in motion)
firstIm = staticRefIm;
lastIm = staticRefIm + nStaticRuns - 1;
corrThresh = -1;
[frame, pos, corrVal, topSurf, xShift, yShift, xPos, yPos, staticCurve] = corr_reg_7(staticVol, firstIm, lastIm, surfFilterSize, highPassFilterSize, smoothFilterSize, maskThresh, roiHeight, roiWidth, roiOffset, corrThresh);



%% --- Measure decorrelation as a function of out of plane movement
decorrelationCurveXCorrVals = zeros(nRuns, maxStep);
for ii = 1: nRuns
    fprintf('Run %d \n', ii);
    firstIm = startIm + ii;
    lastIm = firstIm + maxStep - 1;
    corrThresh = -1;    % This forces corr_reg to keep using the first frame as the reference which is what we want here
    [frame, pos, corrVal, topSurf, xShift, yShift, xPos, yPos, decorVals] = corr_reg_7(movingVol, firstIm, lastIm, surfFilterSize, highPassFilterSize, smoothFilterSize, maskThresh, roiHeight, roiWidth, roiOffset, corrThresh);
    decorrelationCurveXCorrVals(ii,1:maxStep) =  decorVals;
end
decorrelationCurveXCorr = mean(decorrelationCurveXCorrVals,1);
errXCurve = std(decorrelationCurveXCorrVals,1);

% Work out the physical distance corresponding to each frame from stage
% velocity
xScale = ((1: length(decorrelationCurveXCorr)) - 1 ) * frameSeparation;



%% --- Combine static and moving data

% The following averages correlations taken from non-moving frames,
% this becomes the correlation at 0 displacement for the plot. In general
% this is less than 1 and gives a more sensible curve fit
decorrelationCurveXCorrCorrected = decorrelationCurveXCorr;
decorrelationCurveXCorrCorrected(1) = mean(staticCurve);
errXCurveCorrected = errXCurve;
errXCurveCorrected(1) = std(staticCurve);



%% --- Gaussian fit
fitMaxDepth = 50; % microns
gaussEqn = '(c)*exp(-((x)/a)^2)+b';
startPoints = [ 15, 0,1];
fitLimit = find(xScale > fitMaxDepth, 1) - 1;
gaussFitCorrected = fit((xScale(1:fitLimit))',(decorrelationCurveXCorrCorrected(1:fitLimit))',gaussEqn,'Start', startPoints)';



%% --- Display 
figure(1)
clf
hold on
hE = errorbar(xScale, decorrelationCurveXCorrCorrected, errXCurveCorrected); 
hFit = plot(gaussFitCorrected);
hXLabel = xlabel (['Shift (', char(181), 'm)']); hYLabel = ylabel('Correlation'); %title('Decorrelation as function of out of plane movement distance, with static correction');
hold off
axis([0, 40,0,1]);
hLegend = legend('Measured value', 'Gaussian fit'); legend boxoff;
kent_plot_standard_1;

ax = gca;
ax.YRuler.TickLabelFormat = '%.1f';


%% --- Print fit parameters
fMax = gaussFitCorrected.c;
fMin = gaussFitCorrected.b;
sigma = gaussFitCorrected.a;
fwhm = 2*sqrt(2 * log10(2)) * sigma;
dropOff = 0.5;
dropOffDist = sqrt(log((dropOff - fMin) / fMax) * -sigma^2);
fprintf('Drops to correlation of %1.1f in %1.1f microns. \n', dropOff, dropOffDist);
fprintf('Speckle sigma is %1.1f microns, FWHM is %1.1f microns. \n', sigma, fwhm);
