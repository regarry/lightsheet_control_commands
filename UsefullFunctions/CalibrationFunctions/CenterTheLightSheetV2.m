%The function moves the excitation objective until it finds the center of the light sheet
%, the quality measure can be mean intensity or it can be the FWHM
%of the light sheet in static mode 
%Inputs:
%relativePositionRange - the scan radius in um
%scanRes - the resolution of the scan, usually 1 um
%whichQualityMeasure - 1 for FWHM, 2 for mean intensity
%aveNum - how many times to average in each position
%sExtLens - a serial port to the detection objective
%cameraLabel - the MM label of the camera
%mmc - the MM structure 
%expTime - the wanted exposure in [ms]
%moveToBestFocalPoint - in the end of the process to move to the best
%excitation position
%point or not, boolean variable true will move false will not
%lightSheetMode - a boolean variable for light sheet mode, determine of the
%exposure will be changed or not
%outputs:
%bestExcitationLensPos - the best position relative to the input location
%scanVector - the scan vector that was used to minimize backLash
%qualityMeasureVector -  

function [bestExcitationLensPos, imageAtbestExcitationLensPos, actualScanLocations, qualityMeasureVector] = CenterTheLightSheetV2(relativePositionRangeUm, scanResUm,...
    whichQualityMeasure, aveNum, sExtLens, cameraLabel, mmc, expTime, moveToBestFocalPoint, lightSheetMode)
    
    %For debug purposes
    showImages  = false; 
    
    if (nargin == 9)
        lightSheetMode = false;
    end
    
    %It means that no need to scan
    if (relativePositionRangeUm < 0)        
        [bestExcitationLensPos] = str2double(GetPos(sExtLens)); 
        imageAtbestExcitationLensPos = 0;
        actualScanLocations = 0;
        qualityMeasureVector = 0;
        return;
    end
    
    %Configure the buffer the largest allowed in Java
    mmc.setCircularBufferMemoryFootprint(1024*4);  
    
    width = mmc.getImageWidth();
    height = mmc.getImageHeight();
    pixelType = 'uint16';
    downSampleFactor = round(2048/width);
    
    maximumSearchRangeUm = 1000;
    waitTimeForBacklash = 1.5; %sec
    
    %Used for the sobel var algo
    widthOfWindow = round(1000/downSampleFactor);
    heightOfWindow = round(1000/downSampleFactor);
    
    %Used in fitting gaussians to the light-sheet
    lengthFromCenterInPixels = round(150/downSampleFactor); %The size of the cross section
    %How many cross-sections
    numOfSections = 5;
    %The space between the cross sections
    spaceBetweenSectionsInPixels = round(20/downSampleFactor);
    
    %Check that the range is reasonable 
    relativePositionRangeUm = round(relativePositionRangeUm);
    if (relativePositionRangeUm > maximumSearchRangeUm)
        relativePositionRangeUm = maximumSearchRangeUm;
    end
    
    
    %The motor res is ~ 1 um so for centering the light sheet 10 is fine
    scanResUm = round(scanResUm);
    if (scanResUm < 10)
        scanResUm = 10;
    end
   
    scanResMm = scanResUm/1000;
    %define the scan vector
    scanVectorUm = (0:scanResUm:2*relativePositionRangeUm);
    scanVectorMm = scanVectorUm/1000;
    relativePositionRangeMm = relativePositionRangeUm/1000;
    qualityMeasureVector = zeros(1,numel(scanVectorMm));
    actualScanLocations = zeros(1,numel(scanVectorMm));
    aveImageArray = zeros(height, width, numel(scanVectorMm));
    %s = struct('image',zeros(2048,2048), 'detObjLoc', 0 ,'sigma',Inf);
    
    %move the excitation lens to the start position in order to minimize
    %backlash     
    %Get the start position
    [curLoc] = GetPos(sExtLens);
     display(['Stage start position is:',curLoc]);  
    % Change the speed and move the lens to minimize backlash
    fprintf(sExtLens,'1VA1'); 
    fprintf(sExtLens,['1PR-',num2str(relativePositionRangeMm)]);
              
    %Set the exposure time to the required value
    if (~lightSheetMode)
        mmc.setProperty(cameraLabel,'Exposure', expTime);
        expVal = mmc.getProperty(cameraLabel,'Exposure');
        display(['Exposure was set to ',char(expVal),' ms']);
        waitBetweenImages = str2num(char(expVal))/1000;
    else 
        waitBetweenImages = 0.2; %sec
    end
    
    %Change the speed again to small increments 
    stageSpeedDuringScan = '0.25';
    fprintf(sExtLens,['1VA',stageSpeedDuringScan]); 
    pause(waitTimeForBacklash);
    waitTimeForStage = 0.2; %sec
    
    %Start capturing images    
    numOfImages = 1000000;
    intervalMs = 0;
    stopOnOverflow = false;
    mmc.setShutterOpen(true);
    mmc.startSequenceAcquisition(numOfImages, intervalMs, stopOnOverflow);
    pause(0.1);      
   
    for ii = 1:numel(scanVectorMm)
        
        %Create the average image
        aveImage = zeros(height, width); 
        
        %Register the position of the stage
        [actualScanLocations(ii)] = str2double(GetPos(sExtLens)); %The location is a string
        display(['Current location of excitation objective is ',num2str(actualScanLocations(ii)*1000),' in um calc ...']);
        
        %Avarage the signal for more accurate results
        for jj = 1:aveNum            
                     
            mmc.setShutterOpen(true);
            pause(waitBetweenImages + 0.25);
            startTime = tic;
            image = mmc.getLastImage(); 
            image = typecast(image, pixelType);      % pixels must be interpreted as unsigned integers
            image = reshape(image, [width, height]); % image should be interpreted as a 2D array
            image = transpose(image);                % make column-major order for MATLAB
            mmc.setShutterOpen(false);
            aveImage = aveImage + double(image);
            elTime = toc(startTime);
