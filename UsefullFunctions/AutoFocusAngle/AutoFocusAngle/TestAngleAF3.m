load testImage3;
waveLength = 530; %[nm]
zDistance = 192;
meduimRefIndx = 1;
pixelSize = 1.12*sqrt(2)/5;
interpFactor = 1;
convUnits = true; 
zeroPad = false;
freqShift = true;
angleH = 19;
angleV = -23.2;
holo =  testImage3;
holo = imresize(holo, interpFactor);
[propImage] = WavePropAngle_v4(holo, waveLength, -zDistance, meduimRefIndx, pixelSize/interpFactor, pixelSize/interpFactor, angleV, angleH, convUnits, zeroPad, freqShift);
figure; imshow(abs(propImage),[]);

%% look for the angle auto
verticalAng = true; 
convUnits = true; 
stepSize = 0.1;
range = 1.5;
radius = 300;
hPoint = 1881;
vPoint = 2477;

[angleV] = AutoFocusAngle_V1(holo, zDistance, pixelSize, waveLength, meduimRefIndx, angleH, angleV, stepSize, range, convUnits, verticalAng, vPoint, hPoint, radius);
angleV
%% Hor angle
verticalAng = false;
[angleH] = AutoFocusAngle_V1(holo, zDistance, pixelSize, waveLength, meduimRefIndx, angleV, angleH, stepSize, range, convUnits, verticalAng, vPoint, hPoint, radius);
angleH
%% Ver angle
verticalAng = true;
[angleV] = AutoFocusAngle_V1(holo, zDistance, pixelSize, waveLength, meduimRefIndx, angleH, angleV, stepSize, range, convUnits, verticalAng, vPoint, hPoint, radius);
angleV
%% Hor angle
verticalAng = false;
[angleH] = AutoFocusAngle_V1(holo, zDistance, pixelSize, waveLength, meduimRefIndx, angleV, angleH, stepSize, range, convUnits, verticalAng, vPoint, hPoint, radius);
angleH






