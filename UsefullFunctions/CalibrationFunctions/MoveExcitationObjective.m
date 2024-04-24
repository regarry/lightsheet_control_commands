function [delta] = MoveExcitationObjective(controlParameters, requiredExtObjectiveLocation)
   
    upperLimitMm = 2; %mm
    pauseTime = 4;
    [posExt] = str2num(GetPos(controlParameters.sExtLens));           
    
    %Change the position of the stages to account for the chromatic abberations
    %move the stage to the relative difference between the
    %colors
    
    deltaForExt = requiredExtObjectiveLocation - posExt;
    if (abs(deltaForExt) < upperLimitMm)
        fprintf(controlParameters.sExtLens,['1PR',num2str(deltaForExt)]);
        pause(pauseTime);
    end
    
    [posExt] = str2num(GetPos(controlParameters.sExtLens)); 
    delta = requiredExtObjectiveLocation - posExt;
      
end