%             if (elTime <= (waitBetweenImages))
%                 pause(waitBetweenImages - elTime);            
%             else
%                 pause(0.1);
%             end 
            pause(0.25);
        end
        aveImage = aveImage/aveNum;
        aveImageArray(:,:,ii) = aveImage;
        
        
        if (showImages)
            figure; imshow(aveImage, []); title(['mean value = ',num2str(mean2(aveImage)), ' current location = ',num2str(actualScanLocations(ii)*1000)]);
        end
                    
        %move to the next location
        fprintf(sExtLens,['1PR',num2str(scanResMm)]);
        
        
        %Give it some to reach the next location
        if (ii == 1)
            pause((scanResUm/1000/str2num(stageSpeedDuringScan)) + waitTimeForBacklash);
        else
            pause((scanResUm/1000/str2num(stageSpeedDuringScan)) + waitTimeForStage);
        end
        switch whichQualityMeasure
            case 1
                %find the vertical position of the light sheet and check that it is
                %not too close to the edge
                [verPosLightSheet] = FindTheVerticalPositionOfTheLightSheet(aveImage, lengthFromCenterInPixels);
                [qualityMeasureVector(ii)] = EvaluateFWHM(aveImage, lengthFromCenterInPixels, verPosLightSheet, numOfSections,...
                    spaceBetweenSectionsInPixels, showImages);
            case 2
                %[qualityMeasureVector(ii)] = EvaluateNormalizedVariance(aveImage, 250,250);
                [qualityMeasureVector(ii)] = EvaluateNormalizedVariance(aveImage);
            case 3                
                %[qualityMeasureVector(ii)] = EvaluateSobelVariance(aveImage, widthOfWindow, heightOfWindow);
                [qualityMeasureVector(ii)] = EvaluateSobelVariance(aveImage);
            case 4
                [qualityMeasureVector(ii)] = EvaluateChangesInMaxValue(aveImage);
        end
               
    end
    %Debug
