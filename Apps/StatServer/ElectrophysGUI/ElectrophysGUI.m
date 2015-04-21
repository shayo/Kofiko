function varargout = ElectrophysGUI(varargin)
% ELECTROPHYSGUI M-file for ElectrophysGUI.fig
%      ELECTROPHYSGUI, by itself, creates a new ELECTROPHYSGUI or raises the existing
%      singleton*.
%
%      H = ELECTROPHYSGUI returns the handle to a new ELECTROPHYSGUI or the handle to
%      the existing singleton*.
%
%      ELECTROPHYSGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ELECTROPHYSGUI.M with the given input arguments.
%
%      ELECTROPHYSGUI('Property','Value',...) creates a new ELECTROPHYSGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ElectrophysGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ElectrophysGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ElectrophysGUI

% Last Modified by GUIDE v2.5 12-Jul-2013 12:13:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ElectrophysGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ElectrophysGUI_OutputFcn, ...
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


% --- Executes just before ElectrophysGUI is made visible.
function ElectrophysGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ElectrophysGUI (see VARARGIN)

% Choose default command line output for ElectrophysGUI
handles.output = hObject;


acChannelNames = varargin{1};
acGrids = varargin{2};
acAdvancerNames = varargin{3};
strDataFolder = varargin{4};


fnUpdatePrev(strDataFolder,handles);

setappdata(handles.figure1,'acGrids',acGrids);
setappdata(handles.figure1,'acChannelNames',acChannelNames);
setappdata(handles.figure1,'acAdvancerNames',acAdvancerNames);
setappdata(handles.figure1,'iCurrentParameter',1);


handles.hGridAxesMenu = uicontextmenu('Callback',{@fnMouseDownEmulator,handles});
uimenu(handles.hGridAxesMenu, 'Label', 'Toggle Active','Callback', {@fnToggleActive,handles});
uimenu(handles.hGridAxesMenu, 'Label', 'Cancel');

set(handles.figure1,'CloseRequestFcn',@CloseRequestFcn);
set(handles.figure1,'WindowButtonMotionFcn',{@fnMouseMove,handles});
set(handles.figure1,'WindowButtonDownFcn',{@fnMouseDown,handles});
fnGenAdvancerList(handles);

fnUpdateGridListBox(handles);
fnSelectGrid(handles, length(acGrids));

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ElectrophysGUI wait for user response (see UIRESUME)
uiwait(handles.figure1);

function fnGenAdvancerList(handles)
acAdvancerNames = getappdata(handles.figure1,'acAdvancerNames');
acCroppedNames = cell(1, length(acAdvancerNames)+1);
acCroppedNames{1} = 'No Advancer';
for k=1:length(acAdvancerNames)
    acCroppedNames{k+1} = sprintf('Advancer %d',k);
end
set(handles.hAdvancerListbox,'String',acCroppedNames,'value',1);

return;


function fnUpdatePrev(strDataFolder,handles)
astrctFiles = dir([strDataFolder, filesep,'*StatServerInfo.mat']);
if isempty(astrctFiles)
    set(handles.hPrevSessionsList,'visible','off');
    set(handles.hLoadFromPreviousSession,'visible','off');
else
    iNumFiles = length(astrctFiles);
    acPrevSessions = cell(1,iNumFiles);
    for k=1:iNumFiles
        acPrevSessions{k} = fullfile(strDataFolder ,astrctFiles(k).name);
    end
    setappdata(handles.figure1,'acPrevSessions',acPrevSessions);
    set(handles.hPrevSessionsList,'string', {astrctFiles(:).name},'value',iNumFiles)
end
return;


function fnMouseDownEmulator(a,b,handles)
setappdata(handles.figure1,'pt2fSavedMousePos',fnGetMouseCoordinate(handles.hGridAxes));
return;

% --- Outputs from this function are returned to the command line.
function varargout = ElectrophysGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global g_TMP
% Get default command line output from handles structure
varargout{1} = g_TMP{1};
varargout{2} = g_TMP{2};
varargout{3} = g_TMP{3};
clear global g_TMP





% --- Executes during object creation, after setting all properties.
function hPrevSessionsList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hPrevSessionsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in hGridList.
function hGridList_Callback(hObject, eventdata, handles)
iGridIndex = get(hObject,'value');
fnSelectGrid(handles, iGridIndex);

