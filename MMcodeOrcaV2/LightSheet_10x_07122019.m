% Greenbaum Lab
% greenbaum@ncsu.edu, rspate@ncsu.edu
% LightSheet_10x_07122019.m
% July 12, 2019
%
% Script for operation of light sheet microscope
%

addpath('D:\lightSheetsourcecode_twopath\AfgCode','D:\lightSheetsourcecode_twopath\DCMotor',...
    'D:\lightSheetsourcecode_twopath\FilterWheel','D:\lightSheetsourcecode_twopath\OBISGeneral',...
    'D:\lightSheetsourcecode_twopath\UsefullFunctions\CalibrationFunctions','D:\lightSheetsourcecode_twopath\UsefullFunctions\PickTiles',...
    'D:\lightSheetsourcecode_twopath\MMcodeOrcaV2\selfmade',...
    'D:\lightSheetsourcecode_twopath\MMcodeOrcaV2\wholezstackfiles');

%% SETUP (initialize stages, galvos, camera, and shutter)
%run app_test
% Which lasers to use
% [488,561,640]; 
avilableLasers = [1 1 1];
lightSheetMode = false;

pixelSizeUm = 6.5;
tubeLensFocalDistance = 180; %mm
objectiveDesignedTubeLensFocal = 180; %mm
objectiveMag = 10;

% Parameters for MicroManager
pathToCfgFile = 'C:\Program Files\Micro-Manager-1.4\configuration_05302019.cfg';
[mmc] = InitiateHardware(pathToCfgFile); 
cameraLabel = 'HamamatsuHam_DCAM';
stageLabel = 'XYStage';

% Assign Serial Ports
portExt1 = 'COM7'; % Excitation stage
%portExt2 = 'COM10';
portDet = 'COM15'; % Detection stage
portFWDet = 'COM11'; % Filter wheel (detection)
portObis488nm = 'COM4'; % 488nm Laser
portObis561nm = 'COM5'; % 561nm Laser
portObis640nm = 'COM6'; % 640nm Laser
%portExt2 = 'COM19';

% Initiate the filter wheel
[sFWDet] = InitFW(portFWDet);
% 2 is for 525-39 mm
% 3 is for 593/40-25 mm
% 4 is for 676/37-25 
sFWExt = 0;
% Init stages
% Path 1 excitation
[sExtLens1] = InitTheMotor(portExt1); 
%[sExtLens2] = InitTheMotor(portExt2);
% Path 2 excitation
% [sExtLens2] = InitTheMotor(portExt2); 
% Detection objective
[sDetLens] = InitTheMotor(portDet); 
% Arbitrary function generator
[afg] = EstablishComAfg();

% Establish connection to the MCC DAQ (make sure channels are correct)
s1 = daq.createSession('mcc');
shutter1 = addAnalogOutputChannel(s1,'Board0', 'Ao1', 'Voltage');
galvoX1 = addAnalogOutputChannel(s1,'Board0', 'Ao2', 'Voltage');
galvoY1= addAnalogOutputChannel(s1,'Board0', 'Ao3', 'Voltage');
galvoZ1= addAnalogOutputChannel(s1,'Board0', 'Ao0', 'Voltage');

%In multi color light sheet mode is not implemented
expWindowHeight = 30; %pixels, it should be calculated as the size of the FWHM of the light sheet

controlParameters = struct('MMC', mmc, 'cameraLabel', cameraLabel, 'stageLabel', stageLabel, ...
    'sFWDet', sFWDet,'sFWExt',sFWExt, 'sExtLens1', sExtLens1,'sDetLens',...
    sDetLens,'afg', afg,'shutter1',shutter1, 'galvoX1',galvoX1,'galvoY1',galvoY1,'s1',s1);

% Put the AFG voltage at zero
[dcValueAfterWrite] = SetAfgDCValue(afg, 0);
fwrite(afg, ':output1 off;');
fwrite(afg, ':output2 off;');

% Set the Thorlabs galvos to 0 (mcc)
outputSingleScan(s1, [0,0,0,0]);

%Set the light path to excitation 1
path1Excitation = 1;
path2Excitation = 2;
% shutters.open(path1Excitation);
% shutters.close(path2Excitation);
curPath = 1;

downSampleFactor = 1;
mmc.setTimeoutMs(50000);
mmc.getTimeoutMs()

%% LASER SETUP (initiate the lasers based on availability)
%488 nm 
fprintf(sExtLens1,['1PA','4.70']);

disp('lasers set up.')
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

%Define lasers parameters
%Control type:
%PS - power supply
%OBIS - OBIS software
%FW - filter wheel

%The two rows format is for the second light path
laserParameters = struct('wavelength', 405, 'maxPower', 50, 'available', false, 'filterEmission', 1,...
    'filterAF', 1,'filterExcitation', 1,'posExtLens', [0; 0], 'posDetLens', [0; 0], 'symmetry',...
    [97; 97], 'Delay', [0 0 0 0 0 0; 0 0 0 0 0 0], 'OptimalDelay', [0; 0], 'FrameRates', [50 25 15 10 7 5], 'serialPort',0,'ControlType','PS',...
    'minVoltage',-600, 'maxVoltage',600, 'chromaticAberrationDetLens', 0.01, 'newFreq', 0);

numOfActiveLasers = sum(avilableLasers);
allLasers = laserParameters;
indAllLasers = 0;

%488 laser
if (avilableLasers(1))
    laser488nm = laserParameters;
    laser488nm.wavelength = 488;
    laser488nm.maxPower = 20; %mW
    laser488nm.available = true;
    laser488nm.filterEmission = 1;
    laser488nm.filterAF = 1;
    laser488nm.filterExcitation = 2;
    laser488nm.posExtLens = [-0.05,4.10992];
    laser488nm.posDetLens = [-.0249,-0.0549];
    laser488nm.symmetry = [80; 90.1]; 
    laser488nm.Delay = [11.86 25.4 39.52 75.1 84.6 118.01; 11.86 25.5 39.52 75.2 77.3 118.01];
    laser488nm.OptimalDelay = [25.4; 25.5];
    laser488nm.FrameRates = [50 25 15 10 7 5];
    laser488nm.serialPort = s488nm;
    laser488nm.ControlType = 'OBIS';
    laser488nm.minVoltage = [-529; -394];
    laser488nm.maxVoltage = [527;350];
    laser488nm.chromaticAberrationDetLens = 0.01;
    indAllLasers = indAllLasers + 1;
    allLasers(indAllLasers) = laser488nm;    
end


%561 laser 
if (avilableLasers(2))
    laser561nm = laserParameters;
    laser561nm.wavelength = 561;
    laser561nm.maxPower = 20;
    laser561nm.available = true;
    laser561nm.filterEmission = 3;
    laser561nm.filterAF = 1;
    laser561nm.filterExcitation = 3;
    laser561nm.posExtLens = [0.04997; -1.62];
    laser561nm.posDetLens = [0.00; 0.00];
    laser561nm.symmetry = [94.9; 97.5]; %[92.4 92.4 91.4 91.3 91.5 91.4]
    laser561nm.Delay = [12.16 25.4 40.62 60.9 87.1 121.8; 12.16 25.6 40.62 60.9 87.1 121.8]; %ms
    laser561nm.OptimalDelay = [25.4; 25.6]; %ms
    laser561nm.FrameRates = [50 25 15 10 7 5];
    laser561nm.serialPort = s561nm;
    laser561nm.ControlType = 'OBIS';
    laser561nm.minVoltage = [-650; -650];
    laser561nm.maxVoltage = [650; 650];
    laser561nm.chromaticAberrationDetLens = 0.01;
    indAllLasers = indAllLasers + 1;
    allLasers(indAllLasers) = laser561nm;    
