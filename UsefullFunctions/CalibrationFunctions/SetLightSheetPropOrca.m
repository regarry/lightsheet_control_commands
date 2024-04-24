function [] = SetLightSheetPropOrca(mmc, cameraLabel, internalLineInterval, exposurePerLine)
    
        %expTime = 1000/frameRate/2048; %ms
        mmc.setProperty(cameraLabel,'SENSOR MODE','PROGRESSIVE'); %AREA
        mmc.setProperty(cameraLabel,'READOUT DIRECTION', 'FORWARD'); %    BACKWARD
        mmc.setProperty(cameraLabel, 'TRIGGER SOURCE', 'EXTERNAL'); %  INTERNAL
        mmc.setProperty(cameraLabel, 'Exposure', exposurePerLine*1000);
        mmc.setProperty(cameraLabel, 'INTERNAL LINE INTERVAL', internalLineInterval*1000);
        mmc.setProperty(cameraLabel, 'TriggerPolarity', 'POSITIVE');   
        %mmc.getAllowedPropertyValues(cameraLabel,'SENSOR MODE').toArray()
end