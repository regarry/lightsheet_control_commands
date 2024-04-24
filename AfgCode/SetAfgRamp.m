%This function sets the ramp parameter for the galvo
%vLow [mV]
%vHigh [mV]
%frequency [Hz]
%symmetry [%]
%The function does not turn on the channel automatically and let the user
%review the parameters first
function [] = SetAfgRamp(afg, vLow, vHigh, frequency, symmetry,path)
    if path == 1
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
         %display(['High voltage was set to ',val,'V']);

         %Change the voltage low level
         fwrite(afg, [':source1:voltage:low ',num2str(vLow),' mv']);
         val = query(afg, ':source1:voltage:low?');
         %display(['Low voltage was set to ',val,' V']);

         %Change the frequency
         fwrite(afg, [':source1:frequency:fixed ',num2str(frequency),' hz']);
         val = query(afg, ':source1:frequency?');
         %display(['Frequecny was set to ',val,'Hz']); 

         %Change the symmetry
         fwrite(afg, [':source1:function:ramp:symmetry ',num2str(symmetry)]);
         val = query(afg, ':source1:function:ramp:symmetry?');
         %display(['Symmetry was set to ',val,' %']); 
         
         %Change the phase to zero degrees
         fwrite(afg, [':source1:phase:adjust 0deg']);
         
         % change the offset
         %fwrite(afg,[':source2:voltage:offset ',num2str(app.state_afg.Offset_mv_(index+3)),'mv'])
         %Turn on the input
         %fwrite(afg, ':output1 on;'); 
    else
        %Turn off the input
        fwrite(afg, ':output2 off;'); 

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
         val = query(afg, ':source1:voltage:high?');
         display(['High voltage was set to ',val,'V']);

         %Change the voltage low level
         fwrite(afg, [':source2:voltage:low ',num2str(vLow),' mv']);
         val = query(afg, ':source2:voltage:low?');
         display(['Low voltage was set to ',val,' V']);

         %Change the frequency
         fwrite(afg, [':source2:frequency:fixed ',num2str(frequency),' hz']);
         val = query(afg, ':source2:frequency?');
         display(['Frequecny was set to ',val,'Hz']); 

         %Change the symmetry
         fwrite(afg, [':source2:function:ramp:symmetry ',num2str(symmetry)]);
         val = query(afg, ':source2:function:ramp:symmetry?');
         display(['Symmetry was set to ',val,' %']); 

         %Change the phase to zero degrees
         fwrite(afg, [':source2:phase:adjust 0deg']);

         %Turn on the input
         %fwrite(afg, ':output1 on;'); 
    end
end