end

%640 laser 
if (avilableLasers(3))
    laser640nm = laserParameters;
    laser640nm.wavelength = 640;
    laser640nm.maxPower = 20;
    laser640nm.available = true;
    laser640nm.filterEmission = 4;
    laser640nm.filterAF = 1;
    laser640nm.filterExcitation = 4;
    laser640nm.posExtLens = [-0.07, 4.23992];
    laser640nm.posDetLens = [-0.0049, -0.0249];
    laser640nm.symmetry = [80.1; 90.1]; %[92.4 92.4 91.4 91.3 91.5 91.4]
    laser640nm.Delay = [12.16 25.5 75 75.3 87.1 121.8; 12.16 25.4 75 75.2 87.1 121.8]; %ms
    laser640nm.OptimalDelay = [25.5; 25.4]; %ms
    laser640nm.FrameRates = [50 25 15 10 7 5];
    laser640nm.serialPort = s640nm;
    laser640nm.ControlType = 'OBIS';
    laser640nm.minVoltage = [-549;-414];
    laser640nm.maxVoltage = [513;319];
    laser640nm.chromaticAberrationDetLens = 0.01;
    indAllLasers = indAllLasers + 1;
    allLasers(indAllLasers) = laser640nm;    
end

SwitchOnOffObis(allLasers(1).serialPort,0); 
SwitchOnOffObis(allLasers(2).serialPort,0); 
SwitchOnOffObis(allLasers(3).serialPort,0);
ChangePowerObis(allLasers(1).serialPort,1,5);
ChangePowerObis(allLasers(2).serialPort,1,5);
ChangePowerObis(allLasers(3).serialPort,1,5);

%%  load previus dm dont run this

addpath( [pwd '/Wrapper/'] );

mirrorSN = 'BAX362';
mode=15
dm = asdkDM( mirrorSN );
load('final_zernike_avg.mat')
mirrorSN = 'BAX362';
Z2C = importdata( [mirrorSN '-Z2C.mat'] );
nZern = size(Z2C, 1);
zernikeVector = zeros( 1, nZern );
zernikeVector(1:mode)=nwbias3;
%zernikeVector(1:mode)=mn1;
% zernikeVector(3)=zernikeVector(3)+0.25;
%  zernikeVector(4)=zernikeVector(4)+0.1;
%  zernikeVector(5)=zernikeVector(5)+0.1;
%  zernikeVector(6)=zernikeVector(6)-0.1;
% zernikeVector(7)=zernikeVector(7)-0.1;
%  zernikeVector(10)=zernikeVector(10)+0.05;
dm.Send( zernikeVector * Z2C );

%% GUI AND LIGHT SHEET LOCATION
%Run the GUi for camera and motors find the different location of the light-sheet
%The galvo poisition should be zero
%DC value +934mv -940mv
fwrite(afg, ':output1 off;'); 
fwrite(afg, ':output2 off;'); 

%Set the power
wavelength = 561;
intensityInMW = 4;
focusingFilter = true;


%Parameters for the display
frameRate = 6;
expTime = 100; %ms
addLine = false;
pause(1);

% [markedParameters, wavelength, intensityInMW, expTime, lastPosDetStage,...
%     lastPosExtStage, indWavelength, invalidTile, focusParameters, curPath] = ControlDCMotorUsingKeyboardV12(...
%     curPath, controlParameters, allLasers, frameRate, expTime,...
%     wavelength, intensityInMW, focusingFilter, false, addLine);

[markedParameters, wavelength, intensityInMW, expTime, lastPosDetStage,...
    lastPosExtStage, indWavelength, invalidTile, focusParameters, curPath,galvoVoltage] = ControlDCMotorUsingKeyboardV12(...
    curPath, controlParameters, allLasers, frameRate, expTime,...
    wavelength, intensityInMW, focusingFilter, false, addLine);
% selfmade_gui(curPath, controlParameters, allLasers, frameRate, expTime, wavelength, intensityInMW, focusingFilter, false, addLine)

