function ChangePowerObis(serialHandle, powerInMW, maxPowerMW)
    
    %Check if the power is not logical
    if (powerInMW < 0)
        powerInMW = 1;
    end
    
    if (powerInMW > maxPowerMW)
        powerInMW = maxPowerMW;
    end
    
    powerInW = powerInMW/1000;
    fprintf(serialHandle,['SOUR:POW:LEV:IMM:AMPL ',num2str(powerInW)]);
    temp = fscanf(serialHandle);
    
end