% --- Executes during object creation, after setting all properties.
function hGridList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hGridList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
    





% --- Executes during object creation, after setting all properties.
function hGuideTubeLengthEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hGuideTubeLengthEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes during object creation, after setting all properties.
function hIniitalDepthEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hIniitalDepthEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function hElectrodeTypeEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hElectrodeTypeEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox4.
function listbox4_Callback(hObject, eventdata, handles)
% hObject    handle to listbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox4


% --- Executes during object creation, after setting all properties.
function listbox4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes during object creation, after setting all properties.
function hTargetNameEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hTargetNameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function hAdvancerListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hAdvancerListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in hAddGrid.
function hAddGrid_Callback(hObject, eventdata, handles)
[strFile,strPath]=uigetfile('*.mat');
if strFile(1) == 0
    return;
end;
[~,strGridName]=fileparts(strFile);
strctTmp=load(fullfile(strPath,strFile));

acGrids = getappdata(handles.figure1,'acGrids');
iNumExistingGrids = length(acGrids);
strctTmp.strctGridModel.m_strName = strGridName;
% augument with hole information...

acChannelNames = getappdata(handles.figure1,'acChannelNames');
iNumChannels = length(acChannelNames);
iNumHoles = length(strctTmp.strctGridModel.m_afGridHolesX);
for k=1:iNumHoles
    strctTmp.strctGridModel.m_strctGridParams.m_astrctHoleInformation(k).m_strElectrodeType = '';
    strctTmp.strctGridModel.m_strctGridParams.m_astrctHoleInformation(k).m_fGuideTubeLengthMM= 0;
    strctTmp.strctGridModel.m_strctGridParams.m_astrctHoleInformation(k).m_fInitialDepthMM= 0;
    strctTmp.strctGridModel.m_strctGridParams.m_astrctHoleInformation(k).m_strTargetName= 0;

    strctTmp.strctGridModel.m_strctGridParams.m_astrctHoleInformation(k).m_abChannels = zeros(1, iNumChannels)>0;
    strctTmp.strctGridModel.m_strctGridParams.m_astrctHoleInformation(k).m_afChannelDepthOffset = zeros(1, iNumChannels);
    strctTmp.strctGridModel.m_strctGridParams.m_astrctHoleInformation(k).m_strAdvancer = '';
end
acGrids{iNumExistingGrids+1} = strctTmp.strctGridModel;

setappdata(handles.figure1,'acGrids',acGrids);
fnUpdateGridListBox(handles);
fnSelectGrid(handles, iNumExistingGrids+1);
return;

function fnSelectGrid(handles, iGridIndex)
% Draw Grid Model
if iGridIndex == 0
    set(handles.hHolePanel,'Visible','off');
    set(handles.hGridAxes,'visible','off');
    return;
end;
set(handles.hHolePanel,'Visible','on');
set(handles.hGridAxes,'visible','on');

acGrids = getappdata(handles.figure1,'acGrids');



fnPlotGrid(acGrids{iGridIndex}, handles.hGridAxes)

strctGridParams = acGrids{iGridIndex}.m_strctGridParams;

iActiveHole = find(strctGridParams.m_abSelectedHoles,1,'first');
if isempty(iActiveHole)
    set(handles.hHolePanel,'Visible','off');
else    
    fnSetActiveHole(iActiveHole, handles)
end


return;


function fnPlotGrid(strctGrid, hAxes)
cla(hAxes);
hold(hAxes,'on');
afTheta = linspace(0,2*pi,100);

plot(hAxes, cos(afTheta)* strctGrid.m_strctGridParams.m_fGridInnerDiameterMM/2,...
      sin(afTheta)* strctGrid.m_strctGridParams.m_fGridInnerDiameterMM/2,'m','LineWidth',2);
for k=1:length(strctGrid.m_afGridHolesX)
            plot(hAxes, cos(afTheta)* strctGrid.m_strctGridParams.m_fGridHoleDiameterMM/2 + strctGrid.m_afGridHolesX(k),...
      sin(afTheta)* strctGrid.m_strctGridParams.m_fGridHoleDiameterMM/2 + strctGrid.m_afGridHolesY(k),'k');
    
    if strctGrid.m_strctGridParams.m_abSelectedHoles(k) 

    plot(hAxes, strctGrid.m_afGridHolesX(k),...
      strctGrid.m_afGridHolesY(k),'m.','MarkerSize',19);

    end
