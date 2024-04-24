function [AllImage,xyzScanArray]=MoveandStitch(app,Vertiles_num,Horztiles_num,stepSizeInLateralScan)
    %Get the current location of the stage    
    [xPos,yPos,zPos]=getXYZposition(app.controlParameters.MMC);
    %Find the cordinates of the sampling grid
    [xyzScanArray]=createScanpattern(xPos,yPos,zPos,Vertiles_num,Horztiles_num,stepSizeInLateralScan);
    
    [images] = captureALLimagesperTile(app,xyzScanArray);
    %save images images;
    AllImage = StitchImages(images,Vertiles_num,Horztiles_num);
%     for i = 1:size(images,3)
%         name_file = ['stitches/',date,'_ChenLi_',num2str(i),'.tiff'];
%         imwrite(images(:,:,i),name_file);
%     end
    %figure;
    %imshow(AllImage,[0,2500]);
    
end





































