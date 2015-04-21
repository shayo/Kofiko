function varargout = FuncAnalWrapper(varargin)
% FUNCANALWRAPPER M-file for FuncAnalWrapper.fig
%      FUNCANALWRAPPER, by itself, creates a new FUNCANALWRAPPER or raises the existing
%      singleton*.
%
%      H = FUNCANALWRAPPER returns the handle to a new FUNCANALWRAPPER or the handle to
%      the existing singleton*.
%
%      FUNCANALWRAPPER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FUNCANALWRAPPER.M with the given input arguments.
%
%      FUNCANALWRAPPER('Property','Value',...) creates a new FUNCANALWRAPPER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FuncAnalWrapper_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FuncAnalWrapper_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FuncAnalWrapper

% Last Modified by GUIDE v2.5 07-Oct-2011 11:13:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FuncAnalWrapper_OpeningFcn, ...
                   'gui_OutputFcn',  @FuncAnalWrapper_OutputFcn, ...
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


% --- Executes just before FuncAnalWrapper is made visible.
function FuncAnalWrapper_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FuncAnalWrapper (see VARARGIN)

% Choose default command line output for FuncAnalWrapper
handles.output = hObject;
[fDummy, strUser] = system('whoami');
strInputFolder= ['/space/data/',strUser(1:end-1),'/cooked/'];
setappdata(handles.figure1,'strInputFolder',strInputFolder);
fnInvalidate(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes FuncAnalWrapper wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function fnInvalidate(handles)
strInputFolder= getappdata(handles.figure1,'strInputFolder');
fnSetListWithDirectories(handles.hListbox, strInputFolder,false);



% --- Outputs from this function are returned to the command line.
function varargout = FuncAnalWrapper_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be definacParamsed in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in hListbox.
function hListbox_Callback(hObject, eventdata, handles)
% hObject    handle to hListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns hListbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hListbox

if strcmp(get(handles.figure1,'SelectionType'),'open')
    % Change folder
    strInputFolder = getappdata(handles.figure1,'strInputFolder');
    
    iSelected = get(hObject,'value');
    acAllNames= get(hObject,'string');
    
    strCurrcd=pwd();
    cd(strInputFolder);
    cd(acAllNames{iSelected});
    strNewInputFolder=pwd();
    cd(strCurrcd);
    strNewInputFolder = [strNewInputFolder,'/'];
    if exist([strNewInputFolder,'bold'],'dir')
        delete(handles.figure1);
        FuncAnal(strNewInputFolder);
        return;
    end
    setappdata(handles.figure1,'strInputFolder',strNewInputFolder);
    fnInvalidate(handles);

end


% --- Executes during object creation, after setting all properties.
function hListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function acFolders = fnGetSelectedFoldersFullName(strInputFolder,handles)
acAllFolders=get(handles.hListbox,'string');
aiSelectedFolders=get(handles.hListbox,'value');
iNumSelected = length(aiSelectedFolders);
acFolders = cell(1,iNumSelected);
for k=1:iNumSelected
    acFolders{k} = fullfile(strInputFolder,acAllFolders{aiSelectedFolders(k)},'');
end
return;


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
