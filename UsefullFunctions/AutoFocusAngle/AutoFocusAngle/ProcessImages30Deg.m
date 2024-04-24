%% 30 Deg
[image] = ReadRawData('H:\MatlabFiles\SourceCode\AutoFocusAngle\30Deg_avg\530nm_avg_30Deg.bin'); 
[ balancedImage ] = EqualizeG1G2( image );
%figure; imshow(image,[]);
vPoint = 1184;
hPoint = 2219;
radius = 350;
interpFactor = 5; 
transAreaSize = 40;
vDim = 4096;
hDim = 4096;
[imageCropRot] = CropRotateForSony(image, radius, vPoint, hPoint );
%figure; imshow(imageCropRot,[]);
imageCropRotInterp = imresize(imageCropRot, interpFactor);
[testImage3] = ImageSegmentRecombination(imageCropRotInterp, transAreaSize, vDim, hDim);
figure; imshow(testImage3,[]);
save testImage3 testImage3;

%% 0 Deg
[image] = ReadRawData('H:\MatlabFiles\SourceCode\AutoFocusAngle\30Deg_avg\530nm_avg_0Deg.bin'); 
%figure; imshow(image,[]);
vPoint = 1286;
hPoint = 2217;
radius = 500;
interpFactor = 4; 
transAreaSize = 40;
vDim = 4096;
hDim = 4096;
[imageCropRot] = CropRotateForSony(image, radius, vPoint, hPoint );
%figure; imshow(imageCropRot,[]);
imageCropRotInterp = imresize(imageCropRot, interpFactor);
[controlImage] = ImageSegmentRecombination(imageCropRotInterp, transAreaSize, vDim, hDim);
figure; imshow(controlImage,[]);

%% Check z distance
waveLength = 530; %[nm]
zDistance = 192;
meduimRefIndx = 1;
pixelSize = 1.12*sqrt(2)/4;
interpFactor = 1;
convUnits = true; 
zeroPad = false;
freqShift = true;
angleH = 0;
angleV = 0;
holo =  testImage3;
holo = imresize(controlImage, interpFactor);
[propImage] = WavePropAngle_v4(holo, waveLength, -zDistance, meduimRefIndx, pixelSize/interpFactor, pixelSize/interpFactor, angleV, angleH, convUnits, zeroPad, freqShift);
figure; imshow(abs(propImage),[]);

