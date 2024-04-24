function [sFilterWheel] = InitFW(comPort)
    sFilterWheel = serial(comPort);
    set(sFilterWheel, 'BaudRate',115200);
    set(sFilterWheel, 'Terminator','CR');
    fopen(sFilterWheel);
    
    %Move the filter to no filter position
    fprintf(sFilterWheel, 'pos=1');
    position = fscanf(sFilterWheel);
end

