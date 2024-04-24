
%% Create the ramp
vHigh = 50; %mV
vLow = -50; %mV
IT = 20; %ms
goBackTime = 3; %ms
margin = 1; %ms
ratio = 1;
[rampVector, vHighScan, vLowScan, newFreq, symmetry] = CreateRamp3(vHigh, vLow, IT, goBackTime, margin, ratio);

%% Start com
sizeOfBuffer = 1024;
[afg] = EstablishComAfg(sizeOfBuffer); 

%% Set the ramp
SetAfgRamp(afg, vLow, vHigh, newFreq, symmetry);

%% stop the com
fclose(afg);
delete(afg);
clear afg;
