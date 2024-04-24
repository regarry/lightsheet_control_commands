load testImage4;
waveLength = 530; %[nm]
zDistance = 221;
meduimRefIndx = 1;
pixelSize = 1.12*sqrt(2)/5;
interpFactor = 1;
convUnits = true; 
zeroPad = false;
freqShift = true;
angleH = -1.3;
angleV = -27;
holo =  testImage4;
holo = imresize(holo, interpFactor);
[propImage] = WavePropAngle_v4(holo, waveLength, -zDistance, meduimRefIndx, pixelSize/interpFactor, pixelSize/interpFactor, angleV, angleH, convUnits, zeroPad, freqShift);
figure; imshow(abs(propImage),[]);

%% look for the angle auto
verticalAng = true; 
convUnits = true; 
stepSize = 1;
range = 5;
radius = 200;
hPoint = 1802;
vPoint = 1969;

[angleV, shift] = AutoFocusAngle_V2(holo, zDistance, pixelSize, waveLength, meduimRefIndx, angleH, angleV, stepSize, range, convUnits, verticalAng, vPoint, hPoint, radius);
vPoint = vPoint + shift;
angleV
%% Hor angle
verticalAng = false;
[angleH, shift] = AutoFocusAngle_V2(holo, zDistance, pixelSize, waveLength, meduimRefIndx, angleV, angleH, stepSize, range, convUnits, verticalAng, vPoint, hPoint, radius);
hPoint = hPoint + shift;
angleH



%% Fine scan
stepSize = 0.1;
range = 1;
verticalAng = true; 
[angleV, shift] = AutoFocusAngle_V2(holo, zDistance, pixelSize, waveLength, meduimRefIndx, angleH, angleV, stepSize, range, convUnits, verticalAng, vPoint, hPoint, radius);
vPoint = vPoint + shift;
angleV

%%
verticalAng = false;
[angleH, shift] = AutoFocusAngle_V2(holo, zDistance, pixelSize, waveLength, meduimRefIndx, angleV, angleH, stepSize, range, convUnits, verticalAng, vPoint, hPoint, radius);
hPoint = hPoint + shift;
angleH
angleV