end
return


% 
% function fnToggleActive(a,b,handles)
% acGrids = getappdata(handles.figure1,'acGrids');
% iSelectedGrid = get(handles.hGridList,'value');
% iSelectedHole = getappdata(handles.figure1,'iSelectedHole');
% 
% acGrids = getappdata(handles.figure1,'acGrids');
% 
%fnPlotGrid(strctGrid, hAxes)


function fnInvalidate(handles)
iSelectedGrid = get(handles.hGridList,'value');
acGrids = getappdata(handles.figure1,'acGrids');

fnPlotGrid(acGrids{iSelectedGrid}, handles.hGridAxes)
       
return;


function fnUpdateGridListBox(handles)
acGrids = getappdata(handles.figure1,'acGrids');
iNumGrids = length(acGrids);
if iNumGrids > 0
    acGridNames = cell(1,iNumGrids);
    for k=1:iNumGrids
        acGridNames{k} = acGrids{k}.m_strName;
    end
    set(handles.hGridList,'String',acGridNames,'value',iNumGrids,'visible','on');
else
    set(handles.hGridList,'String','','value',1,'visible','off');
    
end



% --- Executes during object creation, after setting all properties.
function hElectrodeTypePopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hElectrodeTypePopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function fnMouseMove(obj,eventdata,handles)
    pt2fPos = fnGetMouseCoordinate(handles.hGridAxes);
    
    iSelectedGrid = get(handles.hGridList,'value');
    acGrids = getappdata(handles.figure1,'acGrids');
    if length(acGrids) < iSelectedGrid
        return;
    end;
    
    strctGridModel = acGrids{iSelectedGrid};
   
    
    afDistToHoleMM = sqrt( (strctGridModel.m_afGridHolesX-pt2fPos(1)).^2+(strctGridModel.m_afGridHolesY-pt2fPos(2)).^2);
    [fMinDistMM, iHoleIndex] = min(afDistToHoleMM);
    
    if iscell(strctGridModel.m_strctGridParams)
        fHoleDiameterMM = fnGetGridParameter(strctGridModel.m_strctGridParams,'HoleDiam');
    else
        fHoleDiameterMM = strctGridModel.m_strctGridParams.m_fGridHoleDiameterMM;
    end
    
    if fMinDistMM <= fHoleDiameterMM
        setappdata(handles.figure1,'iMouseMoveHole',iHoleIndex);
        
        
        %strctGridModel.m_aiLocX(iHoleIndex),        strctGridModel.m_aiLocY(iHoleIndex)
        
        
        % Highlight hole !
        % [iHoleIndex,strctGridModel.m_afGridHolesX(iHoleIndex),strctGridModel.m_afGridHolesY(iHoleIndex)]
        
        hMouseMoveHole = getappdata(handles.figure1,'hMouseMoveHole');
        if isempty(hMouseMoveHole) || (~isempty(hMouseMoveHole) && ~ishandle(hMouseMoveHole))
            hMouseMoveHole = plot(handles.hGridAxes,0,0,'g','uicontextmenu', handles.hGridAxesMenu);
            setappdata(handles.figure1,'hMouseMoveHole',hMouseMoveHole);
        end;
        afTheta = linspace(0,2*pi,20);
        afCos = cos(afTheta);
        afSin = sin(afTheta);
        set(hMouseMoveHole,...
            'xdata',strctGridModel.m_afGridHolesX(iHoleIndex) + afCos*fHoleDiameterMM/2,...
            'ydata',strctGridModel.m_afGridHolesY(iHoleIndex) + afSin*fHoleDiameterMM/2,...
            'visible','on','LineWidth',2);
    else
        setappdata(handles.figure1,'iMouseMoveHole',[]);
    end
return;


function fnSetActiveHole(iSelectedHole, handles)
set(handles.hHolePanel,'Visible','on');    

iSelectedGrid = get(handles.hGridList,'value');
acGrids = getappdata(handles.figure1,'acGrids');
strctGridModel=acGrids{iSelectedGrid};
setappdata(handles.figure1,'iSelectedHole',iSelectedHole);
% Draw it...
hHoleSelected = getappdata(handles.figure1,'hHoleSelected');
if isempty(hHoleSelected) || (~isempty(hHoleSelected) && ~ishandle(hHoleSelected))
    hHoleSelected = plot(handles.hGridAxes,0,0,'r','uicontextmenu', handles.hGridAxesMenu);
    setappdata(handles.figure1,'hHoleSelected',hHoleSelected);
