function [mmc] = InitiateHardware(pathToCfgFile)
    
%     %Load the MM core and the configuration file
    import mmcorej.*;
    mmc = CMMCore;
    mmc.loadSystemConfiguration(pathToCfgFile);


    %Get the list of configured devices
    ShowAllRunningDevices(mmc);
    
%     %Set the camera to 16 bit mode instead of 12
%     mmc.setProperty(cameraLabel, 'Sensitivity/DynamicRange','16-bit (low noise & high well capacity)');
%     %another option is '12-bit (low noise)'
    
    

end

