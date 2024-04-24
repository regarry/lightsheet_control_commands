function MoveStagesToDesiredLocation_NO_EXT(controlParameters, posDetLens)
    
    pauseTime = 1;
    
  
    %Find the curent position of the stage
    [curPosDet] = GetPos(controlParameters.sDetLens);    
    

    %Move detection lens
    deltaForDet = (posDetLens) - str2num(curPosDet);
    if (abs(deltaForDet) < 0.2)
        fprintf(controlParameters.sDetLens,['1PR',num2str(deltaForDet)]);
        pause(pauseTime);
        [curPosDet] = GetPos(controlParameters.sDetLens);
        deltaForDet = (posDetLens) - str2num(curPosDet)
    end


end