end;
if iscell(strctGridModel.m_strctGridParams)
    fHoleDiameterMM = fnGetGridParameter(strctGridModel.m_strctGridParams,'HoleDiam');
else
    fHoleDiameterMM = strctGridModel.m_strctGridParams.m_fGridHoleDiameterMM;
end

afTheta = linspace(0,2*pi,20);
afCos = cos(afTheta);
afSin = sin(afTheta);
set(hHoleSelected,...
    'xdata',strctGridModel.m_afGridHolesX(iSelectedHole) + afCos*fHoleDiameterMM/2,...
    'ydata',strctGridModel.m_afGridHolesY(iSelectedHole) + afSin*fHoleDiameterMM/2,...
    'visible','on','LineWidth',2);

% set(handles.hCurrentHoleText,'string', sprintf('[%s: %d, %s: %d]',strX, strctGridModel.m_aiLocX(iSelectedHole),...
%     strY, strctGridModel.m_aiLocY(iSelectedHole)));
% update information about this hole...
set(handles.hElectrodeTypeEdit,'String', strctGridModel.m_strctGridParams.m_astrctHoleInformation(iSelectedHole).m_strElectrodeType);
set(handles.hGuideTubeLengthEdit,'String', sprintf('%.2f',strctGridModel.m_strctGridParams.m_astrctHoleInformation(iSelectedHole).m_fGuideTubeLengthMM));
set(handles.hIniitalDepthEdit,'String', sprintf('%.2f',strctGridModel.m_strctGridParams.m_astrctHoleInformation(iSelectedHole).m_fInitialDepthMM));
set(handles.hTargetNameEdit,'String', strctGridModel.m_strctGridParams.m_astrctHoleInformation(iSelectedHole).m_strTargetName);


set(handles.hTargetNameEdit,'String', strctGridModel.m_strctGridParams.m_astrctHoleInformation(iSelectedHole).m_strTargetName);


% Set channel table....
acChannelNames = getappdata(handles.figure1,'acChannelNames');
iNumChannels = length(acChannelNames);
iNumCols = 3;
acColName = {'Name','Enabled','Depth Offset'};
acColFormat = {'char','logical','numeric'};
a2cData = cell(iNumChannels, iNumCols);
acRowName = cell(1,iNumChannels);
for k=1:length(a2cData)
    acRowName{k} = sprintf('Channel %d',k);
    a2cData{k,1} = acChannelNames{k};
    a2cData{k,2} = strctGridModel.m_strctGridParams.m_astrctHoleInformation(iSelectedHole).m_abChannels(k);
    a2cData{k,3} = strctGridModel.m_strctGridParams.m_astrctHoleInformation(iSelectedHole).m_afChannelDepthOffset(k);
end
set(handles.hChannelsTable,'Data',a2cData,...
    'ColumnEditable',[false true true],'ColumnFormat',...
    acColFormat,'ColumnName',acColName,'RowName',acRowName,'ColumnWidth',{60 50 80},...
    'CellEditCallback',@fnCellEditChCallback,'UserData',handles);
%

strAdvancer = acGrids{iSelectedGrid}.m_strctGridParams.m_astrctHoleInformation(iSelectedHole).m_strAdvancer;
if isempty(strAdvancer)
    set(handles.hAdvancerListbox,'value',1);
    
else
    acAdvancerNames = getappdata(handles.figure1,'acAdvancerNames');
    iInd= find(ismember(acAdvancerNames,strAdvancer));
    if ~isempty(iInd)
        % Great. found that advancer!
        set(handles.hAdvancerListbox,'value',iInd+1);
    else
        h=msgbox({'Warning. Could not find advancer previously registered to this hole!','Reseting it to no advancer!'},'Warning');
        waitfor(h);
        acGrids{iSelectedGrid}.m_strctGridParams.m_astrctHoleInformation(iSelectedHole).m_strAdvancer = [];
        set(handles.hAdvancerListbox,'value',1);
        setappdata(handles.figure1,'acGrids',acGrids);
    end
end


