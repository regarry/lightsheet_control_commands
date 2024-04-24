%This function disconnect com with the afg

function [] = DisconComAfg(afg)

    % gracefully disconnect
    fclose(afg);
    delete(afg);
    
end

