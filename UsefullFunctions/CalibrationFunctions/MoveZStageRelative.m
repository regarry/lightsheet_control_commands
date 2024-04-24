function [diffInPos] = MoveZStageRelative(mmc, deviceName, newRelativePos)
%MOVEStage Summary of this function goes here
%   Detailed explanation goes here
    pos1 = mmc.getPosition(deviceName);
    mmc.setPosition(deviceName,pos1 + newRelativePos);
    mmc.waitForDevice(deviceName);
    pos2 = mmc.getPosition(deviceName);
    diffInPos = pos2 - pos1;

end

