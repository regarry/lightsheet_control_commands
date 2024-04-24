function MoveStagesToDesiredLocation(controlParameters, posExtLens, posDetLens, whichLaserPath)
    
    pauseTime = 1;
    
    %Provide the handle based on the light path
    if (whichLaserPath == 1)
        extStageHandle = controlParameters.sExtLens;
    else
        extStageHandle = controlParameters.sExtLens; 
    end
    
    %Find the curent position of the stage
    [curPosExt] = GetPos(extStageHandle);    
    [curPosDet] = GetPos(controlParameters.sDetLens);    
    
    %Move excitation lens
    deltaForExt = (posExtLens) - str2num(curPosExt);
    if (abs(deltaForExt) < 2)
        fprintf(extStageHandle,['1PR',num2str(deltaForExt)]);
        pause(pauseTime);
        [curPosExt] = GetPos(extStageHandle);
        deltaForExt = (posExtLens) - str2num(curPosExt)      
    end
    
    %Move detection lens
    deltaForDet = (posDetLens) - str2num(curPosDet);
    if (abs(deltaForDet) < 0.2)
        fprintf(controlParameters.sDetLens,['1PR',num2str(deltaForDet)]);
        pause(pauseTime);
        [curPosDet] = GetPos(controlParameters.sDetLens);
        deltaForDet = (posDetLens) - str2num(curPosDet)
    end


end

