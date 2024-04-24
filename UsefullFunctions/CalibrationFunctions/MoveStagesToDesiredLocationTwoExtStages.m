function MoveStagesToDesiredLocationTwoExtStages(controlParameters, posExtLens1, posExtLens2, posDetLens)
    
    pauseTime = 0.5;
    
    %Find the curent position of the stage
    [curPosExt1] = GetPos(controlParameters.sExtLens);    
    %[curPosExt2] = GetPos(controlParameters.sExtLens2);    
    [curPosDet] = GetPos(controlParameters.sDetLens);    
    
    %Move excitation lens
    deltaForExt = (posExtLens1) - str2num(curPosExt1);
    if (abs(deltaForExt) < 2)
        fprintf(controlParameters.sExtLens,['1PR',num2str(deltaForExt)]);              
    end
    
%     deltaForExt = (posExtLens2) - str2num(curPosExt2);
%     if (abs(deltaForExt) < 2)
%         fprintf(controlParameters.sExtLens2,['1PR',num2str(deltaForExt)]);             
%     end
    
    
    %Move detection lens
    deltaForDet = (posDetLens) - str2num(curPosDet);
    if (abs(deltaForDet) < 0.2)
        fprintf(controlParameters.sDetLens,['1PR',num2str(deltaForDet)]);
        pause(pauseTime);        
    end
    
    % Apperently one time will not be enough if changing direction
    [curPosDet] = GetPos(controlParameters.sDetLens); 
    deltaForDet = (posDetLens) - str2num(curPosDet);
    if (abs(deltaForDet) < 0.1)
        fprintf(controlParameters.sDetLens,['1PR',num2str(deltaForDet)]);
        pause(pauseTime);        
    end

    [curPosExt1] = GetPos(controlParameters.sExtLens);
    deltaForExt = (posExtLens1) - str2num(curPosExt1)
        
%     [curPosExt2] = GetPos(controlParameters.sExtLens2);
%     deltaForExt2 = (posExtLens2) - str2num(curPosExt2) 
        
    [curPosDet] = GetPos(controlParameters.sDetLens);
    deltaForDet = (posDetLens) - str2num(curPosDet)

end

