function [nextWavelength, nextIndWavelength ] = ChangeWavelengthsV2(controlParameters, allLasers, currentWavelength, nextWavelength, intensityInMW, focusingFilter, lightSheetMode)
    
    pauseTime = 0.25;
    %Find the index of the wavelength
    for ii = 1:numel(allLasers)
       if (allLasers(ii).wavelength == currentWavelength)
            curIndWavelength = ii;            
       end
        if (allLasers(ii).wavelength == nextWavelength)
            nextIndWavelength = ii;            
       end
    end
        
    SetPowerOfLasersV3(allLasers, controlParameters.sFWExt, controlParameters.sFWDet,...
        allLasers(nextIndWavelength).wavelength, intensityInMW, focusingFilter);
    
    %Change the position of the stages to account for the chromatic abberations
    %move the stage to the relative difference between the
    %colors
    
    deltaForExt = allLasers(nextIndWavelength).posExtLens - allLasers(curIndWavelength).posExtLens;
    if (abs(deltaForExt) < 2)
        fprintf(controlParameters.sExtLens,['1PR',num2str(deltaForExt)]);
        pause(pauseTime);
    end
    
    deltaForDet = allLasers(nextIndWavelength).posDetLens - allLasers(curIndWavelength).posDetLens;
    if (abs(deltaForDet) < 0.1)
        fprintf(controlParameters.sDetLens,['1PR',num2str(deltaForDet)]);
        pause(pauseTime);
    end
    
    if (lightSheetMode)
        %Set the function generator to the new parameters
        vLowScan = allLasers(nextIndWavelength).minVoltage;
        vHighScan = allLasers(nextIndWavelength).maxVoltage;
        newFreq = allLasers(nextIndWavelength).newFreq;
        symmetry = allLasers(nextIndWavelength).symmetry;
        SetAfgRamp(controlParameters.afg, vLowScan, vHighScan, newFreq, symmetry);

        SetExternalTriggerSignal(controlParameters.afg, newFreq, allLasers(nextIndWavelength).OptimalDelay);

        fwrite(controlParameters.afg, ':source1:phase:initiate');
        fwrite(controlParameters.afg, ':output1 on;');
        fwrite(controlParameters.afg, ':output2 on;');
    end

end

