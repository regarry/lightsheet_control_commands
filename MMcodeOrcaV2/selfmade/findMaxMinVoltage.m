function [meanValueVector] = findMaxMinVoltage(afg, mmc, cameraLabel, expTime,range)
    
    top = 1225;
    bot = -700;
    
    %Set the exposure
    mmc.setProperty(cameraLabel,'Exposure', expTime);
    val = mmc.getProperty(cameraLabel,'Exposure');
    disp(['Exposure was set to ',char(val),' ms']);
    find_top = false;
    find_bot = true;
    % find optimal top
    if find_top == true
        voltageVector = top + [-range:range];
        meanValueVector = zeros(1,size(voltageVector,2));
        width = mmc.getImageWidth();
        height = mmc.getImageHeight();
        imagesArray = zeros(height,width,size(voltageVector,2));
        for ii = 1:size(voltageVector,2)
            fwrite(afg, ':source1:function DC');
            fwrite(afg, [':source1:voltage:offset ',num2str(ii),'mv']);
            dcValueAfterWrite = query(afg, ':source1:voltage:offset?');
            fwrite(afg, ':output1 on;'); 
            pause(0.25);
            img = CaptureImageIntTri(mmc);
            imagesArray(:,:,ii) = img;
            pause(0.25);
            imwrite(img,['test_images/',num2str(ii),'_top.tiff'])
            windowSize = 5;
            lineVector = 1:windowSize;
            meanValueVector(ii) = mean2(imagesArray(lineVector,:,ii));
        end
        maxVal = max(meanValueVector);
        k = find((meanValueVector == maxVal)); 
        k = k(1);
        disp(k)
        disp(voltageVector(k))
    end
    
    if find_bot == true
        voltageVector = bot + [-range:range];
        meanValueVector = zeros(1,size(voltageVector,2));
        width = mmc.getImageWidth();
        height = mmc.getImageHeight();
        imagesArray = zeros(height,width,size(voltageVector,2));
        for ii = 1:size(voltageVector,2)
            fwrite(afg, ':source1:function DC');
            fwrite(afg, [':source1:voltage:offset ',num2str(voltageVector(ii)),'mv']);
            dcValueAfterWrite = query(afg, ':source1:voltage:offset?');
            fwrite(afg, ':output1 on;'); 
            pause(0.25);
            img = CaptureImageIntTri(mmc);
            imagesArray(:,:,ii) = img;
            pause(0.25);
            imwrite(img,['test_images/',num2str(ii),'_top.tiff'])
            windowSize = 5;
            lineVector = 2048-windowSize:2048;
            meanValueVector(ii) = mean2(imagesArray(lineVector,:,ii));
        end
        maxVal = max(meanValueVector);
        k = find((meanValueVector == maxVal)); 
        k = k(1);
        disp(k);
        disp(voltageVector(k))
    end
    topV = 100;
    botV=-100;
end
% 561nm galvox: -0.32 galvoy: 0.16 ext:4.0
% top voltage: 1239
% bot voltage: -706