set(handles.hActiveHole,'value',  acGrids{iSelectedGrid}.m_strctGridParams.m_abSelectedHoles(iSelectedHole) );


return;

function fnCellEditChCallback(a,b)
iChannel = b.Indices(1,1);
handles = get(a,'UserData');
if b.Indices(1,2) == 2
    % Active/non active
        acGrids = getappdata(handles.figure1,'acGrids');
        iSelectedGrid = get(handles.hGridList,'value');
        iSelectedHole = getappdata(handles.figure1,'iSelectedHole');
        acGrids{iSelectedGrid}.m_strctGridParams.m_astrctHoleInformation(iSelectedHole).m_abChannels(iChannel) = b.NewData;
        setappdata(handles.figure1,'acGrids',acGrids);
elseif b.Indices(1,2) == 3
    % depth
        acGrids = getappdata(handles.figure1,'acGrids');
        iSelectedGrid = get(handles.hGridList,'value');
        iSelectedHole = getappdata(handles.figure1,'iSelectedHole');
        acGrids{iSelectedGrid}.m_strctGridParams.m_astrctHoleInformation(iSelectedHole).m_afChannelDepthOffset(iChannel) = b.NewData;
        setappdata(handles.figure1,'acGrids',acGrids);
    
end

return;

function fnMouseDown(obj,eventdata,handles)


strMouseClick = fnGetClickType(handles.figure1);
if strcmpi(strMouseClick,'left') || strcmpi(strMouseClick,'doubleclick')  
    iMouseMoveHole = getappdata(handles.figure1,'iMouseMoveHole');

    iSelectedGrid = get(handles.hGridList,'value');
    acGrids = getappdata(handles.figure1,'acGrids');
    
    if ~isempty(iMouseMoveHole) && ~isempty(acGrids) 
        
 
        if strcmpi(strMouseClick,'doubleclick')
            acGrids{iSelectedGrid}.m_strctGridParams.m_abSelectedHoles(iMouseMoveHole) = ~acGrids{iSelectedGrid}.m_strctGridParams.m_abSelectedHoles(iMouseMoveHole);
            setappdata(handles.figure1,'acGrids',acGrids);
            fnInvalidate(handles);
        end        
        fnSetActiveHole(iMouseMoveHole,handles)
        
    end
end
return;


function pt2fMouseDownPosition = fnGetMouseCoordinate(hAxes)
pt2fMouseDownPosition = get(hAxes,'CurrentPoint');
if size(pt2fMouseDownPosition,2) ~= 3
    pt2fMouseDownPosition = [-1 -1];
else
    pt2fMouseDownPosition = [pt2fMouseDownPosition(1,1), pt2fMouseDownPosition(1,2)];
end;
return;



% --- Executes on selection change in hAdvancerListbox.
function hAdvancerListbox_Callback(hObject, eventdata, handles)
iSelected = get(hObject,'value');
acAdvancerNames = getappdata(handles.figure1,'acAdvancerNames');

if iSelected == 1
    % No advancer
    strName = [];
else
    strName = acAdvancerNames{iSelected-1};
end

acGrids = getappdata(handles.figure1,'acGrids');
iSelectedGrid = get(handles.hGridList,'value');
iSelectedHole = getappdata(handles.figure1,'iSelectedHole');
acGrids{iSelectedGrid}.m_strctGridParams.m_astrctHoleInformation(iSelectedHole).m_strAdvancer = strName;
setappdata(handles.figure1,'acGrids',acGrids);
return;


% --- Executes on button press in hVisualAdvancerGUI.
function hVisualAdvancerGUI_Callback(hObject, eventdata, handles)
fnVisualMiceHook(false);


% --- Executes on button press in hActiveHole.
function hActiveHole_Callback(hObject, eventdata, handles)
iSelectedHole = getappdata(handles.figure1,'iSelectedHole');
if isempty(iSelectedHole)
    return;
end;

iSelectedGrid = get(handles.hGridList,'value');
acGrids = getappdata(handles.figure1,'acGrids');
    
if ~isempty(iSelectedHole) && ~isempty(acGrids) 
    acGrids{iSelectedGrid}.m_strctGridParams.m_abSelectedHoles(iSelectedHole) = get(hObject,'value');
    setappdata(handles.figure1,'acGrids',acGrids);
    fnInvalidate(handles);
end
return;



