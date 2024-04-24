function [delta] = MoveDetectionObjective(controlParameters, requiredDetObjectiveLocation)
   
    upperLimitMm = 0.25; %mm
    pauseTime = 0.25;
    [posDet] = str2num(GetPos(controlParameters.sDetLens));           
    
    %Change the position of the stages to account for the chromatic abberations
    %move the stage to the relative difference between the
    %colors
    
    deltaForDet = requiredDetObjectiveLocation - posDet;
    if (abs(deltaForDet) < upperLimitMm)
        fprintf(controlParameters.sDetLens,['1PR',num2str(deltaForDet)]);
        pause(pauseTime);
    end
    
    [posDet] = str2num(GetPos(controlParameters.sDetLens)); 
    delta = requiredDetObjectiveLocation - posDet;
      
end

