% this function will roll the light sheet
%vLow [mV]
%vHigh [mV]
%frequency [Hz]
%symmetry [%]

function [] = SetAfgRamp_roll(afg, vLow, vHigh, frequency, symmetry,path)
    %Turn off the input
    %fwrite(afg, ':output2 off;');
    %move to ramp
    fwrite(afg, ':source2:function RAMP');
        
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
    fwrite(afg, [':source2:voltage:high ',num2str(vHigh),' mv']);
    val = query(afg, ':source2:voltage:high?');
    
    %Change the voltage low level
    fwrite(afg, [':source2:voltage:low ',num2str(vLow),' mv']);
    val = query(afg, ':source2:voltage:low?');
       
    
    %Change the frequency
    fwrite(afg, [':source2:frequency:fixed ',num2str(frequency),' hz']);
    val = query(afg, ':source2:frequency?');
    
    %fwrite(app.controlParameters.afg, [':source2:voltage:offset ',num2str(app.state_afg.Offset_mv_(index)),'mv']);
    %Change the symmetry
    fwrite(afg, [':source2:function:ramp:symmetry ',num2str(symmetry)]);
    val = query(afg, ':source2:function:ramp:symmetry?');
    
    % set the offset
    %fwrite(afg, [':source2:voltage:offset ',num2str(0),'mv']);
    
    %Change the phase to zero degrees
    fwrite(afg, [':source2:phase:adjust 0deg']);
    
    %fwrite(afg, ':output2 on;');
    
end