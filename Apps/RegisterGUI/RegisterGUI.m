function varargout = RegisterGUI(varargin)
% REGISTERGUI M-file for RegisterGUI.fig
%      REGISTERGUI, by itself, creates a new REGISTERGUI or raises the existing
%      singleton*.
%
%      H = REGISTERGUI returns the handle to a new REGISTERGUI or the handle to
%      the existing singleton*.
%
%      REGISTERGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in REGISTERGUI.M with the given input arguments.
%
%      REGISTERGUI('Property','Value',...) creates a new REGISTERGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RegisterGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RegisterGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RegisterGUI

% Last Modified by GUIDE v2.5 18-Aug-2011 11:09:02

% Begin initialization code - DO NOT EDIT

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RegisterGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @RegisterGUI_OutputFcn, ...
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


% --- Executes just before RegisterGUI is made visible.
function RegisterGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to RegisterGUI (see VARARGIN)

% Choose default command line output for RegisterGUI


% Read from the XML file various config information (DAQ, GUI, paradigms, ...)
if ~exist('.\Config\RegisterGUI.xml','file')
    try
        delete(1);
    catch
    end
    fprintf('Cannot find register GUI configuration file (.\\Config\\RegisterGUI.xml), Aborting!\n');
    return;
end;

strctConfig = fnLoadRegisterXML('.\Config\RegisterGUI.xml');

% Identify Rig-specific configuraiton files...
astrctConfigFiles = dir('.\Config\KofikoConfigForDifferentRigs\*.xml');
if isempty(astrctConfigFiles)
    delete(1);
    fprintf('Cannot find any rig-specific configuration files under (.\\Config\\KofikoConfigForDifferentRigs\\), Aborting!\n');
    return;
end;
iNumConfigFiles = length(astrctConfigFiles);
acNames = cell(1,iNumConfigFiles);
for k=1:iNumConfigFiles
    [Dummy,acNames{k}] = fileparts(astrctConfigFiles(k).name);
end

iDefaultRig = 1;
iDefaultMonkey = 1;
setappdata(handles.figure1,'astrctConfigFiles',astrctConfigFiles);

if exist('.\Config\KofikoConfigForDifferentRigs\RegisterGUICache.mat','file');
    strctTmp = load('.\Config\KofikoConfigForDifferentRigs\RegisterGUICache.mat');
    if isfield(strctTmp,'strctPreviousSettings')
        iIndexMonkey = find(ismember({strctConfig.m_astrctMonkey.m_strName}, strctTmp.strctPreviousSettings.m_strDefaultMonkey));
        if ~isempty(iIndexMonkey)
            iDefaultMonkey = iIndexMonkey;
        end
        iIndexRig= find(ismember(lower({astrctConfigFiles.name}), lower(strctTmp.strctPreviousSettings.m_strDefaultRig)));
        if ~isempty(iIndexRig)
            iDefaultRig = iIndexRig;
        end
    end
end

set(handles.hRigConfiguration,'String',acNames,'value', iDefaultRig);

handles.output = hObject;
setappdata(handles.figure1,'iSelectedMonkey',iDefaultMonkey);
setappdata(handles.figure1,'strctConfig',strctConfig);


fnInvalidateMonkeyImages(handles);


drawnow
% set(handles.figure1,'WindowButtonMotionFcn',{@fnMouseMove,handles});
% set(handles.figure1,'WindowButtonDownFcn',{@fnMouseDown,handles});
% set(handles.figure1,'WindowButtonUpFcn',{@fnMouseUp,handles});

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes RegisterGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);
% 
% function fnMouseMove(obj,eventdata, handles)
% Tmp = get(handles.hGridAxes,'CurrentPoint');
% Tmp = Tmp([1,3]);
% aiRect = axis(handles.hGridAxes);
% if Tmp(1) >= aiRect(1) && Tmp(1) <= aiRect(2) && Tmp(2) >= aiRect(3) && Tmp(2) <= aiRect(4) 
%     % Mouse is in grid axes
% end
% return;


