%This function calculates the ratio of symmetry according to the delay times 
%Convention always start with the upper point 

function [ ratioOfSymmetry ] = CalcSymmetryFactor( vertCordUp, delayUpPoint, vertCordDown, delayDownPoint, ITcamera )
    
    dist = abs(vertCordDown - vertCordUp); %lines
    speed = 2048/ITcamera; %lines/ms
    time = dist/speed; %ms
    
    %diff in delay for opt location positive delay means faster speed
    dDelay = delayDownPoint - delayUpPoint; %ms
    newTime = dDelay + time;
    newSpeed = dist/newTime;
    
    ratioOfSymmetry = newTime/time;
    



end

