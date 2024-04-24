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

function [ xyzScanArray, dirNames ] = CreateScanCordV2(lowerRightCornerX, lowerRightCornerY, lowerRightCornerZ, vertTilesNum, horzTilesNum, stepSize )
        
    xyzScanArray = zeros(3,vertTilesNum*horzTilesNum);
    dirNames = zeros(3,vertTilesNum*horzTilesNum);
    xyzScanArray(1,:) = lowerRightCornerX;
    
    zVec = (0:(vertTilesNum-1));
    yVec = (0:(horzTilesNum-1));
    zVec = stepSize*zVec + lowerRightCornerZ;
    yVec = stepSize*yVec + lowerRightCornerY;
    [yy, zz] = meshgrid(yVec, zVec);
    xyzScanArray(2,:) = yy(:);
                                                                                                                                                                                               
    %snake pattern
    for ii = 2:2:horzTilesNum
        zz(:,ii) = zz(end:-1:1,ii);
    end
    xyzScanArray(3,:) = zz(:);
    
    %figure; plot(xyzScanArray(2,:),xyzScanArray(3,:),'-*'); axis([-100 max(xyzScanArray(2,:))+100 -100 max(xyzScanArray(3,:)+100)]);
    
    dirNames(1,:) = xyzScanArray(1,:) - lowerRightCornerX;
    dirNames(2,:) = xyzScanArray(2,:) - lowerRightCornerY;
    dirNames(3,:) = xyzScanArray(3,:) - lowerRightCornerZ;
    
    %Make strings out of the file names 
    for ii = 1:size(dirNames,2)
        [dirNames(1,ii)] = ConvertToTeraStitcherConvension(dirNames(1,ii));
        [dirNames(2,ii)] = ConvertToTeraStitcherConvension(dirNames(2,ii));
        [dirNames(3,ii)] = ConvertToTeraStitcherConvension(dirNames(3,ii));        
    end
    
    
end

function [numberTeraStitcherStyle] = ConvertToTeraStitcherConvension(numberInUm)
    numberInUmStr = num2str(numberInUm);
    index = strfind(numberInUmStr, '.');
    numberTeraStitcherStyle = '000000';
    if (~isempty(index))
        numberTeraStitcherStyle(end) = numberInUmStr(index + 1);
        if ((index-1) <= 5)
            numberTeraStitcherStyle((5 - index + 2):5) = numberInUmStr(1:(index - 1));        
        else
            numberTeraStitcherStyle = 'XXXXXX';
        end
    else
        index = numel(numberInUmStr);
        if ((index) <= 5)
            numberTeraStitcherStyle((5 - index + 1):5) = numberInUmStr(1:index);        
        else
            numberTeraStitcherStyle = 'XXXXXX';
        end
    end
    
    numberTeraStitcherStyle = str2num(numberTeraStitcherStyle);
    
end