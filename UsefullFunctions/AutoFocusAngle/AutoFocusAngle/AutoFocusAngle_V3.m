%-----------------------------------
%-----------------------------------
%Auto focus part, 
%Version 3 added some parameters to improve scan angle H angle V and z
%distance together
%-----------------------------------
%-----------------------------------

function [optAngleV, optAngleH, optZdist, shiftInFOVpixelsV, shiftInFOVpixelsH, varVector] = AutoFocusAngle_V3(image, pixelSize, waveLength, refractiveIndex, convUnits, angleV, rangeV, stepV, angleH, rangeH, stepH, zDist, rangeZ, stepZ, vPoint, hPoint, radius, showFigures)

%Parameter definition 
zeroPad = false; %For BP
freqShift = true; %For BP

%Create the sobel edge matrix
hh = fspecial('sobel');
hv=hh';
 
%For the proceses keep only the region of intrest 
processedAreaVectorV = vPoint + (-radius:radius);
processedAreaVectorH = hPoint + (-radius:radius);
 
%Vector in Z
zVec = (zDist-rangeZ):stepZ:(zDist+rangeZ);
numOfelementsInZ = numel(zVec);

%Vector in V
angleVecV = (angleV-rangeV):stepV:(angleV+rangeV);
numOfelementsInAngleVecV = numel(angleVecV);

%Vector in H
angleVecH = (angleH-rangeH):stepH:(angleH+rangeH);
numOfelementsInAngleVecH = numel(angleVecH);

%The Focous measure matrix
varVector = zeros(numOfelementsInAngleVecV,  numOfelementsInAngleVecH, numOfelementsInZ);

%count the iterations
zCount = 0;

%To change to processed FOV to follow the angle
initAngleMediumV = asind(sind(angleV)/refractiveIndex);
initShiftV = zDist*tand(initAngleMediumV);
    
%To change to processed FOV to follow the angle
initAngleMediumH = asind(sind(angleH)/refractiveIndex);
initShiftH = zDist*tand(initAngleMediumH);

%loop for z distances
for curZDist = (zDist-rangeZ):stepZ:(zDist+rangeZ)
    
    zCount = zCount + 1;
    vCount = 0;
    
    %loop for v angle
    for curAngleV = (angleV-rangeV):stepV:(angleV+rangeV)
        
        vCount = vCount + 1;
        hCount = 0;
        
        %loop for v angle
        for curAngleH = (angleH-rangeH):stepH:(angleH+rangeH)
            
            hCount = hCount + 1;
           
            fprintf(['z distance = ',num2str(curZDist),' angleV = ',num2str(curAngleV),' angleH = ',num2str(curAngleH),'\n']);
            %Prop the image
            [propImage] = WavePropAngle_v4(image, waveLength, -curZDist, refractiveIndex, pixelSize, pixelSize, curAngleV, curAngleH, convUnits, zeroPad, freqShift);
            
            %Make sure that they have the same FOV, start with vertical 
            angleIterMediumV = asind(sind(curAngleV)/refractiveIndex);
            shiftVertical =  curZDist*tand(angleIterMediumV);
            shiftInPixelsV = round((initShiftV - shiftVertical)/pixelSize);
            processedAreaVectorVmoved = processedAreaVectorV + shiftInPixelsV;
            
            angleIterMediumH = asind(sind(curAngleH)/refractiveIndex);
            shiftHorizontal =  curZDist*tand(angleIterMediumH);
            shiftInPixelsH = round((initShiftH - shiftHorizontal)/pixelSize);
            processedAreaVectorHmoved = processedAreaVectorH + shiftInPixelsH;
            
            imageProces = abs(propImage(processedAreaVectorVmoved, processedAreaVectorHmoved));
            if (showFigures)
                figure; imshow(imageProces,[]); title(['z distance = ',num2str(curZDist),' angleV = ',num2str(curAngleV),' angleH = ',num2str(curAngleH)]);
            end
            %Find the edges using the sobel matrix
            temp2 = abs(imfilter(imageProces,hh));
            temp3 = abs(imfilter(imageProces,hv));
            temp4 = sqrt(temp2.^2 + temp3.^2);
            %Calculate the variance
            varVector(vCount, hCount, zCount) = var(temp4(:));            
            
        end
    end
end
        
%Find the pick
maxVal = max(varVector(:));
[optAngleVind, optAngleHind, optZind] = ind2sub(size(varVector),find(varVector == maxVal));
optAngleV = angleVecV(optAngleVind(1));
optAngleH = angleVecH(optAngleHind(1));
optZdist = zVec(optZind(1));

%The focus curve
% for ii = 1:numOfelementsInZ 
%     if (showFigures)        
%         figure; imagesc(angleVecH, angleVecV, varVector(:,:,ii)); title(['Z = ', num2str(zVec(ii))]); xlabel('V angles Degrees'); ylabel('H angles Measure');     
%     end
% end


%Find the shift in the FOV V direction
angleIterMediumV = asind(sind(optAngleV)/refractiveIndex);
shiftVertical =  optZdist*tand(angleIterMediumV);
shiftInFOVpixelsV = round((initShiftV - shiftVertical)/pixelSize);

%Find the shift in the FOV H direction
angleIterMediumH = asind(sind(optAngleH)/refractiveIndex);
shiftHorizontal =  optZdist*tand(angleIterMediumH);
shiftInFOVpixelsH = round((initShiftH - shiftHorizontal)/pixelSize);


end



