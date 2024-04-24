load testImage2;
waveLength = 600; %[nm]
zDistance = 349;
meduimRefIndx = 1.5;
pixelSize = 1.12/4;
interpFactor = 1;
convUnits = true; 
zeroPad = false;
freqShift = true;
angleH = 1.2;
angleV = 32.5;
holo =  testImage2;
holo = imresize(holo, interpFactor);
[propImage] = WavePropAngle_v4(holo, waveLength, -zDistance, meduimRefIndx, pixelSize/interpFactor, pixelSize/interpFactor, angleV, angleH, convUnits, zeroPad, freqShift);
figure; imshow(abs(propImage),[]);

%% look for the angle auto
verticalAng = true; 
convUnits = true; 
stepSize = 0.5;
range = 2;
radius = 300;
hPoint = 2037;
vPoint = 1580;

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






