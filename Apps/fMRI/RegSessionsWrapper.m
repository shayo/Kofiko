function varargout = RegSessionsWrapper(varargin)
% REGSESSIONSWRAPPER M-file for RegSessionsWrapper.fig
%      REGSESSIONSWRAPPER, by itself, creates a new REGSESSIONSWRAPPER or raises the existing
%      singleton*.
%
%      H = REGSESSIONSWRAPPER returns the handle to a new REGSESSIONSWRAPPER or the handle to
%      the existing singleton*.
%
%      REGSESSIONSWRAPPER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in REGSESSIONSWRAPPER.M with the given input arguments.
%
%      REGSESSIONSWRAPPER('Property','Value',...) creates a new REGSESSIONSWRAPPER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RegSessionsWrapper_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RegSessionsWrapper_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RegSessionsWrapper

% Last Modified by GUIDE v2.5 07-Oct-2011 13:34:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RegSessionsWrapper_OpeningFcn, ...
                   'gui_OutputFcn',  @RegSessionsWrapper_OutputFcn, ...
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


% --- Executes just before RegSessionsWrapper is made visible.
function RegSessionsWrapper_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to RegSessionsWrapper (see VARARGIN)

% Choose default command line output for RegSessionsWrapper
handles.output = hObject;
[fDummy, strUser] = system('whoami');
strInputFolder= ['/space/data/',strUser(1:end-1),'/cooked/'];
setappdata(handles.figure1,'strInputFolderLeft',strInputFolder);
setappdata(handles.figure1,'strInputFolderRight',strInputFolder);

