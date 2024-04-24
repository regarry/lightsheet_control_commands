function [] = LiveModeExternalTriggerMove2Stages(sExtLens, sDetLens, mmc, cameraLabel)

    %Configure the buffer the largest allowed in Java
    mmc.setCircularBufferMemoryFootprint(1024*10);
    mmc.setTimeoutMs(500000);
    
    %capture one image to retrieve parameters
    width = mmc.getImageWidth();
    height = mmc.getImageHeight();
    pixelType = 'uint16';
    
    %Exposure time
    expVal = mmc.getProperty(cameraLabel,'Exposure');
    display(['Exposure time is ',char(expVal),' ms']);
    
    %Check stage positions
    [posExt] = GetPos(sExtLens);
    [posDet] = GetPos(sDetLens);    
    
    %According to newport speed will not change accuracy
    %Set the speed at 1 mm/sec 
    fprintf(sExtLens, '1VA1');
    %Set the speed at 0.25 mm/sec 
    fprintf(sDetLens,'1VA0.25');       
    
    %Start capturing images    
    numOfImages = 1000000;
    intervalMs = 0;
    stopOnOverflow = false;
    mmc.setShutterOpen(true);
    mmc.startSequenceAcquisition(numOfImages, intervalMs, stopOnOverflow);
    %Set the shutter off
    mmc.setAutoShutter(false);    
    mmc.setShutterOpen(true);
    pause(0.2); 
           
    %Create the figure and the call back function
    f = figure;   
    set(f,'toolbar','figure');
    set(f,'WindowKeyRelease', @KeyReleaseFcn); 
    %f.WindowStyle = 'modal';
    hAxes = subplot(1,1,1);
    
    image = mmc.getLastImage();
    mmc.setShutterOpen(false);
    image = typecast(image, pixelType);      % pixels must be interpreted as unsigned integers
    image = reshape(image, [width, height]); % image should be interpreted as a 2D array
    image = transpose(image); 
    
    hImage = imshow(image,'Parent',hAxes, 'DisplayRange', []); 
    textbox_handle = uicontrol('Style','text','HorizontalAlignment','left',...
    'String',['Pos ext ',posExt,'= 0, Step ext = 0.1 mm, Pos det = ',posDet,', Step det = 0.01, exp time =',char(expVal)],...
     'Position', [0 0 1000 50],...
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
    
    %Set the shutter on     
    mmc.setShutterOpen(true);
    
    %Clear any images from the circular buffer and prep the camera
    mmc.clearCircularBuffer;
    %mmc.prepareSequenceAcquisition(cameraLabel);
    
    
    
    %Write once when the sequence stopped running
    stopFlag = true;
    
    %Update the structure
    while (myhandles.continue)
        
        guidata(f,myhandles); 
        image = mmc.getLastImage();
        image = typecast(image, pixelType);      % pixels must be interpreted as unsigned integers
        image = reshape(image, [width, height]); % image should be interpreted as a 2D array
        image = transpose(image);                % make column-major order for MATLAB
        set(hImage,'CData',image);
        
        %Let it check any key press events
        pause(0.01);
        
        %Check if the buffer is about to finish
        if (mmc.getBufferFreeCapacity < 10)
            display('oh no');
        end
        
        %Display if the the sequence stopped
        if (~mmc.isSequenceRunning && stopFlag)
            
            stopFlag = false;
            display('Sequence stopped running');
            mmc.setShutterOpen(false);            
        end
        myhandles = guidata(f);                               
    end
    
    if (mmc.isSequenceRunning)
        mmc.stopSequenceAcquisition;
    end
         mmc.clearCircularBuffer;
    %Close the shutter
    mmc.setShutterOpen(false);
    %Enable the auto shutter
    mmc.setAutoShutter(1);    
   
    close(f);
    figure; imshow(image,[]);

    


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
                %Change the stage speed
                %According to newport speed will not change accuracy
                %fprintf(myhandles.sExt,['1VA',num2str(str2num(myhandles.stepSizeExtOpt{myhandles.stepSizeExtIndex})*speedFactor)]);                
                %fprintf(myhandles.sExt,'1VA?');
                %out = fscanf(myhandles.sExt)
            case 'x'
                %Change the step size
                myhandles.stepSizeDetIndex = myhandles.stepSizeDetIndex + 1;
                if (myhandles.stepSizeDetIndex > numel(myhandles.stepSizeDetOpt))
                    myhandles.stepSizeDetIndex = myhandles.stepSizeDetIndex - numel(myhandles.stepSizeDetOpt);
                end  
                %Change the stage speed
                %fprintf(myhandles.sDet,['1VA',num2str(str2num(myhandles.stepSizeDetOpt{myhandles.stepSizeDetIndex})*speedFactor)]); 
                %fprintf(myhandles.sDet,'1VA?');
                %out = fscanf(myhandles.sDet);
            case 'e'
                display('Exposure time was set by the light-sheet mode');
                %myhandles.expousreTimeIndex = myhandles.expousreTimeIndex + 1;
                %if (myhandles.expousreTimeIndex > numel(myhandles.expousreTime))
                %    myhandles.expousreTimeIndex = myhandles.expousreTimeIndex - numel(myhandles.expousreTime);
                %end  
                %myhandles.mmc.setProperty(myhandles.cameraLabel,'Exposure', myhandles.expousreTime(myhandles.expousreTimeIndex));                
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
            '   Pos Det = ',posDet,'   Step Det = ',myhandles.stepSizeDetOpt{myhandles.stepSizeDetIndex},'  Exp time = ',char(expVal),'ms'];
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





