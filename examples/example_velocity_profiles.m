% Example generation of plots of out-of-plane velocity
% from single-axis scanning endoscopic OCT probe.
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
addpath('..\lib\utility')
addpath('..\lib\b_scan_assemble');


% Input dataset
startIm = 1;    
endIm = 250;

% Acquisition frame rate, allows calibration of velocity
frameRate = 250;


% B-Scan Assembly Method Parameters
corrThresh = .5;

% These are the characteristic distances moved to achieve each
% decorrelation, extracted from decorrelation plot
corrDist = 10.4;  % microns

% Analysis Options
roiHeight = 100;         % Area this height in pixels is used
roiWidth = 180;          % Lateral size of xcorr template
roiOffset = 0;           % Position of top of ROI relative to surface
roiPos = -1;             % x position of ROI, -1 for centered.
surfFilterSize = 30;     % Size of smoothing filter in pixels for surface detect    
highPassFilterSize = 5;  % Size of mean filter applied to image and subtracted
smoothFilterSize = 1.5;  % Sigma of Gaussian filter applied
maskThresh = 5;          % Mask pixels > this times mean   

% Files
OCTFilename = {'..\example data\tissue velocity\tissue_0250ups.tif', ...
               '..\example data\tissue velocity\tissue_0500ups.tif', ...
               '..\example data\tissue velocity\tissue_1000ups.tif', ...
               '..\example data\tissue velocity\tissue_2000ups.tif', ...
               '..\example data\tissue velocity\tissue_3000ups.tif', ...
               '..\example data\tissue velocity\tissue_4000ups.tif'};


% Experimental speeds corresponding to each datatset           
speed = [0.25,0.5,1,2,3,4];  %mm/s

nRuns = length(speed);
runs = 1:6;

% Pre-allocate memory
maxFrames = 2000;
frameMap = zeros(nRuns,  maxFrames);
framePos = zeros(nRuns,  maxFrames);
xPosRec = zeros(nRuns,  maxFrames);
yPosRec = zeros(nRuns,  maxFrames);
nFrames = zeros(nRuns);


%% --------------- Perform registration - find out which frames would be used in reconstructed en face
for iRun = runs
    
    rawVolume = double(read_volume_16bit(OCTFilename{iRun}));
        
    [frame, pos, corrVal, topSurf, xShift, yShift, xPos, yPos] = corr_reg_7(rawVolume, startIm, endIm, surfFilterSize, highPassFilterSize, smoothFilterSize, maskThresh, roiHeight, roiWidth, roiOffset, corrThresh);
    
    nFrames (iRun) = length(frame);
    frameMap(iRun, 1:length(frame)) = frame;
    framePos(iRun, 1:length(frame)) = pos;
    xPosRec(iRun, 1:length(frame)) = xPos;
   
end



%% ------------------ Plots of mapped frame against raw frame (essentially position against time)
clear hData;
figure(1);
clf;
hold on
for iRun = runs
    hData{iRun} = plot(squeeze(framePos(iRun,1:nFrames(iRun))),squeeze(frameMap(iRun,1:nFrames(iRun))) - squeeze(frameMap(iRun,1)),'-' );
end
hold off

hXLabel = xlabel ('Corrected Volume B-scan Number');
hYLabel = ylabel('Raw B-scan Number');
hLegend = legend('0.25 mm/s', '0.5 mm/s', '1 mm/s', '2 mm/s', '4 mm/s', 'Location', 'southeast');
kent_plot_standard_2



%% -------------------- Plot graph of measured speed against actual speed 

