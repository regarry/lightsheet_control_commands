%For now this program assume a fixed exposure time of 50 ms, since it will
%support the required frame rate. Presss E to exit the live mode
function [wavelengthList, indWavelegth, intensityInMW, lastExpTime] = ControlDCMotorUsingKeyboardV6(sExtLens, sDetLens, mmc, ...
    cameraLabel, frameRate, expTime, addLine, s473nm, s556nm, s640nm, sFWExt, sFWDet,...
    wavelength, intensityInMW, focusingFilter)
    
    %Check if it is needed to add a line for alignment 
    if (nargin == 6)
        addLine = false;
    end
    
    %Check the value of frameRate and make sure it is reasonable
    if (frameRate > 7)
        frameRate = 7;
    end
    if (frameRate < 0)
        frameRate = 2;
    end
    
    %In case that a line is added 
    if (addLine)
        %Crerate line array
        vPos = 1:100:2048;
        array1 = [vPos' ones(size(vPos,2),1)]; 
        array2 = [vPos' 2048*ones(size(vPos,2),1)];
    end
    
    %Set the exposure according to the user input
    mmc.setProperty(cameraLabel,'Exposure', expTime);
    expVal = mmc.getProperty(cameraLabel,'Exposure');
    waitBetweenImages = 1/frameRate; %[sec]

    %Snap an image and get its properties
    mmc.snapImage();
    image = mmc.getImage();  % returned as a 1D array of signed integers in row-major order
    width = mmc.getImageWidth();
    height = mmc.getImageHeight();
    pixelType = 'uint16';
    image = typecast(image, pixelType);      % pixels must be interpreted as unsigned integers
    image = reshape(image, [width, height]); % image should be interpreted as a 2D array
    image = transpose(image);                % make column-major order for MATLAB
    
        
    %Start capturing images and show them until somebody press the 'q' key
    
    %     w = warning('query','last');
    %     id = w.identifier;
    %     warning('off',id);
    
    %Check stage positions
    [posExt] = GetPos(sExtLens);
    [posDet] = GetPos(sDetLens);    
    
    %According to newport speed will not change accuracy
    %Set the speed at 1 mm/sec 
    fprintf(sExtLens, '1VA1');
    %Set the speed at 0.25 mm/sec 
    fprintf(sDetLens,'1VA0.25');
    
    
    %Find which wavelength  
    switch wavelength
        case 473
            indWavelegth = 1;
        case 556 
            indWavelegth = 2;
        case 640 
            indWavelegth = 3;
    end
        
           
    %Create the figure and the call back function
    f = figure;   
    set(f,'toolbar','figure');
    set(f,'WindowKeyRelease', @KeyReleaseFcn); 
    %f.WindowStyle = 'modal';
    hAxes = subplot(1,1,1);
    hImage = imshow(image,'Parent',hAxes, 'DisplayRange', []); 
    textbox_handle = uicontrol('Style','text','HorizontalAlignment','left',...
    'String',['Pos ext ',posExt,'= 0, Step ext = 0.1 mm, Pos det = ',posDet,', Step det = 0.01, exp time =',char(expVal)...
    ,' intensity = ', num2str(intensityInMW),'mW, wavelength = ', num2str(wavelength),' nm'],'Position', [0 0 1000 50],...
     'TooltipString','Press up,down,right,left, z to change step size ext, x to change step size detection, e to change exposure time and q to close the figure.');
    set(textbox_handle,'FontSize',12);
    
    %Create the handles structure
    myhandles = guihandles(f);
    myhandles.textbox_handle = textbox_handle;     
    myhandles.continue = true;
    myhandles.sDet = sDetLens;
    myhandles.sExt = sExtLens;
    myhandles.stepSizeExtOpt = {'1', '0.1', '0.01', '0.001'};
    myhandles.stepSizeExtIndex = 2; 
    myhandles.stepSizeDetOpt = {'0.25', '0.1', '0.01', '0.001'};
    myhandles.stepSizeDetIndex = 3;   
    myhandles.expousreTime = [500 250 100 50 25];
    myhandles.expousreTimeIndex = 3; 
    myhandles.cameraLabel = cameraLabel;
    myhandles.mmc = mmc;
    myhandles.s473nm = s473nm;
    myhandles.s556nm = s556nm;
    myhandles.s640nm = s640nm;
    myhandles.sFWExt = sFWExt;
    myhandles.sFWDet = sFWDet;
    myhandles.wavelengthList = [473 556 640];
    myhandles.indWavelegth = indWavelegth;
    myhandles.intensityInMW = intensityInMW;
    myhandles.focusingFilter = focusingFilter;
     
    %Disable the auto shutter
    mmc.setAutoShutter(0);
    mmc.setShutterOpen(true);
    
    %For alignment 
    if (addLine)
        for ii = 1:size(vPos,2)
            hold on;  line([array1(ii,2) array2(ii,2)],[array1(ii,1) array2(ii,1)],'Color','y','LineWidth',2);        
        end
    end
    
    %Update the structure
    while (myhandles.continue)
        guidata(f,myhandles); 
        startTime = tic;
        mmc.snapImage();
        image = mmc.getImage();
        image = typecast(image, pixelType);      % pixels must be interpreted as unsigned integers
        image = reshape(image, [width, height]); % image should be interpreted as a 2D array
        image = transpose(image);                % make column-major order for MATLAB
        set(hImage,'CData',image);
        
        elTime = toc(startTime);
        if (elTime <= (waitBetweenImages))
            pause(waitBetweenImages - elTime);            
        else
            pause(0.15);
        end
        myhandles = guidata(f);                               
    end
    
    %Close the shutter
    mmc.setShutterOpen(false);
    %Enable the auto shutter
    mmc.setAutoShutter(1);    
    close(f);
    figure; imshow(image,[]);
    intensityInMW = myhandles.intensityInMW;
    indWavelegth = myhandles.indWavelegth; 
    wavelengthList = myhandles.wavelengthList;
    lastExpTime = myhandles.expousreTime(myhandles.expousreTimeIndex);

end

function [] = KeyReleaseFcn(src, evt)
        myhandles = guidata(src);
        speedFactor = 1;
        pauseTime = (1/speedFactor) + 0.1;
        switch lower(evt.Key)
            %Push the ext objective backwards
            case 'uparrow'
                fprintf(myhandles.sExt,['1PR-',myhandles.stepSizeExtOpt{myhandles.stepSizeExtIndex}]);
                pause(pauseTime);                
            %Push the ext objective toward the chamber
            case 'downarrow'
                fprintf(myhandles.sExt,['1PR',myhandles.stepSizeExtOpt{myhandles.stepSizeExtIndex}]);
                pause(pauseTime);                
            %Push the det objective toward the chamber
            case 'leftarrow'
                fprintf(myhandles.sDet,['1PR',myhandles.stepSizeDetOpt{myhandles.stepSizeDetIndex}]);
                pause(pauseTime); 
            %Push the det objective away from the chamber
            case 'rightarrow'
                fprintf(myhandles.sDet,['1PR-',myhandles.stepSizeDetOpt{myhandles.stepSizeDetIndex}]);
                pause(pauseTime);
            case 'z'
                %Change the step size
                myhandles.stepSizeExtIndex = myhandles.stepSizeExtIndex + 1;
                if (myhandles.stepSizeExtIndex > numel(myhandles.stepSizeExtOpt))
                    myhandles.stepSizeExtIndex = myhandles.stepSizeExtIndex - numel(myhandles.stepSizeExtOpt);
                end  
                %Change the stage speed according to newport speed will not
                %change accuracy, therefore the speed will remain 0.25 mm/sec 
                %fprintf(myhandles.sExt,['1VA',num2str(str2num(myhandles.stepSizeExtOpt{myhandles.stepSizeExtIndex})*speedFactor)]);                
                %fprintf(myhandles.sExt,'1VA?');
                %out = fscanf(myhandles.sExt)
            case 'x'
                %Change the step size
                myhandles.stepSizeDetIndex = myhandles.stepSizeDetIndex + 1;
                if (myhandles.stepSizeDetIndex > numel(myhandles.stepSizeDetOpt))
                    myhandles.stepSizeDetIndex = myhandles.stepSizeDetIndex - numel(myhandles.stepSizeDetOpt);
                end  
                %Change the stage speed according to newport speed will not
                %change accuracy, therefore the speed will remain 0.25 mm/sec 
                %fprintf(myhandles.sDet,['1VA',num2str(str2num(myhandles.stepSizeDetOpt{myhandles.stepSizeDetIndex})*speedFactor)]); 
                %fprintf(myhandles.sDet,'1VA?');
                %out = fscanf(myhandles.sDet)
            case 'e'
                myhandles.expousreTimeIndex = myhandles.expousreTimeIndex + 1;
                if (myhandles.expousreTimeIndex > numel(myhandles.expousreTime))
                    myhandles.expousreTimeIndex = myhandles.expousreTimeIndex - numel(myhandles.expousreTime);
                end  
                myhandles.mmc.setProperty(myhandles.cameraLabel,'Exposure', myhandles.expousreTime(myhandles.expousreTimeIndex));                
            %increase the power
            case 'u'
                myhandles.intensityInMW = myhandles.intensityInMW + 5;
                SetPowerOfLasersV2(myhandles.s473nm, myhandles.s556nm, myhandles.s640nm, myhandles.sFWExt, myhandles.sFWDet,myhandles.wavelengthList(myhandles.indWavelegth), myhandles.intensityInMW, myhandles.focusingFilter);                                
            case 'y' 
                myhandles.intensityInMW = myhandles.intensityInMW - 5;
                SetPowerOfLasersV2(myhandles.s473nm, myhandles.s556nm, myhandles.s640nm, myhandles.sFWExt, myhandles.sFWDet, myhandles.wavelengthList(myhandles.indWavelegth), myhandles.intensityInMW, myhandles.focusingFilter);                                
            case 'w'
                myhandles.intensityInMW = 10;
                myhandles.indWavelegth = myhandles.indWavelegth + 1;
                if (myhandles.indWavelegth > numel(myhandles.wavelengthList))
                    myhandles.indWavelegth = myhandles.indWavelegth - numel(myhandles.wavelengthList);
                end  
                SetPowerOfLasersV2(myhandles.s473nm, myhandles.s556nm, myhandles.s640nm, myhandles.sFWExt, myhandles.sFWDet,  myhandles.wavelengthList(myhandles.indWavelegth), myhandles.intensityInMW, myhandles.focusingFilter);                                
            case 'q'
                display('Stopped');
                myhandles.continue = false;                                   
        end     
               
        %Check for position of excitation lens
        [posExt] = GetPos(myhandles.sExt);
        
        %Check for position of detection lens
        [posDet] = GetPos(myhandles.sDet);
        
        %Check the exposure time
        expVal = myhandles.mmc.getProperty(myhandles.cameraLabel,'Exposure');
       
        %Update the text box
        textToDisplay = ['Pos Ext = ',posExt,'   Step Ext = ',myhandles.stepSizeExtOpt{myhandles.stepSizeExtIndex},...
            '   Pos Det = ',posDet,'   Step Det = ',myhandles.stepSizeDetOpt{myhandles.stepSizeDetIndex},'  Exp time = ',char(expVal),'ms', ...
            ' intensity = ', num2str(myhandles.intensityInMW),'mW, wavelength = ', num2str(myhandles.wavelengthList(myhandles.indWavelegth)),' nm'];
        set(myhandles.textbox_handle,'String',textToDisplay);   
        guidata(src,myhandles); 
    
end

function [pos] = GetPos(serial)
        
        maxSizeOfString = 7;        
        fprintf(serial,'1TP?');
        pos = fscanf(serial);
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
        
        if(numel(pos) > maxSizeOfString)
            pos = pos(1:maxSizeOfString);
        end       
            
end



