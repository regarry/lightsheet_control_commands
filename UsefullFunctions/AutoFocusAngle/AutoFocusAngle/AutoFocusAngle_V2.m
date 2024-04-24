%-----------------------------------
%-----------------------------------
%Auto focus part, 
%Version 2 added some parameters to improve flexability
%-----------------------------------
%-----------------------------------

function [optAngle, shiftInFOVpixels] = AutoFocusAngle_V2(image, zDist, pixelSize, waveLength, refractiveIndex, statAngle, initAngle, stepSize, range, convUnits, verticalAng, vPoint, hPoint, radius, showFigures)

if (nargin == 14)
    showFigures = true; 
end

%Parameter definition 
zeroPad = false; %For BP
freqShift = true; %For BP

%Create the sobel edge matrix
hh = fspecial('sobel');
hv=hh';
 
%For the proceses keep only the region of intrest 
processedAreaVectorV = vPoint + (-radius:radius);
processedAreaVectorH = hPoint + (-radius:radius);

 
count = 1;
angleVec = (initAngle-range):stepSize:(initAngle+range);
numOfelementsInAngleVec = numel(angleVec);
varVector = zeros(1, numOfelementsInAngleVec);

%To change to processed FOV to follow the angle
initAngleMedium = asind(sind(initAngle)/refractiveIndex);
initShift = zDist*tand(initAngleMedium);

%For vertical angle
for angleIter = (initAngle - range):stepSize:(initAngle + range)
    fprintf(['angle = ',num2str(angleIter),'\n']);    
    if (verticalAng)
                 
           [propImage] = WavePropAngle_v4(image, waveLength, -zDist, refractiveIndex, pixelSize, pixelSize, angleIter, statAngle, convUnits, zeroPad, freqShift);
           %Make sure that they have the same FOV
           %angleIter
           angleIterMedium = asind(sind(angleIter)/refractiveIndex);
           shiftVertical =  zDist*tand(angleIterMedium);
           shiftInPixels = round((initShift - shiftVertical)/pixelSize);
           processedAreaVectorVmoved = processedAreaVectorV + shiftInPixels;
           imageProces = abs(propImage(processedAreaVectorVmoved, processedAreaVectorH));
           if (showFigures)
            figure; imshow(imageProces,[]); title(['angle = ',num2str(angleIter)]);
           end
           %Find the edges using the sobel matrix           
           temp2 = abs(imfilter(imageProces,hh));
           temp3 = abs(imfilter(imageProces,hv));
           temp4 = sqrt(temp2.^2 + temp3.^2);
           %Calculate the variance
           varVector(count) = var(temp4(:));
           count = count + 1;
    else
           [propImage] = WavePropAngle_v4(image, waveLength, -zDist, refractiveIndex, pixelSize, pixelSize, statAngle, angleIter, convUnits, zeroPad, freqShift);
           %Make sure that they have the same FOV
           angleIterMedium = asind(sind(angleIter)/refractiveIndex);
           shiftHorizontal =  zDist*tand(angleIterMedium);
           shiftInPixels = round((initShift - shiftHorizontal)/pixelSize);
           processedAreaVectorHmoved = processedAreaVectorH + shiftInPixels;
           imageProces = abs(propImage(processedAreaVectorV, processedAreaVectorHmoved));
           if (showFigures)
            figure; imshow(imageProces,[]); title(['angle = ',num2str(angleIter)]);
           end
           %Find the edges using the sobel matrix           
           temp2 = abs(imfilter(imageProces,hh));
           temp3 = abs(imfilter(imageProces,hv));
           temp4 = sqrt(temp2.^2 + temp3.^2);
           %Calculate the variance
           varVector(count) = var(temp4(:));
           count = count + 1;
    end
   
end

maxVal = max(varVector);
ind = (varVector == maxVal);
optAngle = angleVec(ind);

%The focus curve
figure; plot(angleVec,varVector); xlabel('Angles Degrees'); ylabel('Focus Measure'); 

%Find the shift in the FOV
angleIterMedium = asind(sind(optAngle)/refractiveIndex);
shiftHorizontal =  zDist*tand(angleIterMedium);
shiftInFOVpixels = round((initShift - shiftHorizontal)/pixelSize);


end



