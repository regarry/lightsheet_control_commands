
%% Create the ramp
vHigh = 50; %mV
vLow = -50; %mV
IT = 20; %ms
goBackTime = 1; %ms
margin = 1; %ms
[rampVector, vHighScan, vLowScan, newFreq] = CreateRamp2(vHigh, vLow, IT, goBackTime, margin);

%% Assume that the data is between 0 to 16382
[parsedRampVector, header, bytes] = ParseDataForAFGWriting(rampVector);

%% Start com
sizeOfBuffer = ceil((bytes + 100)/1024)*1024;
[afg] = EstablishComAfg(sizeOfBuffer); 

%% Write the ramp to the AFG
WriteTheFunctionToAFG(afg, header, parsedRampVector, vHighScan, vLowScan, newFreq);

%% Write the external trigger signal
SetExternalTriggerSignal(afg, newFreq);

%% stop the com
fclose(afg);
delete(afg);
clear afg;
