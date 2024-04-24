function [imagesForTiling] = CaptureOneImagePerTile(xyzScanArray,  controlParameters)
    
    %The current cordinates save them and get back to them in the end
    [initXPos, initYPos, initZPos] = GetXYZPosition(controlParameters.MMC);
    %currSpeed = controlParameters.MMC.getProperty(controlParameters.stageLabel,'Speed-S');
    currSpeed = controlParameters.MMC.getProperty('XYStage:XY:31','MotorSpeedX-S(mm/s)');%5.7458;
    controlParameters.MMC.setProperty('XYStage:XY:31','MotorSpeedX-S(mm/s)', '1');
    controlParameters.MMC.setProperty('XYStage:XY:31','MotorSpeedY-S(mm/s)', '1');
    val = controlParameters.MMC.getProperty('XYStage:XY:31','MotorSpeedX-S(mm/s)');
    display(['Speed was set to ',char(val),' mm/sec']);
    
            
    %Set the camera running 
    numOfImages = 1000000;
    intervalMs = 0;
    stopOnOverflow = false;
    %Set the shutter off
    
    controlParameters.MMC.stopSequenceAcquisition;
    %Make sure the buffer is empty
    controlParameters.MMC.clearCircularBuffer;
    %Debug
    controlParameters.MMC.setCircularBufferMemoryFootprint(1024*10);
            
    controlParameters.MMC.setAutoShutter(false);
    controlParameters.MMC.setShutterOpen(false);outputSingleScan(controlParameters.s,[4,0,0]);
    controlParameters.MMC.startSequenceAcquisition(numOfImages, intervalMs, stopOnOverflow);
    
    checkBuffer = controlParameters.MMC.getRemainingImageCount();
    if checkBuffer==0
        pause(0.4);
    end
    
    %Snap an image and get its properties    
    image = controlParameters.MMC.getLastImage();  % returned as a 1D array of signed integers in row-major order
    width = controlParameters.MMC.getImageWidth();
    height = controlParameters.MMC.getImageHeight();
    pixelType = 'uint16';
    image = typecast(image, pixelType);      % pixels must be interpreted as unsigned integers
    image = reshape(image, [width, height]); % image should be interpreted as a 2D array
    image = rot90(image);
%     image = transpose(image);                % make column-major order for MATLAB
%     image = flipud(image);
%     
    %create an array of images
    imagesForTiling = zeros(height, width, numel(xyzScanArray(1,:)));
    
    %Increase the wait time for the MMC
    controlParameters.MMC.setTimeoutMs(500000);
    
    
    for ii = 1:numel(xyzScanArray(1,:))
        
                %move to the new cordinates
                [xPos, yPos, zPos] = GetXYZPosition(controlParameters.MMC);
                dx = xyzScanArray(1,ii) - xPos; dy = xyzScanArray(2,ii) - yPos; dz = xyzScanArray(3,ii) - zPos;
                [newPosX, newPosY, newPosZ] = SetRelativeXYZPosition(controlParameters.MMC, dx, dy, dz);  
                
                pause(1);
                
                %open the shutter 
                controlParameters.MMC.setShutterOpen(true);
                %Wait for it to open
                pause(0.5);
                %grab the last image
                temp = controlParameters.MMC.getLastImage();
                temp = typecast(temp, pixelType);      % pixels must be interpreted as unsigned integers
                temp = reshape(temp, [width, height]); % image should be interpreted as a 2D array
                imagesForTiling(:,:,ii) = flipud(transpose(temp));                % make column-major order for MATLAB
                  
                %close the shutter
                controlParameters.MMC.setShutterOpen(false);                           
                
    end
    
    %Get back to the previous cordinates
    [xPos, yPos, zPos] = GetXYZPosition(controlParameters.MMC);
    dx = initXPos - xPos; dy = initYPos - yPos; dz = initZPos - zPos;
    SetRelativeXYZPosition(controlParameters.MMC, dx, dy, dz ); 
    
    %Set the speed to the previous value
    controlParameters.MMC.setProperty('XYStage:XY:31','MotorSpeedY-S(mm/s)',currSpeed);
    val = controlParameters.MMC.getProperty('XYStage:XY:31','MotorSpeedY-S(mm/s)');
    display(['Speed was set to ',char(val),' mm/sec']);
    
    %Terminate the acquisation sequence
    controlParameters.MMC.stopSequenceAcquisition; controlParameters.MMC.setAutoShutter(true);
    controlParameters.MMC.setShutterOpen(false); controlParameters.MMC.clearCircularBuffer;
end
 