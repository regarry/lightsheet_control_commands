%This function calculates the poistion of the filter wheel to provide the
%required power. It takes into account the MAX power of the laser and the
%ND filters that are on the wheel

function [ positionOfTheFilterWheel ] = SetPowerUsingFW(serialHandleToFW, powerInMW, maxPowerMW )
    
    %The preloaded power of the filters
    NDofFilters = [0 .1 .2 .3 .4 .5 .6 1 1.3 2 3 4];  
    %Calculate the power options
    powerRatio = 10.^(-NDofFilters);
    optionalPowers = maxPowerMW*powerRatio;
    
    %Find the closest filter
    dist = (powerInMW - optionalPowers).^2;
    ind = find(dist == min(dist));
    ind = ind(1);
    
    SetFilterPosition(serialHandleToFW, ind);    
    [positionOfTheFilterWheel] = GetFilterPosition(serialHandleToFW);

end

