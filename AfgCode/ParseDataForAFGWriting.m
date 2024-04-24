%This function parses the vector in order to write it in AFG format
%Parses the signal according to the AFG convention 
%Input:
%vector - a funtction that needs to be written to the AFG, between 0 to 16382
%Outpus:
%binblock - the parsed data
%header - the needed header in order to transfer the data
%bytes - the size of the vector 

function [binblock, header, bytes] = ParseDataForAFGWriting(vector)
    
    binblock = zeros(2 * length(vector), 1);
    binblock(2:2:end) = bitand(vector, 255);
    binblock(1:2:end) = bitshift(vector, -8);
    binblock = binblock';

    % build binary block header
    bytes = num2str(length(binblock));
    header = ['#' num2str(length(bytes)) bytes];
    bytes = str2num(bytes);

end

