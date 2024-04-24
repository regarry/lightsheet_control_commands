%The function issue a command that ask for all motor parameters
%inputs:
%s the port handle
function [] = GetMotorParameters(s)
 fprintf(s,'1ZT');
 numOfParameters = 27;
 
 for ii = 1:numOfParameters
    out = fscanf(s)
 end
    


end

