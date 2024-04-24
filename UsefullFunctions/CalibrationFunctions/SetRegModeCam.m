function [] = SetRegModeCam(mmc, cameraLabel)
    
    mmc.setProperty(cameraLabel, 'TriggerMode', 'Internal (Recommended for fast acquisitions)'); 
    %mmc.setProperty(cameraLabel, 'Overlap', 'on');
    
    % An addition 
    mmc.setProperty(cameraLabel, 'Sensitivity/DynamicRange','16-bit (low noise & high well capacity)');
    %another option is '12-bit (low noise)'
    
    mmc.setProperty(cameraLabel, 'LightScanPlus-ScanSpeedControlEnable', 'Off');
    
    %mmc.setProperty(cameraLabel, 'LightScanPlus-SensorReadoutMod', 'Centre Out Simultaneous');
    
    mmc.setProperty(cameraLabel, 'Overlap', 'On');

          
        

end