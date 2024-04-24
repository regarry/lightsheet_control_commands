%This function set the power to all the lasers either for OBIS controlled
%or power supply controlled or for FW support

function SetPowerOfLasersV3(allLasers, sFWExt, sFWDet, wavelength, powerInMW, focusingFilter)
    
    %Go over turn on just the right laser while turning of the others
    for ii = 1:numel(allLasers)
        %Turn on only the required laser
        if (wavelength == allLasers(ii).wavelength)
            %Turn on the laser
            switch allLasers(ii).ControlType
                case 'PS'
                    SetLaserPowerGeneralPS(allLasers(ii).serialPort, powerInMW, allLasers(ii).wavelength);
                case 'FW'
                    SetPowerUsingFW(allLasers(ii).serialPort, powerInMW, allLasers(ii).maxPower);
                case 'OBIS'
                    ChangePowerObis(allLasers(ii).serialPort, powerInMW, allLasers(ii).maxPower);
                    SwitchOnOffObis(allLasers(ii).serialPort,1);                    
            end
            %move to the right filter position for excitation and emission 
%             SetFilterPosition(sFWExt, allLasers(ii).filterExcitation);
            if (focusingFilter)
                SetFilterPosition(sFWDet, allLasers(ii).filterAF);
            else
                SetFilterPosition(sFWDet, allLasers(ii).filterEmission);
            end
            
        else
            
            %Turn off the other lasers that you can
             switch allLasers(ii).ControlType
                case 'PS'
                    SetLaserPowerGeneralPS(allLasers(ii).serialPort, 0, allLasers(ii).wavelength);
                case 'FW' 
                    display('o');
                    %Change the power filter position to 1
                    SetFilterPosition(allLasers(ii).serialPort, 1);    
                    [positionOfTheFilterWheel] = GetFilterPosition(allLasers(ii).serialPort);
                case 'OBIS'
                    SwitchOnOffObis(allLasers(ii).serialPort,0);                    
            end
            
            
        end
    end
    
    
end



