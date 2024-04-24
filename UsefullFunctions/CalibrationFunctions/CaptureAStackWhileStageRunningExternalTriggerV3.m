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

function [] = CaptureAStackWhileStageRunningExternalTriggerV3(mmc, stageLabel, frameRate, numOfImages, stepSize, pathToSave, filePrefix, tifFormat, overlapBetweenZScans)
    
    %Configure the buffer the largest allowed in Java
    mmc.setCircularBufferMemoryFootprint(1024*10);
    mmc.setTimeoutMs(500000);
    
    %Get the current speed and save it for later
    currSpeed = mmc.getProperty(stageLabel,'Speed-S');
    
    %Calc the required speed in [mm/sec]
    setSpeedOfStage = frameRate*stepSize/1000;
            
    width = 2048;
    height = 2048;
    pixelType = 'uint16';
    
    %Set the shutter off
    mmc.setAutoShutter(false);
    
    %Clear any images from the circular buffer and prep the camera
    mmc.clearCircularBuffer;
    %mmc.prepareSequenceAcquisition(cameraLabel);
    
    %Move the stage to the starting point 
    pos1 = mmc.getXYStagePosition(stageLabel);
    newRelativePosX = round(abs(numOfImages*stepSize)/2);
    [diffInPos] = MoveXYStageRelative(mmc, stageLabel, newRelativePosX, 0);
    display(['the stage move to the following position X = ', num2str(-diffInPos(1)),' , Y = ', num2str(-diffInPos(2))]);
    
    %Set the speed and make sure it was written
    mmc.setProperty(stageLabel,'Speed-S', setSpeedOfStage);
    val = mmc.getProperty(stageLabel,'Speed-S');
    display(['Speed was set to ',char(val),' mm/sec']);
    
    mmc.setShutterOpen(true);
    
    %Start the stage scan, the direction is negative
    pos1 = mmc.getXYStagePosition(stageLabel);
    newRelativePosX = -abs(numOfImages*stepSize);
    mmc.setXYPosition(stageLabel, pos1.x + newRelativePosX, pos1.y);
    
    %Start capturing images    
    %The interval does not work currently Andor bug the exposure time
    %determines the intervals
    showImageEveryHowManyFrames = 20;
    intervalMs = 0;
    stopOnOverflow = true;
    mmc.startSequenceAcquisition(numOfImages, intervalMs, stopOnOverflow);
    numOfImagesToWait = 20;
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
        
    tic;
    
    for ii = 1:numOfImages
        %ii
        %pop the images from the stack one by one
        img = mmc.popNextImage();
        img = typecastFast(img, pixelType);      % pixels must be interpreted as unsigned integers
        
        if (tifFormat)
             
            img = reshape(img, [width, height]); % image should be interpreted as a 2D array
            %Transpose is too slow
            %img = transpose(img);                % make column-major order for MATLAB
            cmd = ['imwrite(img,','''',pathToSave,'\',filePrefix,num2str(ii),'.tiff'');'];
            eval(cmd);
            if (mod(ii,showImageEveryHowManyFrames) == 0);
                set(hImage,'CData',img); pause(0.01);
            end
         
        else
            
            %Write bin
            cmd = ['fid = fopen(''',pathToSave,'\',filePrefix,num2str(ii),'.bin''',',''w''',');'];
            eval(cmd);
            fwrite(fid,img,'uint16');        
            fclose(fid);
            if (mod(ii,showImageEveryHowManyFrames) == 0);
                img = reshape(img, [width, height]); % image should be interpreted as a 2D array
                img = transpose(img);  
                set(hImage,'CData',img); pause(0.01);
            end
            
        end
        
        %Check if the buffer is about to end
        %if (mmc.getBufferFreeCapacity < 10)
        %    display('oh no');
        %end
        
        %Display if the the sequence stopped
        %if (~mmc.isSequenceRunning && stopFlag)
        %    toc;
        %    stopFlag = false;
        %    display('Sequence stopped running');
        %    mmc.setShutterOpen(false);            
        %end
        
    end
    toc;
    mmc.isSequenceRunning
    mmc.setShutterOpen(false);
        
    %Set the speed to the previous value
    mmc.setProperty(stageLabel,'Speed-S', currSpeed);
    val = mmc.getProperty(stageLabel,'Speed-S');
    display(['Speed was set to ',char(val),' mm/sec']);
        
    %Move the stage to the starting point of the next scan with an overlap
    %of given by overlapBetweenZScans    
    pos1 = mmc.getXYStagePosition(stageLabel);
    newRelativePosX = round(abs(numOfImages*stepSize)/2) - overlapBetweenZScans;
    [diffInPos] = MoveXYStageRelative(mmc, stageLabel, -newRelativePosX, 0);
    display(['the stage move to the following position X = ', num2str(-diffInPos(1)),' , Y = ', num2str(-diffInPos(2))]);
        
    mmc.clearCircularBuffer;    
    mmc.setAutoShutter(true);
        
end

