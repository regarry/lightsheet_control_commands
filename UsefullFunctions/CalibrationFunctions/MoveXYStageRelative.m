function [diffInPos] = MoveXYStageRelative(mmc, deviceName, newRelativePosX, newRelativePosY)
%MOVEStage Summary of this function goes here
%   Detailed explanation goes here
    pos1 = mmc.getXYStagePosition(deviceName);
    mmc.setXYPosition(deviceName,pos1.x + newRelativePosX, pos1.y + newRelativePosY);
    mmc.waitForDevice(deviceName);
    pos2 = mmc.getXYStagePosition(deviceName);
    diffInPos = [pos2.x - pos1.x,pos2.y - pos1.y];
end