% Go over the marked parameters
intensityVal = cat(2,markedParameters(1).intensity', markedParameters(2:end).intensity);
ind = (intensityVal == 0);
if (sum(ind) > 0)
    for jj = 1:10
            display('Missing parameters');
    end
end

save markedParameters markedParameters;

%% Store the new offsets between colors 
%For all lasers
for ii = 1:numel(allLasers)
    %For all light paths
    for jj = 1:1
        allLasers(ii).posExtLens(jj) = (markedParameters(ii).posExtStage(jj)); 
        allLasers(ii).posDetLens(jj) = (markedParameters(ii).posDetStage(jj));
    end  
end

%Lock the stages in the new relative cood
%Make sure that the stages are in the right position for whatever reason
 MoveStagesToDesiredLocationTwoExtStages(controlParameters,...
        allLasers(indWavelength).posExtLens(path1Excitation),...
        allLasers(indWavelength).posExtLens(path2Excitation),...
        allLasers(indWavelength).posDetLens(curPath));   

%press q to quit the gui

% find FWHM
% smoothFactor = 1;
% c = improfile; 
% d = smooth(c,smoothFactor);
% %pixel size = 6.5, mag = 25, focal distance should be 180 but it is 400
% figure; plot((1:size(d,1))*(pixelSizeUm/objectiveMag)*(objectiveDesignedTubeLensFocal/tubeLensFocalDistance)*downSampleFactor,d);

%% find the best DC voltages for the bottom line,
% ---------------------------------------------------------------
% Better to use 556 nm laser, LS calibration was done on this color
% ---------------------------------------------------------------

onlyOneWavelengthForCalib = true;
if (onlyOneWavelengthForCalib)
    startIndex = round(numOfActiveLasers/2);
    endIndex = round(numOfActiveLasers/2);
else
    startIndex = 1;
    endIndex = numOfActiveLasers;
end
% For each path and each laser
for curPath = 1:1
    % open and close the right light path
    %-------------------
    % Warning, you can switch path so easly on in this calibration as the
    % positions of the stages are set by the markedParameters i.e.
    % MoveStagesToDesiredLocation function
    %-------------------
%     if (curPath == 1)
%         shutters.open(path1Excitation);
%         shutters.close(path2Excitation);
%     else
%         shutters.open(path2Excitation);
%         shutters.close(path1Excitation);
%     end
    for ii = startIndex:endIndex
        %Clean the buffer
        controlParameters.MMC.clearCircularBuffer;
        controlParameters.MMC.getRemainingImageCount;

        SetPowerOfLasersV3(allLasers, controlParameters.sFWExt, controlParameters.sFWDet, markedParameters(ii).wavelength,markedParameters(ii).intensity(curPath), focusingFilter);
        MoveStagesToDesiredLocation(controlParameters, markedParameters(ii).posExtStage(curPath), markedParameters(ii).posDetStage(curPath), curPath);
        pause(4);

        %Parameters for bottom line
        showImages = false;
        range = 7;
        if (curPath == 1)
            centerV = -940;
        else
            centerV = -940;
        end
        windowSize = round(5/downSampleFactor);
        whichLine = round(2048/downSampleFactor); 
        
        %Ask the users to give the value
        fwrite(afg, ':source1:function DC');
        fwrite(afg, [':source1:voltage:offset ',num2str(centerV),'mv']);
        fwrite(afg, ':output1 on;');
       
        display('Move the line to the bottom by changing the offset manually');
        
        ControlDCMotorUsingKeyboardV12(...
    curPath, controlParameters, allLasers, frameRate, expTime,...
    markedParameters(ii).wavelength, markedParameters(ii).intensity(curPath), focusingFilter, false, addLine);
        dcValueAfterWrite = query(afg, ':source1:voltage:offset?');       
        centerV = str2num(dcValueAfterWrite)*1000;
        
        [VoptimalLow] = CalibrateDCVoltages(afg, mmc, cameraLabel, expTime, centerV, range, windowSize, whichLine, showImages);

        %Parameters for top line
        if (curPath == 1)
            centerV = 940;
        else
            centerV = 940;
        end        
        whichLine = 1;  
        
        fwrite(afg, ':source1:function DC');
        fwrite(afg, [':source1:voltage:offset ',num2str(centerV),'mv']);
        fwrite(afg, ':output1 on;');
        display('Move the line to the top by changing the offset manually');
        
        %User choice
        ControlDCMotorUsingKeyboardV12(...
    curPath, controlParameters, allLasers, frameRate, expTime,...
    markedParameters(ii).wavelength, markedParameters(ii).intensity(curPath), focusingFilter, false, addLine);

        dcValueAfterWrite = query(afg, ':source1:voltage:offset?');
        centerV = str2num(dcValueAfterWrite)*1000;
        
        [VoptimalHigh] = CalibrateDCVoltages(afg, mmc, cameraLabel, expTime, centerV, range, windowSize, whichLine, showImages);
        
         allLasers(ii).minVoltage(curPath) = VoptimalLow;
         allLasers(ii).maxVoltage(curPath) = VoptimalHigh;
    end
    
end

%Put the only value in the rest of the cells if it is only one wavelength
if (onlyOneWavelengthForCalib)
    for ii = 1:numOfActiveLasers
        allLasers(ii).minVoltage(path1Excitation) = allLasers(startIndex).minVoltage(path1Excitation);
        allLasers(ii).minVoltage(path2Excitation) = allLasers(startIndex).minVoltage(path2Excitation);
        allLasers(ii).maxVoltage(path1Excitation) = allLasers(startIndex).maxVoltage(path1Excitation);
        allLasers(ii).maxVoltage(path2Excitation) = allLasers(startIndex).maxVoltage(path2Excitation);
    end
end

allLasers.minVoltage
allLasers.maxVoltage 
%% Lower the sample to the light-sheet set a ramp for dether mode

%Make sure that the stages are in the right position for whatever reason
MoveStagesToDesiredLocationTwoExtStages(controlParameters,...
        allLasers(endIndex).posExtLens(path1Excitation),...
        allLasers(endIndex).posExtLens(path2Excitation),...
        allLasers(endIndex).posDetLens(curPath)); 

    %Parameters
%Scan frequency = 1KHz
scanFreq = 500;
symmetry = 50;
marginVoltage = 75;
maxVoltageColorandPath = max(cat(1,allLasers.maxVoltage));

% Write the ramp to the AFG
SetAfgRamp(afg, min(cat(1,allLasers.minVoltage)) - marginVoltage, max(cat(1,allLasers.maxVoltage)) + marginVoltage, scanFreq, symmetry);
SetAfgRamp(afg, -1000, 1000, 500, 50);
fwrite(afg, ':output1 on;');
count = 1;
%% Live mode press q = 'exit' to abort live mode
%Set the power
%wavelength = 640;
controlParameters.MMC.clearCircularBuffer;
controlParameters.MMC.getRemainingImageCount;

intensityInMW = 4;
focusingFilter = false;

if (count == 1)
    %SetPowerOfLasersV3(allLasers, controlParameters.sFWExt, controlParameters.sFWDet, wavelength,markedParameters(ii).intensity, focusingFilter);  
    [markedParameters, wavelength, intensityInMW, expTime, lastPosDetStage, lastPosExtStage, indWavelength, invalidTile, focusParameters, curPath] = ControlDCMotorUsingKeyboardV12(...
        curPath, controlParameters, allLasers, frameRate, expTime,...
        allLasers(endIndex).wavelength, intensityInMW, focusingFilter, false, addLine);
    count = 2;
else
    %SetPowerOfLasersV3(allLasers, controlParameters.sFWExt, controlParameters.sFWDet, wavelength,markedParameters(ii).intensity, focusingFilter);  
    [markedParameters, wavelength, intensityInMW, expTime, lastPosDetStage, lastPosExtStage, indWavelength, invalidTile, focusParameters, curPath] = ControlDCMotorUsingKeyboardV12(...
        curPath, controlParameters, allLasers, frameRate, expTime,...
     wavelength, intensityInMW, focusingFilter, lightSheetMode, addLine);
end
%% light sheet mode set up, skip if not needed
lightSheetMode = false;
frameRate = 10; %choose from these values 50,25,15,10,7 and 5
%The VPP parameter 
%Path 1 needs more voltage
optVppForPaths = [1100 1200];

%Click 2 points on displayed image - first on bottom, second on top

if (lightSheetMode)
    
    % Move the camera to a light sheet mode
    internalFrameInterval = (1/frameRate); 
    internalLineInterval = internalFrameInterval/(expWindowHeight + 2058);
    exposurePerLine = expWindowHeight*internalLineInterval;
    SetLightSheetPropOrca(controlParameters.MMC, cameraLabel, internalLineInterval, exposurePerLine);
    GetLightSheetPropV3(controlParameters.MMC, cameraLabel);
    
    % Calculate the actual frame rate or the new frequency
    actualFrameRate = mmc.getProperty(cameraLabel,'INTERNAL LINE INTERVAL');    
    actualFrameRate = str2num(actualFrameRate);
    exposureLightSheet = mmc.getProperty(cameraLabel,'Exposure');
    exposureLightSheet = str2num(exposureLightSheet);
    actualFrameRate = 1000/(actualFrameRate*2058);
    newFreq = floor(actualFrameRate*43/48.915); % Try to slow down the galvo
    %newFreq = actualFrameRate*44.6875/48.915; %50 fps is only 48.915
    
    rangeMsRough = 2;
    stepSizeMsRough = rangeMsRough; %ms
    
    % Galvo speed    
    %showImage = true;
    %[galvoSpeed] = CalcGalvoSpeed(galvoChannelNumber, newFreq, showImage);
    
    % image
    focusingFilter = false;
    
    %Write the parameters to the structure before starting the calibration
    %So every time you change the parameters they will change accordingly    
    for calibrationPath = 1:2
        for ii = 1:numOfActiveLasers
           % write the parametetrs to the AFG, like the newFrequency and
           % the optimal delay for the frequency, give also margins for the
           % top and bottom voltages
            kk = find(allLasers(ii).FrameRates == frameRate);
            delay = allLasers(ii).Delay(calibrationPath, kk);
            allLasers(ii).OptimalDelay(calibrationPath) = delay;
            allLasers(ii).newFreq = newFreq;
            vPP = abs(allLasers(ii).maxVoltage(calibrationPath) - allLasers(ii).minVoltage(calibrationPath));            
            voltageMargin = optVppForPaths(calibrationPath) - vPP;
            vLowScan = allLasers(ii).minVoltage(calibrationPath) - ceil(voltageMargin/2);
            vHighScan = allLasers(ii).maxVoltage(calibrationPath) + floor(voltageMargin/2);
            
            %Keep these values when switching lasers
            allLasers(ii).maxVoltage(calibrationPath) = vHighScan;
            allLasers(ii).minVoltage(calibrationPath) = vLowScan;
           
        end
    end
    
    %Start the calibration
    for calibrationPath = 1:2
        
        % Change to the calibration path
        [curPath] = ChangeLightPath(controlParameters, allLasers, wavelength, curPath, calibrationPath, lightSheetMode); 
        
        for ii = numOfActiveLasers:-1:1
            
            %Clean the buffer
            controlParameters.MMC.clearCircularBuffer;
            
            %Change to the current wavelength
            [wavelength, indWavelength, curPath] = ChangeWavelengths(controlParameters, allLasers, wavelength, allLasers(ii).wavelength, intensityInMW, focusingFilter, curPath, lightSheetMode);
                                   
            [markedParameters, wavelength, intensityInMW, expTime, lastPosDetStage, lastPosExtStage, indWavelength, invalidTile, focusParameters, curPath] = ControlDCMotorUsingKeyboardV12(...
                curPath, controlParameters, allLasers, frameRate, expTime,...
                wavelength, intensityInMW, focusingFilter, lightSheetMode, addLine);
                          
            % pick 2 points for finding the delay
            [horizontalP, verticalP] = getpts();
            horizontalP = round(horizontalP);
            verticalP = round(verticalP);
            
             %Get the initial values from the user
            val = query(afg, ':source1:function:ramp:symmetry?');
            display(['Symmetry was set to ',val,' %']); 
            allLasers(ii).symmetry(calibrationPath) = str2num(val); 
            val = query(afg, ':source2:pulse:delay?');
            display(['Delay is currently to ',val,'sec']);
            currentDelayMs = str2num(val)*1000; %delay in ms
            allLasers(ii).OptimalDelay(calibrationPath) = currentDelayMs;
            
            % Sync the light sheet using the selected points, it will provide you with the delays
            close all;
            iterativeSearch = true;
            
            %Parameters
            windowSize = 50;
            methodOfQuality = 2; %1 is peak power, 2 is mean value
            showFigure = false;
            averageNumberOfImagesPerSpot = 1;
            optimalDelay = zeros(1,size(horizontalP,1));
            symmetry = allLasers(ii).symmetry(calibrationPath);
            tolerance = 0.5; %The differenc between the dif
            toleranceE = 0.4;
            
            while (abs(tolerance) > toleranceE)
                
                for jj = 1:size(horizontalP,1)
                    
                    %Rough estimate
                    whichPoint = jj;
                    [optimalDelay(jj)] = CalcDelayV4(mmc, afg, cameraLabel, verticalP(whichPoint), horizontalP(whichPoint), rangeMsRough, stepSizeMsRough, windowSize, methodOfQuality, averageNumberOfImagesPerSpot, showFigure);
                    
                    % Fine tune
                    [optimalDelay(jj)] = CalcDelayV4(mmc, afg, cameraLabel, verticalP(whichPoint), horizontalP(whichPoint), stepSizeMsRough/2, stepSizeMsRough/10, windowSize, methodOfQuality, averageNumberOfImagesPerSpot, showFigure);
                    
                end
                
                %Only if iterative search continue to change the symmetry
                if (~iterativeSearch)
                    tolerance = 0;
                else
                    %Change the speed according to the delay
                    tolerance = optimalDelay(1) - optimalDelay(2);
                    
                    if (abs(tolerance) > toleranceE)
                        if (tolerance > 0)
                            if (tolerance > 0.4)
                                symmetry = symmetry + 1;
                            else
                                symmetry = symmetry + 0.2;
                            end
                        else
                            if (tolerance < -0.4)
                                symmetry = symmetry - 1;
                            else
                                symmetry = symmetry - 0.2;
                            end
                        end
                    end
                    
                    %Check that the symmetry is in OK
                    if ((symmetry > 99) ||(symmetry < 70))
                        tolerance = 0;
                        display('Failed to find the right symmetry');
                    else
                        SetAfgRamp(afg, allLasers(ii).minVoltage(calibrationPath),  allLasers(ii).maxVoltage(calibrationPath), newFreq, symmetry);
                        fwrite(afg, ':output1 on;');
                        setDelay = mean(optimalDelay);
                        fwrite(afg, [':source2:pulse:delay ',num2str(setDelay),'ms']);
                    end
                end
                
            end
            
            %Change the delay to ahe average
            setDelay = mean(optimalDelay)
            fwrite(afg, [':source2:pulse:delay ',num2str(setDelay),'ms']);
            val = query(afg, ':source2:pulse:delay?');
            display(['Delay is currently to ',val,'sec']);
            allLasers(ii).OptimalDelay(curPath) = mean(optimalDelay);
            allLasers(ii).symmetry(curPath) = symmetry;
        end
    end
end
close all;
allLasers.OptimalDelay
allLasers.symmetry


%% preview mode
 [markedParameters, wavelength, intensityInMW, expTime, lastPosDetStage, lastPosExtStage, indWavelength, invalidTile, focusParameters, curPath] = ControlDCMotorUsingKeyboardV12(...
                curPath, controlParameters, allLasers, frameRate, expTime,...
                wavelength, intensityInMW, focusingFilter, lightSheetMode, addLine);
 
%% Large Field of View Image Pick only the relevant tiles %%
fwrite(afg, ':output1 on;');pause(.5);outputSingleScan(s,[4,0,0]);
overlap = 10;
%Keep them even both of them
vertTilesNum = 4;
horzTilesNum = 4;

%Get the current location of the stage !pixelsize=6.5;objectivemag=10;objectivedesignedtubelensfoc=180;tubelensF=180
effectivePixelSize = (pixelSizeUm/objectiveMag)*(objectiveDesignedTubeLensFocal/tubeLensFocalDistance)*downSampleFactor;
stepSizeInLateralScan = effectivePixelSize*(2048/downSampleFactor)*(100-overlap)/100;

%move to the center of the desired area to scan
TileAndMoveToOneOfTheTiles( controlParameters, vertTilesNum, horzTilesNum, stepSizeInLateralScan, downSampleFactor );
outputSingleScan(s,[0,0,0]);
fwrite(afg, ':output1 off;');
%% Create the scan array, the begining is the bottom right corner

%Scan parameters:
binning = '1x1'; %Other options '2x2', '4x4', '8x8'
%For second path increase the power by 4% (loss) * 9 elements => 0.36
additionalPowerForPath2 = 1.8;
downSampleFactor = str2num(binning(1));
%Manually go over each tile 
manualFocus = true;
%On the fly provide the calibration points
freeStyleFocus = true;
addRangeToSlicesUM = 50; %um, add 50 um to the beginning of the scan and the end
%Not relevant for light-sheet mode
expTimeForScan = 100; %ms
% the same order as before for each laser a number for PATH 1
laserIntensityForScan = [10, 10];
laserIntensityForAutoFocus = [7, 7];
%Duplicate for second path
laserIntensityForScanTwoPaths = cat(1,laserIntensityForScan, additionalPowerForPath2*laserIntensityForScan);
laserIntensityForAutoFocusTwoPaths = cat(1,laserIntensityForAutoFocus, additionalPowerForPath2*laserIntensityForAutoFocus);
    

%The wavelength that the main calibration will be done
domFocusWL = 556;

%not relevant for free style focus manual, a constant depth 
depthOfScan = 1000; %um

stepSizeOfScan = 2; %Um
toleranceInFocusUm = 2;
tifFormat = true;

%Parameters for AF 
numOfTestPointsAlongTheScan = 2; 
relativePositionRangeDetUm = 15;
scanResDetUm = 2;

%For different colors the center position should be large ~ 400 um
relativePositionRangeExtUm = 100;
scanResExtUm = 20;
whichQualityMeasure = 3;
aveNum = 1;
moveToBestFocalPoint = true;

%create a calibration curve
if (~lightSheetMode)
    mmc.setProperty(cameraLabel,'Exposure', expTimeForScan);
end
%mmc.setProperty(cameraLabel, 'Binning',binning);

%Scan parameters
rootDirectory = 'I:\Heart_paper_rev_488nm_TH_556nm_PGP';

%Parameters to get the overlap in pixels
%Get the position of the stage
[xPos, yPos, zPos] = GetXYZPosition(controlParameters.MMC);
effectivePixelSize = (pixelSizeUm/objectiveMag)*(objectiveDesignedTubeLensFocal/tubeLensFocalDistance)*downSampleFactor;
stepSizeInLateralScan = effectivePixelSize*(2048/downSampleFactor)*(100-overlap)/100;
[xyzScanArray, dirNames] = CreateScanCordCurrentCenterAsIs( xPos, yPos, zPos, vertTilesNum, horzTilesNum, stepSizeInLateralScan );
%xyzScanArrayOnlySelectedTiles = xyzScanArray(:,selectedTilesVectorAfterSnakePatternRemoval);
% dirNames = dirNames(:, selectedTilesVectorAfterSnakePatternRemoval);

rootDirectory_array = cell(1,numel(allLasers));
filterPosEmission_array = zeros(1, numel(allLasers));
filterPosExcitation_array = zeros(1, numel(allLasers));
filterPosAF_array = zeros(1, numel(allLasers));

%Create a directory for each color each one will have tera stitcher
%structure
for ii = 1:numel(allLasers)
    mkdir([rootDirectory,'\',num2str(ii)]);
    rootDirectory_array{ii} = [rootDirectory,'\',num2str(ii)];   
    filterPosEmission_array(ii) = allLasers(ii).filterEmission;     
    filterPosExcitation_array(ii) = allLasers(ii).filterExcitation;
    filterPosAF_array(ii) = allLasers(ii).filterAF;
end

%Write the parameters to a data file
fileID = fopen([rootDirectory,'\data.txt'],'w');
%Save the bigImage
%imwrite(mat2gray(bigImage),[rootDirectory,'\imageWithBorders.tif']);

temp = date;
laserIntensityForScan ;
laserIntensityForAutoFocus ;

fprintf(fileID,'date %s:\n\n',temp);
fprintf(fileID,'BINNING %s:\n\n',binning);
fprintf(fileID,'Wavelengths:\n');
fprintf(fileID,'%s nm\n',num2str(cat(2,allLasers.wavelength)));
fprintf(fileID,'filterPosAF:\n');
fprintf(fileID,'%s\n',num2str(cat(1,filterPosAF_array)));
fprintf(fileID,'filterPosEmission:\n');
fprintf(fileID,'%s\n',num2str(cat(1,filterPosEmission_array)));
fprintf(fileID,'filterPosExcitation:\n');
fprintf(fileID,'%s\n',num2str(cat(1,filterPosExcitation_array)));
fprintf(fileID,'\nSCAN PARAMETERS:\n');
fprintf(fileID,'stepSizeOfScan: %d\n',stepSizeOfScan);
%fprintf(fileID,'expTimeForScan: %d\n',expTimeForScan);
fprintf(fileID,'toleranceInFocusUm: %f\n\n',toleranceInFocusUm);
% if (lightSheetMode)
%     fprintf(fileID,'lightSheetMode ON \n');
%     fprintf(fileID,'frame rate: %d \n',newFreq);
%     fprintf(fileID,'Symmetry path1 \n');
%     a = cat(2,allLasers.symmetry);
%     fprintf(fileID,'%d \n',(cat(1,a(:,1))));
%     fprintf(fileID,'Symmetry path2 \n');
%     fprintf(fileID,'%d \n',(cat(1,a(:,2))));
%     fprintf(fileID,'OptimalDelay path 1\n');
%     a = cat(2,allLasers.OptimalDelay);
%     fprintf(fileID,'%d \n',(cat(1,a(:,1))));
%     fprintf(fileID,'OptimalDelay path 2\n');
%     fprintf(fileID,'%d \n',(cat(1,a(:,2))));       
% end
fprintf(fileID,'AUTO FOCUS PARAMETERS:\n');
if (~manualFocus)
    fprintf(fileID,'depthOfScan: %d\n',depthOfScan);
    fprintf(fileID,'numOfTestPointsAlongTheScan: %d\n',numOfTestPointsAlongTheScan);
    %fprintf(fileID,'expTimeForAutoFocus: %d\n',expTimeForAutoFocus);
    fprintf(fileID,'relativePositionRangeDetUm: %d\n',relativePositionRangeDetUm);
    fprintf(fileID,'scanResDetUm: %d\n',scanResDetUm);
    fprintf(fileID,'relativePositionRangeExtUm: %d\n',relativePositionRangeExtUm);
    fprintf(fileID,'scanResExtUm: %d\n',scanResExtUm);
    fprintf(fileID,'whichQualityMeasureForExcitationFocus: %d\n',whichQualityMeasure);
    fprintf(fileID,'aveNum: %d\n',aveNum);
    fprintf(fileID,'moveToBestFocalPoint: %d\n',moveToBestFocalPoint);
else 
    fprintf(fileID,'manualFocus: %d\n',manualFocus);
end
fprintf(fileID,'laserIntensityForScan: %s mw\n',num2str(cat(1,laserIntensityForScan)));
fprintf(fileID,'laserIntensityForAutoFocus: %s mw\n',num2str(cat(1,laserIntensityForAutoFocus)));

fclose(fileID);
%% Downsample the number of tiles to scan

fileID = fopen([rootDirectory,'\data.txt'],'a');
decFact = 1;
if (manualFocus)
    fprintf(fileID,'\n Manual focusing decimation factor: %d X %d \n', decFact, decFact);    
end

%Get position
[xPos, yPos, zPos] = GetXYZPosition(controlParameters.MMC);

%If the decimation facor or the number of tiles is one calibrate all of
%them, if not sample them 
if ((decFact == 1) || (vertTilesNum == 1) || (horzTilesNum == 1))
    xyzScanArrayFocus = xyzScanArray;
else
    %dy = stepSizeInLateralScan*(decFact - 1)/2; dz = stepSizeInLateralScan*(decFact - 1)/2;
    [xyzScanArrayFocus, ~] = CreateScanCordCurrentCenterV2( xPos, yPos, zPos, ceil(vertTilesNum/decFact), ceil(horzTilesNum/decFact), stepSizeInLateralScan*decFact);
    figure; scatter(xyzScanArray(2,:), xyzScanArray(3,:),'ob'); hold on; scatter(xyzScanArrayFocus(2,:), xyzScanArrayFocus(3,:),'*r');
    xlabel('Y axis'); ylabel('Z axis');
end

fclose(fileID);

%% For manual focusing move the stage according to the number of tiles and perform focusing
%this is a focus scan so it should work for all colors
fileID = fopen([rootDirectory,'\data.txt'],'a');

%Find the index of the dominant color
domFocusWLind = find([allLasers.wavelength] == domFocusWL);

%Find the index of the rest of the colors
restWLind = numOfActiveLasers:-1:1;
restWLind(find(restWLind == domFocusWLind)) = [];

%Make sure that the frame rate is correct
if (~lightSheetMode)
    %Change to the right exposure time for the scan
    mmc.setProperty(cameraLabel,'Exposure', expTimeForScan);
    %There is a bug in the frame rate, it changes sometimes
    mmc.startSequenceAcquisition(5, 0, false);
    %Frame rate is 1/exposure
    Value = 1/(str2num(mmc.getProperty(cameraLabel, 'Exposure'))/1000);
    display(['FrameRate = ',num2str(Value)]);
    newFreq = Value;
    fprintf(fileID,'New freq or actual exposure time  %f:\n',newFreq);    
    mmc.clearCircularBuffer;
end

delayTimeConst = 200; %ms the delay between the camera and the stage
delayImages = round(delayTimeConst/(1000/newFreq)); %The number of images to skip because of stage camera sync
fprintf(fileID,'DelayImages: between stage movment and camera acquisition : %d\n',delayImages);

if (manualFocus)
    %Manual focus
    focusingFilter = false;

    %The new structure with the corrected parameters
    scanParaManCorrection = cell(numOfActiveLasers,size(xyzScanArrayFocus,2));
   
    for ii = 1:size(xyzScanArrayFocus,2)
        
        %The dominant laser line first, keep the intensity as prev value
        [wavelength, indWavelength, curPath] = ChangeWavelengths(controlParameters, allLasers, wavelength, allLasers(domFocusWLind).wavelength, laserIntensityForAutoFocusTwoPaths(curPath, domFocusWLind), focusingFilter, curPath, lightSheetMode);
        
        %Display the tile number 
        display(['Tile ', num2str(ii),'/',num2str(size(xyzScanArrayFocus,2))]); 
        
        %move to the new cordinates
        [xPos, yPos, zPos] = GetXYZPosition(mmc);
        dx = 0; dy = xyzScanArrayFocus(2,ii) - yPos; dz = xyzScanArrayFocus(3,ii) - zPos;
        [newPosX, newPosY, newPosZ] = SetRelativeXYZPosition(mmc, dx, dy, dz );
        
        close all;      
        
        if (ii == 1)
            %Do not use prior knowledge
            [scanParaManCorrection{domFocusWLind,ii}, curPath] = FindDetStagePosExcStagePosForScanV8(controlParameters, ...
                allLasers, allLasers(domFocusWLind).wavelength, curPath, laserIntensityForAutoFocusTwoPaths(curPath, domFocusWLind), ...
                expTimeForScan, lightSheetMode);             
        else
            %Use the prior knowledge from the first color
            %even for the first tile
            [xPos, yPos, zPos] = GetXYZPosition(mmc);
            %Bring the stage to the begining of the sample
            dx = scanParaManCorrection{domFocusWLind,ii-1}(1).sampleXPos - xPos; dy = 0; dz = 0;
            [newPosX, newPosY, newPosZ] = SetRelativeXYZPosition(mmc, dx, dy, dz );
            %Start the calibration
            [scanParaManCorrection{domFocusWLind,ii}, curPath] = FindDetStagePosExcStagePosForScanV8(controlParameters, ...
                allLasers, allLasers(domFocusWLind).wavelength, curPath, scanParaManCorrection{domFocusWLind,(ii-1)}(1).intensityInMW, ...
                expTimeForScan, lightSheetMode, scanParaManCorrection{domFocusWLind,(ii-1)});                
        end
        
         %Sort the results according to the X value
         [~, ind] = sort([scanParaManCorrection{domFocusWLind,ii}.sampleXPos]);
         scanParaManCorrection{domFocusWLind,ii} = scanParaManCorrection{domFocusWLind,ii}(ind);
 
         %Write its parameters to the file
         fprintf(fileID,['Tile ', num2str(ii),'/',num2str(size(xyzScanArrayFocus,2)), ' wavelength ', num2str(wavelength), ' nm']);
         fprintf(fileID,'Position excitation lens after manual correction %f:\n',cat(1, scanParaManCorrection{domFocusWLind,ii}.posExtLens));
         fprintf(fileID,'Position detection lens after manual correction %f:\n',cat(1, scanParaManCorrection{domFocusWLind,ii}.posDetLens));
         fprintf(fileID,'Laser power after manual correction %f:\n',cat(1, scanParaManCorrection{domFocusWLind,ii}.intensityInMW));
                    
         %Now find only one point for the rest of the lasers more will be
         %ignored
         for jj = 1:numel(restWLind)
             
             if (ii == 1) 
                %Go back to the first point and change laser lines
                MoveStagesToDesiredLocationTwoExtStages(controlParameters,...
                scanParaManCorrection{domFocusWLind,(ii)}(1).posExtLens,...
                scanParaManCorrection{domFocusWLind,(ii)}(1).posExtLens2,...
                scanParaManCorrection{domFocusWLind,(ii)}(1).posDetLens); 
                %The change light path should not change anything 
                [curPath] = ChangeLightPath(controlParameters, allLasers, allLasers(domFocusWLind).wavelength, curPath, ...
                    scanParaManCorrection{domFocusWLind,(ii)}(1).whichLightPath, lightSheetMode);
                [wavelength, indWavelength, curPath] = ChangeWavelengths(controlParameters, allLasers, wavelength, ...
                    allLasers(restWLind(jj)).wavelength, laserIntensityForAutoFocusTwoPaths(curPath, restWLind(jj)), focusingFilter, curPath, lightSheetMode);
                adpInt = laserIntensityForAutoFocusTwoPaths(curPath, restWLind(jj));
             else
                 %Go back to the first point use the bias from the previous tile
                 temp = scanParaManCorrection{domFocusWLind,(ii)}(1);
                 biasDet = scanParaManCorrection{restWLind(jj),(ii-1)}(1).posDetLens - scanParaManCorrection{domFocusWLind,(ii-1)}(1).posDetLens - ...
                     (allLasers(restWLind(jj)).posDetLens(curPath) - allLasers(indWavelength).posDetLens(curPath));
                 temp.posDetLens = temp.posDetLens + biasDet;
                 biasExt1 = scanParaManCorrection{restWLind(jj),(ii-1)}(1).posExtLens - scanParaManCorrection{domFocusWLind,(ii-1)}(1).posExtLens - ...
                     (allLasers(restWLind(jj)).posExtLens(path1Excitation) - allLasers(indWavelength).posExtLens(path1Excitation));
                 temp.posExtLens = temp.posExtLens + biasExt1;
                 biasExt2 = scanParaManCorrection{restWLind(jj),(ii-1)}(1).posExtLens2 - scanParaManCorrection{domFocusWLind,(ii-1)}(1).posExtLens2 - ...
                     (allLasers(restWLind(jj)).posExtLens(path2Excitation) - allLasers(indWavelength).posExtLens(path2Excitation));
                 temp.posExtLens2 = temp.posExtLens2 + biasExt2;
                 MoveStagesToDesiredLocationTwoExtStages(controlParameters,...
                 temp.posExtLens,...
                 temp.posExtLens2,...
                 temp.posDetLens); 
                 %The change light path should not change anything 
                 [curPath] = ChangeLightPath(controlParameters, allLasers, wavelength, curPath, ...
                    temp.whichLightPath, lightSheetMode);                
                 [wavelength, indWavelength, curPath] = ChangeWavelengths(controlParameters, allLasers, wavelength, ...
                    allLasers(restWLind(jj)).wavelength, scanParaManCorrection{restWLind(jj),(ii-1)}(1).intensityInMW, ...
                    focusingFilter, curPath, lightSheetMode);
                adpInt = scanParaManCorrection{restWLind(jj),(ii-1)}(1).intensityInMW;
             end
             
             [xPos, yPos, zPos] = GetXYZPosition(mmc);
             %Bring the stage to the begining of the sample
             dx = scanParaManCorrection{domFocusWLind,ii}(1).sampleXPos - xPos;
             dy = scanParaManCorrection{domFocusWLind,ii}(1).sampleYPos - yPos;
             dz = scanParaManCorrection{domFocusWLind,ii}(1).sampleZPos - zPos;
             [newPosX, newPosY, newPosZ] = SetRelativeXYZPosition(mmc, dx, dy, dz );
             
             [scanParaManCorrection{restWLind(jj),ii}, curPath] = FindDetStagePosExcStagePosForScanV8(controlParameters, ...
                allLasers, allLasers(restWLind(jj)).wavelength, curPath, adpInt, ...
                expTimeForScan, lightSheetMode);   
             
            %If it is a valid tile add write its parameters to the
            %file
            fprintf(fileID,['Tile ', num2str(ii),'/',num2str(size(xyzScanArrayFocus,2)), ' wavelength ', num2str(wavelength), ' nm']);
            fprintf(fileID,'Position excitation lens after manual correction: %f \n',cat(1,scanParaManCorrection{restWLind(jj),ii}.posExtLens));
            fprintf(fileID,'Position detection lens after manual correction: %f \n',cat(1,scanParaManCorrection{restWLind(jj),ii}.posDetLens));
            fprintf(fileID,'Laser power after manual correction: %f \n',cat(1,scanParaManCorrection{restWLind(jj),ii}.intensityInMW));
        end

    end

    %Go back to the first wavelength essential since the scan assumes it
    [wavelength, indWavelength, curPath] = ChangeWavelengths(controlParameters, allLasers, wavelength, ...
                    allLasers(1).wavelength, laserIntensityForAutoFocusTwoPaths(curPath, 1), ...
                    focusingFilter, curPath, lightSheetMode);
    [curPath] = ChangeLightPath(controlParameters, allLasers, wavelength, curPath, ...
                    path1Excitation, lightSheetMode);
    cmd = ['save ' rootDirectory,'\ScanCalibrationParameters.mat scanParaManCorrection;'];
    eval(cmd);       
end

%% Interpolate the scan parameters to tiles that were not manually evaluated 

%Start from the primary wavelength
eps = 100;
scanCalibrationParametersAll = cell(numOfActiveLasers, vertTilesNum*horzTilesNum);
for ii = 1:size(xyzScanArrayFocus,2)
    %Dominant part first
    dist = sum((xyzScanArrayFocus(:,ii)*ones(1,size(xyzScanArray,2)) - xyzScanArray).^2);
    ind = (find(dist <= (min(dist)+eps)))
    for tt = 1:numel(ind)
        scanCalibrationParametersAll{domFocusWLind, ind(tt)} = scanParaManCorrection{domFocusWLind,ii};
    end
    
    %The rest of the lasers
    for jj = 1:numel(restWLind)
        
        temp1 = scanParaManCorrection{restWLind(jj), ii};
        temp2 = scanParaManCorrection{domFocusWLind, ii};
        biasDet = temp1(1).posDetLens - temp2(1).posDetLens;        
        for rr = 1:numel(temp2)
            temp2(rr).posDetLens = temp2(rr).posDetLens + biasDet;
        end
        biasExt = temp1(1).posExtLens - temp2(1).posExtLens;
        for rr = 1:numel(temp2)
            temp2(rr).posExtLens = temp2(rr).posExtLens + biasExt;
        end
        biasExt2 = temp1(1).posExtLens2 - temp2(1).posExtLens2;
        for rr = 1:numel(temp2)
            temp2(rr).posExtLens2 = temp2(rr).posExtLens2 + biasExt2;
        end        
        for tt = 1:numel(ind)
            scanCalibrationParametersAll{restWLind(jj), ind(tt)} = temp2;
        end
    end
end

%% Parse the files in order to find the scan parameters

onlyDomData = cell(1,vertTilesNum*horzTilesNum);
for ii = 1:vertTilesNum*horzTilesNum
    onlyDomData{ii} = scanCalibrationParametersAll{domFocusWLind,ii};
end
[ tableDetPos, ~, tableXPos] = CreateATableFromCalParameters(onlyDomData);
%Find the shallowest location 
surfaceInX = min(tableXPos(:,2)) - addRangeToSlicesUM;
temp = tableXPos(:,2:end);
deepInX = max(temp(:)) + addRangeToSlicesUM;
fullRangeInX = floor(((deepInX - surfaceInX)/stepSizeOfScan))*stepSizeOfScan;
numOfImagesFullRange = fullRangeInX/stepSizeOfScan;

%% Tile and scan with different colors, for each tile run all the colors and than change tiles

for jj = 1:(vertTilesNum*horzTilesNum)
    
    close all;
    
    %Move to the new cordinates
    [xPos, yPos, zPos] = GetXYZPosition(mmc);
    dx = xyzScanArray(1,jj) - xPos; dy = xyzScanArray(2,jj) - yPos; dz = xyzScanArray(3,jj) - zPos;
    [newPosX, newPosY, newPosZ] = SetRelativeXYZPosition(mmc, dx, dy, dz );
    fprintf(fileID,'\n Tile number %d:',jj);
    fprintf(fileID,'X %f Y %f Z %f \n', newPosX, newPosY, newPosZ);
    
    %Create the directories to save the images according to Tera
    %Stitcher
    pathToSave2_array = cell(1,numel(allLasers));
    for kk = 1:numel(allLasers)
        %Convension to Tera stitcher
        pathToSave1 = ConvertFromTeraNumberToTeraString(dirNames(2,jj));
        if (~(exist(pathToSave1,'dir') == 7))
            newDir = [rootDirectory_array{kk},'\',pathToSave1];
            mkdir(newDir);
        end
        pathToSave2_array{kk} = [rootDirectory_array{kk},'\',pathToSave1,'\',ConvertFromTeraNumberToTeraString(dirNames(2,jj)),'_',ConvertFromTeraNumberToTeraString(dirNames(3,jj))];
        mkdir(pathToSave2_array{kk});
    end
    
    %For each tile, scan all colors first
    for ii = numel(allLasers):-1:1
        
        %If manual focusing was done, use these parameters
        %ii for color and jj for tile number
        scanCalibrationParameters = scanCalibrationParametersAll{ii,jj};
        
        %Which color and which tile
        fprintf(fileID,'Wavelength %d, Tile number %d\n', allLasers(ii).wavelength, jj);
        
        %Change the lasers 
        [wavelength, indWavelength, curPath] = ChangeWavelengths(controlParameters, allLasers, wavelength, ...
                    allLasers(ii).wavelength, laserIntensityForScanTwoPaths(scanCalibrationParameters(1).whichLightPath, ii), ...
                    focusingFilter, curPath, lightSheetMode);
                
        %Change to the right light path
        [curPath] = ChangeLightPath(controlParameters, allLasers, wavelength, curPath, ...
                    scanCalibrationParameters(1).whichLightPath, lightSheetMode);
                
        %Move everything to the preset condition
        MoveStagesToDesiredLocationTwoExtStages(controlParameters,...
                 scanCalibrationParameters(1).posExtLens,...
                 scanCalibrationParameters(1).posExtLens2,...
                 scanCalibrationParameters(1).posDetLens); 
                                             
        %Create the calibration curve for the scan compensate for
        %different depths
        depthOfScan = (scanCalibrationParameters(end).sampleXPos - scanCalibrationParameters(1).sampleXPos) + 2*addRangeToSlicesUM;
        depthOfScan = floor(depthOfScan/stepSizeOfScan)*stepSizeOfScan;
        
        [absoluteMovementVector, timePointsVector, frameNumberToMoveVector] = CreateADetLensCalibCurveV3(scanCalibrationParameters, newFreq, ...
            stepSizeOfScan, depthOfScan, addRangeToSlicesUM, toleranceInFocusUm);
        
        %This function does not take into account the non-uniform sampling
        %of the focus points, for now I will ignore it by adding only one
        %value that is equal thw user input
        [laserPowerVector, timePointsVectorLaserPower, frameNumberToMoveVectorLaserPower] = CreateALaserPowerCalibCurveV1(scanCalibrationParameters, newFreq, ...
            stepSizeOfScan, depthOfScan);
        
        %For now use the same power everywhere 
        laserPowerVector = ones(size(laserPowerVector))*laserIntensityForScanTwoPaths(curPath, ii);
        
        %Move to the new X location, add a little space for redundency
        [xPos, yPos, zPos] = GetXYZPosition(mmc);
        dx = (scanCalibrationParameters(1).sampleXPos - addRangeToSlicesUM - xPos); dy = xyzScanArray(2,jj) - yPos; dz = xyzScanArray(3,jj) - zPos;
        [newPosX, newPosY, newPosZ] = SetRelativeXYZPosition(mmc, dx, dy, dz );
        fprintf(fileID,'Corrected Z to Tile number %d:',jj);
        fprintf(fileID,'X %f Y %f Z %f \n', newPosX, newPosY, newPosZ);
        
        numOfZeroImagesBegin = (scanCalibrationParameters(1).sampleXPos - surfaceInX - addRangeToSlicesUM);
        numOfZeroImagesBegin = floor(numOfZeroImagesBegin/stepSizeOfScan);
        numOfZeroImagesEnd = numOfImagesFullRange - numOfZeroImagesBegin - frameNumberToMoveVector(end);
        
        CaptureAStackWhileStageRunningExternalTriggerV7(controlParameters, allLasers,...
            absoluteMovementVector, frameNumberToMoveVector, newFreq, ...
            frameNumberToMoveVector(end), laserPowerVector, frameNumberToMoveVectorLaserPower,  allLasers(ii).wavelength...
            , stepSizeOfScan, pathToSave2_array{ii}, tifFormat, delayImages, numOfZeroImagesBegin, numOfZeroImagesEnd, downSampleFactor);
        
    end
    
end

%Go back to the first wavelength essential since the scan assumes it
[wavelength, indWavelength, curPath] = ChangeWavelengths(controlParameters, allLasers, wavelength, ...
                    allLasers(1).wavelength, laserIntensityForAutoFocusTwoPaths(curPath, 1), ...
                    focusingFilter, curPath, lightSheetMode);
[curPath] = ChangeLightPath(controlParameters, allLasers, wavelength, curPath, ...
                    path1Excitation, lightSheetMode);
fclose(fileID);

%% Reset the mmc 
fwrite(afg, ':output1 off;'); 
fwrite(afg, ':output2 off;'); 

reset(mmc);
clear mmc;

%Release the serial handles
fclose(sExtLens);
delete(sExtLens);
clear sExtLens;

% fclose(sExtLens2);
% delete(sExtLens2);
% clear sExtLens2;

fclose(sDetLens);
delete(sDetLens);
clear sDetLens;

fclose(afg);
delete(afg);
clear afg;

fclose(sFWDet);
delete(sFWDet);
clear sFWDet;

clear shutter;
clear galvoX;
clear galvoY;
release(s);
clear s;

% fclose(sFWExt);
% delete(sFWExt);
% clear sFWExt;

% shutters.delete;
% clear shutters; 

%% 
%488 nm 
if (avilableLasers(1))
    DisconectObis(s488nm); 
    clear s488nm;    
end

%561 nm
if (avilableLasers(2))
    DisconectObis(s561nm); 
    clear s589nm;    
end

%640 nm 
if (avilableLasers(3))
    DisconectObis(s640nm); 
    clear s640nm;
end

%Release the buffer to prevent memory leakage
controlParameters.MMC.setCircularBufferMemoryFootprint(1024*.01);