function hElectrodeTypeEdit_Callback(hObject, eventdata, handles)
iSelectedHole = getappdata(handles.figure1,'iSelectedHole');
iSelectedGrid = get(handles.hGridList,'value');
acGrids = getappdata(handles.figure1,'acGrids');
acGrids{iSelectedGrid}.m_strctGridParams.m_astrctHoleInformation(iSelectedHole).m_strElectrodeType = get(hObject,'string');
setappdata(handles.figure1,'acGrids',acGrids);
return;


    
function hGuideTubeLengthEdit_Callback(hObject, eventdata, handles)
iSelectedHole = getappdata(handles.figure1,'iSelectedHole');
iSelectedGrid = get(handles.hGridList,'value');
acGrids = getappdata(handles.figure1,'acGrids');
acGrids{iSelectedGrid}.m_strctGridParams.m_astrctHoleInformation(iSelectedHole).m_fGuideTubeLengthMM = str2num(get(hObject,'string'));
setappdata(handles.figure1,'acGrids',acGrids);
return;

function hIniitalDepthEdit_Callback(hObject, eventdata, handles)
iSelectedHole = getappdata(handles.figure1,'iSelectedHole');
iSelectedGrid = get(handles.hGridList,'value');
acGrids = getappdata(handles.figure1,'acGrids');
acGrids{iSelectedGrid}.m_strctGridParams.m_astrctHoleInformation(iSelectedHole).m_fInitialDepthMM = str2num(get(hObject,'string'));
setappdata(handles.figure1,'acGrids',acGrids);
return;

function hTargetNameEdit_Callback(hObject, eventdata, handles)
iSelectedHole = getappdata(handles.figure1,'iSelectedHole');
iSelectedGrid = get(handles.hGridList,'value');
acGrids = getappdata(handles.figure1,'acGrids');
acGrids{iSelectedGrid}.m_strctGridParams.m_astrctHoleInformation(iSelectedHole).m_strTargetName = get(hObject,'string');
setappdata(handles.figure1,'acGrids',acGrids);
return;

% --- Executes on selection change in hElectrodeTypePopup.
function hElectrodeTypePopup_Callback(hObject, eventdata, handles)

function CloseRequestFcn(a,b)
global g_TMP
acGrids = getappdata(a,'acGrids');
acAdvancerNames = getappdata(a,'acAdvancerNames');

[bOK, a2iChannelToGridHoleAdvancer,afAdvancerOffset]= fnConsistencyCheckOK(acGrids,acAdvancerNames);
if bOK
    g_TMP{1} = acGrids;
    g_TMP{2} = a2iChannelToGridHoleAdvancer;
    g_TMP{3} = afAdvancerOffset;
    delete(a);
end

function [bOK,a2iChannelToGridHoleAdvancer, afAdvancerOffset] = fnConsistencyCheckOK(acGrids,acAdvancerNames)
% Verify there is no channel overlap
iNumGrids = length(acGrids);
NumCh = 128;
a2iChannelToGridHoleAdvancer = NaN*ones(NumCh, 4); % GridIndex, HoleIndex, Advancer Index, Depth Offset, GT+Initial
bOK = false;
iNumAdvancers = length(acAdvancerNames);
afAdvancerOffset = zeros(1,iNumAdvancers);

