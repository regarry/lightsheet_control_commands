%This function allows the camera to acquire image while the stage is
%running. We assume that it is in Light sheet mode and that all the
%parameters were calibrated properly. We assume that the stage is in the
%middle position in order to make sure that the focus is in the middle

%Inputs:
%mmc - the jave MM object
%stageLabel - as defined in MM
%frameRate - [Hz]
%numOfImages - the number of images to capture
%stepSize - the required axial scan resolution
%pathToSave - the directory to save the images
%filePrefix - the prefix to use for the pictures names
%tifFormat - writing the images as tif or bin 
%overlapBetweenZScans - the overlaps between different Z scans
%sDetLens - the serial struct for the detection objective
%absoluteMovementVector - the location of the detection lens vs frame
%                         numbers
%frameNumberToMoveVector - the frame number coresponding to the objective
%location
%delayImages - the number of images that are repeated due to the delay
%between the stage and the camera

function [] = CaptureAStackWhileStageRunningExternalTriggerV5(mmc, stageLabel,...
    sDetLens, absoluteMovementVector, frameNumberToMoveVector, frameRate, ...
    numOfImages, stepSize, pathToSave, tifFormat, delayImages)
    
    %First take care that the detection objective is in the right location
    %and minimize backlash by approaching the right direction of movement
    [curPos] = GetPos(sDetLens);
    stageSpeedDuringScan = '0.25';
    fprintf(sDetLens,['1VA',stageSpeedDuringScan]); 
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
    fprintf(sDetLens,['1PR',num2str(diff)]);    
    
    %Configure the buffer the largest allowed in Java
    mmc.setCircularBufferMemoryFootprint(1024*10);
    mmc.setTimeoutMs(500000);
    
    %Get the current speed and save it for later
    currSpeed = mmc.getProperty(stageLabel,'Speed-S');
    
    %Calc the required speed in [mm/sec]
    setSpeedOfStage = frameRate*stepSize/1000;
        
    width = mmc.getImageWidth();
    height = mmc.getImageHeight();
    pixelType = 'uint16';
    downSampleFactor = 2048/width;
    
    %Set the shutter off
    mmc.setAutoShutter(false);
    
    %Clear any images from the circular buffer and prep the camera
    mmc.clearCircularBuffer;
    
    fprintf(sDetLens,['1PR',num2str(signOfMovement*delta)]);
    %Wait for two seconds to be sure that the detection stage is in the right
    %position 
    pause(2);
    %mmc.prepareSequenceAcquisition(cameraLabel);
        
    %Set the speed and make sure it was written
    mmc.setProperty(stageLabel,'Speed-S', setSpeedOfStage);
    val = mmc.getProperty(stageLabel,'Speed-S');
    display(['Speed was set to ',char(val),' mm/sec']);
    
    mmc.setShutterOpen(true);
    
    %Start capturing images for some reason it seems that the stage is faster than the camera    
    %The interval does not work currently Andor bug the exposure time
    %determines the intervals
    showImageEveryHowManyFrames = 20;
    intervalMs = 0;
    stopOnOverflow = true;
    mmc.startSequenceAcquisition(numOfImages + delayImages, intervalMs, stopOnOverflow);
    numOfImagesToWait = 20;
    
    %Start the stage scan, the direction is negative
    pos1 = mmc.getXYStagePosition(stageLabel);
    newRelativePosX = -abs(numOfImages*stepSize);
    mmc.setXYPosition(stageLabel, pos1.x + newRelativePosX, pos1.y);
    
    %Let the camera put some images in the buffer before writing to memory
    while ((mmc.getBufferTotalCapacity - mmc.getBufferFreeCapacity) ~= numOfImagesToWait)
        %(mmc.getBufferTotalCapacity - mmc.getBufferFreeCapacity)
    end
    
    %Show the first image
    f = figure;
    hAxes = subplot(1,1,1);
    img = mmc.getLastImage();
    img = typecast(img, pixelType);      % pixels must be interpreted as unsigned integers
    img = reshape(img, [width, height]); % image should be interpreted as a 2D array
    img = transpose(img);                % make column-major order for MATLAB
    hImage = imshow(img,'Parent',hAxes, 'DisplayRange', []); 
    
    %Tells us if the sequence stopped running
    %stopFlag = true;
    
    movedTheStage = false;
    tic;
    
    indexForObjectiveCorrection = 2;
    frameNumberToMoveVector = [frameNumberToMoveVector inf];
    
    for ii = 1:(numOfImages + delayImages)
        ii
        if ((mmc.getBufferTotalCapacity - mmc.getBufferFreeCapacity) == 0)
            pause(1);
        end
        
        %pop the images from the stack one by one
        img = mmc.popNextImage();
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
        if (ii + delayImages + mmc.getRemainingImageCount() > frameNumberToMoveVector(indexForObjectiveCorrection))
            
            %Debug
            [curPos] = GetPos(sDetLens)
            diff = absoluteMovementVector(indexForObjectiveCorrection) - str2double(curPos);
    
            %Check that it does not move more than 100 um
            if (abs(diff) > (confidenceMargin)) 
                diff = 0.001;
                display('Error in pos calculation');
            end
            %The second move of the delts will make sure that the stage compensated
            %for backlash when we start the scan
            fprintf(sDetLens,['1PR',num2str(diff)]);  
            indexForObjectiveCorrection = indexForObjectiveCorrection + 1;
                        
        end
        
        %When done turn off the shutter to prevent photo bleaching and move
        %the stage to the starting point since it takes time  
        if (((ii + mmc.getRemainingImageCount() + delayImages) > numOfImages - 1) && (~movedTheStage))
            
           movedTheStage = true; 
           %Set the speed to the previous value
           mmc.setProperty(stageLabel,'Speed-S', currSpeed);
           val = mmc.getProperty(stageLabel,'Speed-S');
           display(['Speed was set to ',char(val),' mm/sec']);
           pause(1);
           mmc.setShutterOpen(false);
           %Move the stage to the starting point in order to save time
           mmc.setXYPosition(stageLabel, pos1.x , pos1.y);
           
        end
    
        
    end
    toc;
    mmc.isSequenceRunning;
    mmc.setShutterOpen(false);
    [curPos] = GetPos(sDetLens);    
        
    %Move the detection lens to the start point
    [curPos] = GetPos(sDetLens);
    diff = absoluteMovementVector(1) - str2double(curPos);
    
    %Check that it does not move more than 100 um
    if (abs(diff) > (confidenceMargin)) 
        diff = 0.001;
        display('Error in pos calculation');
    end
    
    %The second move of the delts will make sure that the stage compensated
    %for backlash when we start the scan
    fprintf(sDetLens,['1PR',num2str(diff)]);   
        
    %Wait for the stage to reach its location
    mmc.waitForDevice(stageLabel);
    %[diffInPos] = MoveXYStageRelative(mmc, stageLabel, -newRelativePosX, 0);
    %display(['the stage move to the following position X = ', num2str(-diffInPos(1)),' , Y = ', num2str(-diffInPos(2))]);
         
    mmc.clearCircularBuffer;    
    mmc.setAutoShutter(true);
        
end

