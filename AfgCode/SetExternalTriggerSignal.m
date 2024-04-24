%This function creates an external trigger signal in the AFG
%The voltage will be low 0V and high 2.5 V in channel 2. 
%The duty cycle is 1%, the frequency should match the Galvo signal in order
%to sync them
%Input:
%frequency [Hz]
%afg - the device object
%delay the required delay for the external trigger in ms

function [] = SetExternalTriggerSignal(afg, frequency, delay)
    
    %Turn off the input
    fwrite(afg, ':output2 off;'); 
    
    %move to ramp
    fwrite(afg, ':source2:function pulse');
    
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
     fwrite(afg, [':source2:voltage:high 2.5v']);
     val = query(afg, ':source2:voltage:high?');
     display(['High voltage was set to ',val,'V']);
     
     %Change the voltage low level
     fwrite(afg, [':source2:voltage:low 0v']);
     val = query(afg, ':source2:voltage:low?');
     display(['Low voltage was set to ',val,' V']);
     
     %Change the frequency
     fwrite(afg, [':source2:frequency:fixed ',num2str(frequency),' hz']);
     val = query(afg, ':source2:frequency?');
     display(['Frequecny was set to ',val,'Hz']); 
     
     %Change the Duty cycle to only 1 %
     fwrite(afg, [':source2:pulse:dcycle 1']);
     val = query(afg, ':source2:pulse:dcycle?');
     display(['Duty cycle was set to ',val,'%']); 
     
     %Set the best delay
     fwrite(afg, [':source2:pulse:delay ',num2str(delay),'ms']);
     val = query(afg, ':source2:pulse:delay?');
     display(['Delay is currently to ',val,'sec']);     
         
end

