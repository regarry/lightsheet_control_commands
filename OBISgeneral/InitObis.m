function [ serialHandle ] = InitObis( portNumber )
    
    % Establish communication for excitation lens
    serialHandle = serial(portNumber);
    set(serialHandle,'BaudRate',115200);
    set(serialHandle, 'Terminator','CR/LF');
    fopen(serialHandle);
    %Start the controller 
    fprintf(serialHandle,'SOUR:AM:STAT ON');  
    temp = fscanf(serialHandle);
%     fprintf(serialHandle, 'SOUR:AM:STAT?');
%     %Need to read twice to get the position
%     position = fscanf(serialHandle);
%     fprintf(serialHandle, '*IDN?');
%     position = fscanf(serialHandle);        
end

