%This function allows the camera to acquire image while the stage is
%running. We assume that it is in Light sheet mode and that all the
%parameters were calibrated properly. We assume that the stage is in the
%middle position in order to make sure that the focus is in the middle

%Inputs:
%controlParameters.MMC - the jave MM object
%controlParameters.stageLabel - as defined in MM
%frameRate - [Hz]
%numOfImages - the number of images to capture
%stepSize - the required axial scan resolution
%pathToSave - the directory to save the images
%filePrefix - the prefix to use for the pictures names
%tifFormat - writing the images as tif or bin 
%overlapBetweenZScans - the overlaps between different Z scans
%controlParameters.sDetLens - the serial struct for the detection objective
%absoluteMovementVector - the location of the detection lens vs frame
%                         numbers
%frameNumberToMoveVector - the frame number coresponding to the objective
%location
%delayImages - the number of images that are repeated due to the delay
%between the stage and the camera

function [] = CaptureAStackWhileStageRunningExternalTriggerV6(controlParameters, allLasers,...
    absoluteMovementVector, frameNumberToMoveVector, frameRate, ...
    numOfImages, laserPowerVector, frameNumberToMoveVectorLaserPower, wavelength...
    , stepSize, pathToSave, tifFormat, delayImages)
    
    %First take care that the detection objective is in the right location
    %and minimize backlash by approaching the right direction of movement
    [curPos] = GetPos(controlParameters.sDetLens);
    stageSpeedDuringScan = '0.25';
    fprintf(controlParameters.sDetLens,['1VA',stageSpeedDuringScan]); 
    delta = 0.005; %The value of the overshoot to correct for backlash
    confidenceMargin = 0.1; %Make sure we do not move the objective above this value
    
    %check which direction the objective needs to go to
    if ((absoluteMovementVector(end) - absoluteMovementVector(1)) > 0)
       signOfMovement = 1;                
    else
       signOfMovement = -1;
    end
            
    diff = absoluteMovementVector(1) - str2double(curPos) - signOfMovement*delta;
    
    %Check that it does not move more than 100 um
    if (abs(diff) > (confidenceMargin)) 
        diff = 0.001;
        display('Error in pos calculation');
    end
    %The second move of the delts will make sure that the stage compensated
    %for backlash when we start the scan
    fprintf(controlParameters.sDetLens,['1PR',num2str(diff)]);    
    
    %Configure the buffer the largest allowed in Java
    controlParameters.MMC.setCircularBufferMemoryFootprint(1024*8);
    controlParameters.MMC.setTimeoutMs(500000);
    
    %Get the current speed and save it for later
    currSpeed = controlParameters.MMC.getProperty(controlParameters.stageLabel,'Speed-S');
    
    %Calc the required speed in [mm/sec]
    setSpeedOfStage = frameRate*stepSize/1000;
        
    width = controlParameters.MMC.getImageWidth();
    height = controlParameters.MMC.getImageHeight();
    pixelType = 'uint16';
        
    %Set the shutter off
    controlParameters.MMC.setAutoShutter(false);
    
    %Clear any images from the circular buffer and prep the camera
    controlParameters.MMC.clearCircularBuffer;
    
    fprintf(controlParameters.sDetLens,['1PR',num2str(signOfMovement*delta)]);
    %Wait for two seconds to be sure that the detection stage is in the right
    %position 
    pause(2);
    %controlParameters.MMC.prepareSequenceAcquisition(cameraLabel);
        
    %Set the speed and make sure it was written
    controlParameters.MMC.setProperty(controlParameters.stageLabel,'Speed-S', setSpeedOfStage);
    val = controlParameters.MMC.getProperty(controlParameters.stageLabel,'Speed-S');
    display(['Speed was set to ',char(val),' mm/sec']);
    
    controlParameters.MMC.setShutterOpen(true);
    
    %Start capturing images for some reason it seems that the stage is faster than the camera    
    %The interval does not work currently Andor bug the exposure time
    %determines the intervals
    showImageEveryHowManyFrames = 20;
    intervalMs = 0;
    stopOnOverflow = true;
    controlParameters.MMC.startSequenceAcquisition(numOfImages + delayImages, intervalMs, stopOnOverflow);
    numOfImagesToWait = 20;
    
    %Start the stage scan, the direction is negative
    pos1 = controlParameters.MMC.getXYStagePosition(controlParameters.stageLabel);
    newRelativePosX = -abs(numOfImages*stepSize);
    controlParameters.MMC.setXYPosition(controlParameters.stageLabel, pos1.x + newRelativePosX, pos1.y);
    
    %Let the camera put some images in the buffer before writing to memory
