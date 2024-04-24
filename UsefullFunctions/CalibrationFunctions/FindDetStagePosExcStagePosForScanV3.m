%This function goes along the scan and find the right focus point for the
%detection objective and the excitation objective. The function assumes that
%for autofocus of the detection objective the best algorithm is sobel variance
%while for the excitation objective the best algorithm is intensity variance  
%Inputs:
%depthOfScan - a number in [um]
%numOfTestPointsAlongTheScan - an integer number
%relativePositionRangeUm - the range for the aluto focus algorithm in Z
%scanResUm - the scan resolution in um
%sExtLens - the serial object to control the excitation lens
%sDetLens - the serial object to control the detection lens
%mmc - the MM structure
%cameraLabel - the label of the camera as called in MM
%stageLabel - the label of the stage
%expTime - the exposure time will be ignored if runnining in light-sheet
%mode
%lightSheetMode - if running in light-sheet mode the exposure should not
%manualFocus - should the focusing done manually ?
%change
%Outputs:
%scanCalibrationParameters - a structure that contain the position of the sample stage when the autofocus happened 
%               - , the power of the laser ,and the poistion of the excitatyion lens and detection lens  

function [scanCalibrationParameters] = FindDetStagePosExcStagePosForScanV3(depthOfScan,...
    numOfTestPointsAlongTheScan, relativePositionRangeDetUm, scanResDetUm, relativePositionRangeExtUm, ...
    scanResExtUm, sExtLens, ...
    sDetLens, mmc, cameraLabel, stageLabel, expTime, lightSheetMode, manualFocus)
    
    %For debug 
    showImages = true;
    
    mmc.setTimeoutMs(500000);
    
    % Check the input
    if (numOfTestPointsAlongTheScan < 1)
        numOfTestPointsAlongTheScan = 2;
    end
    
    % The stage movment 
    stepSizeSampleStageUm = depthOfScan/(numOfTestPointsAlongTheScan - 1);
    
    %Set the stage speed to 0.4 mm/sec
    mmc.setProperty(stageLabel,'Speed-S', 0.4);
    
    %Find the sample stage position
    [sampleXPos, sampleYPos, sampleZPos] = GetXYZPosition(mmc);
    
    %Find the position of the excitation stage
    [posExtLens] = GetPos(sExtLens);   
    
    %Find the position of the detection stage
    [posDetLens] = GetPos(sDetLens); 
    
    %Set the output structure
    scanCalibrationParameters = struct('sampleXPos',sampleXPos, 'sampleYPos', sampleYPos, 'sampleZPos', sampleZPos ,...
        'posExtLens', posExtLens, 'posDetLens', posDetLens, 'laserControlVoltage', 1);
    
    if (~manualFocus)
        %I assume the excitation light does not change a lot only once
        aveNum = 1;
        whichQualityMeasure = 2;
        moveToBestFocalPoint = true;
        [bestExcitationLensPos, imageAtbestExcitationLensPos, actualScanLocations, qualityMeasureVector] = CenterTheLightSheetV2(relativePositionRangeExtUm, scanResExtUm,...
            whichQualityMeasure, aveNum, sExtLens, cameraLabel, mmc, expTime, moveToBestFocalPoint, lightSheetMode);

        %Show the images
        if (showImages)
            figure; imshow(imageAtbestExcitationLensPos,[]);
            figure; plot(actualScanLocations, qualityMeasureVector); title('Excitation objective Location vs. sample brightness');
            bestExcitationLensPos
        end
    end
            
    for ii = 1:numOfTestPointsAlongTheScan
        
        %Do not move the stage for the first point
        if (ii ~= 1)
    
            % Start the stage scan, the direction is negative
            pos1 = mmc.getXYStagePosition(stageLabel);
            newRelativePosX = -abs(stepSizeSampleStageUm);
            mmc.setXYPosition(stageLabel, pos1.x + newRelativePosX, pos1.y);
            mmc.waitForDevice(stageLabel);
            
        end
        
        if (~manualFocus)

            whichQualityMeasure = 3;

            moveToBestFocalPoint = true;

            [bestFocusPos, imageAtBestFocusPos, actualScanLocations, qualityMeasureVector] = FocusDetectionObjectiveV2(relativePositionRangeDetUm, scanResDetUm,...
                whichQualityMeasure, aveNum, sDetLens, cameraLabel, mmc, expTime, moveToBestFocalPoint, lightSheetMode);

            %Show the images
            if (showImages)
                figure; imshow(imageAtBestFocusPos,[]);
                figure; plot(actualScanLocations, qualityMeasureVector); title('Detection Objective Location vs. Focus measure');
                bestFocusPos
            end
               
        else 
            
            if (lightSheetMode)
                LiveModeExternalTriggerMove2Stages(sExtLens, sDetLens, mmc, cameraLabel);                               
            else
                Value = mmc.getProperty(cameraLabel, 'FrameRate');
                frameRate =  str2num(char(Value));
                ControlDCMotorUsingKeyboardV4(sExtLens, sDetLens, mmc, cameraLabel, frameRate, expTime, false);
            end
                          
        end
        
        %Find the sample stage position
        [sampleXPos, sampleYPos, sampleZPos] = GetXYZPosition(mmc);
        
        %Find the position of the excitation stage
        [posExtLens] = GetPos(sExtLens);
        
        %Find the position of the detection stage
        [posDetLens] = GetPos(sDetLens);
        
        scanCalibrationParameters(ii).sampleXPos = sampleXPos;
        scanCalibrationParameters(ii).sampleYPos = sampleYPos;
        scanCalibrationParameters(ii).sampleZPos = sampleZPos;
        scanCalibrationParameters(ii).posExtLens = str2num(posExtLens);
        scanCalibrationParameters(ii).posDetLens = str2num(posDetLens);
        
    end
    
    %Go back to the original position of the stage
    pos1 = mmc.getXYStagePosition(stageLabel);
    newRelativePosX = abs(stepSizeSampleStageUm * (numOfTestPointsAlongTheScan - 1));
    mmc.setXYPosition(stageLabel, pos1.x + newRelativePosX, pos1.y);
    mmc.waitForDevice(stageLabel);
    
    %Return the detection objective to the first position
    [curPos] = GetPos(sDetLens);
    diff = scanCalibrationParameters(1).posDetLens - str2double(curPos);
    %Check that it does not move more than 20 um
    if (abs(diff) > 0.1)
        diff = 0.001;
        display('Error in pos calculation');
    end
    fprintf(sDetLens,['1PR',num2str(diff)]);

end

function [pos] = GetPos(serial)
        
        maxSizeOfString = 7;        
        fprintf(serial,'1TP?');
        pos = fscanf(serial);
        k = strfind(pos,'TP');
        k = k(1);
        pos = pos(k+2:end);
        k = strfind(pos,'e');        
        if (~isempty(k))
            k = k(1);
            scale = pos(k+1:k+3);
            pos = pos(1:k-1);
            switch scale
                case '-06'
                    pos = num2str(0);
                case '-05'
                    pos = num2str(0);                
            end                   
        end
        
        if(numel(pos) > maxSizeOfString)
            pos = pos(1:maxSizeOfString);
        end       
            
end
