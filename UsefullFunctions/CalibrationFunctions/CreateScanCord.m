%This functino creates the scan cordinates for the stage
%It assumes that the lower left stage cordinates were provided 
%Returns a snake pattern
%inputs:
%lowerLeftCornerX - the X stage controller cord [um]
%lowerLeftCornerY - the Y stage controller cord [um]
%lowerLeftCornerZ - the Z stage controller cord [um]
%vertTilesNum - how many vertical tiles
%horzTilesNum - how many horizontal tiles
%stepSize - how many um to move = (0.95 size of field of view => 5% overlap 
%Output:
%xyzScanArray - [2,vertTilesNum X horzTilesNum] array with the first row
%has the X cord and the second cord has the Y cord 

function [xyzScanArray] = CreateScanCord( lowerLeftCornerX, lowerLeftCornerY, lowerLeftCornerZ, vertTilesNum, horzTilesNum, stepSize )
        
    xyzScanArray = zeros(3,vertTilesNum*horzTilesNum);
    
    xyzScanArray(1,:) = lowerLeftCornerX;
    
    zVec = (0:(vertTilesNum-1));
    yVec = (0:(horzTilesNum-1));
    zVec = stepSize*zVec + lowerLeftCornerZ;
    yVec = -stepSize*yVec + lowerLeftCornerY;
    [yy, zz] = meshgrid(yVec, zVec);
    xyzScanArray(2,:) = yy(:);
    
    %snake pattern
    for ii = 2:2:horzTilesNum
        zz(:,ii) = zz(end:-1:1,ii);
    end
    xyzScanArray(3,:) = zz(:);
    
   
    
    
end

