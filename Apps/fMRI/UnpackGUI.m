function varargout = UnpackGUI(varargin)
% UNPACKGUI M-file for UnpackGUI.fig
%      UNPACKGUI, by itself, creates a new UNPACKGUI or raises the existing
%      singleton*.
%
%      H = UNPACKGUI returns the handle to a new UNPACKGUI or the handle to
%      the existing singleton*.
%
%      UNPACKGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UNPACKGUI.M with the given input arguments.
%
%      UNPACKGUI('Property','Value',...) creates a new UNPACKGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before UnpackGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to UnpackGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help UnpackGUI

% Last Modified by GUIDE v2.5 12-Oct-2011 19:48:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @UnpackGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @UnpackGUI_OutputFcn, ...
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


% --- Executes just before UnpackGUI is made visible.
function UnpackGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to UnpackGUI (see VARARGIN)

% Choose default command line output for UnpackGUI
handles.output = hObject;
strInputFolder= '/space/raw_data/';
setappdata(handles.figure1,'strInputFolder',strInputFolder);
set(handles.hSubmitToCluster,'value',0,'enable','off');
set(handles.hUnpackToCurrentYear,'value',0);

setappdata(handles.figure1,'bSortByDate',false);

fnInvalidate(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes UnpackGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function fnInvalidate(handles)
strInputFolder= getappdata(handles.figure1,'strInputFolder');
bSortByDate = getappdata(handles.figure1,'bSortByDate');

fnSetListWithDirectories(handles.hListbox, strInputFolder,false,bSortByDate);



% --- Outputs from this function are returned to the command line.
function varargout = UnpackGUI_OutputFcn(hObject, eventdata, handles) 
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



% --- Executes on button press in hRefreshList.
function hRefreshList_Callback(hObject, eventdata, handles)
fnInvalidate(handles);


% --- Executes on button press in hSubmitToCluster.
function hSubmitToCluster_Callback(hObject, eventdata, handles)
% hObject    handle to hSubmitToCluster (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in hUnpackToCurrentYear.
function hUnpackToCurrentYear_Callback(hObject, eventdata, handles)
% hObject    handle to hUnpackToCurrentYear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hUnpackToCurrentYear



% --- Executes on button press in uUnpackButton.
function uUnpackButton_Callback(hObject, eventdata, handles)
strInputFolder= getappdata(handles.figure1,'strInputFolder');
bSubmitToCluster  = get(handles.hSubmitToCluster,'value');
bUnpackToCurrentYear = get(handles.hUnpackToCurrentYear,'value');
acAllFolders=get(handles.hListbox,'string');
aiSelectedFolders=get(handles.hListbox,'value');

[Dummy,strCurrentUser] = system('whoami');
strCurrentUser=strCurrentUser(1:end-1);

for iIter=1:length(aiSelectedFolders)
    strSource = [strInputFolder,acAllFolders{aiSelectedFolders(iIter)}];
    if strncmpi(acAllFolders{aiSelectedFolders(iIter)},'dicom',5)
        strSession = acAllFolders{aiSelectedFolders(iIter)}(9:end);
    elseif strncmpi(acAllFolders{aiSelectedFolders(iIter)},'DYT',3)
        strSession = acAllFolders{aiSelectedFolders(iIter)}(5:end);
    else
        strSession = acAllFolders{aiSelectedFolders(iIter)};
    end
    
    if length(strSession) >= 10
        strSessionYear = acAllFolders{aiSelectedFolders(iIter)}(7:10);
    else
        strSessionYear = [];
    end
    
    if bUnpackToCurrentYear
        strYear = datestr(now,'yyyy');
    else
        if length(strSession) >= 10
            strYear = acAllFolders{aiSelectedFolders(iIter)}(7:10);
        else
            strYear = datestr(now,'yyyy');
        end;
    end
    
    strTarget = ['/space/data/',strCurrentUser,'/cooked/',strYear,'/',strSession];
    if ~exist(strTarget,'dir')
        mkdir(strTarget);
    end
    
    strTargetKofiko = ['/space/data/',strCurrentUser,'/cooked/',strYear,'/',strSession,'/kofiko'];
    if ~exist(strTargetKofiko,'dir')
        mkdir(strTargetKofiko);
    end;
    
    
    if ~isempty(strSessionYear)
        % copy kofiko files (if they are present)
        iIndex = find(strSession == '_');
        if ~isempty(iIndex)
            % multiple dicom were sent on the same session. crop postfix
            strSessionCropped=strSession(1:iIndex-1);
         strKofikoData = ['/space/raw_data/stimulation/',strSessionYear,'/20',strSessionCropped,'/'];
        
        else
            strKofikoData = ['/space/raw_data/stimulation/',strSessionYear,'/20',strSession,'/'];
        end
        if exist(strKofikoData,'dir')
            system(['cp ',strKofikoData,'* ',strTargetKofiko]);
        end
    end
            
    
    if bSubmitToCluster
        strJobsFolder = [strTarget,'/jobs'];
        if ~exist(strJobsFolder,'dir')
            mkdir(strJobsFolder);
        end;
        
        strJobUID = ['Unpack_',strSession];
        strScript = 'unpack_SO.csh';
        strInputScript = [strJobsFolder,'/',strJobUID,'.input'];
        hFileID = fopen(strInputScript,'w+');
        fprintf(hFileID,'#! /bin/csh -f\n');
        fprintf(hFileID,'echo Job %s\n',strJobUID);
        fprintf(hFileID,'setenv srcdir %s\n',strSource);
        fprintf(hFileID,'setenv targdir %s\n',strTarget);
        fclose(hFileID);
        system(['chmod 744 ',strInputScript]);
        strCommand = sprintf('qsub -V -v InputScript=%s %s -N %s -e %s -o %s', ...
            strInputScript, strScript,strJobUID,strJobsFolder,strJobsFolder);
        [Dummy, strJobID] = system(strCommand);

    % Make sure we got it submited
    bOK = Dummy == 0;
    
    if bOK
        EOL = 10;
        if strJobID(end) == EOL
            strJobID = strJobID(1:end-1);
        end;
        fprintf('Job submitted:%s\n',strJobID);
    else
        fprintf('Error submitting:\n');
        fprintf('%s\n',strJobID);
        strJobID = [];
    end
    
    else
        strCommand = ['$FREESURFER_HOME/lib/tcltktixblt/bin/tclsh8.4 unpacksdcmdir_SO.tcl -src ',strSource,' -targ ',strTarget,' -seqcfg CIT_FS_cfg -fsfast -sphinx'];
        system(strCommand)
        fprintf('Done Unpacking!\n');
    end
    
   
end


% --- Executes on button press in hSortByDate.
function hSortByDate_Callback(hObject, eventdata, handles)
setappdata(handles.figure1,'bSortByDate', get(hObject,'value'));
fnInvalidate(handles);
