%%
FWport = 'COM11';
[sFilterWheel] = InitFW(FWport);

%%
fprintf(sFilterWheel, 'pos?');
out = fscanf(sFilterWheel)
out = fscanf(sFilterWheel)
fprintf(sFilterWheel, 'pos=5');
out = fscanf(sFilterWheel)
%out = fscanf(serialHandle)

%%
fclose(sFilterWheel);
clear sFilterWheel;