% The gradient of the vector frame numbers where the correlation has dropped below threshold
% tells us how fast we are moving
for iRun = runs
    
    y = squeeze(frameMap(iRun,1:nFrames(iRun)))';
    x = squeeze(framePos(iRun,1:nFrames(iRun)))';

    [fit, fitErr] = polyfit(x, y,1);
    gradient(iRun) = fit(1);
    
    fitSimple = polyfit((1:length(y))',y,1);
    gradientSimple(iRun) = fitSimple(1);
        
end

measuredSpeed = corrDist ./ gradient * frameRate /1000;
measuredSpeedSimple = corrDist ./ gradientSimple * frameRate /1000;

figure(1);
clf;
hold on
hData = plot(speed(runs), measuredSpeed(runs), 'o');
hDataSimple = plot(speed(runs), measuredSpeedSimple(runs), 'kx');
hXLabel = xlabel('Stage velocity (mm/s)');
hYLabel = ylabel('Measured velocity (mm/s)');
title(['Est. speed from decorrelation distance, threshold ', num2str(corrThresh)]);
axis([0, max(speed) + 0.5, 0, max(measuredSpeed) + 0.3]);


% Fit line
y = measuredSpeed(1:2)';
x = speed(1:2)';
slope = x\y;
fitXVals = linspace(0,4,100);
fitYVals = slope * fitXVals;
hold on
hData2 = plot(linspace(0,4,10), linspace(0,4,10), 'k--');
hLegend = legend('Interpolation', 'Simple', 'Expected', 'Location','northwest');
legend boxoff
kent_plot_standard_1
set(hData, 'MarkerSize', 6);
set(hDataSimple, 'MarkerSize', 6, 'LineWidth', 2);
set(hData2, 'LineWidth', 2);
ax = gca;
ax.YRuler.TickLabelFormat = '%.1f';
hold off



%% ---------------- Plots of velocity as a function of time
for iRun = runs
    
    map = squeeze(frameMap(iRun,1:nFrames(iRun)))';
    pos = squeeze(framePos(iRun,1:nFrames(iRun)))';
    velInterp = corrDist .* frameRate /1000 .* diff(pos)./diff(map);
    velSimple = corrDist .* frameRate /1000 ./ diff(map);
    velMean(iRun) = mean(velInterp);
    velSD(iRun) = std(velInterp);
    timePoints = (map(2:end) - map(2)) / frameRate;
    
    figure(100 + iRun);
    hData = plot(timePoints, velInterp, 'k-');
   
    hXLabel = xlabel('Time (s)');
    hYLabel = ylabel('Velocity (mm/s)');
    line([0,100], [speed(iRun), speed(iRun)],'Color',[0 0 0],'LineWidth', 2, 'LineStyle', '--')
    hLegend = legend('Measured', 'Expected');
    
    kent_plot_standard_1
    set(hData, 'LineStyle', '-');
    axis([0, max(timePoints),0, speed(iRun) + 1]);
    ax = gca;
    ax.YRuler.TickLabelFormat = '%.1f';
    
end

%% Make a combined plot for the four lowest velocities
combineRuns = [1,2,3,4];
figure(10); clf; hold on
for iRun = combineRuns
    
    map = squeeze(frameMap(iRun,1:nFrames(iRun)))';
    pos = squeeze(framePos(iRun,1:nFrames(iRun)))';
    velInterp = corrDist .* frameRate /1000 .* diff(pos)./diff(map);
    velSimple = corrDist .* frameRate /1000 ./ diff(map);
    timePoints = (map(2:end) - map(2)) / frameRate;
      
    hData2 = line([0,100], [speed(iRun), speed(iRun)],'Color',[0 0 0],'LineWidth', 2, 'LineStyle', '--');
    hData = plot(timePoints, velInterp, 'k-');
   
    hXLabel = xlabel('Time (s)');
    hYLabel = ylabel('Velocity (mm/s)');
    hLegend = legend('Expected', 'Measured', 'Location', 'northwest');
    legend boxoff;
    kent_plot_standard_1
    set(hData, 'Marker' , 'none');
        
    set(hData2, 'LineStyle', ':', 'Color', 'r', 'MarkerSize' , 2);
    axis([0, max(timePoints),0, speed(iRun) + 2]);
   
    
end
hold off
ax = gca;
ax.YRuler.TickLabelFormat = '%.1f';

%% Print average speeds and standard deviations
for iRun = runs
    fprintf('Speed %1.2f mm/s, Mean: %1.2f mm/s, SD: %1.2f mm/s \n', speed(iRun), velMean(iRun), velSD(iRun));
end


    
