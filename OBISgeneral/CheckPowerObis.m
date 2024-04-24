function [ outPutPowerInMW ] = CheckPowerObis( serialHandle )
   
    %check the power
    fprintf(serialHandle,'SOUR:POW:LEV:IMM:AMPL?');
    %Read it, require two reads one for Ok and one for the acyual power
    outPutPowerInMW = fscanf(serialHandle);  
    %Convert to milliW
    outPutPowerInMW = str2num(outPutPowerInMW)*1000;
    temp = fscanf(serialHandle);

end

