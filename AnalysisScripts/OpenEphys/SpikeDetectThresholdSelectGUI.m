function varargout = SpikeDetectThresholdSelectGUI(varargin)
% SPIKEDETECTTHRESHOLDSELECTGUI MATLAB code for SpikeDetectThresholdSelectGUI.fig
%      SPIKEDETECTTHRESHOLDSELECTGUI, by itself, creates a new SPIKEDETECTTHRESHOLDSELECTGUI or raises the existing
%      singleton*.
%
%      H = SPIKEDETECTTHRESHOLDSELECTGUI returns the handle to a new SPIKEDETECTTHRESHOLDSELECTGUI or the handle to
%      the existing singleton*.
%
%      SPIKEDETECTTHRESHOLDSELECTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SPIKEDETECTTHRESHOLDSELECTGUI.M with the given input arguments.
%
%      SPIKEDETECTTHRESHOLDSELECTGUI('Property','Value',...) creates a new SPIKEDETECTTHRESHOLDSELECTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SpikeDetectThresholdSelectGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SpikeDetectThresholdSelectGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SpikeDetectThresholdSelectGUI

% Last Modified by GUIDE v2.5 20-Mar-2014 13:44:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SpikeDetectThresholdSelectGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @SpikeDetectThresholdSelectGUI_OutputFcn, ...
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


% --- Executes just before SpikeDetectThresholdSelectGUI is made visible.
function SpikeDetectThresholdSelectGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SpikeDetectThresholdSelectGUI (see VARARGIN)

% Choose default command line output for SpikeDetectThresholdSelectGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SpikeDetectThresholdSelectGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SpikeDetectThresholdSelectGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in OK.
function OK_Callback(hObject, eventdata, handles)
% hObject    handle to OK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
