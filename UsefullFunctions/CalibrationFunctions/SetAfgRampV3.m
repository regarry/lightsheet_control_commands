%This function sets the ramp parameter for the galvo
%vLow [mV]
%vHigh [mV]
%frequency [Hz]
%symmetry [%]
%The function does not turn on the channel automatically and let the user
%review the parameters first
function [] = SetAfgRampV3(afg, vLow, vHigh, frequency, symmetry, phase, delayTrig)
    
    %Turn off the input
    fwrite(afg, ':output1 off;'); 
    
    %move to ramp
    fwrite(afg, ':source1:function RAMP');
    
    %Check the input
    if (frequency > 1000)
        display('frequency was changed to 1KHz');
        frequency = 1000;
    end
     if (frequency < 0)
        display('frequency was changed to 1Hz');
        frequency = 1;
     end
    
     %Change the voltage high level
     fwrite(afg, [':source1:voltage:high ',num2str(vHigh),' mv']);
     val = query(afg, ':source1:voltage:high?');
     display(['High voltage was set to ',val,'V']);
     
     %Change the voltage low level
     fwrite(afg, [':source1:voltage:low ',num2str(vLow),' mv']);
     val = query(afg, ':source1:voltage:low?');
     display(['Low voltage was set to ',val,' V']);
     
     %Change the frequency
     fwrite(afg, [':source1:frequency:fixed ',num2str(frequency),' hz']);
     val = query(afg, ':source1:frequency?');
     display(['Frequecny was set to ',val,'Hz']); 
     
     %Change the symmetry
     fwrite(afg, [':source1:function:ramp:symmetry ',num2str(symmetry)]);
     val = query(afg, ':source1:function:ramp:symmetry?');
     display(['Symmetry was set to ',val,' %']); 
     
     %Change the phase to zero degrees
     fwrite(afg, [':source1:phase:adjust ',num2str(phase),'deg']);
     
     %change the mode to burst
     fwrite(afg, ':source1:burst:state on');
     %fwrite(afg, ':source1:burst:trigered');
     fwrite(afg, ':source1:burst:ncycles 1');
     fwrite(afg, 'trigger:sequence:source external');
     
     fwrite(afg, ['source1:burst:tdelay ',num2str(delayTrig),'ms']);
     
     %Turn on the input
     %fwrite(afg, ':output1 on;'); 

end

