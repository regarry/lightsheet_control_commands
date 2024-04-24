function [] = ControlDCMotorUsingKeyboardV3(portExt, portDet)
    
    %Initialize the motors
    [sExtLens] = initiliazeMotors(portExt); 
    [sDetLens] = initiliazeMotors(portDet); 
    %sDetLens = 0;
    
    
    image = randn(2048,2048);
    
    %Check stage positions
    [posExt] = GetPos(sExtLens);
    [posDet] = GetPos(sDetLens);
    
    
    %Create the figure and the call back function
    f = figure;
    set(f,'WindowKeyRelease', @KeyReleaseFcn); 
    %f.WindowStyle = 'modal';
    hAxes = subplot(1,1,1);
    hImage = imshow(image,'Parent',hAxes, 'DisplayRange', []); 
    textbox_handle = uicontrol('Style','text',...
    'String',['Pos ext ',posExt,'= 0, Step ext = 0.1 mm, Pos det = ',posDet,', Step det = 0.1'],...
     'Position', [0 0 1000 50],...
     'TooltipString','Press up,down,right,left, z to change step size ext, x to change step size detection. q to close the figure.');
    set(textbox_handle,'FontSize',15);
    
    %Create the handles structure
    myhandles = guihandles(f);
    myhandles.textbox_handle = textbox_handle;     
    myhandles.continue = true;
    myhandles.sDet = sDetLens;
    myhandles.sExt = sExtLens;
    myhandles.stepSizeExtOpt = {'1', '0.1', '0.01', '0.001'};
    myhandles.stepSizeExtIndex = 2; 
    myhandles.stepSizeDetOpt = {'0.25', '0.1', '0.01', '0.001'};
    myhandles.stepSizeDetIndex = 2;    
    
    
    %Update the structure
    guidata(f,myhandles); 
    while (myhandles.continue)
        
        image = randn(2048,2048);
        set(hImage,'CData',image);
        guidata(f,myhandles); 
        pause(0.15);
        myhandles = guidata(f);
                       
    end
    
    
    %Release the serial handles
    fclose(sExtLens);
    delete(sExtLens);
    clear sExtLens;

    fclose(sDetLens);
    delete(sDetLens);
    clear sDetLens;
    
    close(f);

end

function [serialHandle] = initiliazeMotors(portNumber)
    
    % Establish communication for excitation lens
    serialHandle = serial(portNumber);
    set(serialHandle,'BaudRate',921600);
    set(serialHandle,'Terminator','CR/LF');
    fopen(serialHandle);
    % To see the different properties just wrie set(s)/get(s)
    %set(s,'Parity') show all the options for Parity

    %Start the controller 
    fprintf(serialHandle,'1OR');  
    %Reduce the speed
    fprintf(serialHandle,'1VA0.2');
    
end

function [] = KeyReleaseFcn(src, evt)
        myhandles = guidata(src);
        speedFactor = 1;
        pauseTime = (1/speedFactor) + 0.4;
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
                fprintf(myhandles.sExt,['1VA',num2str(str2num(myhandles.stepSizeExtOpt{myhandles.stepSizeExtIndex})*speedFactor)]);                
            case 'x'
                %Change the step size
                myhandles.stepSizeDetIndex = myhandles.stepSizeDetIndex + 1;
                if (myhandles.stepSizeDetIndex > numel(myhandles.stepSizeDetOpt))
                    myhandles.stepSizeDetIndex = myhandles.stepSizeDetIndex - numel(myhandles.stepSizeDetOpt);
                end  
                %Change the stage speed
                fprintf(myhandles.sDet,['1VA',num2str(str2num(myhandles.stepSizeDetOpt{myhandles.stepSizeDetIndex})*speedFactor)]); 
            case 'q'
                display('Stopped');
                myhandles.continue = false;                                   
        end     
               
        %Check for position of excitation lens
        [posExt] = GetPos(myhandles.sExt);
        
        %Check for position of detection lens
        [posDet] = GetPos(myhandles.sDet);
        
        %Update the text box
        textToDisplay = ['Pos Ext = ',posExt,'   Step Ext = ',myhandles.stepSizeExtOpt{myhandles.stepSizeExtIndex},...
            '   Pos Det = ',posDet,'   Step Det = ',myhandles.stepSizeDetOpt{myhandles.stepSizeDetIndex}];
        set(myhandles.textbox_handle,'String',textToDisplay);
        
%         fprintf(myhandles.sExt,'1VA?');
%         out = fscanf(myhandles.sExt)
%         
%         fprintf(myhandles.sDet,'1VA?');
%         out = fscanf(myhandles.sDet)
        
        guidata(src,myhandles); 
    
end

function [pos] = GetPos(serial)
        
        maxSizeOfString = 6;        
        fprintf(serial,'1TP?');
        pos = fscanf(serial);
        k = strfind(pos,'TP');
        k = k(1);
        pos = pos(k+2:end);
        if(numel(pos) > maxSizeOfString)
            pos = pos(1:maxSizeOfString);
        end            
    
end



