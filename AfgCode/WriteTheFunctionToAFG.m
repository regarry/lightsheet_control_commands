%This function sends and writes a vector to the memory of the AFG
%Moreover the function creates a ramp that is following the voltage for
%scan
%afg - the device object name
%parsedRampVector - the function after it has been parsed for writing
%vHighScan - the high voltage value [ms]
%vLowScan - the low voltage value [ms]
%newFreq - the new frequency [Hz]

function [] = WriteTheFunctionToAFG( afg, header, parsedRampVector, vHighScan, vLowScan, newFreq )
    
    %Turn off the input
    fwrite(afg, ':output1 off;');
    
    % clear edit memory and set to 1 samples
    fwrite(afg, ':trace:define ememory, 1;');

    % send the data to edit memory
    fwrite(afg, [':trace ememory,' header parsedRampVector ';'], 'uint8');

    % set channel 1 to arb function found in edit memory
    fwrite(afg, ':source1:function ememory;');
    
    %Change the voltage high level
    fwrite(afg, [':source1:voltage:high ',num2str(vHighScan),' mv']);
    val = query(afg, ':source1:voltage:high?');
    display(['High voltage was set to ',val,'V']);
     
    %Change the voltage low level
    fwrite(afg, [':source1:voltage:low ',num2str(vLowScan),' mv']);
    val = query(afg, ':source1:voltage:low?');
    display(['Low voltage was set to ',val,' V']);
     
    %Change the frequency
    fwrite(afg, [':source1:frequency:fixed ',num2str(newFreq),' hz']);
    val = query(afg, ':source1:frequency?');
    display(['Frequecny was set to ',val,'Hz']); 
    

end

