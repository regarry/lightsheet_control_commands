function SetRelativePos(mmc,dx,dy,dz)
    mmc.setRelativeXYPosition(dx, dy);
    
    mmc.waitForDevice('XYStage:XY:31');
    mmc.setRelativePosition('ZStage:Z:32', dz);
    
    mmc.waitForDevice('ZStage:Z:32');
end


