function [] = ControlDCMotorUsingKeyboard(portExt, portDet )
    
    %Initialize the motors
    %[sExtLens] = initiliazeMotors(portExt); 
    %[sDetLens] = initiliazeMotors(portDet); 
    
    image = randn(2048,2048);
    
    f = figure;
    %f.WindowStyle = 'modal';
    hAxes = subplot(1,1,1);
    hImage = imshow(image,'Parent',hAxes, 'DisplayRange', []); 
    
    
    while (true)
        
        image = randn(2048,2048);
        set(hImage,'CData',image);
        pause(0.05);
        
        k = get(f,'CurrentCharacter');
        switch lower(k)
        case 'p'
            display('hello');
            shg;
        case 'e'
            display('Stopped');
            break;
        end
        
                
    end
    
    
    %Release the serial handles
%     fclose(sExtLens);
%     delete(sExtLens);
%     clear sExtLens;
% 
%     fclose(sDetLens);
%     delete(sDetLens);
%     clear sDetLens;
    
    close(f);

end

function [serialHandle] = initiliazeMotors(portNumber)
    
    % Establish communication for excitation lens
    serialHandle = serial(portNumber);
    set(serialHandle,'BaudRate',921600);
    set(serialHandle,'Terminator','CR/LF');
    fopen(serialHandle);
    % To see the different properties just wrie set(s)/get(s)
    %set(s,'Parity') show all the options for Parity

    %Start the controller 
    fprintf(serialHandle,'1OR');    
    
end



