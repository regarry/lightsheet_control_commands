## Lightsheet_control_commands references
Basic hardware command line for light sheet system control   
Useful link https://micro-manager.org/Micro-Manager_Programming_Guide

* [1. System initialzation](#1)
 * [1.1 Laser](#1.1)
 * [1.2 Filter wheel](#1.2)
 * [1.3 Measure computing](#1.3])

<h2 id='1'>1. System initalization</h2>  
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

% laser setup
if (avilableLasers(1))
    [s488nm] = InitObis(portObis488nm);    
end
%561 nm 
if (avilableLasers(2))
    [s561nm] = InitObis(portObis561nm);    
end
%640 nm
if (avilableLasers(3))
    [s640nm] = InitObis(portObis640nm);    
end
```

<h2 id='1.1'>1.1 laser</h2>

```Matlab

```

