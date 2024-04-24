%This function goes along the scan and find the right focus point for the
%detection objective and the excitation objective. The function assumes that
%for autofocus of the detection objective the best algorithm is sobel variance
%while for the excitation objective the best algorithm is intensity variance  
%Inputs:
%depthOfScan - a number in [um]
%numOfTestPointsAlongTheScan - an integer number
%relativePositionRangeUm - the range for the aluto focus algorithm in Z
%scanResUm - the scan resolution in um
%controlParameters.sExtLens - the serial object to control the excitation lens
%controlParameters.sDetLens - the serial object to control the detection lens
%controlParameters.MMC - the MM structure
%controlParameters.cameraLabel - the label of the camera as called in MM
%controlParameters.stageLabel - the label of the stage
%expTime - the exposure time will be ignored if runnining in light-sheet
%mode
%lightSheetMode - if running in light-sheet mode the exposure should not
%manualFocus - should the focusing done manually ?
%change
%Outputs:
%scanCalibrationParameters - a structure that contain the position of the sample stage when the autofocus happened 
%               - , the power of the laser ,and the poistion of the excitatyion lens and detection lens  

function [scanCalibrationParameters] = FindDetStagePosExcStagePosForScanV5(depthOfScan,...
    numOfTestPointsAlongTheScan, relativePositionRangeDetUm, scanResDetUm, relativePositionRangeExtUm, ...
    scanResExtUm, controlParameters, allLasers, wavelength, intensityInMW, ...
    expTime, whichQualityMeasure, lightSheetMode, manualFocus, focusFilter, autoParameters)
    
    %i.e there is a good exstimate for the values and you can use that,
    %would be applicable if autofocus scan is done before
    if (nargin < 16)
        presetValues = false;
    else
        presetValues = true;
    end
    
    %Assume that the focusing is on the sample
    focusingFilter = focusFilter;
    
    %Parameters:
    moveToBestFocalPoint = true;
    aveNum = 1;      
    addLine = false;
    
    %For debug 
    showImages = true;
    controlParameters.MMC.setTimeoutMs(500000);
    
    % Check the input
    if (numOfTestPointsAlongTheScan < 1)
        numOfTestPointsAlongTheScan = 2;
    end
    
    % The stage movment 
    stepSizeSampleStageUm = depthOfScan/(numOfTestPointsAlongTheScan - 1);
    
    %Set the stage speed to 0.4 mm/sec
    controlParameters.MMC.setProperty(controlParameters.stageLabel,'Speed-S', 0.4);
    
    %Find the sample stage position
    [sampleXPos, sampleYPos, sampleZPos] = GetXYZPosition(controlParameters.MMC);
    
    %Find the position of the excitation stage
    [posExtLens] = GetPos(controlParameters.sExtLens);   
    
    %Find the position of the detection stage
    [posDetLens] = GetPos(controlParameters.sDetLens); 
    
    %Set the output structure
    scanCalibrationParameters = struct('sampleXPos',sampleXPos, 'sampleYPos', sampleYPos, 'sampleZPos', sampleZPos ,...
        'posExtLens', posExtLens, 'posDetLens', posDetLens, 'intensityInMW', intensityInMW);
    
    %For now canceled the excitation position focusing
    %Focus the excitation light if not manual focusing !!!!
    
    %Focus the detection lens
    for ii = 1:numOfTestPointsAlongTheScan
        
         %Move to the values that were acquired using autofocus/manual
         %focusing previously
         if (presetValues)      
             %If you changed it for the first scan leave it as is
             if (ii ~= 1)
                 autoParameters(ii).posExtLens = str2num(GetPos(controlParameters.sExtLens));                 
             end
                ChangeToPreset(controlParameters, autoParameters(ii));                  
                SetPowerOfLasersV3(allLasers, controlParameters.sFWExt, controlParameters.sFWDet, wavelength, autoParameters(ii).intensityInMW, focusingFilter);  
         end             
        
        %Do not move the stage for the first point
        if (ii ~= 1)
    
            % Start the stage scan, the direction is negative
            pos1 = controlParameters.MMC.getXYStagePosition(controlParameters.stageLabel);
            newRelativePosX = -abs(stepSizeSampleStageUm);
            controlParameters.MMC.setXYPosition(controlParameters.stageLabel, pos1.x + newRelativePosX, pos1.y);
            controlParameters.MMC.waitForDevice(controlParameters.stageLabel);
                       
        end
                       
        if (~manualFocus)

            [bestFocusPos, imageAtBestFocusPos, actualScanLocations, qualityMeasureVector] = FocusDetectionObjectiveV3(...
    relativePositionRangeDetUm, scanResDetUm, whichQualityMeasure, aveNum, ...
    controlParameters, expTime, moveToBestFocalPoint, lightSheetMode);
         
            %Show the images
            if (showImages)
                figure; imshow(imageAtBestFocusPos,[]);
                figure; plot(actualScanLocations, qualityMeasureVector); title('Detection Objective Location vs. Focus measure');
                bestFocusPos
            end
               
        else 
            focusingFilter = false;
            Value = controlParameters.MMC.getProperty(controlParameters.cameraLabel, 'FrameRate');
            frameRate =  str2num(char(Value));            
              [markedParameters, lastWavelength, lastIntensityInMW, lastExpTime, lastPosDetStage, lastPosExtStage, indWavelength] = ControlDCMotorUsingKeyboardV10(...
    controlParameters, allLasers, frameRate, expTime,...
    wavelength, intensityInMW, focusingFilter, lightSheetMode, addLine);
            
                                   
        end
        
        %Find the sample stage position
        [sampleXPos, sampleYPos, sampleZPos] = GetXYZPosition(controlParameters.MMC);
        
        %Find the position of the excitation stage
        [posExtLens] = GetPos(controlParameters.sExtLens);
        
        %Find the position of the detection stage
        [posDetLens] = GetPos(controlParameters.sDetLens);
        
        scanCalibrationParameters(ii).sampleXPos = sampleXPos;
        scanCalibrationParameters(ii).sampleYPos = sampleYPos;
        scanCalibrationParameters(ii).sampleZPos = sampleZPos;
        scanCalibrationParameters(ii).posExtLens = str2num(posExtLens);
        scanCalibrationParameters(ii).posDetLens = str2num(posDetLens);
        if (manualFocus)
            scanCalibrationParameters(ii).intensityInMW = lastIntensityInMW;   
        else
            scanCalibrationParameters(ii).intensityInMW = intensityInMW;
        end
        
        
    end
    
    %Go back to the original position of the stage
    pos1 = controlParameters.MMC.getXYStagePosition(controlParameters.stageLabel);
    newRelativePosX = abs(stepSizeSampleStageUm * (numOfTestPointsAlongTheScan - 1));
    controlParameters.MMC.setXYPosition(controlParameters.stageLabel, pos1.x + newRelativePosX, pos1.y);
    controlParameters.MMC.waitForDevice(controlParameters.stageLabel);
    
    %Return the detection objective to the first position
    [curPos] = GetPos(controlParameters.sDetLens);
    diff = scanCalibrationParameters(1).posDetLens - str2double(curPos);
    %Check that it does not move more than 20 um
    if (abs(diff) > 0.1)
        diff = 0.001;
        display('Error in pos calculation');
    end
    fprintf(controlParameters.sDetLens,['1PR',num2str(diff)]);

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

function ChangeToPreset(controlParameters, autoParameters)

    %Find the position of the excitation stage
    [posExtLens] = GetPos(controlParameters.sExtLens);

    %Find the position of the detection stage
    [posDetLens] = GetPos(controlParameters.sDetLens);

    %Excitation lens
    deltaForExt = autoParameters.posExtLens - str2num(posExtLens);
    %Move excitation lens
    if (abs(deltaForExt) < 2)
        fprintf(controlParameters.sExtLens,['1PR',num2str(deltaForExt)]);
    end

    %Detection lens
    deltaForDet = autoParameters.posDetLens - str2num(posDetLens);
    %Move excitation lens
    if (abs(deltaForDet) < 0.25)
        fprintf(controlParameters.sDetLens,['1PR',num2str(deltaForDet)]);
    end
    
    

end
