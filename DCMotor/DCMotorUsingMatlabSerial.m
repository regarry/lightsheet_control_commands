%% Establish communication for excitation lens
sExtLens = serial('COM19');
set(sExtLens,'BaudRate',921600);
set(sExtLens,'Terminator','CR/LF');
fopen(sExtLens);
% To see the different properties just wrie set(s)/get(s)
%set(s,'Parity') show all the options for Parity

%Start the controller 
fprintf(sExtLens,'1OR');

%% Establish communication for detection lens
sDetLens = serial('COM5');
set(sDetLens,'BaudRate',921600);
set(sDetLens,'Terminator','CR/LF');
fopen(sDetLens);
% To see the different properties just wrie set(s)/get(s)
%set(s,'Parity') show all the options for Parity

%Start the controller 
fprintf(sDetLens,'1OR');


%%
%Check current speed  
fprintf(sExtLens,'1VA?');
out = fscanf(sExtLens)

%Set the current speed to 0.1 mm/sec
fprintf(sExtLens,'1VA0.1');
%Wait 1 ms until we get the reponse 
pause(0.01);
fprintf(sExtLens,'1VA?');
out = fscanf(sExtLens)

%Move relative 0.01 mm backward
fprintf(sExtLens,'1PT0.2');
out = fscanf(sExtLens)

fprintf(sExtLens,'1PR0.01');
pause(1);
%Check for position
fprintf(sExtLens,'1TP?');
out = fscanf(sExtLens)


%Get accelration
fprintf(sExtLens,'1AC?');
out = fscanf(sExtLens)

%%

fclose(sExtLens)
delete(sExtLens)
clear sExtLens

fclose(sDetLens)
delete(sDetLens)
clear sDetLens

