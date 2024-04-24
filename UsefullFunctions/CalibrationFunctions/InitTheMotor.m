function [serialHandle] = InitTheMotor(portNumber)
    
    % Establish communication for excitation lens
    serialHandle = serial(portNumber);
    set(serialHandle,'BaudRate',921600);
    set(serialHandle,'Terminator','CR/LF');
    fopen(serialHandle);
    % To see the different properties just wrie set(s)/get(s)
    %set(s,'Parity') show all the options for Parity

    %Start the controller 
    fprintf(serialHandle,'1OR');  
    %Reduce the speed
    fprintf(serialHandle,'1VA0.2');
    
    
    
end
