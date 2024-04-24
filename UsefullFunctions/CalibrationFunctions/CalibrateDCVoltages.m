%This function is calibrating the bottom and top DC voltages, 
%Inputs: mmc, cameraLabel, intTime, centerV [mV], range [mv], windowSize, whichLine
function [ Voptimal ] = CalibrateDCVoltages(afg, mmc, cameraLabel, expTime, centerV, range, windowSize, whichLine, showImages)
    
    %Create the scan range
    voltageVector = centerV + (-range:range);
    meanValueVector = zeros(1,size(voltageVector,2));
    width = mmc.getImageWidth();
    height = mmc.getImageHeight();
    imagesArray = zeros(height,width,size(voltageVector,2));
    
    %Set the exposure
    mmc.setProperty(cameraLabel,'Exposure', expTime);
    val = mmc.getProperty(cameraLabel,'Exposure');
    display(['Exposure was set to ',char(val),' ms']);
    
    for ii = 1:size(voltageVector,2)
        
        %Set the proper DC voltage
        [dcValueAfterWrite] = SetAfgDCValue(afg, voltageVector(ii));
        display(['Set the voltage to ',num2str(dcValueAfterWrite),' mv']);
        
        %Capture an image
        [imagesArray(:,:,ii)] = CaptureImageIntTri(mmc);
        
        pause(0.25);
        
        %Check which has the higher mean value
        if (whichLine == 1)
            whichLineVector = 1:windowSize;
        else
            whichLineVector = ((whichLine - windowSize):whichLine);            
        end
        meanValueVector(ii) = mean2(imagesArray(whichLineVector,:,ii));
        if (showImages)
            figure; imshow(imagesArray(:,:,ii),[0 600]); title(['Voltage value = ',num2str(voltageVector(ii))]);      
        end
    end
    
    %Print the parameter
    maxVal = max(meanValueVector);
    k = find((meanValueVector == maxVal)); 
    k = k(1);
    display(['Best DC value = ',num2str(voltageVector(k)) ,' mV']);
    display(['Mean value = ',num2str(maxVal)]);
    linesImage = imagesArray(whichLineVector,:,k);
    
    %Set the best voltage
    [dcValueAfterWrite] = SetAfgDCValue(afg, voltageVector(k));
    display(['Set the voltage to ',num2str(dcValueAfterWrite),' mv']);
    
    %Show the best lines
    %figure; imshow(linesImage,[]);
    stdVal = std(linesImage(:));
    display(['Std value = ',num2str(stdVal)]);
    
    %Show the best image
    figure; imshow(imagesArray(:,:,k),[]); 
    figure; plot(voltageVector,meanValueVector); title('Mean Value vs. Voltage');
    
    Voptimal = voltageVector(k);

end

