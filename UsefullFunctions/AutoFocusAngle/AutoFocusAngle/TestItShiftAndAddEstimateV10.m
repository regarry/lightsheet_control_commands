
%this script is built to test the Shift and Add SR method 

%Rotation images
fileDirEst = 'H:\Tests\140313_Tissue_Laser\V\-30Deg\';
fileDirSolve = fileDirEst;
fileString = '*.bin';
radius = 100;

% vPoint =  1388;
% hPoint =  3169;

%Zone2 
vPoint =  2447;
hPoint =  2326;

resFactor = 4;


radiusH = 200;
radiusV = 200;

%Do not change this value 
correlationRadiusCoarse = 50;
correlationRadiusFine = 25;

showFigures = 1;
RGBchannels = [0 1;1 0];
filterIt = 0;

[HR_image shiftMatrix] = SA_MC_V10(fileDirEst,fileDirSolve, fileString, vPoint, hPoint, resFactor, radiusH, radiusV,...
    showFigures, RGBchannels, filterIt, correlationRadiusCoarse, correlationRadiusFine, [vPoint hPoint]);

save HR_image HR_image;