%     while ((controlParameters.MMC.getBufferTotalCapacity - controlParameters.MMC.getBufferFreeCapacity) ~= numOfImagesToWait)
%         %(controlParameters.MMC.getBufferTotalCapacity - controlParameters.MMC.getBufferFreeCapacity)
%     end
    pause(2);
    
    %Show the first image
    f = figure;
    hAxes = subplot(1,1,1);
    img = controlParameters.MMC.getLastImage();
    img = typecast(img, pixelType);      % pixels must be interpreted as unsigned integers
    img = reshape(img, [width, height]); % image should be interpreted as a 2D array
    img = transpose(img);                % make column-major order for MATLAB
    hImage = imshow(img,'Parent',hAxes, 'DisplayRange', []); 
    
    %Tells us if the sequence stopped running
    %stopFlag = true;
    
    movedTheStage = false;
    tic;
    
    indexForObjectiveCorrection = 2;
    indexForPowerCorrection = 2;
    frameNumberToMoveVector = [frameNumberToMoveVector inf];
    
    for ii = 1:(numOfImages + delayImages)
        
        %ii
        
        if ((controlParameters.MMC.getBufferTotalCapacity - controlParameters.MMC.getBufferFreeCapacity) == 0)
            pause(1);
        end
        
        %pop the images from the stack one by one
        img = controlParameters.MMC.popNextImage();
        img = typecastFast(img, pixelType);      % pixels must be interpreted as unsigned integers
        
        if (tifFormat)
            
            if (ii > delayImages) 
                
                filePrefixStr = num2str((ii - delayImages)*stepSize*10);
                filePrefix = '000000';
                switch numel(filePrefixStr)
                    case 1 
                        filePrefix(6) = filePrefixStr;
                    case 2 
                        filePrefix(5:6) = filePrefixStr;
                    case 3
                        filePrefix(4:6) = filePrefixStr;
                    case 4   
                        filePrefix(3:6) = filePrefixStr;
                    case 5   
                        filePrefix(2:6) = filePrefixStr;
                    case 6 
                        filePrefix(1:6) = filePrefixStr;
                end
            
                img = reshape(img, [width, height]); % image should be interpreted as a 2D array
                %Transpose is too slow
                %img = transpose(img);                % make column-major order for MATLAB
                cmd = ['imwrite(img,','''',pathToSave,'\',filePrefix,'.tiff'');'];
                eval(cmd);
                if (mod(ii,showImageEveryHowManyFrames) == 0);
                    img = transpose(img);
                    set(hImage,'CData',img); pause(0.01);
                end
            
            end
         
        else
            
           if (ii > delayImages)   
                
                filePrefixStr = num2str((ii - delayImages)*stepSize*10);
                filePrefix = '000000';
                switch numel(filePrefixStr)
                    case 1 
                        filePrefix(6) = filePrefixStr;
                    case 2 
                        filePrefix(5:6) = filePrefixStr;
                    case 3
                        filePrefix(4:6) = filePrefixStr;
                    case 4   
                        filePrefix(3:6) = filePrefixStr;
                    case 5   
                        filePrefix(2:6) = filePrefixStr;
                    case 6 
                        filePrefix(1:6) = filePrefixStr;
                end
                
                %Write bin
                cmd = ['fid = fopen(''',pathToSave,'\',filePrefix,'.bin''',',''w''',');'];
                eval(cmd);
                fwrite(fid,img,'uint16');        
                fclose(fid);
                if (mod(ii,showImageEveryHowManyFrames) == 0);
                    img = reshape(img, [width, height]); % image should be interpreted as a 2D array
                    img = transpose(img);  
                    set(hImage,'CData',img); pause(0.01);
                end
            end
            
        end
        
        %Check if it is time to move the detection objective
        if (ii + delayImages + controlParameters.MMC.getRemainingImageCount() > frameNumberToMoveVector(indexForObjectiveCorrection))
            
            %Debug
            [curPos] = GetPos(controlParameters.sDetLens);
            diff = absoluteMovementVector(indexForObjectiveCorrection) - str2double(curPos);
    
            %Check that it does not move more than 100 um
            if (abs(diff) > (confidenceMargin)) 
                diff = 0.001;
                display('Error in pos calculation');
            end
            %The second move of the delts will make sure that the stage compensated
            %for backlash when we start the scan
            fprintf(controlParameters.sDetLens,['1PR',num2str(diff)]);  
            indexForObjectiveCorrection = indexForObjectiveCorrection + 1;
            display(['Obj moved #',num2str(ii + delayImages + controlParameters.MMC.getRemainingImageCount())]);                        
        end
        
        %Check if it is time to increase the power
        if (ii + delayImages + controlParameters.MMC.getRemainingImageCount() > frameNumberToMoveVectorLaserPower(indexForPowerCorrection))
            focusingFilter = false;
            %Change the power
            SetPowerOfLasersV3(allLasers, controlParameters.sFWExt, controlParameters.sFWDet, wavelength, laserPowerVector(indexForPowerCorrection), focusingFilter);
            indexForPowerCorrection = indexForPowerCorrection + 1;                        
            
        end
        
        
        %When done turn off the shutter to prevent photo bleaching and move
        %the stage to the starting point since it takes time  
        if (((ii + controlParameters.MMC.getRemainingImageCount() + delayImages) > numOfImages - 1) && (~movedTheStage))
            
           movedTheStage = true; 
           %Set the speed to the previous value
           controlParameters.MMC.setProperty(controlParameters.stageLabel,'Speed-S', currSpeed);
           val = controlParameters.MMC.getProperty(controlParameters.stageLabel,'Speed-S');
           display(['Speed was set to ',char(val),' mm/sec']);
           pause(1);
           controlParameters.MMC.setShutterOpen(false);
           %Move the stage to the starting point in order to save time
           controlParameters.MMC.setXYPosition(controlParameters.stageLabel, pos1.x , pos1.y);
           
        end
    
        
    end
    toc;
    controlParameters.MMC.isSequenceRunning;
    controlParameters.MMC.setShutterOpen(false);
    [curPos] = GetPos(controlParameters.sDetLens);    
        
    %Move the detection lens to the start point
    [curPos] = GetPos(controlParameters.sDetLens);
    diff = absoluteMovementVector(1) - str2double(curPos);
    
    %Check that it does not move more than 100 um
    if (abs(diff) > (confidenceMargin)) 
        diff = 0.001;
        display('Error in pos calculation');
    end
    
    %The second move of the delts will make sure that the stage compensated
    %for backlash when we start the scan
    fprintf(controlParameters.sDetLens,['1PR',num2str(diff)]);   
        
    %Wait for the stage to reach its location
    controlParameters.MMC.waitForDevice(controlParameters.stageLabel);
    %[diffInPos] = MoveXYStageRelative(controlParameters.MMC, controlParameters.stageLabel, -newRelativePosX, 0);
    %display(['the stage move to the following position X = ', num2str(-diffInPos(1)),' , Y = ', num2str(-diffInPos(2))]);
         
    controlParameters.MMC.clearCircularBuffer;    
    controlParameters.MMC.setAutoShutter(true);
        
end

