## Lightsheet_control_commands references
Basic hardware command line for light sheet system control   
Useful link:  
-https://micro-manager.org/Micro-Manager_Programming_Guide  
-https://javadoc.scijava.org/Micro-Manager-Core/mmcorej/CMMCore.html
* [**System initialzation**](#1)
 * [1.1 Laser](#1.1)
 * [1.2 Filter wheel](#1.2)
 * [1.3 Measure computing](#1.3)
 * [1.4 Motor stage control](#1.4)
* [**Camera**](#2)
* [**Arbitrary Founction generator**](#3)
* [**Sample 3D stage**](#4)
* [**Use python packages and scipts**](#5)

  
<h1 id='1'>System initalization</h1>  
The purpose of the initalization is to make sure all devices are connected and able to work.

```Matlab
% adding supporting scripts for hardware
addpath(path1, path2, path3, ....);
% initalize three laser
avilableLasers = [1 1 1];

% Parameters for MicroManager
% more devices' name, parameters_variables can be found in software "Micro-Manager-1.4" under tools/device property browser
pathToCfgFile = 'C:\Program Files\Micro-Manager-1.4\configuration_05302019.cfg';
[mmc] = InitiateHardware(pathToCfgFile); 
cameraLabel = 'HamamatsuHam_DCAM';
stageLabel = 'XYStage';

% Assign Serial Ports the num can be found in the device mangager/ports
% sometimes error happens, need to restart matlab and replug usb port
portExt1 = 'COM7'; % Excitation stage （not used in currently setup, but can be added in need）
portDet = 'COM15'; % Detection stage

portFWDet = 'COM11'; % Filter wheel detection)
portObis488nm = 'COM4'; % 488nm Laser
portObis561nm = 'COM5'; % 561nm Laser
portObis640nm = 'COM6'; % 640nm Laser

% Initiate the filter wheel and exitation and detection stage
[sFWDet] = InitFW(portFWDet);
[sDetLens] = InitTheMotor(portDet); 
[sExtLens1] = InitTheMotor(portExt1);

% arbitrary function generator which scan the beam up and down fast to form light-sheet and also rotate light-sheet
[afg] = EstablishComAfg();
% Establish connection to the MCC DAQ to output signal to galvo mirrors (make sure channels are correct)
% open measurement computing/instacal to make sure configuration
s1 = daq.createSession('mcc');
shutter1 = addAnalogOutputChannel(s1,'Board0', 'Ao1', 'Voltage');
galvoX1 = addAnalogOutputChannel(s1,'Board0', 'Ao2', 'Voltage');
galvoY1= addAnalogOutputChannel(s1,'Board0', 'Ao3', 'Voltage');
galvoZ1= addAnalogOutputChannel(s1,'Board0', 'Ao0', 'Voltage');

% all control parameters
controlParameters = struct('MMC', mmc, 'cameraLabel', cameraLabel, 'stageLabel', stageLabel, ...
    'sFWDet', sFWDet,'sFWExt',sFWExt, 'sExtLens1', sExtLens1,'sDetLens',...
    sDetLens,'afg', afg,'shutter1',shutter1, 'galvoX1',galvoX1,'galvoY1',galvoY1,'s1',s1);

% laser setup
if (avilableLasers(1))
    [s488nm] = InitObis(portObis488nm);    
end
% 561 nm 
if (avilableLasers(2))
    [s561nm] = InitObis(portObis561nm);    
end
% 640 nm
if (avilableLasers(3))
    [s640nm] = InitObis(portObis640nm);    
end
```

<h2 id='1.1'>1.1 Laser</h2>

```Matlab
% standalone software: Coherent Connection 4 
% detailed function can be found in OBISgeneral
% on and off
SwitchOnOffObis(app.allLasers(1).serialPort,0);
SwitchOnOffObis(app.allLasers(1).serialPort,1);
% power setting
ChangePowerObis(app.allLasers(ii).serialPort,value,MaxPower);
```
<h2 id='1.2'>1.2 Filter wheel</h2>

```Matlab
fprintf(sFWDet, 'pos=1'); % no filter
fprintf(sFWDet, 'pos=2'); % blue
fprintf(sfWDet, 'pos=3'); % green
fprintf(sfWDet, 'pos=4'); % red
```
<h2 id='1.3'>1.3 Measurement computing</h2>

```Matlab
% give a certain voltage to one of the channels (predefined)
% which is used to change angle of galvo x and y
outputSingleScan(s1,[value0, value1, value2, value3]);
```
<h2 id='1.4'>1.4 Motor stage control</h2>  
More command please check CONEX-CC Command Interface User Manual （https://www.newport.com/p/CONEX-TRA12CC）

```Matlab
% read positon of stage motor
fprintf(app.controlParameters.sDetLens,'1TP?');
pos = fscanf(app.controlParameters.sDetLens);
pos = getpos(pos);
% move stage
fprintf(sDetLens,['1PR',num2str(stepsize)]);
fprintf(sDetLens,['1PR-',num2str(stepsize)]); % R means relative, '-' means another direction
fprintf(sExtLens1,['1PA','4.70']); % A means absolute
```
<h1 id='2'> Camera</h1>  

```Matlab

```

<h1 id='3'>Arbitrary Founction generator</h1>  

Reference https://mmrc.caltech.edu/Tektronics/AFG3021B/AFG3021B%20Programmer%20Manual.pdf

```Matlab

```

<h1 id='4'>Sample 3D stage</h1>  
Reference https://javadoc.scijava.org/Micro-Manager-Core/mmcorej/CMMCore.html  

```Matlab
# the property name can be found in micro manager/device browser
# the sample xyz is not the same as the stage xyz according to the actual placement we make in the system
# on z axis
# check current position 
app.controlParameters.MMC.getYPosition();
# move sample stage by relative distance
app.controlParameters.MMC.setRelativeXYPosition('XYStage:XY:31',0,value);
app.controlParameters.MMC.waitForDevice('XYStage:XY:31');

# up and down
# read posiiton
current_x = app.controlParameters.MMC.getXPosition();
# move sample by relative distance
app.controlParameters.MMC.setRelativeXYPosition('XYStage:XY:31',value,0);
app.controlParameters.MMC.waitForDevice('XYStage:XY:31');

# left and right
# read position
current_z = app.controlParameters.MMC.getPosition('ZStage:Z:32');
# move sample by relative distance
app.controlParameters.MMC.setRelativePosition('ZStage:Z:32',app.Stage_step_Z);
app.controlParameters.MMC.waitForDevice('ZStage:Z:32');

# rotation
# current not used
app.controlParameters.MMC.setRelativePosition('ZStage:T:32',-app.Stage_step_T);
app.controlParameters.MMC.waitForDevice('ZStage:T:32');
app.controlParameters.MMC.getPosition('ZStage:T:32');

```


<h1 id='5'>Use python packages and scipts</h1>  

Start Matlab by typing `matlab` in Anaconda prompt (under the activated environment), so the required packages can be automaticially loaded.  

Relevent file contains using python script in Malab can be found under  

MMcodeOrcaV2/app_for_lightsheet_V2_deeplearning.mlapp `deep learning autofocus` button  
MMcodeOrcaV2/img_stack_pred.m  
MMcodeOrcaV2/pred_img_6nm.py  



