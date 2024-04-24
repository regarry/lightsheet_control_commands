%This function fits a line to the detection lens locations and finds the
%required speed for the detection lens, that will be used in the same time
%with the objective lens
function [laserPowerVector, timePointsVectorLaserPower, frameNumberToMoveVectorLaserPower] = CreateALaserPowerCalibCurveV1(scanCalibrationParameters, frameRate, ...
    stepSize, depthOfScan)

    %For debug purposes
    showImages = true;

    %Get the required values from the structure
    laserPowerVector = zeros(1,numel(scanCalibrationParameters));
          
    for ii = 1:numel(scanCalibrationParameters)
        laserPowerVector(ii) = scanCalibrationParameters(ii).intensityInMW;        
    end
    
    numOfImages = depthOfScan/stepSize;
    accumulatedTime = numOfImages/frameRate; %sec    
    
    timePointsVectorLaserPower = linspace(0,accumulatedTime,numel(scanCalibrationParameters));
    frameNumberToMoveVectorLaserPower = linspace(0,numOfImages,numel(scanCalibrationParameters));   
    
    %For the "CaptureAStackWhileStageRunningExternalTriggerV6" function I add inf in the end
    frameNumberToMoveVectorLaserPower = [frameNumberToMoveVectorLaserPower inf];
    
    
end