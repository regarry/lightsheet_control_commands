function [] = ControlDCMotorUsingKeyboardV2(portExt, portDet )
    
    %Initialize the motors
    %[sExtLens] = initiliazeMotors(portExt); 
    %[sDetLens] = initiliazeMotors(portDet); 
    
    image = randn(2048,2048);
    
    f = figure;
    myhandles = guihandles(f);
    %f.WindowStyle = 'modal';
    hAxes = subplot(1,1,1);
    hImage = imshow(image,'Parent',hAxes, 'DisplayRange', []); 
    pressListener = addlistener(f,'WindowKeyRelease', @KeyReleaseFcn);  
    myhandles.continue = true;
    myhandles.a = 5;
    guidata(f,myhandles); 
    ii = 0;    
    while (myhandles.continue)
        
        image = randn(2048,2048);
        set(hImage,'CData',image);
        myhandles.a = myhandles.a + 1;
        guidata(f,myhandles); 
        pause(0.15);
        myhandles = guidata(f);
        
%         k = get(f,'CurrentCharacter');
%         switch lower(k)
%         case 'p'
%             display('hello');
%             shg;
%         case 'e'
%             display('Stopped');
%             break;
%         end
        
                
    end
    
    
    %Release the serial handles
%     fclose(sExtLens);
%     delete(sExtLens);
%     clear sExtLens;
% 
%     fclose(sDetLens);
%     delete(sDetLens);
%     clear sDetLens;
    
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
    
end

function [] = KeyReleaseFcn(src, evt)
        shg;
        myhandles = guidata(src);
        evt.Source.CurrentCharacter       
        switch lower(evt.Source.CurrentCharacter)
            case 'p'
                display('hello');              
            case 'e'
                display('Stopped');
                myhandles.continue = false;                                   
        end        
        %shg;
        guidata(src,myhandles); 
    
end



