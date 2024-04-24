## Lightsheet_control_commands
Basic hardware command line for light sheet system control 

* [1. System initialzation](#1)
 * [1.1 Laser](#1.1)
 * [1.2 Filter wheel](#1.2)
 * [1.3 Measure computing](#1.3])

<h2 id='1'>1. System initalization</h2>

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

```

```Matlab
disp('hello')
```
