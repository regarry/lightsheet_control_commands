function varargout = Joystick(varargin)
% JOYSTICK MATLAB code for Joystick.fig
%      JOYSTICK, by itself, creates a new JOYSTICK or raises the existing
%      singleton*.
%
%      H = JOYSTICK returns the handle to a new JOYSTICK or the handle to
%      the existing singleton*.
%
%      JOYSTICK('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in JOYSTICK.M with the given input arguments.
%
%      JOYSTICK('Property','Value',...) creates a new JOYSTICK or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Joystick_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Joystick_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Joystick

% Last Modified by GUIDE v2.5 04-Mar-2015 18:33:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Joystick_OpeningFcn, ...
                   'gui_OutputFcn',  @Joystick_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Joystick is made visible.
function Joystick_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Joystick (see VARARGIN)

% Choose default command line output for Joystick
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes Joystick wait for user response (see UIRESUME)
% uiwait(handles.figure1);

sExtLens = serial('COM7');
set(sExtLens,'BaudRate',921600);
set(sExtLens,'Terminator','CR/LF');
fopen(sExtLens);

%Start the controller 
fprintf(sExtLens,'1OR');

%Com with the det motor
sDetLens = serial('COM15');
set(sDetLens,'BaudRate',921600);
set(sDetLens,'Terminator','CR/LF');
fopen(sDetLens);

%Start the controller 
fprintf(sDetLens,'1OR');

%Set the speeds
fprintf(sExtLens,'1VA1');
fprintf(sDetLens,'1VA1');

%Update the handles structure
handles.sExtLens = sExtLens;
handles.sDetLens = sDetLens;
guidata(hObject,handles);


% --- Outputs from this function are returned to the command line.
function varargout = Joystick_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in SpeedExcLens.
function SpeedExcLens_Callback(hObject, eventdata, handles)
% hObject    handle to SpeedExcLens (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SpeedExcLens contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SpeedExcLens


% --- Executes during object creation, after setting all properties.
function SpeedExcLens_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SpeedExcLens (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in StepSizeExcitationLens.
function StepSizeExcitationLens_Callback(hObject, eventdata, handles)
% hObject    handle to StepSizeExcitationLens (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns StepSizeExcitationLens contents as cell array
%        contents{get(hObject,'Value')} returns selected item from StepSizeExcitationLens


% --- Executes during object creation, after setting all properties.
function StepSizeExcitationLens_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StepSizeExcitationLens (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in StepSizeDetectionLens.
function StepSizeDetectionLens_Callback(hObject, eventdata, handles)
% hObject    handle to StepSizeDetectionLens (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns StepSizeDetectionLens contents as cell array
%        contents{get(hObject,'Value')} returns selected item from StepSizeDetectionLens


% --- Executes during object creation, after setting all properties.
function StepSizeDetectionLens_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StepSizeDetectionLens (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in DetTowardChamber.
function DetTowardChamber_Callback(hObject, eventdata, handles)
% hObject    handle to DetTowardChamber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in DetAwayChamber.
function DetAwayChamber_Callback(hObject, eventdata, handles)
% hObject    handle to DetAwayChamber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in ExcTowardChamber.
function ExcTowardChamber_Callback(hObject, eventdata, handles)
% hObject    handle to ExcTowardChamber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in ExcAwayChamber.
function ExcAwayChamber_Callback(hObject, eventdata, handles)
% hObject    handle to ExcAwayChamber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Initilize.
function Initilize_Callback(hObject, eventdata, handles)
% hObject    handle to Initilize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Com with the ext motor



% --- Executes on button press in Exit.
function Exit_Callback(hObject, eventdata, handles)
% hObject    handle to Exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fclose(handles.sExtLens);
fclose(handles.sDetLens);

