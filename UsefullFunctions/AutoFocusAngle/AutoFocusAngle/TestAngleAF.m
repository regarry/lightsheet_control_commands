load testImage;
waveLength = 600; %[nm]
zDistance = 338;
meduimRefIndx = 1.5;
pixelSize = 1.12/4;
interpFactor = 1;
convUnits = true; 
zeroPad = false;
freqShift = true;
angleH = testImage.angleH;
angleV = testImage.angleV;
holo =  testImage.image;
holo = imresize(holo, interpFactor);
[propImage] = WavePropAngle_v4(holo, waveLength, -zDistance, meduimRefIndx, pixelSize/interpFactor, pixelSize/interpFactor, angleV, angleH, convUnits, zeroPad, freqShift);
figure; imshow(abs(propImage),[]);

%% look for the angle auto
verticalAng = true; 
convUnits = true; 
stepSize = 1;
range = 1;
radius = 150;
hPoint = 1535;
vPoint = 2098;

[optAngle] = AutoFocusAngle_V1(holo, zDistance, pixelSize, waveLength, meduimRefIndx, testImage.angleH, testImage.angleV, stepSize, range, convUnits, verticalAng, vPoint, hPoint, radius);
optAngle