fnInvalidate(handles,true,true);
fnInvalidateLeftBottom(handles);
fnInvalidateRightBottom(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes RegSessionsWrapper wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function fnInvalidate(handles,bLeft,bRight,bKeepSelected)
if bLeft
    strInputFolderLeft= getappdata(handles.figure1,'strInputFolderLeft');
    acLeft=fnSetListWithDirectories(handles.hSourceList, strInputFolderLeft,false);
    setappdata(handles.figure1,'acLeft',acLeft);
end

if bRight
strInputFolderRight= getappdata(handles.figure1,'strInputFolderRight');
acRight =fnSetListWithDirectories(handles.hTargetList, strInputFolderRight,false);
setappdata(handles.figure1,'acRight',acRight);
end
return;

function fnInvalidateLeftBottom(handles)
   % Check for existance of mri and bold folders
   strInputFolderLeft = getappdata(handles.figure1,'strInputFolderLeft');

    acLeft = getappdata(handles.figure1,'acLeft');
    iSelected = get(handles.hSourceList,'value');
     if exist([strInputFolderLeft,acLeft{iSelected},'/mri'],'dir')
            strAnatomicalSourceExist = 'on';
    else
            strAnatomicalSourceExist = 'off';
    end

    if exist([strInputFolderLeft,acLeft{iSelected},'/bold'],'dir')
            strFunctionalSourceExist = 'on';
    else
            strFunctionalSourceExist = 'off';
    end
    set(handles.hSrcAnat,'enable',strAnatomicalSourceExist);
    set(handles.hSrcFunc,'enable',strFunctionalSourceExist);
    
    bValue = get(handles.hSrcAnat,'value');
    if bValue
       % Anatomical 
        acAvailFiles=fnGetAllFilesRecursive([strInputFolderLeft,acLeft{iSelected},'/mri'],{'*.nii','*.mgz','*.mgh'}, 1);

    else
        % Functional
        acAvailFiles=fnGetAllFilesRecursive([strInputFolderLeft,acLeft{iSelected},'/bold'],{'*.nii'}, 1);
    end
    set(handles.hAvailSrcVol,'string',acAvailFiles,'value',1);
    
    dbg = 1;


% --- Outputs from this function are returned to the command line.
function varargout = RegSessionsWrapper_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be definacParamsed in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in hSourceList.
function hSourceList_Callback(hObject, eventdata, handles)
strInputFolderLeft = getappdata(handles.figure1,'strInputFolderLeft');

if strcmp(get(handles.figure1,'SelectionType'),'open')
    % Change folder
    iSelected = get(hObject,'value');
    acAllNames= get(hObject,'string');
    strCurrcd=pwd();
    cd(strInputFolderLeft);
    cd(acAllNames{iSelected});
    strNewInputFolder=pwd();
    cd(strCurrcd);
    strNewInputFolder = [strNewInputFolder,'/'];
    if exist([strNewInputFolder,'bold'],'dir')
        return;
    end
    setappdata(handles.figure1,'strInputFolderLeft',strNewInputFolder);
    fnInvalidate(handles,true,false);
    fnInvalidateLeftBottom(handles);
elseif strcmp(get(handles.figure1,'SelectionType'),'normal')
    fnInvalidateLeftBottom(handles);
end


% --- Executes during object creation, after setting all properties.
function hSourceList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hSourceList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function fnInvalidateRightBottom(handles)
    strInputFolderRight = getappdata(handles.figure1,'strInputFolderRight');

   % Check for existance of mri and bold folders
   acRight = getappdata(handles.figure1,'acRight');
    iSelected = get(handles.hTargetList,'value');
    if exist([strInputFolderRight,acRight{iSelected},'/mri'],'dir')
            strAnatomicalTargetExist = 'on';
            
            
    else
            strAnatomicalTargetExist = 'off';
    end

    if exist([strInputFolderRight,acRight{iSelected},'/bold'],'dir')
            strFunctionalTargetExist = 'on';
    else
            strFunctionalTargetExist = 'off';
    end
    set(handles.hTargAnat,'enable',strAnatomicalTargetExist);
    set(handles.hTargFunc,'enable',strFunctionalTargetExist);
    
    
   
    bValue = get(handles.hTargAnat,'value');
    if bValue
       % Anatomical 
        acAvailFiles=fnGetAllFilesRecursive([strInputFolderRight,acRight{iSelected},'/mri'],{'*.nii','*.mgz','*.mgh'}, 1);

    else
        % Functional
        acAvailFiles=fnGetAllFilesRecursive([strInputFolderRight,acRight{iSelected},'/bold'],{'*.nii'}, 1);
    end
    set(handles.hAvailTargVol,'string',acAvailFiles,'value',1);
        
    dbg = 1;
    
% --- Executes on selection change in hTargetList.
function hTargetList_Callback(hObject, eventdata, handles)
strInputFolderRight = getappdata(handles.figure1,'strInputFolderRight');

if strcmp(get(handles.figure1,'SelectionType'),'open')
    % Change folder
    iSelected = get(hObject,'value');
    acAllNames= get(hObject,'string');
    strCurrcd=pwd();
    cd(strInputFolderRight);
    cd(acAllNames{iSelected});
    strNewInputFolder=pwd();
    cd(strCurrcd);
    strNewInputFolder = [strNewInputFolder,'/'];
    if exist([strNewInputFolder,'bold'],'dir')
        return;
    end
    setappdata(handles.figure1,'strInputFolderRight',strNewInputFolder);
    fnInvalidate(handles,false,true);
elseif strcmp(get(handles.figure1,'SelectionType'),'normal')
    fnInvalidateRightBottom(handles);
end

% --- Executes during object creation, after setting all properties.
function hTargetList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hTargetList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hRegName_Callback(hObject, eventdata, handles)
dbg = 1;


% --- Executes during object creation, after setting all properties.
function hRegName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hRegName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in hAvailSrcVol.
function hAvailSrcVol_Callback(hObject, eventdata, handles)
% hObject    handle to hAvailSrcVol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns hAvailSrcVol contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hAvailSrcVol


% --- Executes during object creation, after setting all properties.
function hAvailSrcVol_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hAvailSrcVol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in hAvailTargVol.
function hAvailTargVol_Callback(hObject, eventdata, handles)
% hObject    handle to hAvailTargVol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns hAvailTargVol contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hAvailTargVol


% --- Executes during object creation, after setting all properties.
function hAvailTargVol_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hAvailTargVol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in hRegister.
function hRegister_Callback(hObject, eventdata, handles)
strInputFolderRight = getappdata(handles.figure1,'strInputFolderRight');
strInputFolderLeft = getappdata(handles.figure1,'strInputFolderLeft');

acLeft=get(handles.hSourceList,'string');
strSessionLeft = acLeft{get(handles.hSourceList,'value')};

acRight=get(handles.hTargetList,'string');
strSessionRight = acRight{get(handles.hTargetList,'value')};

acSources=get(handles.hAvailSrcVol,'String');
iSelectedSource = get(handles.hAvailSrcVol,'value');

acTargets=get(handles.hAvailTargVol,'String');
iSelectedTarget = get(handles.hAvailTargVol,'value');
if get(handles.hSrcAnat,'value')
    strPrefixLeft = 'mri/';
else
    strPrefixLeft = 'bold/';
end
if get(handles.hTargAnat,'value')
    strPrefixRight = 'mri/';
else
    strPrefixRight = 'bold/';
end


strMove = [strInputFolderLeft,strSessionLeft,'/',strPrefixLeft,acSources{iSelectedSource}];
strStationary = [strInputFolderRight,strSessionRight,'/',strPrefixRight,acTargets{iSelectedTarget}];

if  ~exist([strInputFolderRight,strSessionRight,'/reg'],'dir')
    mkdir([strInputFolderRight,strSessionRight,'/reg']);
end;

if  ~exist([strInputFolderLeft,strSessionLeft,'/reg'],'dir')
    mkdir([strInputFolderLeft,strSessionLeft,'/reg']);
end;

strSrc = acSources{iSelectedSource};
strSrc(strSrc == '/') = '_';
strSrc=strSrc(1:end-4);

strTarg = acTargets{iSelectedTarget};
strTarg(strTarg== '/') = '_';
strTarg=strTarg(1:end-4);

strRegFile = [strInputFolderLeft,strSessionLeft,'/reg/',strSessionLeft,'_',strSrc,'_To_',strSessionRight,'_',strTarg,'.reg'];
strRegInvFile = [strInputFolderRight,strSessionRight,'/reg/',strSessionRight,'_',strSrc,'_To_',strSessionLeft,'_',strTarg,'.reg'];

if ~exist(strRegFile,'file')
    strCmd = ['tkregister2 --targ ',strStationary,' --mov ',strMove,' --reg ',strRegFile,' --regheader'];
else
    strCmd = ['tkregister2 --targ ',strStationary,' --mov ',strMove,' --reg ',strRegFile];
end
system(strCmd);
% invert & copy to other folder as well...
if exist(strRegFile,'file')
    [T,strSubjectName, strVolType,afVoxelSpacing] = fnReadRegisteration(strRegFile);
   fnWriteRegisteration(strRegInvFile,inv(T),strSubjectName, strVolType,afVoxelSpacing);
end

return;

% --- Executes when selected object is changed in uipanel3.
function uipanel3_SelectionChangeFcn(hObject, eventdata, handles)
fnInvalidateLeftBottom(handles);
% --- Executes when selected object is changed in uipanel4.
function uipanel4_SelectionChangeFcn(hObject, eventdata, handles)
fnInvalidateRightBottom(handles);
