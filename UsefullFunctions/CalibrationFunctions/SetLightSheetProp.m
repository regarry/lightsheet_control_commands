function [] = SetLightSheetProp(mmc, cameraLabel, expWindowHeight, lineScanSpeed, frameRate)
    
    
    mmc.setProperty(cameraLabel, 'Overlap', 'Off');
    
    % An addition 
    mmc.setProperty(cameraLabel, 'Sensitivity/DynamicRange','16-bit (low noise & high well capacity)');
    %another option is '12-bit (low noise)'
    
    mmc.setProperty(cameraLabel, 'LightScanPlus-ScanSpeedControlEnable', 'On');
    %mmc.setProperty(cameraLabel, 'LightScanPlus-SensorReadoutMode', 'Top Down Sequential');
    mmc.setProperty(cameraLabel, 'LightScanPlus-SensorReadoutMode', 'Bottom Up Sequential');    
    mmc.setProperty(cameraLabel, 'LightScanPlus-ExposedPixelHeight', expWindowHeight);
    mmc.setProperty(cameraLabel, 'LightScanPlus-LineScanSpeed [lines/sec]', lineScanSpeed);
    val = mmc.getProperty(cameraLabel, 'FrameRateLimits');
    temp = char(val);
    k = strfind(temp,'Max: ');
    temp = temp((k+5):(k+9));
    temp = str2num(temp);
    if (round(frameRate) > temp)
        mmc.setProperty(cameraLabel, 'FrameRate', frameRate-1);
    end
    
    %mmc.setProperty(cameraLabel, 'TriggerMode', 'Internal (Recommended for fast acquisitions)')   
    mmc.setProperty(cameraLabel, 'TriggerMode', 'External');
    mmc.setProperty(cameraLabel, 'LightScanPlus-ExternalTriggerDelay [s]','0.005');
    
    

end