function varargout = PLX_To_Kofiko(varargin)
% PLX_TO_KOFIKO M-file for PLX_To_Kofiko.fig
%      PLX_TO_KOFIKO, by itself, creates a new PLX_TO_KOFIKO or raises the existing
%      singleton*.
%
%      H = PLX_TO_KOFIKO returns the handle to a new PLX_TO_KOFIKO or the handle to
%      the existing singleton*.
%
%      PLX_TO_KOFIKO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLX_TO_KOFIKO.M with the given input arguments.
%
%      PLX_TO_KOFIKO('Property','Value',...) creates a new PLX_TO_KOFIKO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PLX_To_Kofiko_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PLX_To_Kofiko_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PLX_To_Kofiko

% Last Modified by GUIDE v2.5 17-Jun-2011 11:12:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PLX_To_Kofiko_OpeningFcn, ...
                   'gui_OutputFcn',  @PLX_To_Kofiko_OutputFcn, ...
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


% --- Executes just before PLX_To_Kofiko is made visible.
function PLX_To_Kofiko_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PLX_To_Kofiko (see VARARGIN)

% Choose default command line output for PLX_To_Kofiko
handles.output = hObject;
set(handles.listbox1,'string','');
fnResetWaitbar(handles.axes1);
fnResetWaitbar(handles.axes2);

if length(varargin) == 1
  set(handles.listbox1,'string',varargin{1} );
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PLX_To_Kofiko wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = PLX_To_Kofiko_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in hConvert.
function hConvert_Callback(hObject, eventdata, handles)
acFolders = get(handles.listbox1,'string');
strctOptions.m_bSpikes = get(handles.hSpikes,'value');
strctOptions.m_bAnalog = get(handles.hAnalog,'value');
strctOptions.m_bStrobe = get(handles.hStrobe,'value');
strctOptions.m_bSync= get(handles.hSync,'value');
fnConvertPLXtoFastDataAccessRecursive(acFolders,strctOptions, handles.axes1, handles.axes2);
return;


% --- Executes on button press in hAdd.
function hAdd_Callback(hObject, eventdata, handles)
strPath = uigetdir();
if length(strPath) == 1 && strPath(1) == 0
    return;
end;
strPath = [strPath,filesep];
acOptions = get(handles.listbox1,'string');
if isempty(acOptions)
    acOptions = {strPath};
else
    acOptions = [acOptions;strPath];
end
set(handles.listbox1,'string',acOptions );
return;

% --- Executes on button press in hRemove.
function hRemove_Callback(hObject, eventdata, handles)
aiSelected = get(handles.listbox1,'value');
acOptions = get(handles.listbox1,'string');
acOptions(aiSelected) = [];
set(handles.listbox1,'string',acOptions,'value',1);

return;


% --- Executes on button press in hSpikes.
function hSpikes_Callback(hObject, eventdata, handles)
% hObject    handle to hSpikes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hSpikes


% --- Executes on button press in hAnalog.
function hAnalog_Callback(hObject, eventdata, handles)
% hObject    handle to hAnalog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hAnalog


% --- Executes on button press in hStrobe.
function hStrobe_Callback(hObject, eventdata, handles)
% hObject    handle to hStrobe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hStrobe


% --- Executes on button press in hSync.
function hSync_Callback(hObject, eventdata, handles)
% hObject    handle to hSync (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hSync
