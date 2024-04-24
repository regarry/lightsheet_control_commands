function pos = posfind(serialHandle)
    fprintf(serialHandle,'1TP?');
            pos = fscanf(serialHandle);
            k = strfind(pos,'TP');
            k = k(1);
            pos = pos(k+2:end);
            k = strfind(pos,'e');        
            if (~isempty(k))
                k = k(1);
                scale = pos(k+1:k+3);
                pos = pos(1:k-1);
                switch scale
                    case '-06'
                    pos = num2str(0);
                    case '-05'
                    pos = num2str(0);                
                end                  
end
