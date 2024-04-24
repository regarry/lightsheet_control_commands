%This function establish com with the AFG3022B using Visa
%The output is the afg device object for visa com
%Default buffer size 5120, should be X*1024

function [afg] = EstablishComAfg(sizeOfBuffer)
    if (nargin == 0)
        sizeOfBuffer = 1024;
    end
    
    afg = visa('ni', 'USB0::0x0699::0x0356::C010263::INSTR', 'InputBufferSize',sizeOfBuffer,'OutputBufferSize',sizeOfBuffer);
    fopen(afg);


end