for iGridIter=1:iNumGrids
    strctGrid = acGrids{iGridIter};
    
    aiActiveHoles = find(strctGrid.m_strctGridParams.m_abSelectedHoles);
    iNumHoles = length(aiActiveHoles);
    for iHoleIter=1:iNumHoles
        iHoleIndex = aiActiveHoles(iHoleIter);
        strctHole = strctGrid.m_strctGridParams.m_astrctHoleInformation(iHoleIndex);
        aiActiveChannels = find(strctHole.m_abChannels);
        
        if isempty(aiActiveChannels)
            strErr = sprintf('Grid %s , Hole [%d,%d] has no active channels!',strctGrid.m_strName,...
                strctGrid.m_afGridHolesX(iHoleIndex),strctGrid.m_afGridHolesY(iHoleIndex));
            h=msgbox(strErr,'ERROR!');
            waitfor(h);
            return;
        end
        
        for iChannelIter=1:length(aiActiveChannels)
            iChannelIndex = aiActiveChannels(iChannelIter);
            if ~isnan(a2iChannelToGridHoleAdvancer(iChannelIndex,1))
                iOtherGrid = a2iChannelToGridHoleAdvancer(iChannelIndex,1);
                iOtherHole = a2iChannelToGridHoleAdvancer(iChannelIndex,2);
                
                
                strErr = sprintf('Grid %s , Hole [%d,%d] occupies channel %d, but it is also shared by Grid %s, hole [%d,%d]',strctGrid.m_strName,...
                    strctGrid.m_afGridHolesX(iHoleIndex),strctGrid.m_afGridHolesY(iHoleIndex), iChannelIndex,...
                    acGrids{iOtherGrid}.m_strModelName,...
                    acGrids{iOtherGrid}.m_afGridHolesX(iOtherHole),acGrids{iOtherGrid}.m_afGridHolesY(iOtherHole));
                 h=msgbox(strErr,'ERROR!');
                 waitfor(h);
                return;
            else
                a2iChannelToGridHoleAdvancer(iChannelIndex,1) = iGridIter;
                a2iChannelToGridHoleAdvancer(iChannelIndex,2) = iHoleIndex;
                a2iChannelToGridHoleAdvancer(iChannelIndex,4) = strctHole.m_afChannelDepthOffset(iChannelIndex) + ...
                    strctHole.m_fGuideTubeLengthMM + strctHole.m_fInitialDepthMM; 

                if isempty(strctHole.m_strAdvancer)
                
                    iAdvancerIndex = NaN;
                else
                    iInd = find(ismember(acAdvancerNames,strctHole.m_strAdvancer));
                    if isempty(iInd)
                           strErr = sprintf('Grid %s , Hole [%d,%d] occupies unknown advancer!',strctGrid.m_strName,...
                                strctGrid.m_afGridHolesX(iHoleIndex),strctGrid.m_afGridHolesY(iHoleIndex));
                        h=msgbox(strErr,'ERROR!');
                        waitfor(h);
                    else
                        iAdvancerIndex = iInd;
                        afAdvancerOffset(iAdvancerIndex) = strctHole.m_fGuideTubeLengthMM + strctHole.m_fInitialDepthMM; 
                    end
                end
                
                
                a2iChannelToGridHoleAdvancer(iChannelIndex,3) = iAdvancerIndex;
            end
        end
            
    end
        
end

bOK = true;
return;


% --- Executes on selection change in hPrevSessionsList.
function hPrevSessionsList_Callback(hObject, eventdata, handles)


% --- Executes on button press in hLoadFromPreviousSession.
function hLoadFromPreviousSession_Callback(hObject, eventdata, handles)
acFiles = getappdata(handles.figure1,'acPrevSessions');
iSelected = get(handles.hPrevSessionsList,'value');
strctTmp = load(acFiles{iSelected});
if isfield(strctTmp,'g_strctNeuralServer') && isfield(strctTmp.g_strctNeuralServer,'m_acGrids') && ~isempty(strctTmp.g_strctNeuralServer.m_acGrids)
    acGrids = strctTmp.g_strctNeuralServer.m_acGrids;
    setappdata(handles.figure1,'acGrids',acGrids);
    fnUpdateGridListBox(handles);
    fnSelectGrid(handles, 1);
end

return;


% --- Executes on button press in hRemoveGrid.
function hRemoveGrid_Callback(hObject, eventdata, handles)
acGrids = getappdata(handles.figure1,'acGrids');
iGridToRemove = get(handles.hGridList,'value');
acGrids(iGridToRemove) = [];
setappdata(handles.figure1,'acGrids',acGrids);

fnUpdateGridListBox(handles);
fnSelectGrid(handles, max(0, length(acGrids)));


% --- Executes on button press in hRenameGrid.
function hRenameGrid_Callback(hObject, eventdata, handles)
acGrids = getappdata(handles.figure1,'acGrids');
if isempty(acGrids)
    return;
end;
iGridToRename = get(handles.hGridList,'value');

prompt={'Enter the matrix size for x^2:','Enter the colormap name:'};

name='';
numlines=1;
defaultanswer={acGrids{iGridToRename}.m_strModelName};
answer=inputdlg('Enter a new name',name,numlines,defaultanswer);
if ~isempty(answer)  
    acGrids{iGridToRename}.m_strModelName = answer{1};
    setappdata(handles.figure1,'acGrids',acGrids);
    fnUpdateGridListBox(handles);
end
return;
