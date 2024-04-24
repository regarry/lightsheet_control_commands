%%
%Set the parameters
numOfDataPoints = 2000;
minVoltage = -5; %v
maxVoltage = 5; %v
upperVoltageLimit = 5; %v
lowerVoltageLimit = -5; %v
upLimit = 16382;
lowLimit = 0;

%Create the ramp
range = upperVoltageLimit - lowerVoltageLimit;
ramp = ((0:(numOfDataPoints-1))*range/(numOfDataPoints-1)) + minVoltage;
%figure; plot(ramp); title('the wave form');

%Translate it to the device scale
delta = (upperVoltageLimit - lowerVoltageLimit)/(upLimit - lowLimit);
rampConv = round((ramp - lowerVoltageLimit)/delta);
%figure; plot(rampConv);

%Use the convention in order to create the block
binblock = zeros(2 * length(rampConv), 1);
binblock(2:2:end) = bitand(rampConv, 255);
binblock(1:2:end) = bitshift(rampConv, -8);
binblock = binblock';

% build binary block header
bytes = num2str(length(binblock));
header = ['#' num2str(length(bytes)) bytes];

%%
buf = ceil((str2num(bytes) + 100)/1024)*1024;
%Send the function to the afg
afg = visa('TEK', 'USB0::0x0699::0x0347::C037694::0::INSTR', 'InputBufferSize',buf,'OutputBufferSize',buf);
fopen(afg);

fwrite(afg, '*rst;');
fwrite(afg, '*cls;');

% clear edit memory and set to 1 samples
fwrite(afg, ':trace:define ememory, 1;');

% send the data to edit memory
fwrite(afg, [':trace ememory,' header binblock ';'], 'uint8');

% set channel 1 to arb function found in edit memory
fwrite(afg, ':source1:function ememory;');

%Change the voltage level
fwrite(afg, ':source1:voltage:high 60mv');
query(afg, ':source1:voltage:high?')
fwrite(afg, ':source1:voltage:low -50mv');
query(afg, ':source1:voltage:low?')

%Change the frequency
fwrite(afg, ':source1:frequency:fixed 50hz');




% gracefully disconnect
fclose(afg);
delete(afg);
clear afg;