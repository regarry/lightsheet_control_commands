function [] = GetLightSheetPropV2( mmc, cameraLabel)

    Value = mmc.getProperty(cameraLabel, 'FrameRate');
    display(['FrameRate = ',char(Value)]);
    
    Value = mmc.getProperty(cameraLabel, 'LightScanPlus-ExposedPixelHeight');
    display(['LightScanPlus-ExposedPixelHeight = ',char(Value)]);
        
    Value = mmc.getProperty(cameraLabel, 'LightScanPlus-LineScanSpeed [lines/sec]');
    display(['LightScanPlus-LineScanSpeed [lines/sec]= ',char(Value)]);
    
    Value = mmc.getProperty(cameraLabel, 'Exposure');
    display(['Exposure = ',char(Value)]);
    
    Value = mmc.getProperty(cameraLabel, 'FrameRateLimits');
    display(['FrameRateLimits = ',char(Value)]);
        
    Value = mmc.getProperty(cameraLabel, 'Overlap');
    display(['Overlap = ',char(Value)]);
    
    Value = mmc.getProperty(cameraLabel, 'LightScanPlus-ScanSpeedControlEnable');
    display(['LightScanPlus-ScanSpeedControlEnable = ',char(Value)]);

    Value = mmc.getProperty(cameraLabel, 'LightScanPlus-SensorReadoutMode');
    display(['LightScanPlus-SensorReadoutMode = ',char(Value)]);
    
    Value = mmc.getProperty(cameraLabel, 'TriggerMode');
    display(['TriggerMode = ',char(Value)]);
    
    Value = mmc.getProperty(cameraLabel, 'LightScanPlus-ExternalTriggerDelay [s]');
    display(['LightScanPlus-ExternalTriggerDelay [s]',char(Value)]);
    
end

