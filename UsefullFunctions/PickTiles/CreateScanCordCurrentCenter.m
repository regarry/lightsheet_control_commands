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

function [ xyzScanArray, dirNames ] = CreateScanCordCurrentCenter(centerX, centerY, centerZ, vertTilesNum, horzTilesNum, stepSize )
        
    xyzScanArray = zeros(3,vertTilesNum*horzTilesNum);
    dirNames = zeros(3,vertTilesNum*horzTilesNum);
    xyzScanArray(1,:) = centerX;
    
    zVec = (-1*floor(vertTilesNum/2)):(ceil(vertTilesNum/2)-1);
    yVec = (-1*floor(horzTilesNum/2)):(ceil(horzTilesNum/2)-1);
    %Even number of tiles in zVec even number in yVec
    if ((mod(numel(zVec),2) == 0) && (mod(numel(yVec),2) == 0) )
        zVec = stepSize*zVec + centerZ; % + stepSize/2;
        yVec = stepSize*yVec + centerY; % + stepSize/2;
    end
    if ((mod(numel(zVec),2) == 1) && (mod(numel(yVec),2) == 1) )
        zVec = stepSize*zVec + centerZ;
        yVec = stepSize*yVec + centerY;
    end
    if ((mod(numel(zVec),2) == 1) && (mod(numel(yVec),2) == 0) )
        zVec = stepSize*zVec + centerZ;
        yVec = stepSize*yVec + centerY; % + stepSize/2;
    end
    if ((mod(numel(zVec),2) == 0) && (mod(numel(yVec),2) == 1) )
        zVec = stepSize*zVec + centerZ; % + stepSize/2;
        yVec = stepSize*yVec + centerY;
    end
        
    [yy, zz] = meshgrid(yVec, zVec);
    xyzScanArray(2,:) = yy(:);
                                                                                                                                                                                               
    %snake pattern
    for ii = 2:2:horzTilesNum
        zz(:,ii) = zz(end:-1:1,ii);
    end
    xyzScanArray(3,:) = zz(:);
    
    %figure; plot(xyzScanArray(2,:),xyzScanArray(3,:),'-*'); axis([-100 max(xyzScanArray(2,:))+100 -100 max(xyzScanArray(3,:)+100)]);
    
    dirNames(1,:) = xyzScanArray(1,:) - xyzScanArray(1,1);
    dirNames(2,:) = xyzScanArray(2,:) - xyzScanArray(2,1);
    dirNames(3,:) = xyzScanArray(3,:) - xyzScanArray(3,1);
    
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