function strMouseClick = fnGetClickType(handles)
global g_strctWindows
strMouseType = get(handles.figure1,'selectiontype');
if (strcmp( strMouseType,'alt'))
    strMouseClick = 'Right';
end;
if (strcmp( strMouseType,'normal'))
    strMouseClick = 'Left';
end;
if (strcmp( strMouseType,'extend'))
    strMouseClick = 'Both';
end;
if (strcmp( strMouseType,'open'))
    strMouseClick = 'DoubleClick';
end;
return;


function fnInvalidateMonkeyImages(handles)
iSelectedMonkey = getappdata(handles.figure1,'iSelectedMonkey');
strctConfig = getappdata(handles.figure1,'strctConfig');

hold(handles.axes2,'off');
image([],[],strctConfig.m_astrctMonkey(iSelectedMonkey).m_a2iImage,'parent',handles.axes2);
hold(handles.axes2,'on');

aiRect = axis(handles.axes2);
plot(handles.axes2,[aiRect(1) aiRect(2)],[aiRect(3) aiRect(3)],'r','LineWidth',3)
plot(handles.axes2,[aiRect(1) aiRect(2)],[aiRect(4) aiRect(4)],'r','LineWidth',3)
plot(handles.axes2,[aiRect(1) aiRect(1)],[aiRect(3) aiRect(4)],'r','LineWidth',3)
plot(handles.axes2,[aiRect(2) aiRect(2)],[aiRect(3) aiRect(4)],'r','LineWidth',3)

set(handles.hMonkey2Name,'String',strctConfig.m_astrctMonkey(iSelectedMonkey).m_strName);
%handles.
iPrevMonkey = iSelectedMonkey-1;
if iPrevMonkey == 0
    iPrevMonkey = length(strctConfig.m_astrctMonkey);
end
iNextMonkey = iSelectedMonkey+1;
if iNextMonkey >length(strctConfig.m_astrctMonkey)
    iNextMonkey  = 1;
end;

image([],[],strctConfig.m_astrctMonkey(iPrevMonkey).m_a2iImage,'parent',handles.axes1);
set(handles.hMonkey1Name,'String',strctConfig.m_astrctMonkey(iPrevMonkey).m_strName);

image([],[],strctConfig.m_astrctMonkey(iNextMonkey).m_a2iImage,'parent',handles.axes3);
set(handles.hMonkey3Name,'String',strctConfig.m_astrctMonkey(iNextMonkey).m_strName);

set(handles.axes1,'visible','off')
set(handles.axes2,'visible','off')
set(handles.axes3,'visible','off')

return;


function strctConfig =  fnLoadRegisterXML(strConfigurationFile)
tree = xmltree(strConfigurationFile);
q=1;

for k=1:length(tree)
    strctRoot=get(tree,k);
    if isfield(strctRoot,'name') && strcmpi(strctRoot.name,'Monkeys') 
        aiMonkeyList = strctRoot.contents;
        iNumMonkeys = length(aiMonkeyList);
        for j=1:iNumMonkeys
            strctMonkey=get(tree,aiMonkeyList(j));
            if isfield(strctMonkey,'attributes')
                strctConfig.m_astrctMonkey(q).m_strName = strctMonkey.attributes{1}.val;
                strctConfig.m_astrctMonkey(q).m_a2iImage = imread(strctMonkey.attributes{2}.val);
                q=q+1;
            end;
        end
    end
end
return;

% --- Outputs from this function are returned to the command line.
function varargout = RegisterGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end




% --- Executes on button press in hStartKofiko.
function hStartKofiko_Callback(hObject, eventdata, handles)
global g_strLogFileName

astrctRigConfigFiles = getappdata(handles.figure1,'astrctConfigFiles');
iSelectedRig = get(handles.hRigConfiguration,'value');
iSelectedMonkey = getappdata(handles.figure1,'iSelectedMonkey');
strctConfig = getappdata(handles.figure1,'strctConfig');

