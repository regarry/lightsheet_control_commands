function [xPos,yPos,zPos]=getXYZposition(mmc)
    zPos = mmc.getPosition('ZStage:Z:32');
    posXY = mmc.getXYStagePosition('XYStage:XY:31');
    xPos = double(posXY.x);
    yPos = double(posXY.y);
end