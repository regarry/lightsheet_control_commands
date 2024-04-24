function [nextWavelength, nextIndWavelength, curPath] = ChangeWavelengths(controlParameters, allLasers, currentWavelength, nextWavelength, intensityInMW, focusingFilter, curPath, lightSheetMode)
    
    path1Excitation = 1;
    path2Excitation = 2;
    
    pauseTime = 0.25;
    %Find the index of the wavelength
    %listWavelength = cat(1,allLasers.wavelength)    
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
            
    %The first Excitation lens
    deltaForExt = allLasers(nextIndWavelength).posExtLens(path1Excitation) - allLasers(curIndWavelength).posExtLens(path1Excitation);
    if (abs(deltaForExt) < 2)
        fprintf(controlParameters.sExtLens,['1PR',num2str(deltaForExt)]);
        pause(pauseTime);
    end
    
    %The second excitation lens
    deltaForExt = allLasers(nextIndWavelength).posExtLens(path2Excitation) - allLasers(curIndWavelength).posExtLens(path2Excitation);
    if (abs(deltaForExt) < 2)
        fprintf(controlParameters.sExtLens2,['1PR',num2str(deltaForExt)]);
        pause(pauseTime);
    end
    
    %The detection lens which is path depended 
    deltaForDet = allLasers(nextIndWavelength).posDetLens(curPath) - allLasers(curIndWavelength).posDetLens(curPath);
    if (abs(deltaForDet) < 0.1)
        fprintf(controlParameters.sDetLens,['1PR',num2str(deltaForDet)]);
        pause(pauseTime);
    end
    
     if (lightSheetMode)
        
        %Set the function generator to the new parameters
        vLowScan = allLasers(nextIndWavelength).minVoltage(curPath);
        vHighScan = allLasers(nextIndWavelength).maxVoltage(curPath);
        newFreq = allLasers(nextIndWavelength).newFreq;
        symmetry = allLasers(nextIndWavelength).symmetry(curPath);
        SetAfgRamp(controlParameters.afg, vLowScan, vHighScan, newFreq, symmetry);
        
        SetExternalTriggerSignal(controlParameters.afg, newFreq, allLasers(nextIndWavelength).OptimalDelay(curPath));
        fwrite(controlParameters.afg, ':source1:phase:initiate');
        fwrite(controlParameters.afg, ':output1 on;');
        fwrite(controlParameters.afg, ':output2 on;');
        
    end

end