%     if (whichQualityMeasure ~= 1)
%         qualityMeasureVector(1) = min(qualityMeasureVector);
%     end
    %qualityMeasureVector(1) = 0;
    %Analyze the data
    switch whichQualityMeasure
        case 1
                ind = find(min(qualityMeasureVector) == qualityMeasureVector);
        case 2 
                ind = find(max(qualityMeasureVector) == qualityMeasureVector);
        case 3
                ind = find(max(qualityMeasureVector) == qualityMeasureVector);
        case 4
                ind = find(max(qualityMeasureVector) == qualityMeasureVector);
    end
    
    ind = ind(1);
    bestExcitationLensPos = actualScanLocations(ind);
    imageAtbestExcitationLensPos = aveImageArray(:,:,ind);
    showImages = true;
    %Show the best image
    switch whichQualityMeasure
        case 1
            %find the vertical position of the light sheet and check that it is
            %not too close to the edge
            [verPosLightSheet] = FindTheVerticalPositionOfTheLightSheet(aveImage, lengthFromCenterInPixels);
            [~] = EvaluateFWHM(imageAtbestExcitationLensPos, lengthFromCenterInPixels, verPosLightSheet, numOfSections,...
                spaceBetweenSectionsInPixels, showImages);
        case 2
            [~] = EvaluateNormalizedVariance(imageAtbestExcitationLensPos, widthOfWindow, heightOfWindow);
        case 3
            [~] = EvaluateSobelVariance(imageAtbestExcitationLensPos, widthOfWindow, heightOfWindow);
    end
    
    if (moveToBestFocalPoint)
        
         [curLoc] = GetPos(sExtLens);
         diff = bestExcitationLensPos - str2double(curLoc);
         %Check that it does not move more than 20 um
         if (abs(diff) > (2.5*abs(relativePositionRangeUm)/1000)) 
             diff = 0.001;
             display('Error in pos calculation');
         end
         pause(1);
         fprintf(sExtLens,['1PR',num2str(diff)]);         
    end  
    
    %Check and close the shutter
    if (mmc.isSequenceRunning)
        mmc.stopSequenceAcquisition;
    end
    
    %Enable the auto shutter
    mmc.setAutoShutter(true);
    mmc.setShutterOpen(false);
end

function [pos] = GetPos(serial)
        
        maxSizeOfString = 7;        
        fprintf(serial,'1TP?');
        pos = fscanf(serial);
        k = strfind(pos,'TP');
        k = k(1);
        pos = pos(k+2:end);
        k = strfind(pos,'e');        
        if (~isempty(k))
            k = k(1);
            scale = pos(k+1:k+3);
            pos = pos(1:k-1);
            switch scale
                case '-06'
                    pos = num2str(0);
                case '-05'
                    pos = num2str(0);                
            end                   
        end
        
        if(numel(pos) > maxSizeOfString)
            pos = pos(1:maxSizeOfString);
        end              
    
end

function [verPosLightSheet] = FindTheVerticalPositionOfTheLightSheet(aveImage, lengthFromCenterInPixels)

        verPosLightSheet = find(mean(aveImage,2) == max(mean(aveImage,2)));
        
        %Take care of the edges
        if (verPosLightSheet <= lengthFromCenterInPixels) 
            verPosLightSheet = lengthFromCenterInPixels + 1;
        end
        
        [height, ~] = size(aveImage);
        
        if ((height - verPosLightSheet) <= lengthFromCenterInPixels)
            verPosLightSheet = height - lengthFromCenterInPixels - 1;
        end

end

