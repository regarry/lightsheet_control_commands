function [] = ShowAllRunningDevices( mmc )
%SHOWALLRUNNINGDEVICES Summary of this function goes here
    devicesLoaded = mmc.getLoadedDevices;
    display('Device status');
    for ii = 1:(devicesLoaded.size-1)
        display([num2str(ii),' = ',char(devicesLoaded.get(ii))]);    
    end
end

