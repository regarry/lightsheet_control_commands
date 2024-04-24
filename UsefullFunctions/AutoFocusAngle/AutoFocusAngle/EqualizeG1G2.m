function [ balancedImage ] = EqualizeG1G2( image )
    balancedImage = image;
    [vSize hSize] = size(image);    
    vVecGreen1 = 1:2:vSize;
    hVecGreen1 = 2:2:hSize;
    imageGreen1 = image(vVecGreen1, hVecGreen1);
    meanGreen1 = mean2(imageGreen1);
    vVecGreen2 = 2:2:vSize;
    hVecGreen2 = 1:2:hSize;
    imageGreen2= image(vVecGreen2, hVecGreen2);
    meanGreen2 = mean2(imageGreen2);
    balancedImage(vVecGreen1, hVecGreen1) = image(vVecGreen1, hVecGreen1).*(meanGreen2/meanGreen1);
end

