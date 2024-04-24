%The function moves the XYZ stage to a desired new relative position
function [newPosX, newPosY, newPosZ] = SetRelativeXYZPosition(mmc, dx, dy, dz )
    
    %move the XY stage
    mmc.setRelativeXYPosition('XYStage:XY:31', -dx, dy);
    mmc.waitForDevice('XYStage:XY:31');
    
    %move the Z stage
    mmc.setRelativePosition('ZStage:Z:32', dz);   
    mmc.waitForDevice('ZStage:Z:32');
    
    [newPosX, newPosY, newPosZ] = GetXYZPosition(mmc);

end

