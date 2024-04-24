%This function creates the waveform that will be sent
%to the afg in order to run the galvo 
%vHigh [mv]
%vLow [mv]
%IT integration time in [ms]
%goBackTime - how much time to let the mirror to return to 
%start scan position [ms]
%margin - how much more room to provide the signal for sync [ms]
%ratio - by how much to offset the symmetry factor
%Outputs:
%rampVector - between 0 ... 16382 (max vol in AFG)
%newFreq - the frequency including the margin and the goBackTime [hz]
%vHighScan - the new high voltage after adding the margins [mv]
%vLowScan - the new low voltage after adding the margins [mv]
%symmetry - the symmetry factor [%]

function [rampVector, vHighScan, vLowScan, newFreq, symmetry] = CreateRamp3(vHigh, vLow, IT, goBackTime, margin, ratio )
    
    %How many samples
    vectorSize = 1024*20;
    
    %AFG limits
    upLimit = 16382;
    lowLimit = 0;
    
    %Scan speed
    speed = (vHigh - vLow)/(IT); %V/sec
    
    %The new integration time
    NIT = IT + goBackTime + margin; %ms
    
    %New frequency 
    newFreq = 1/(NIT/1000); %Hz
    
    %The end voltage of the scan
    vEnd = speed*(NIT - goBackTime); %mV
    
    %Add a little more range
    ranges = (vEnd - (vHigh - vLow))/2;
    
    vHighScan = vHigh + ranges;
    vLowScan = vLow - ranges;
    
    %Recalc to have vLowScan and vHighScan to be an integer of mv as the
    %AFG resolution -----------------------------
    newVoltageHigh = ceil(vHighScan);
    timeExtend = (newVoltageHigh - vHighScan)/speed; %ms
    newTimeMargin = margin + 2*timeExtend;
    
    %The new integration time
    NIT = IT + goBackTime + newTimeMargin; %ms
    
    %New frequency 
    newFreq = 1/(NIT/1000); %Hz
    
    %The end voltage of the scan
    vEnd = speed*(NIT - goBackTime); %mV
    
    %Add a little more range
    ranges = (vEnd - (vHigh - vLow))/2;
    
    vHighScan = vHigh + ranges;
    vLowScan = vLow - ranges;    
    %------------------------------------
    
    %Build the signal
    dT = NIT/vectorSize; %ms
    
    %Where to start to go back
    samplesUntilGoBack = round((IT + newTimeMargin)/dT);
    samplesUntilGoBack = round(samplesUntilGoBack*ratio);
    symmetry = (samplesUntilGoBack/vectorSize)*100; % in prec
    
    %Create the vector
    rampVector = zeros(1,vectorSize);
    rampVector(1:samplesUntilGoBack) = (0:(samplesUntilGoBack-1))/(samplesUntilGoBack-1);
    rampVector((samplesUntilGoBack+1):end) = 1-(1:(vectorSize-samplesUntilGoBack))/(vectorSize-samplesUntilGoBack);
    rampVector = round(rampVector*(upLimit-lowLimit));
    %rampVector = rampVector*(vHighScan-vLowScan);
    
    %Plot the vector
    %figure; plot(rampVector);
    figure; plot((1:vectorSize)*NIT/(vectorSize-1) - NIT/(vectorSize-1), rampVector);
    
    
 end

