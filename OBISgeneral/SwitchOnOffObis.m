%State is a boolean true for on, false for off
function SwitchOnOffObis( serialHandle, state )
    
    if (state)
        %Turn on
        fprintf(serialHandle,'SOUR:AM:STAT ON');
        temp = fscanf(serialHandle);
    else
        %Turn off
        fprintf(serialHandle,'SOUR:AM:STAT OFF');
        temp = fscanf(serialHandle);
    end    

end

