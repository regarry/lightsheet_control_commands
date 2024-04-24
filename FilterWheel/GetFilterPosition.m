function [position] = GetFilterPosition(sFilterWheel)
    
    fprintf(sFilterWheel, 'pos?');
    %Need to read twice to get the position
    position = fscanf(sFilterWheel);
    position = fscanf(sFilterWheel);

end

