%This function fits a line to the detection lens locations and finds the
%required speed for the detection lens, that will be used in the same time
%with the objective lens
function [relativeMovementVector, timePointsVector, frameNumberToMoveVector] = CreateADetLensCalibCurveV2(scanCalibrationParameters, frameRate, ...
    stepSize, depthOfScan, toleranceInFocusUm)

    %For debug purposes
    showImages = true;

    %Get the required values from the structure
    detLensVector = zeros(1,numel(scanCalibrationParameters));
    xPosVector = zeros(1,numel(scanCalibrationParameters));
    for ii = 1:numel(scanCalibrationParameters)
        detLensVector(ii) = scanCalibrationParameters(ii).posDetLens;
        xPosVector(ii) = scanCalibrationParameters(ii).sampleXPos;
    end
    
    numOfImages = depthOfScan/stepSize;
    accumulatedTime = numOfImages/frameRate; %sec    
    
    timeVector = linspace(0,accumulatedTime,numel(scanCalibrationParameters));
    
    P = polyfit(timeVector,detLensVector,1);    
    detLensSpeed = P(1);
    initialPos =  P(2);    
    
    if (showImages)
        figure; plot(timeVector, detLensVector*1000); xlabel('Time [sec]'); ylabel('Position of detection objective [um]');        
        yfit = P(1)*timeVector+P(2);   
        yfit = yfit*1000;
        hold on;            
        display(['Speed it equal to ',num2str(P(1)),'[mm/sec]']);
        plot(timeVector,yfit,'r-.');      
        hold off;        
    end
    
    %check which direction the objective needs to go to
    if ((detLensVector(end) - detLensVector(1)) > 0)
        %negativeDirection = false;      
        toleranceInFocusMm = abs(toleranceInFocusUm)/1000;
        diffVector = diff(detLensVector);
        ind = find(diffVector < 0);
        detLensVector(ind + 1) = detLensVector(ind);        
    else
        toleranceInFocusMm = -1*abs(toleranceInFocusUm)/1000;
        diffVector = diff(detLensVector);
        ind = find(diffVector > 0);
        detLensVector(ind + 1) = detLensVector(ind);   
    end
    
    
    
    relativeMovementVector = []; 
    timePointsVector = [];
    
    %Look for the points to move the objective
    for ii = 1:(numel(detLensVector) - 1)
        
        slop = (detLensVector(ii+1) - detLensVector(ii))/(accumulatedTime/(numel(detLensVector)-1));
        %initialpoint = detLensVector(ii);
        numOfMovementPointsInSegment = floor((detLensVector(ii+1) - detLensVector(ii))/(toleranceInFocusMm)) + 1;
        addVectorTime = zeros(1,numOfMovementPointsInSegment);
        addVectorRelativeLocation = zeros(1,numOfMovementPointsInSegment);
        
        for jj = 1:numOfMovementPointsInSegment
            addVectorRelativeLocation(jj) = detLensVector(ii) + toleranceInFocusMm*(jj-1); 
            timeValue = toleranceInFocusMm*(jj-1)/slop;
            addVectorTime(jj) = (ii-1)*(accumulatedTime/(numel(detLensVector)-1)) + timeValue;            
        end                
        %Check if the last point is too close to the edge
        if (abs(detLensVector(ii+1) - (toleranceInFocusMm*(jj-1) + detLensVector(ii))) < (abs(toleranceInFocusMm/4)) )
            addVectorTime(jj) = [];
            addVectorRelativeLocation(jj) = [];
        end
               
        relativeMovementVector = [relativeMovementVector addVectorRelativeLocation];
        timePointsVector = [timePointsVector addVectorTime];        
    end
    
    relativeMovementVector = [relativeMovementVector detLensVector(end)];
    timePointsVector = [timePointsVector accumulatedTime];
    frameNumberToMoveVector = round(timePointsVector*frameRate);     
    
    if (showImages)
        figure; plot(timeVector, detLensVector*1000, '*', timePointsVector, relativeMovementVector*1000, 'o');
        xlabel('Time [sec]'); ylabel('Position of detection objective [um]');
    end
    
end