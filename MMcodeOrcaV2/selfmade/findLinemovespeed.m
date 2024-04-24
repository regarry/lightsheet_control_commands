function [] = findLinemovespeed(afg,mmc, cameraLabel)
    top = 1200;
    bot = -600;
    %Set the exposure
    expTime = 100;
    mmc.setProperty(cameraLabel,'Exposure', expTime);
    val = mmc.getProperty(cameraLabel,'Exposure');
    disp(['Exposure was set to ',char(val),' ms']);
    
    voltageVector = [bot:100:top];
    
    for ii = 1:size(voltageVector,2)
        fwrite(afg, ':source1:function DC');
        fwrite(afg, [':source1:voltage:offset ',num2str(voltageVector(ii)),'mv']);
        dcValueAfterWrite = query(afg, ':source1:voltage:offset?');
        fwrite(afg, ':output1 on;');
        pause(0.2);
        img = CaptureImageIntTri(mmc);
        imwrite(img,['selfmade/test_images/',num2str(ii),'_',num2str(voltageVector(ii)),'_.tiff']);
        pause(0.25);
    end



end