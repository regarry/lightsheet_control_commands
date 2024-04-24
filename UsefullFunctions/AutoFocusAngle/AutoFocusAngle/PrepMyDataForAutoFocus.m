load H:\MatlabFiles\SourceCode\AutoFocusAngle\TestImagesMyData\measurements;
ind = 12;
transAreaSize = 40;
vDim = 4096;
hDim = vDim;
interpFactor = 5;
measurements(ind).angleH
measurements(ind).angleV
testImage4 = measurements(ind).image;
testImage4 = imresize(testImage4, interpFactor);
testImage4 = ImageSegmentRecombination(testImage4, transAreaSize, vDim, hDim);
figure; imshow(testImage4,[]);
save testImage4 testImage4;

