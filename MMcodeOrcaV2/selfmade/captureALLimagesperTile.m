function [imagesForTiling] = captureALLimagesperTile(app,xyzScanArray)
    [initxPos,inityPos,initzPos] = getXYZposition(app.controlParameters.MMC);
    app.controlParameters.MMC.setProperty('XYStage:XY:31','MotorSpeedX-S(mm/s)', '1');
    app.controlParameters.MMC.setProperty('XYStage:XY:31','MotorSpeedMaximumX(mm/s)', '1.92');
    app.controlParameters.MMC.setProperty('XYStage:XY:31','MotorSpeedMinimumX(um/s)', '0.172');
    app.controlParameters.MMC.setProperty('XYStage:XY:31','WaitTime(ms)', '1000');
    
    app.controlParameters.MMC.setProperty('XYStage:XY:31','MotorSpeedY-S(mm/s)', '1');
    app.controlParameters.MMC.setProperty('XYStage:XY:31','MotorSpeedMaximumY(mm/s)', '1.92');
    app.controlParameters.MMC.setProperty('XYStage:XY:31','MotorSpeedMinimumY(um/s)', '0.172');
    
    app.controlParameters.MMC.setProperty('XYStage:XY:31','AccelerationX-AC(ms)','70');
    app.controlParameters.MMC.setProperty('XYStage:XY:31','AccelerationX-AC(ms)','70');
    
    app.controlParameters.MMC.setProperty('ZStage:Z:32','MotorSpeed-S(mm/s)', '1');
    
    app.controlParameters.MMC.setProperty('ZStage:Z:32','WaitTime(ms)', '1000');
    %Set the camera running 
    numOfImages = 1000000;
    intervalMs = 0;
    stopOnOverflow = false;
    
    app.controlParameters.MMC.stopSequenceAcquisition;
    %Make sure the buffer is empty
    app.controlParameters.MMC.clearCircularBuffer;
    %Debug
    app.controlParameters.MMC.setCircularBufferMemoryFootprint(1024*10);
    
    outputSingleScan(app.controlParameters.s1,[app.Shutterstate1,app.state_path.Galvo_X(1),app.state_path.Galvo_Y(1),app.state_path.Galvo_Z(1)]);
    outputSingleScan(app.controlParameters.s2,[app.Shutterstate2,app.state_path.Galvo_X(2),app.state_path.Galvo_Y(2),app.state_path.Galvo_Z(2)]);     
    app.controlParameters.MMC.startSequenceAcquisition(numOfImages, intervalMs, stopOnOverflow);
    
    checkBuffer = app.controlParameters.MMC.getRemainingImageCount();
    if checkBuffer==0
        pause(0.4);
    end
    
    %Snap an image and get its properties    
    image = app.controlParameters.MMC.getLastImage();  % returned as a 1D array of signed integers in row-major order
    width = app.controlParameters.MMC.getImageWidth();
    height = app.controlParameters.MMC.getImageHeight();
    pixelType = 'uint16';
    image = typecast(image, pixelType);      % pixels must be interpreted as unsigned integers
    image = reshape(image, [width, height]); % image should be interpreted as a 2D array
    image = rot90(image);
    
    imagesForTiling = zeros(height, width, numel(xyzScanArray(1,:)));
    app.controlParameters.MMC.setTimeoutMs(500000);
    
    for ii = 1:numel(xyzScanArray(1,:))
        [xPos, yPos, zPos] = getXYZposition(app.controlParameters.MMC);
        %outputSingleScan(app.controlParameters.s1,[app.Shutterstate1,app.state_path.Galvo_X(1),app.state_path.Galvo_Y(1),app.state_path.Galvo_Z(1)]);
        %outputSingleScan(app.controlParameters.s2,[app.Shutterstate2,app.state_path.Galvo_X(2),app.state_path.Galvo_Y(2),app.state_path.Galvo_Z(2)]);
        dx = xyzScanArray(1,ii) - xPos; dy = xyzScanArray(2,ii) - yPos; dz = xyzScanArray(3,ii) - zPos;
        % for some unknow reason, dx need to be larger, something wrong
        % with the stage
        SetRelativePos(app.controlParameters.MMC,dx,dy,dz);
        pause(0.01);
        outputSingleScan(app.controlParameters.s1,[app.Shutterstate1,app.state_path.Galvo_X(1),app.state_path.Galvo_Y(1),app.state_path.Galvo_Z(1)]);
        outputSingleScan(app.controlParameters.s2,[app.Shutterstate2,app.state_path.Galvo_X(2),app.state_path.Galvo_Y(2),app.state_path.Galvo_Z(2)]);
        pause(0.5);% wait for open
        temp = app.controlParameters.MMC.getLastImage();
        temp = typecast(temp, pixelType);      % pixels must be interpreted as unsigned integers
        temp = reshape(temp, [width, height]); % image should be interpreted as a 2D array
        temp = rot90(temp);
        
        imagesForTiling(:,:,ii) = temp;
        app.wait_status.Value = ii/numel(xyzScanArray(1,:));
        app.wait_status.Message = ['Images ',num2str(ii),'/',num2str(numel(xyzScanArray(1,:)))];
        if app.wait_status.CancelRequested
            break;
        end
    end
    [xPos, yPos, zPos] = getXYZposition(app.controlParameters.MMC);
    dx = initxPos - xPos; dy = inityPos - yPos; dz = initzPos - zPos;
    SetRelativePos(app.controlParameters.MMC,dx,dy,dz);
    app.controlParameters.MMC.stopSequenceAcquisition;
    app.controlParameters.MMC.clearCircularBuffer;
    outputSingleScan(app.controlParameters.s1,[app.Shutterstate1,app.state_path.Galvo_X(1),app.state_path.Galvo_Y(1),app.state_path.Galvo_Z(1)]);
    outputSingleScan(app.controlParameters.s2,[app.Shutterstate1,app.state_path.Galvo_X(2),app.state_path.Galvo_Y(2),app.state_path.Galvo_Z(2)]);
end






