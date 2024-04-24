function [] = GetLightSheetPropV3( mmc, cameraLabel)

    if (strcmp(cameraLabel, 'HamamatsuHam_DCAM'))
        
        
        val = mmc.getProperty(cameraLabel,'Exposure');
        display(['Exposure is ',char(val),' ms']);
    
        val = mmc.getProperty(cameraLabel,'INTERNAL LINE SPEED');
        display(['Internal line speed is ',char(val),' m/sec']);
        
        val = mmc.getProperty(cameraLabel,'INTERNAL LINE INTERVAL');
        display(['Internal line interval is ',char(val),' ms']);
        
        val = mmc.getProperty(cameraLabel,'ReadoutTime');
        display(['ReadoutTime is ',char(val),'s']);      
        
        val = mmc.getProperty(cameraLabel,'READOUT DIRECTION');
        display(['READOUT DIRECTION is ',char(val)]);
        
        val = mmc.getProperty(cameraLabel,'TRIGGER SOURCE');
        display(['TRIGGER SOURCE is ',char(val)]);
        
        val = mmc.getProperty(cameraLabel,'TriggerPolarity');
        display(['Trigger Polarity is ',char(val)])
                
    else

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
    
end

