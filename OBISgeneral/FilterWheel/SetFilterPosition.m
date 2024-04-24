%pos is integer
function SetFilterPosition(sFilterWheel, pos)
    
    fprintf(sFilterWheel, ['pos=',num2str(pos)]);
    %To make sure that the messages buffer is clear 
    currFilterPos = fscanf(sFilterWheel);
    
end

