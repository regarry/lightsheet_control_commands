%This functin provides the XY and Z position as shown in the controller
%The function returns a double
%input:
%mmc - the MM object
function [xPos, yPos, zPos] = GetXYZPosition(mmc)
    zPos = mmc.getPosition('ZStage:Z:32');
    posXY = mmc.getXYStagePosition('XYStage:XY:31');
    xPos = double(-posXY.x);
    yPos = double(posXY.y);
    
end