fNow = now;
strTmp = datestr(fNow,25);
strDate = strTmp([1,2,4,5,7,8]);
strTmp = datestr(fNow,13);
strTime =  strTmp([1,2,4,5,7,8]);


strctPreviousSettings.m_strDefaultMonkey = strctConfig.m_astrctMonkey(iSelectedMonkey).m_strName;
strctPreviousSettings.m_strDefaultRig = astrctRigConfigFiles(iSelectedRig).name;
try
    save('.\Config\KofikoConfigForDifferentRigs\RegisterGUICache.mat','strctPreviousSettings');
catch
    fprintf('Cannot write to RegisterGUICache\n');
end

try
    strRigConfigFile = ['.\Config\KofikoConfigForDifferentRigs\',astrctRigConfigFiles(iSelectedRig).name];
strctRigConfig = fnLoadConfigXML(strRigConfigFile);
catch
    fprintf('Crashed parsing XML file (%s). Aborting\n',strRigConfigFile);
    return;
end

strLogFileName = [strctRigConfig.m_strctDirectories.m_strLogFolder,strDate,'_',strTime,'_',strctConfig.m_astrctMonkey(iSelectedMonkey).m_strName,'.txt'];
[strPath,strFile]=fileparts(strLogFileName);

set(handles.hStartKofiko,'enable','off');
h=msgbox({'Please start a plexon recording file with the following name:',strFile});
uiwait(h);
drawnow
set(handles.hStartKofiko,'enable','on');
strctRegisterConfig.m_strctMonkeyInfo.m_strName = strctConfig.m_astrctMonkey(iSelectedMonkey).m_strName;
strctRegisterConfig.m_strLogFileName = strLogFileName;
Kofiko(strRigConfigFile,strctRegisterConfig);

return;

% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
iSelectedMonkey = getappdata(handles.figure1,'iSelectedMonkey');
strctConfig = getappdata(handles.figure1,'strctConfig');

iSelectedMonkey = iSelectedMonkey + 1;

if iSelectedMonkey <= 0
    iSelectedMonkey = length(strctConfig.m_astrctMonkey);
end
if iSelectedMonkey >length(strctConfig.m_astrctMonkey)
    iSelectedMonkey  = 1;
end;
setappdata(handles.figure1,'iSelectedMonkey',iSelectedMonkey );
fnInvalidateMonkeyImages(handles)
return;


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
iSelectedMonkey = getappdata(handles.figure1,'iSelectedMonkey');
strctConfig = getappdata(handles.figure1,'strctConfig');

iSelectedMonkey = iSelectedMonkey - 1;

if iSelectedMonkey <= 0
    iSelectedMonkey = length(strctConfig.m_astrctMonkey);
end
if iSelectedMonkey >length(strctConfig.m_astrctMonkey)
    iSelectedMonkey  = 1;
end;
setappdata(handles.figure1,'iSelectedMonkey',iSelectedMonkey );
fnInvalidateMonkeyImages(handles)
return;


% --- Executes on button press in hTouchScreenMode.
function hTouchScreenMode_Callback(hObject, eventdata, handles)
% hObject    handle to hTouchScreenMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hTouchScreenMode


% --- Executes on selection change in hRigConfiguration.
function hRigConfiguration_Callback(hObject, eventdata, handles)
% hObject    handle to hRigConfiguration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns hRigConfiguration contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hRigConfiguration


% --- Executes during object creation, after setting all properties.
function hRigConfiguration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hRigConfiguration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in hModify.
function hModify_Callback(hObject, eventdata, handles)

astrctRigConfigFiles = getappdata(handles.figure1,'astrctConfigFiles');
iSelectedRig = get(handles.hRigConfiguration,'value');
system(['notepad ',which(astrctRigConfigFiles(iSelectedRig).name)])