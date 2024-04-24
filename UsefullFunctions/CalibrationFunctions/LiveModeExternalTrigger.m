function [] = LiveModeExternalTrigger(mmc, cameraLabel)

    %Configure the buffer the largest allowed in Java
    mmc.setCircularBufferMemoryFootprint(1024*10);
    mmc.setTimeoutMs(500000);
    
    val = mmc.getProperty(cameraLabel,'Exposure');
    display(['Exposure time is ',char(val),' ms']);
    
    %capture one image to retrieve parameters
    width = 2048;
    height = 2048;
    pixelType = 'uint16';
    
    %Set the shutter off
    mmc.setAutoShutter(false);    
    %Clear any images from the circular buffer and prep the camera
    mmc.clearCircularBuffer;
    %mmc.prepareSequenceAcquisition(cameraLabel);
    
    %Start capturing images    
    numOfImages = 1000000;
    showImageEveryHowManyFrames = 6;
    intervalMs = 0;
    stopOnOverflow = false;
    mmc.setShutterOpen(true);
    mmc.startSequenceAcquisition(numOfImages, intervalMs, stopOnOverflow);
    pause(0.2);    
    
    f = figure;
    hAxes = subplot(1,1,1);
    img = mmc.getLastImage();
    img = typecast(img, pixelType);      % pixels must be interpreted as unsigned integers
    img = reshape(img, [width, height]); % image should be interpreted as a 2D array
    img = transpose(img);                % make column-major order for MATLAB
    hImage = imshow(img,'Parent',hAxes, 'DisplayRange', []); 
    stopFlag = true;
    tic;
    ii = 0;
    while ((mmc.getBufferTotalCapacity - mmc.getBufferFreeCapacity) > 0) 
        
        ii = ii + 1;
        %pop the images from the stack one by one
        
        if (mod(ii,showImageEveryHowManyFrames) == 0)            
            img = mmc.getLastImage();
            img = typecast(img, pixelType);      % pixels must be interpreted as unsigned integers
            img = reshape(img, [width, height]); % image should be interpreted as a 2D array
            img = transpose(img);                % make column-major order for MATLAB
            set(hImage,'CData',img);
            pause(0.01);
        end
        
        %Check if the buffer is about to finish
        if (mmc.getBufferFreeCapacity < 10)
            display('oh no');
        end
        
        %Display if the the sequence stopped
        if (~mmc.isSequenceRunning && stopFlag)
            toc;
            stopFlag = false;
            display('Sequence stopped running');
            mmc.setShutterOpen(false);            
        end
        
        if (get(f,'currentKey') == 'e')
            mmc.stopSequenceAcquisition;
            display('Stopped');
            %close(f);
            break;
        end
        
        if (get(f,'currentKey') == 'q')
            mmc.stopSequenceAcquisition;
            display('Stopped');
            %close(f);
            break;
        end
        
    end
    mmc.isSequenceRunning
        
    toc;
    mmc.clearCircularBuffer;
    mmc.setShutterOpen(false);
    mmc.setAutoShutter(true);
    


end

