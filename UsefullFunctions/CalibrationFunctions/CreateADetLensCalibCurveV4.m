%This function fits a line to the detection lens locations and finds the
%required speed for the detection lens, that will be used in the same time
%with the objective lens
function [relativeMovementVector, timePointsVector, frameNumberToMoveVector] = CreateADetLensCalibCurveV4(scanCalibrationParameters, frameRate, ...
    stepSize, depthOfScan, addRangeToSlicesUM, toleranceInFocusUm)

    %For debug purposes
    showImages = true;

    %Get the required values from the structure
    detLensVector = [scanCalibrationParameters.posDetLens];
    xPosVector = [scanCalibrationParameters.sampleXPos];
    %Add a margin to the user specific bounderies
    xPosVector = [(xPosVector(1) - addRangeToSlicesUM), xPosVector, xPosVector(end) + addRangeToSlicesUM];
    detLensVector = [detLensVector(1) detLensVector detLensVector(end)];
   
    numOfImages = depthOfScan/stepSize;
    accumulatedTime = numOfImages/frameRate; %sec    
    
    %When will we reach this calibration points
    timeVector = (xPosVector - xPosVector(1))/(frameRate*stepSize);
    %timeVector = linspace(0,accumulatedTime,numel(scanCalibrationParameters));
    
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
    
    toleranceInFocusMm = toleranceInFocusUm/1000;
    %check which direction the objective needs to go to
%     if ((detLensVector(end) - detLensVector(1)) > 0)
%         %negativeDirection = false;      
%         toleranceInFocusMm = abs(toleranceInFocusUm)/1000;
%         diffVector = diff(detLensVector);
%         ind = find(diffVector < 0);
%         detLensVector(ind + 1) = detLensVector(ind);        
%     else
%         toleranceInFocusMm = -1*abs(toleranceInFocusUm)/1000;
%         diffVector = diff(detLensVector);
%         ind = find(diffVector > 0);
%         detLensVector(ind + 1) = detLensVector(ind);   
%     end
    
    relativeMovementVector = []; 
    timePointsVector = [];
    
    %Look for the points to move the objective
    for ii = 1:(numel(detLensVector) - 1)
        
        slop = (detLensVector(ii+1) - detLensVector(ii))/(timeVector(ii+1) - timeVector(ii));
        %initialpoint = detLensVector(ii);
        numOfMovementPointsInSegment = floor((detLensVector(ii+1) - detLensVector(ii))/(toleranceInFocusMm)) + 1;
        addVectorTime = zeros(1,numOfMovementPointsInSegment);
        addVectorRelativeLocation = zeros(1,numOfMovementPointsInSegment);
        
        for jj = 1:numOfMovementPointsInSegment
            addVectorRelativeLocation(jj) = detLensVector(ii) + toleranceInFocusMm*(jj-1);
            if (slop ~= 0)
                timeValue = abs(toleranceInFocusMm*(jj-1)/slop);
                addVectorTime(jj) = timeVector(ii) + timeValue;            
            else
                addVectorTime(jj) = timeVector(ii);
            end
        end  
        
        %Check if the last point is too close to the edge
        if (numOfMovementPointsInSegment > 1)
            if (abs(detLensVector(ii+1) - (toleranceInFocusMm*(jj-1) + detLensVector(ii))) < (abs(toleranceInFocusMm/4)) )
                addVectorTime(jj) = [];
                addVectorRelativeLocation(jj) = [];
            end
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