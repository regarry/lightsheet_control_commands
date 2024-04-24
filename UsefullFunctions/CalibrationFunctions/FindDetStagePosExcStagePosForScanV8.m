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

function [scanCalibrationParameters, lightPath] = FindDetStagePosExcStagePosForScanV8(controlParameters, allLasers, wavelength, lightPath, intensityInMW, ...
    expTime, lightSheetMode, autoParameters)
    
    %i.e there is a good estimate for the values and you can use that,
    %would be applicable if autofocus scan is done before
    if (nargin < 8)
        presetValues = false;
    else
        presetValues = true;
    end
        
    %Parameters:
    addLine = false;
    focusingFilter = false;
    Value = controlParameters.MMC.getProperty(controlParameters.cameraLabel, 'Exposure');
    frameRate =  1000/str2num(char(Value));    
    
    % For debug 
    % showImages = true;
    
    controlParameters.MMC.setTimeoutMs(500000);
    
    %Find all the initial parameters 
    %-----
    %Find the sample stage position
    [initSampleXPos, initSampleYPos, initSsampleZPos] = GetXYZPosition(controlParameters.MMC);
    
    %Find the position of the first excitation stage
    [posExtLens] = GetPos(controlParameters.sExtLens);   
    
    %Find the position of the second excitation stage
    [posExtLens2] = GetPos(controlParameters.sExtLens2);
    
    %Find the position of the detection stage
    [posDetLens] = GetPos(controlParameters.sDetLens); 
    
    %Set the output structure
    scanCalibrationParameters = struct('sampleXPos',initSampleXPos, 'sampleYPos', initSampleYPos, 'sampleZPos', initSsampleZPos ,...
        'posExtLens', posExtLens, 'posExtLens2', posExtLens2, 'posDetLens', posDetLens, 'intensityInMW', intensityInMW, 'invalidTile', false, 'wavelength', wavelength, 'whichLightPath', lightPath);
    %-----
        
    %Move to the values that were acquired using autofocus/manual
    %focusing previously
    if (presetValues)        
        %Make sure that you in the right light path
        [lightPath] = ChangeLightPath(controlParameters, allLasers, wavelength, lightPath, autoParameters(1).whichLightPath, lightSheetMode); 
        MoveStagesToDesiredLocationTwoExtStages(controlParameters,...
        autoParameters(1).posExtLens,...
        autoParameters(1).posExtLens2,...
        autoParameters(1).posDetLens); 
        SetPowerOfLasersV3(allLasers, controlParameters.sFWExt, controlParameters.sFWDet, wavelength, autoParameters(1).intensityInMW, focusingFilter);        
    end
            
    %Manual focusing
    [markedParameters, wavelength, intensityInMW, expTime, lastPosDetStage, lastPosExtStage, indWavelength, invalidTile, focusParameters, lightPath] = ControlDCMotorUsingKeyboardV12(...
                lightPath, controlParameters, allLasers, frameRate, expTime,...
                wavelength, intensityInMW, focusingFilter, lightSheetMode, addLine);
        
    scanCalibrationParameters = focusParameters;
    scanCalibrationParameters(1).invalidTile = invalidTile;
    scanCalibrationParameters(1).intensityInMW = intensityInMW;
    
    %Go to the first recorded position
    [~, ind] = sort([scanCalibrationParameters.sampleXPos]);
    scanCalibrationParameters = scanCalibrationParameters(ind);

    %Go back to the original X position of the stage
    [xPos, yPos, zPos] = GetXYZPosition(controlParameters.MMC);
    dx = scanCalibrationParameters(1).sampleXPos - xPos; dy = 0; %initSampleYPos - yPos;
    dz = 0; %initSsampleZPos - zPos;
    [newPosX, newPosY, newPosZ] = SetRelativeXYZPosition(controlParameters.MMC, dx, dy, dz );
    controlParameters.MMC.waitForDevice(controlParameters.stageLabel);

    %Return the detection objective to the first position
    [curPos] = GetPos(controlParameters.sDetLens);
    diff = scanCalibrationParameters(1).posDetLens - str2double(curPos);
    %Check that it does not move more than 20 um
    if (abs(diff) > 0.2)
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