function [qualityMeasure] = EvaluateFWHM(image, lengthFromCenterInPixels, verPosLightSheet, numOfSections, spaceBetweenSectionsInPixels, showImages)
   
    %Define parameters
    smoothFactor = 4;
    tubeLensFocalDistance = 30; %cm
    objectiveDesignedTubeLensFocal = 18;
    objectiveMag = 25;
    pixelSizeUm = 6.5;
    downSampleFactor = 2048/size(image,1);
    effectivePixelSize = (pixelSizeUm/objectiveMag)*(objectiveDesignedTubeLensFocal/tubeLensFocalDistance)*downSampleFactor;
    qualityMeasure = zeros(1, numOfSections);
    
    %Check that the number of cross-sections is odd
    if (mod(numOfSections,2) == 0)
        numOfSections = numOfSections + 1;
    end

    %Create the cordinates for all the cross sections
    crossSectionCordV = verPosLightSheet + (-lengthFromCenterInPixels:(lengthFromCenterInPixels-1));
    edge = spaceBetweenSectionsInPixels*(numOfSections-1)/2;
    crossSectionCordH = size(image,1)/2 + (-edge:spaceBetweenSectionsInPixels:edge);
      
    %Show the cross sections 
    if (showImages)
        figure; imshow(image,[]);
        hold on;
        for ii = 1:numOfSections
            p1 = [crossSectionCordV(1), crossSectionCordH(ii)];
            p2 = [crossSectionCordV(end), crossSectionCordH(ii)];
            plot([p1(2),p2(2)],[p1(1),p2(1)],'Color','r','LineWidth',2)
        end
        hold off;
        
        %For next figure
        figure; 
        hold on;
    end
    
    
    for ii = 1:numOfSections
       
        c = image(crossSectionCordV, crossSectionCordH(ii));
        crossSection = smooth(c,smoothFactor);
        xDataInUm = (1:size(crossSection,1))*effectivePixelSize;
        xDataInUm = xDataInUm';
               
        %Fit a guassian
        [xData, yData] = prepareCurveData(xDataInUm, crossSection);
        
        x0 = [mean(yData) max(yData) xData(end)/2 5];     
        myfit3 = @(x,xdata)x(1) + x(2)*exp(-0.5*((xdata-x(3))/x(4)).^2);
        %options = optimset('TolFun',1.0000e-10, 'TolX',1.0000e-10);        
        %lb, ub are the similar matrix as x0 that define lower and upper bound of x.
        [x, ~, ~,exitflag,output] = lsqcurvefit(myfit3, x0, xData, yData);
        output.iterations
        fittedCurve = myfit3(x,xData);
        if (showImages)
            subplot(numOfSections,1,ii); plot(xData, fittedCurve, xData, yData );
            title(['sigma = ',num2str(x(4))]);
            xlabel( 'xData' );
            ylabel( 'yData' );
            grid on 
         end
         qualityMeasure(ii) = x(4); 
        
    end     
    
    qualityMeasure = median(qualityMeasure);

end

function [qualityMeasure] = EvaluateNormalizedVariance(aveImage, widthOfWindow, heightOfWindow)
    
    if (nargin < 3)
        fullImage = true;        
    else 
        fullImage = false;
    end
    
    if (fullImage)
        
        temp = aveImage;
        
    else
        
        vPoint = round(size(aveImage,1)/2);
        hPoint = round(size(aveImage,2)/2);
        vVec = vPoint + (-heightOfWindow:(heightOfWindow - 1));
        hVec = hPoint + (-widthOfWindow:(widthOfWindow - 1));
        temp = aveImage(vVec, hVec);      
        %figure; imshow(temp,[0 2000]);
        
    end
    
    qualityMeasure = mean(temp(:));
    %qualityMeasure = (1/(size(temp,1)*size(temp,2)*mean(temp(:))))*var(temp(:));    
        
end

function [qualityMeasure] = EvaluateSobelVariance(aveImage, widthOfWindow, heightOfWindow)
    
    if (nargin < 3)
        fullImage = true;        
    else 
        fullImage = false;
    end
    
    %Create the sobel edge matrix
    hh = fspecial('sobel');
    hv = hh';
    
    if (fullImage)
        
        temp = aveImage;
        
    else
        
        vPoint = round(size(aveImage,1)/2);
        hPoint = round(size(aveImage,2)/2);
        vVec = vPoint + (-heightOfWindow:(heightOfWindow - 1));
        hVec = hPoint + (-widthOfWindow:(widthOfWindow - 1));
        temp = aveImage(vVec, hVec);                        
        
    end
    
     %Find the edges using the sobel matrix
     temp2 = abs(imfilter(temp,hh));
     temp3 = abs(imfilter(temp,hv));
     temp4 = sqrt(temp2.^2 + temp3.^2);
     %Calculate the variance
     qualityMeasure = var(temp4(:)); 
        
end

function [qualityMeasure] = EvaluateChangesInMaxValue(aveImage)
    
    %[counts,centers] = hist(aveImage(:),100);
    averageVal = mean2(aveImage);
    stdVal = std(aveImage(:));
    qualityMeasure = sum(sum(aveImage > (averageVal + 10*stdVal)));
    
end
