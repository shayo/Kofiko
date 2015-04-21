function varargout = DataBrowser(varargin)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

% DATABROWSER M-file for DataBrowser.fig
%      DATABROWSER, by itself, creates a new DATABROWSER or raises the existing
%      singleton*.
%
%      H = DATABROWSER returns the handle to a new DATABROWSER or the handle to
%      the existing singleton*.
%
%      DATABROWSER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DATABROWSER.M with the given input arguments.
%
%      DATABROWSER('Property','Value',...) creates a new DATABROWSER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DataBrowser_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DataBrowser_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DataBrowser

% Last Modified by GUIDE v2.5 17-Jul-2013 10:32:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @DataBrowser_OpeningFcn, ...
    'gui_OutputFcn',  @DataBrowser_OutputFcn, ...
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


% --- Executes just before DataBrowser is made visible.
function DataBrowser_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DataBrowser (see VARARGIN)
global g_strDataBrowserSavedSessionFile
dbstop if error

% Choose default command line output for DataBrowser
handles.output = hObject;
fnOpenPanels(1);
strctConfig = fnMyXMLToStruct(fullfile('.', 'Config', 'DataBrowser.xml'));
setappdata(handles.figure1,'strctConfig',strctConfig);

% Update menus.
fnUpdateMenus(handles);


% strAttributesListfile = fullfile('.', 'Config', 'DataBrowserAttr.mat');
% if exist(strAttributesListfile,'file')
%     load(strAttributesListfile);
%     setappdata(handles.figure1,'acActiveAttributes',acActiveAttributes);
%     setappdata(handles.figure1,'acAllAttributes',acAllAttributes);
% else
%     setappdata(handles.figure1,'acAllAttributes',{'TimeDate','Subject','Target','Channel','Unit','Paradigm','List'});
%     setappdata(handles.figure1,'acActiveAttributes',{'TimeDate','Subject','Target','Channel','Unit','Paradigm','List'});
% end


%%



%%
setappdata(handles.figure1,'iCurrPanel',1);
guidata(hObject, handles);

g_strDataBrowserSavedSessionFile = 'C:\DataBrowserSavedSession.mat';
if exist(g_strDataBrowserSavedSessionFile,'file')
    try
        strctTmp = load(g_strDataBrowserSavedSessionFile);
        acDates = fnCellStructToArray(strctTmp.acSessions,'m_strTimeDate');
        afDateNum = zeros(1,length(acDates));
        for k=1:length(acDates)
            afDateNum(k) = datenum(acDates{k});
        end
        [Dummy, aiIndex]=sort(afDateNum,2,'ascend');
        setappdata(handles.figure1,'acSessions',strctTmp.acSessions(aiIndex));
        fnInvalidateSessionList(handles);
        
        
    catch
        
    end
    
end
set(handles.figure1,'visible','on');
drawnow


setappdata(handles.figure1,'aiSelectedRaw',[]);

fnModifyTable(handles)

%
% set(handles.hRawTable,'CellSelectionCallback',@fnRawSelection,'UserData',handles);
fnResetWaitbar(handles.hListenAxes);
fnInvalidateDataEntries(handles);
set(handles.figure1,'CloseRequestFcn',@fnMyClose)

return;



function fnOpenPanels(hFig)
iNumPanels = 8;
handles.hFigurePanel = figure(hFig);
handles.hDisplayPanel = uipanel('parent',handles.hFigurePanel);
aiPos = get(handles.hDisplayPanel,'Position');
strUnits = get(handles.hDisplayPanel,'Units');
hParent = get(handles.hDisplayPanel,'Parent');
strctUserData.m_ahPanels = zeros(1,iNumPanels );

strctUserData.m_iActivePanel = 1;
strctUserData.m_ahPanels(1) = handles.hDisplayPanel;
for k=2:iNumPanels
    strctUserData.m_ahPanels(k) = uipanel('units',strUnits,'Position',aiPos,'Visible','off','Parent',hParent);
end;
set(handles.hFigurePanel,'UserData',strctUserData);
set(handles.hFigurePanel,'toolbar','figure');
set(handles.hFigurePanel,'WindowScrollWheelFcn',{@fnMouseWheel,handles});

set(handles.hFigurePanel,'KeyPressFcn',@fnKeyDown);
%set(handles.figure1,'KeyReleaseFcn',@fnKeyUp);
if hFig == 1
    set(handles.hFigurePanel,'CloseRequestFcn',@fnDontClose)
end
return;

function fnDontClose(src,evnt)
return;


function fnKeyDown(obj,eventdata)
strctUserData = get(obj,'UserData');
switch eventdata.Key
    case 'rightarrow'
        strctUserData.m_iActivePanel = strctUserData.m_iActivePanel + 1;
        if strctUserData.m_iActivePanel> length(strctUserData.m_ahPanels)
            strctUserData.m_iActivePanel = 1;
        end
        
        for k=1:length(strctUserData.m_ahPanels)
            if strctUserData.m_iActivePanel  == k
                set(strctUserData.m_ahPanels(k),'visible','on');
            else
                set(strctUserData.m_ahPanels(k),'visible','off');
            end;
        end;
        set(obj,'UserData',strctUserData);
    case 'leftarrow'
        strctUserData.m_iActivePanel = strctUserData.m_iActivePanel - 1;
        if strctUserData.m_iActivePanel <= 0
            strctUserData.m_iActivePanel = length(strctUserData.m_ahPanels);
        end
        
        for k=1:length(strctUserData.m_ahPanels)
            if strctUserData.m_iActivePanel  == k
                set(strctUserData.m_ahPanels(k),'visible','on');
            else
                set(strctUserData.m_ahPanels(k),'visible','off');
            end;
        end;
        set(obj,'UserData',strctUserData);
end

return;


function fnMyClose(src,evnt)
try
    delete(1);
catch
    
end
delete(gcf);

return;

% UIWAIT makes DataBrowser wait for user response (see UIRESUME)
% uiwait(handles.figure1);




function fnModifyTable(handles)
warning off
hJTable1 = fnGetJavaHandle(handles.hRawTable);
hJTable2 = fnGetJavaHandle(handles.hDataTable);
% ,,@fnRawSelection,@SortRawTable);
% fnModifyTable(handles,handles.hDataTable,@fnDataSelection,@SortDataTable);

try
    % new matlab version (> 2013?)
    set(hJTable1,'DoubleBuffered',1);
catch
    % Older matlab versions...
    set(hJTable1,'DoubleBuffered','on');
end

hJTable1.setNonContiguousCellSelection(false);
hJTable1.setColumnSelectionAllowed(false);
hJTable1.setRowSelectionAllowed(true);

hJTable1tmp = handle(hJTable1, 'CallbackProperties');
    set(hJTable1tmp, 'MousePressedCallback', {@fnRawSelection, handles});
    set(hJTable1tmp, 'MouseDraggedCallback', {@fnRawSelection, handles});
    set(hJTable1tmp, 'KeyPressedCallback', {@fnRawSelection, handles});
try
    set(hJTable1.getTableHeader,'MousePressedCallback',{@SortRawTable,handles});
catch
    
end


try
    set(hJTable2,'DoubleBuffered',1);
catch
    set(hJTable2,'DoubleBuffered','on');
end

%set(jscroll,'DoubleBuffered',1);

hJTable2.setNonContiguousCellSelection(false);
hJTable2.setColumnSelectionAllowed(false);
hJTable2.setRowSelectionAllowed(true);

% hJTable = handle(hJTable, 'CallbackProperties');

hJTable2Tmp = handle(hJTable2, 'CallbackProperties');
set(hJTable2Tmp, 'MousePressedCallback', {@fnDataSelection, handles});
set(hJTable2Tmp, 'MouseDraggedCallback', {@fnDataSelection, handles});
set(hJTable2Tmp, 'KeyPressedCallback', {@fnDisplayEntries, handles});
try
    set(hJTable2.getTableHeader,'MousePressedCallback',{@SortDataTable,handles});
catch
end

setappdata(handles.figure1,'hJTable1',hJTable1);
setappdata(handles.figure1,'hJTable2',hJTable2);

warning on
return;

function SortRawTable(hObject,strctTmp,handles)
X=get(handles.hRawTable,'ColumnWidth');
aiRange = cumsum([0;cat(1,X{:})])';
x=get(strctTmp,'X');
iSelected = find(x >= aiRange,1,'last');


return;


function fnDataSelection(hObject,strctTmp,handles)
aiSelected = get(hObject,'SelectedRows')+1;
setappdata(handles.figure1,'aiSelectedData',aiSelected);
if ~isempty(aiSelected)
    set(handles.hProcessedPipelinesMenuCallback,'enable','on');
else
    set(handles.hProcessedPipelinesMenuCallback,'enable','off');
end
return;


function fnDisplayEntries(hObject,strctTmp,handles)
acDisplayedEntries = getappdata(handles.figure1,'acDisplayedEntries');
aiSelected = get(hObject,'SelectedRows')+1;
setappdata(handles.figure1,'aiSelectedData',aiSelected);

%aiSelected = getappdata(handles.figure1,'aiSelectedData');
strctTmp2 = get(strctTmp);

if double(strctTmp2.KeyChar(1)) == 32
    
    for iDataIter=1:length(aiSelected)
        iSelectedEntry = aiSelected(iDataIter);
        
        if exist(acDisplayedEntries{iSelectedEntry}.m_strFile,'file')
            strctData = load(acDisplayedEntries{iSelectedEntry}.m_strFile);
        else
            fnRemoveEntry(handles,acDisplayedEntries{iSelectedEntry}.m_strFile);
            continue;
        end
        
        if strctTmp2.Modifiers == 1 && iDataIter == 1
            hFig = figure;
        else
            hFig = figure(iDataIter);
        end
        [Dummy,strShortFile]=fileparts(acDisplayedEntries{iSelectedEntry}.m_strFile);
        
        
        set(hFig,'Name',strShortFile);
        
        strctUserData = get(hFig,'UserData');
        
        try
            for k=1:length(strctUserData.m_ahPanels)
                delete(get(strctUserData.m_ahPanels(k),'children'));
                set(strctUserData.m_ahPanels(k),'Title','');
            end;
        catch
            fnOpenPanels(hFig);
            strctUserData = get(hFig,'UserData');
            
        end
        
        try
            acFields = fieldnames(strctData);
            strctDataField = getfield(strctData,acFields{1});
            if isfield(strctDataField,'m_strDisplayFunction')
                fprintf('calling %s\n',strctDataField.m_strDisplayFunction);
                feval(strctDataField.m_strDisplayFunction ,strctUserData.m_ahPanels, strctDataField);
            else
                fprintf('m_strDisplayFunction is missing from data entry.  Don''t know how to display this data entry\n');
            end
            figure(handles.figure1);
        catch
            fprintf('Error evaluating %s\n',strctDataField.m_strDisplayFunction);
        end
    end
end
%fnInvalidateDataEntries(handles);
return;


function fnRemoveEntry(handles, strFile)
return;




function fnRawSelection(hObject,strctTmp,handles)
aiSelected = get(hObject,'SelectedRows')+1;
setappdata(handles.figure1,'aiSelectedRaw',aiSelected);

fnInvalidateDataEntries(handles);
return;

function fnInvalidateDataEntries(handles)
aiSelected = getappdata(handles.figure1,'aiSelectedRaw');

acSessions = getappdata(handles.figure1,'acSessions');
if isempty(acSessions)
    return;
end;
iNumEntries = 0;
abSessionHasData = zeros(1,length(aiSelected))>0;
for iIter=1:length(aiSelected)
    if isfield(acSessions{aiSelected(iIter)},'acDataEntries') && ~isempty(acSessions{aiSelected(iIter)}.acDataEntries)
        iNumEntries  = iNumEntries+length(acSessions{aiSelected(iIter)}.acDataEntries);
        abSessionHasData(iIter)=true;
    end
end

iCounter = 1;
acDisplayedEntries = cell(0);
acDisplayedAlready = cell(0);
for iSessionIter=find(abSessionHasData)
    for iDataEntryIter=1:length(acSessions{aiSelected(iSessionIter)}.acDataEntries)
        if ismember(acSessions{aiSelected(iSessionIter)}.acDataEntries{iDataEntryIter}.m_strFile,acDisplayedAlready)
            continue;
        end;
        acDisplayedAlready = [acDisplayedAlready,acSessions{aiSelected(iSessionIter)}.acDataEntries{iDataEntryIter}.m_strFile];
        acDisplayedEntries{iCounter} = acSessions{aiSelected(iSessionIter)}.acDataEntries{iDataEntryIter};
        iCounter=iCounter+1;
    end
end

set(handles.hProcessedPipelinesMenuCallback,'enable','off');
setappdata(handles.figure1,'acDisplayedEntries',acDisplayedEntries);
 fnInvalidateDataEntriesAux(handles);
return;

function fnInvalidateDataEntriesAux(handles)
acDisplayedEntries = getappdata(handles.figure1,'acDisplayedEntries');

acAllAttributes = [];
% Build attributes from the highlighted sessions...
acFileNames = cell(0);
for iDataEntryIter=1:length(acDisplayedEntries)
    if ~isempty(acDisplayedEntries{iDataEntryIter}.m_a2cAttributes)
        acAllAttributes = [acAllAttributes,acDisplayedEntries{iDataEntryIter}.m_a2cAttributes(1,:)];
    end
end

acAttributes=unique(acAllAttributes);
if isempty(acAttributes)
    acAttributes = {};
end
% Prioritize certain attributes.
acPrioritize ={'Subject','TimeDate','Channel','Unit','Paradigm','List','Design'};
acAttributes=[acPrioritize(ismember(acPrioritize,intersect(acAttributes, acPrioritize))), setdiff(acAttributes,acPrioritize)];
iNumRows = length(acDisplayedEntries);
iNumColumns = length(acAttributes);

a2cData = cell(iNumRows,iNumColumns);
for iDataEntryIter=1:iNumRows
    for iAttrIter=1:length(acAttributes)
        [bAttributeExist, strValue] = fnFindAttribute(acDisplayedEntries{iDataEntryIter}.m_a2cAttributes, acAttributes{iAttrIter});
        if bAttributeExist
            a2cData{iDataEntryIter,iAttrIter} = strValue;
        else
            a2cData{iDataEntryIter,iAttrIter} = 'N/A';
        end
    end
end
set(handles.hDataTable,'Data',a2cData,'ColumnName',acAttributes,'columnWidth',{150});
return;


% --- Outputs from this function are returned to the command line.
function varargout = DataBrowser_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

function fnInvalidateSelectedUnitsList(handles)
aiSelectedUnits = getappdata(handles.figure1,'aiSelectedUnits');
acUnits = getappdata(handles.figure1,'acUnits');
fnInvalidateUnitsListAux(handles.hUnitList2,acUnits(aiSelectedUnits))
return;


function strFolder = fnGetDefaultSearchFolder(handles)
strctConfig = getappdata(handles.figure1,'strctConfig');
if exist(strctConfig.m_strctDirectories.m_strDataFolder,'dir')
    strFolder = strctConfig.m_strctDirectories.m_strDataFolder;
elseif (isfield(strctConfig.m_strctDirectories,'m_strAlternativeDataFolder') && exist(strctConfig.m_strctDirectories.m_strAlternativeDataFolder,'dir'))
    strFolder = strctConfig.m_strctDirectories.m_strAlternativeDataFolder;
else
    strFolder = '.';
end
return;


% --------------------------------------------------------------------
function hAddFolder_Callback(hObject, ~, handles)
strDefualtSearchFolder = fnGetDefaultSearchFolder(handles);
strPath = uigetdir(strDefualtSearchFolder);

[bRawFolder, acKofikoFile, acSessionInfo] = fnIsRawFolder({strPath},handles.hListenAxes);

if bRawFolder
    iNumSameDaySessions = length(acKofikoFile{1});
    for iInDayIter=1:iNumSameDaySessions
        fnAddSession(handles,acSessionInfo{1}{iInDayIter});
    end;
end
return;

% --------------------------------------------------------------------
function hAddFolderRec_Callback(hObject, eventdata, handles)
global g_prev
if isempty(g_prev)
    strDefualtSearchFolder = fnGetDefaultSearchFolder(handles);
    g_prev = strDefualtSearchFolder;
end
strPath = uigetdir(g_prev);
if strPath(1) == 0
    return;
end;
g_prev = strPath;
acAllFolders = fnMyParseDirs(fnMyGenPath(strPath));

fnResetWaitbar(handles.hListenAxes)
[abRawFolder, acKofikoFile, acSessionInfo] = fnIsRawFolder(acAllFolders,handles.hListenAxes);
for iDayIter=1:length(abRawFolder)
    if abRawFolder(iDayIter)
        iNumSameDaySessions = length(acKofikoFile{iDayIter});
        for iInDayIter=1:iNumSameDaySessions
            if ~isempty(acSessionInfo{iDayIter}{iInDayIter})
                fnAddSession(handles,acSessionInfo{iDayIter}{iInDayIter});
            end
        end;
    end
end

fnSaveDataBrowserConf(handles);
return;

function fnSaveDataBrowserConf(handles)
global g_strDataBrowserSavedSessionFile
acSessions = getappdata(handles.figure1,'acSessions');
save(g_strDataBrowserSavedSessionFile,'acSessions','-V6');
return;



% --------------------------------------------------------------------
function hRemoveSession_Callback(hObject, eventdata, handles)
aiSelectedRaw = getappdata(handles.figure1,'aiSelectedRaw');
acSessions = getappdata(handles.figure1,'acSessions');
if isempty(acSessions)
    return;
end;
acSessions(aiSelectedRaw) = [];
aiSelected = 1:length(acSessions);
setappdata(handles.figure1,'aiSelectedRaw',aiSelected);
setappdata(handles.figure1,'acSessions',acSessions);
fnInvalidateSessionList(handles);
fnInvalidateDataEntries(handles);
save('C:\DataBrowserSavedSession.mat','acSessions');

return;



function fnInvalidate(handles, bUpperList)
if bUpperList
    aiSelected = get(handles.hUnitsList,'value');
else
    aiSelectedUnits = getappdata(handles.figure1,'aiSelectedUnits');
    if isempty(aiSelectedUnits)
        
        return;
    end;
    aiSelected = aiSelectedUnits(get(handles.hUnitList2,'value'));
end;

acUnits = getappdata(handles.figure1,'acUnits');
if isempty(acUnits)
    return;
end;
if length(aiSelected) == 1
    for k=1:length(handles.ahPanels)
        delete(get(handles.ahPanels(k),'children'));
        set(handles.ahPanels(k),'Title','');
    end;
    try
        if ~isfield(acUnits{aiSelected},'m_strDisplayFunction')
            fprintf('Missing field how to display this unit????\n');
        else
            feval(acUnits{aiSelected}.m_strDisplayFunction,handles.ahPanels,acUnits{aiSelected});
        end
    catch
        fprintf('DISPLAY FUNCTION CRASHED! (%s)\n',acUnits{aiSelected}.m_strDisplayFunction);
        %       edit(acUnits{aiSelected}.m_strDisplayFunction);
    end
else
    for k=1:length(handles.ahPanels)
        delete(get(handles.ahPanels(k),'children'));
    end;
    
end;
return;

% --- Executes on selection change in hUnitsList.
function hUnitsList_Callback(hObject, eventdata, handles)
fnInvalidate(handles,true);
return;

% --- Executes during object creation, after setting all properties.
function hUnitsList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hUnitsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Untitled_1_Callback(hObject, eventdata, handles)
return;

% --- Executes on selection change in hRecordedSessionsList.
function hRecordedSessionsList_Callback(hObject, eventdata, handles)
return;

% --- Executes during object creation, after setting all properties.
function hRecordedSessionsList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hRecordedSessionsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function hAddSession_Callback(hObject, eventdata, handles)
strDefualtSearchFolder = fnGetDefaultSearchFolder(handles);
[strFile,strPath] = uigetfile(fullfile(strDefualtSearchFolder,'*.mat'));
if strFile(1) == 0
    return;
end;
try
    [bValid,strctInfo] = fnGetSessionInformation(fullfile(strPath,strFile));
    fnAddSession(handles,strctInfo);
catch
    fprintf('Error adding session!\n');
end




return;



function fnAddSession(handles, strctSession)
acSessions = getappdata(handles.figure1,'acSessions');

% Make sure we do not duplicate sessions!
iNumSessions = length(acSessions);

for k=1:iNumSessions
    if strcmpi(acSessions{k}.m_strTimeDate,strctSession.m_strTimeDate) && ...
            strcmpi(acSessions{k}.m_strSubject,strctSession.m_strSubject)
        fprintf('Session %s : %s already exist. Skipping!\n',strctSession.m_strTimeDate,strctSession.m_strSubject);
        return;
    end
end
fprintf('Adding %s\n',strctSession.m_strTimeDate);
acSessions{iNumSessions+1} = strctSession;

setappdata(handles.figure1,'acSessions',acSessions);
fnInvalidateSessionList(handles);
return;


function fnInvalidateSessionList(handles)
acSessions = getappdata(handles.figure1,'acSessions');

iNumSessions = length(acSessions);
acParadigms=[];
for iIter=1:iNumSessions
    acParadigms = [acParadigms,acSessions{iIter}.m_acParadigms];
end
acParadigms=setdiff(unique(acParadigms),{'Default'});
iNumParadigms = length(acParadigms);

acColumnNames = {'Time Date','Subject','Num Channels',acParadigms{:}};
iNumColumns = length(acColumnNames);
a2cData = cell(iNumSessions, iNumColumns);
for iIter=1:iNumSessions
    
    a2cData{iIter,1} = acSessions{iIter}.m_strTimeDate;
    a2cData{iIter,2} = acSessions{iIter}.m_strSubject;
    a2cData{iIter,3} = acSessions{iIter}.m_iNumRecordedChannels;
    for iParadigmIter=1:iNumParadigms
        a2cData{iIter,3+iParadigmIter} = ~isempty(intersect(acSessions{iIter}.m_acParadigms,acParadigms{iParadigmIter}));
    end
end

Tmp = cell(1,iNumColumns);
Tmp{1} = 140;
Tmp{2} = 100;
Tmp{3} = 100;
for k=4:iNumColumns
    Tmp{k} = 120;
end

set(handles.hRawTable,'data',a2cData,'ColumnName',acColumnNames,'ColumnWidth',Tmp);
return;




% --------------------------------------------------------------------
function hSaveSessionList_Callback(hObject, eventdata, handles)
strDefualtSearchFolder = fnGetDefaultSearchFolder(handles);
[strFile, strPath] = uiputfile(fullfile(strDefualtSearchFolder,'SessionList.mat'));
if strFile(1) == 0
    return;
end;
acSessions = getappdata(handles.figure1,'acSessions');
save([strPath,strFile],'acSessions');
return;


% --------------------------------------------------------------------
function hCollectUnitStatisticsAdd_Callback(hObject, eventdata, handles)
aiSelectedSessions = get(handles.hRecordedSessionsList,'value');
fnCollectUnitStatistics(handles,aiSelectedSessions, true);
return;


% --------------------------------------------------------------------
function Untitled_10_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
% function hSortByParadigmType_Callback(hObject, eventdata, handles)
% acUnits = getappdata(handles.figure1,'acUnits');
% aiSelectedUnits = getappdata(handles.figure1,'aiSelectedUnits');
% if isempty(aiSelectedUnits)
%     return;
% end;
% iNumUnits = length(acUnits);
% aiType = zeros(1,iNumUnits);
% for k=1:iNumUnits
%     switch acUnits{k}.m_strImageListDescrip
%         case 'FOB'
%             aiType(k) = 0;
%         case 'Sinha'
%             aiType(k) = 1;
%         otherwise
%             aiType(k) = 2;
%     end;
% end;
% [afDummy, aiSortedIndices] = sort(aiType);
% acUnits = acUnits(aiSortedIndices);
% aiSelectedUnits = aiSortedIndices(aiSelectedUnits);
% setappdata(handles.figure1,'aiSelectedUnits',aiSelectedUnits);
% setappdata(handles.figure1,'acUnits',acUnits);
% fnInvalidateUnitsList(handles);
% fnInvalidateSelectedUnitsList(handles);
% return;


% --------------------------------------------------------------------
function hLoadSession_Callback(hObject, eventdata, handles)
strctConfig = getappdata(handles.figure1,'strctConfig');
strDefualtSearchFolder = fnGetDefaultSearchFolder(handles);
[strFile,strPath] = uigetfile(fullfile(strDefualtSearchFolder,'*.mat'));
if strFile(1) == 0
    return;
end;
strctTmp = load([strPath,strFile]);
acSessions = strctTmp.acSessions;

setappdata(handles.figure1,'acSessions',acSessions);
fnInvalidateSessionList(handles);
return;






function fnMouseWheel(a,b,handles)
aiMousePos = get(handles.hFigurePanel,'CurrentPoint');
set(handles.hDisplayPanel,'Units','pixels')
aiDisplayRect = get(handles.hDisplayPanel,'Position');
set(handles.hDisplayPanel,'Units','normalized')
if ~(aiMousePos(1) >=    aiDisplayRect(1) && ...
        aiMousePos(2) >= aiDisplayRect(2) && ...
        aiMousePos(1) <= aiDisplayRect(1)+aiDisplayRect(3) && ...
        aiMousePos(2) <= aiDisplayRect(2)+aiDisplayRect(4))
    
    return;
end;
%
% hFig = a;
% iCurrPanel = getappdata(handles.figure1,'iCurrPanel');
% iNumPanels = getappdata(handles.figure1,'iNumPanels');
% iCurrPanel = iCurrPanel + b.VerticalScrollCount;
% if iCurrPanel > iNumPanels
%     iCurrPanel  = 1;
% end;
% if iCurrPanel <= 0
%     iCurrPanel  = iNumPanels;
% end;
%
% setappdata(handles.figure1,'iCurrPanel',iCurrPanel);
% for k=1:iNumPanels
%     if iCurrPanel == k
%         set(handles.ahPanels(k),'visible','on');
%     else
%         set(handles.ahPanels(k),'visible','off');
%     end;
% end;
return;

% --- Executes on button press in hPrevPanel.
function hPrevPanel_Callback(hObject, eventdata, handles)
iCurrPanel = getappdata(handles.figure1,'iCurrPanel');
iNumPanels = getappdata(handles.figure1,'iNumPanels');
iCurrPanel = iCurrPanel - 1;
if iCurrPanel <= 0
    iCurrPanel  = iNumPanels;
end;
setappdata(handles.figure1,'iCurrPanel',iCurrPanel);
for k=1:iNumPanels
    if iCurrPanel == k
        set(handles.ahPanels(k),'visible','on');
    else
        set(handles.ahPanels(k),'visible','off');
    end;
end;

return;

% --- Executes on button press in hNextPanel.
function hNextPanel_Callback(hObject, eventdata, handles)
iCurrPanel = getappdata(handles.figure1,'iCurrPanel');
iNumPanels = getappdata(handles.figure1,'iNumPanels');
iCurrPanel = iCurrPanel + 1;
if iCurrPanel > iNumPanels
    iCurrPanel  = 1;
end;
setappdata(handles.figure1,'iCurrPanel',iCurrPanel);

for k=1:iNumPanels
    if iCurrPanel == k
        set(handles.ahPanels(k),'visible','on');
    else
        set(handles.ahPanels(k),'visible','off');
    end;
end;

return;


% --- Executes on selection change in hUnitList2.
function hUnitList2_Callback(hObject, eventdata, handles)
fnInvalidate(handles,false);
return;


% --- Executes during object creation, after setting all properties.
function hUnitList2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hUnitList2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function hRemoveSelectedUnits_Callback(hObject, eventdata, handles)
acUnits = getappdata(handles.figure1,'acUnits');
if isempty(acUnits)
    return;
end;
aiUnits = get(handles.hUnitsList,'value');
acUnits(aiUnits) = [];
setappdata(handles.figure1,'acUnits',acUnits);


aiSelectedUnits = getappdata(handles.figure1,'aiSelectedUnits');
aiSelectedUnits = setdiff(aiSelectedUnits,aiUnits);
setappdata(handles.figure1,'aiSelectedUnits',aiSelectedUnits);
fnInvalidateSelectedUnitsList(handles);
fnInvalidateUnitsList(handles);
fnInvalidate(handles,true);
return;



% --------------------------------------------------------------------
function hSortByTimeDate_Callback(hObject, eventdata, handles)
acUnits = getappdata(handles.figure1,'acUnits');
aiSelectedUnits = getappdata(handles.figure1,'aiSelectedUnits');
afTime = zeros(1,length(acUnits));
for k=1:length(acUnits)
    afTime(k) = datenum(acUnits{k}.m_strRecordedTimeDate);
end
[afDummy,aiIndices ] = sort(afTime);

acUnits = acUnits(aiIndices);
aiSelectedUnits = aiIndices(aiSelectedUnits);

setappdata(handles.figure1,'acUnits',acUnits);
setappdata(handles.figure1,'aiSelectedUnits',aiSelectedUnits);
fnInvalidateUnitsList(handles);
fnInvalidateSelectedUnitsList(handles);

return;



% --------------------------------------------------------------------
function hSaveSelected_Callback(hObject, eventdata, handles)
strFolder = fnGetDefaultSearchFolder(handles);
[strFile, strPath] = uiputfile(fullfile(strFolder,'SelectedUnitsList.mat'));
if strFile(1) == 0
    return;
end;

acUnits = getappdata(handles.figure1,'acUnits');
aiSelectedUnits = getappdata(handles.figure1,'aiSelectedUnits');

for k=1:length(aiSelectedUnits)
    astrctUnitInfo(k).m_strRecordedTimeDate = acUnits{aiSelectedUnits(k)}.m_strRecordedTimeDate;
    astrctUnitInfo(k).m_iRecordedSession = acUnits{aiSelectedUnits(k)}.m_iRecordedSession;
    astrctUnitInfo(k).m_iChannel = acUnits{aiSelectedUnits(k)}.m_iChannel;
    astrctUnitInfo(k).m_iUnitID = acUnits{aiSelectedUnits(k)}.m_iUnitID;
end
save([strPath,strFile],'astrctUnitInfo');
return;


% --------------------------------------------------------------------
function hLoadSelected_Callback(hObject, eventdata, handles)
strctConfig = getappdata(handles.figure1,'strctConfig');
strFolder = fnGetDefaultSearchFolder(handles);

%strDefualtSearchFolder = strctConfig.m_strctDirectories.m_strUnitsFolder;
[strFile, strPath] = uigetfile(fullfile(strFolder,'UnitList.mat'));
if strFile(1) == 0
    return;
end;
strctTmp = load([strPath,strFile]);
if ~isfield(strctTmp,'astrctUnitInfo')
    msgbox('Wrong file format');
    return;
end;

acUnits = getappdata(handles.figure1,'acUnits');
abSelected = zeros(1, length(acUnits)) > 0;
for k=1:length(strctTmp.astrctUnitInfo)
    for j=1:length(acUnits)
        if strcmp(strctTmp.astrctUnitInfo(k).m_strRecordedTimeDate, acUnits{(j)}.m_strRecordedTimeDate) &&  ...
                length( strctTmp.astrctUnitInfo(k).m_iRecordedSession ) == length(acUnits{(j)}.m_iRecordedSession ) && ...
                all(strctTmp.astrctUnitInfo(k).m_iRecordedSession == acUnits{(j)}.m_iRecordedSession) && ...
                all(strctTmp.astrctUnitInfo(k).m_iChannel == acUnits{(j)}.m_iChannel) && ...
                all(strctTmp.astrctUnitInfo(k).m_iUnitID == acUnits{(j)}.m_iUnitID)
            abSelected(j) = 1;
        end
    end
end

setappdata(handles.figure1,'aiSelectedUnits',find(abSelected));
fnInvalidateSelectedUnitsList(handles);
return;


% -----
% --------------------------------------------------------------------
function hUnitsMenu_Callback(hObject, eventdata, handles)
% hObject    handle to hUnitsMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --------------------------------------------------------------------
function LoadAndOverride_Callback(hObject, eventdata, handles)
fnLoadAux(handles, true);
return;

% --------------------------------------------------------------------
function hLoadUnits_Callback(hObject, eventdata, handles)
fnLoadAux(handles, false);
return;

function fnLoadAux(handles, bOverride)
strctConfig = getappdata(handles.figure1,'strctConfig');
strDefualtSearchFolder = fnGetDefaultSearchFolder(handles);

[strFile,strPath] = uigetfile(fullfile(strDefualtSearchFolder ,'Units.mat'),'MultiSelect', 'on');
if ~iscell(strFile)
    if strFile(1) == 0
        return;
    else
        strFile = {strFile};
    end;
end

acUnits= getappdata(handles.figure1,'acUnits');

if bOverride
    acUnits = cell(0);
    iUnitCounter = 1;
else
    iUnitCounter = length(acUnits)+1;
end;
%%
cla(handles.hListenAxes);
set(handles.hListenAxes,'Color','k','Xlim',[0 1],'YLim',[0 1],'YTick',[],'XTick',[]);

for iFileIter=1:length(strFile)
    fprintf('[%d / %d] Loading %s\n',iFileIter, length(strFile),strFile{iFileIter});
    rectangle('Position',[0 0 iFileIter/(length(strFile)+1)  1], 'Parent',handles.hListenAxes,'FaceColor','r');
    drawnow
    strctTmp = load([strPath,strFile{iFileIter}]);
    if isfield(strctTmp,'acUnits')
        for k=1:length(strctTmp.acUnits)
            acUnits{iUnitCounter} = strctTmp.acUnits{k};
            iUnitCounter = iUnitCounter + 1;
        end
    elseif isfield(strctTmp,'strctUnit')
        acUnits{iUnitCounter} = strctTmp.strctUnit;
        iUnitCounter = iUnitCounter + 1;
    elseif isfield(strctTmp,'strctStatistics')
        acUnits{iUnitCounter} = strctTmp.strctStatistics;
        iUnitCounter = iUnitCounter + 1;
    else
        fprintf('Don''t know how to handle this file type\n');
    end
    
end
%%

setappdata(handles.figure1,'acUnits',acUnits);
setappdata(handles.figure1,'aiSelectedUnits',[]);

fnInvalidateUnitsList(handles);
fnInvalidateSelectedUnitsList(handles);
fnInvalidate(handles,true);
return;

% --------------------------------------------------------------------
function hSaveMultiple_Callback(hObject, eventdata, handles)
acUnits = getappdata(handles.figure1,'acUnits');
strDefualtSearchFolder = fnGetDefaultSearchFolder(handles);
strPath = uigetdir(strDefualtSearchFolder);

cla(handles.hListenAxes);
set(handles.hListenAxes,'Color','k','Xlim',[0 1],'YLim',[0 1],'YTick',[],'XTick',[]);

for iUnitIter=1:length(acUnits)
    rectangle('Position',[0 0 iUnitIter/length(acUnits)  1], 'Parent',handles.hListenAxes,'FaceColor','r');
    strctUnit = acUnits{iUnitIter};
    if isfield(strctUnit,'m_iRecordedSession')
        strctUnit = acUnits{iUnitIter};
        strTimeDate = datestr(datenum(strctUnit.m_strRecordedTimeDate),31);
        strTimeDate(strTimeDate == ':') = '-';
        strTimeDate(strTimeDate == ' ') = '_';
        
        strParadigm = strctUnit.m_strParadigm;
        strParadigm(strParadigm == ' ') = '_';
        strDesr = strctUnit.m_strParadigmDesc;
        strDesr(strDesr == ' ') = '_';
        strUnitName = sprintf('%s_%s_Exp_%02d_Ch_%03d_Unit_%03d_%s_%s',...
            strctUnit.m_strSubject, strTimeDate,strctUnit.m_iRecordedSession,...
            strctUnit.m_iChannel(1),strctUnit.m_iUnitID(1), strParadigm, strDesr);
        strOutputFilename = fullfile(strPath, [strUnitName,'.mat']);
        fprintf('[%d/%d] Saving %s...',iUnitIter,length(acUnits),strUnitName);
        save(strOutputFilename,  'strctUnit');
        fprintf('Done!\n');
    else
        strctStatistics = acUnits{iUnitIter};
        strTimeDate = datestr(datenum(strctStatistics.m_strRecordedTimeDate),31);
        strTimeDate(strTimeDate == ':') = '-';
        strTimeDate(strTimeDate == ' ') = '_';
        strParadigm = strctStatistics.m_strParadigm;
        strParadigm(strParadigm == ' ') = '_';
        strDesr = strctStatistics.m_strParadigmDesc;
        strDesr(strDesr == ' ') = '_';
        
        strUnitName = sprintf('%s_%s_Behavior_%s_%s',...
            strctUnit.m_strSubject, strTimeDate, strParadigm, strDesr);
        strOutputFilename = fullfile(strPath, [strUnitName,'.mat']);
        fprintf('[%d/%d] Saving %s...',iUnitIter,length(acUnits),strUnitName);
        
        save(strOutputFilename,  'strctStatistics');
        fprintf('Done!\n');
    end
    drawnow update
    drawnow
end

% afTime = zeros(1,length(acUnits));
% for k=1:length(acUnits)
%     afTime(k) = datenum(acUnits{k}.m_strRecordedTimeDate);
% end
% [afDummy,aiIndices ] = sort(afTime);
% strStart = acUnits{aiIndices(1)}.m_strRecordedTimeDate;
% strEnd = acUnits{aiIndices(end)}.m_strRecordedTimeDate;
% strProposedName = [strStart(1:11),'_Until_',strEnd(1:11)]

% --------------------------------------------------------------------
function hSaveUnitsList_Callback(hObject, eventdata, handles)
strDefualtSearchFolder = fnGetDefaultSearchFolder(handles);
[strFile,strPath] = uiputfile(fullfile(strDefualtSearchFolder,'Units.mat'));

if strFile(1) == 0
    return;
end;
acUnits = getappdata(handles.figure1,'acUnits');
aiSelectedUnits = getappdata(handles.figure1,'aiSelectedUnits');
fprintf('Saving... This might take some time....');
save([strPath,strFile],'acUnits','aiSelectedUnits','-v7.3');
fprintf('Done!\n');
return;



% --------------------------------------------------------------------
function hRawAnalyzeOnCluster_Callback(hObject, eventdata, handles)
acSessions = getappdata(handles.figure1,'acSessions');
if isempty(acSessions)
    return;
end
aiSelectedSessions = get(handles.hRecordedSessionsList,'value');
strctConfig = fnMyXMLToStruct(fullfile('.', 'Config', 'SessionBrowser.xml'));
% Make sure cluster support is installed
switch lower(strctConfig.m_strctDistributedAnalysis.m_strClusterType)
    case 'condor'
        if ~exist([strctConfig.m_strctDistributedAnalysis.m_strClusterBinaries,'condor_q.exe'],'file')
            h=msgbox('Could not find cluster executable');
            waitfor(h);
            return;
        end
    otherwise
        error('Unknown cluster type');
end
SubmitJobGUI(strctConfig,acSessions(aiSelectedSessions));

return;


function fnPopulationCallback(hObject, Tmp, handles,iSelection)
strctConfig = getappdata(handles.figure1,'strctConfig');

aiSelectedUnits = getappdata(handles.figure1,'aiSelectedUnits');
if isempty(aiSelectedUnits)
    h=msgbox('Your list for population is empty!\n');
    waitfor(h)
    return;
end;

aiSelectedDown = get(handles.hUnitList2,'value');
acUnits = getappdata(handles.figure1,'acUnits');

try
    feval(strctConfig.m_strctPopulationAnalysis.m_acAnalysis{iSelection}.m_strFunc,acUnits(aiSelectedUnits(aiSelectedDown)),...
        strctConfig.m_strctPopulationAnalysis.m_acAnalysis{iSelection},handles);
catch
    
    feval(strctConfig.m_strctPopulationAnalysis.m_acAnalysis{iSelection}.m_strFunc,acUnits(aiSelectedUnits(aiSelectedDown)),...
        strctConfig.m_strctPopulationAnalysis.m_acAnalysis{iSelection});
end


return;


% --------------------------------------------------------------------
function hPLXtoKofiko_Callback(hObject, eventdata, handles)
acSessions = getappdata(handles.figure1,'acSessions');
aiSelectedRaw = getappdata(handles.figure1,'aiSelectedRaw');
acPaths = cell(0);
for iIter=1:length(aiSelectedRaw)
    strPath = fileparts(acSessions{aiSelectedRaw(iIter)}.m_strKofikoFullFilename);
    if strPath(end) ~= filesep()
        strPath(end+1) = filesep();
    end;
    acPaths{iIter} = strPath;
end
PLX_To_Kofiko(acPaths);
hScanForData_Callback(hObject, eventdata, handles);
return;



% --------------------------------------------------------------------
function hOfflineSpikeSorting_Callback(hObject, eventdata, handles)
acSessions = getappdata(handles.figure1,'acSessions');
aiSelectedRaw = getappdata(handles.figure1,'aiSelectedRaw');
for k=1:length(aiSelectedRaw)
    [strP,strF]=fileparts(acSessions{aiSelectedRaw(k)}.m_strKofikoFullFilename);
    SpikeSorter(acSessions{aiSelectedRaw(k)}.m_strKofikoFullFilename);
end;
return;

% --------------------------------------------------------------------
function hScanForData_Callback(hObject, eventdata, handles)
acSessions = getappdata(handles.figure1,'acSessions');
aiSelectedRaw = getappdata(handles.figure1,'aiSelectedRaw');
fnResetWaitbar(handles.hListenAxes);
fprintf('Scanning for data entries...\n');
% acCheckedFolder = cell(0);
for iIter=1:length(aiSelectedRaw)
    %    [Dummy1, acSessions{aiSelectedRaw(iIter)}] = fnGetSessionInformation(acSessions{aiSelectedRaw(iIter)}.m_strKofikoFullFilename);
    [strPath,strFile] = fileparts(acSessions{aiSelectedRaw(iIter)}.m_strKofikoFullFilename);
    %     if ismember(strPath,acCheckedFolder)
    %         continue;
    %     end;
    %     acCheckedFolder = [acCheckedFolder,strPath];
    acSessions{aiSelectedRaw(iIter)}.acDataEntries = fnScanForData(acSessions{aiSelectedRaw(iIter)}.m_strKofikoFullFilename);
    fnSetWaitbar(handles.hListenAxes, iIter/length(aiSelectedRaw));
end
setappdata(handles.figure1,'acSessions',acSessions);

fnUpdateAllAttributes(handles);

fnSaveDataBrowserConf(handles);
fnResetWaitbar(handles.hListenAxes);
fnInvalidateSessionList(handles);
fnInvalidateDataEntries(handles);
fprintf('Done!...\n');
return;


function acDataEntrires = fnScanForData(strKofikoFullFilename)
acDataEntrires = cell(0);

strPath = fileparts(strKofikoFullFilename);
% Assume that if there is data, it will be under ../Processed
if exist(fullfile(strPath,['..',filesep],'Processed'),'dir')
    strProcessedRoot = fullfile(strPath,['..',filesep],'Processed');
elseif exist(fullfile(strPath,['..',filesep],'processed'),'dir')
    strProcessedRoot = fullfile(strPath,['..',filesep],'processed');
else
    % No processed data found!
    return;
end

acFiles = fnGetAllFilesRecursive(strProcessedRoot, '.mat');
% Read files....
iCounter = 1;
for iFileIter=1:length(acFiles)
    strctTmp = load(acFiles{iFileIter});
    strctDataEntry.m_strFile = acFiles{iFileIter};
    try
        acFieldNames = fieldnames(strctTmp); % assume only one field ?
        strctData = getfield(strctTmp,acFieldNames{1});
        if  isfield(strctData,'m_a2cAttributes')
            strctDataEntry.m_a2cAttributes = strctData.m_a2cAttributes;
        else
            strctDataEntry.m_a2cAttributes = [];
        end
    catch
        strctDataEntry.m_a2cAttributes = [];
    end
    acDataEntrires{iCounter} = strctDataEntry;
    iCounter=iCounter+1;
end

return;



% --- Executes on button press in hRemoveFromDown.
function hRemoveFromDown_Callback(hObject, eventdata, handles)
aiSelectedUnits = getappdata(handles.figure1,'aiSelectedUnits');
aiSelected = get(handles.hUnitList2,'value');
if isempty(aiSelectedUnits)
    return;
end;
aiSelectedUnits = setdiff(aiSelectedUnits,aiSelectedUnits(aiSelected));
setappdata(handles.figure1,'aiSelectedUnits',aiSelectedUnits);
fnInvalidateSelectedUnitsList(handles);
return;


function fnPipelineCallback(a,b,strAnalysisEntryPoint, handles, bOnCluster)
global g_hWaitBar
acSessions = getappdata(handles.figure1,'acSessions');
aiSelectedRaw = getappdata(handles.figure1,'aiSelectedRaw');


if bOnCluster
    % Compile & Submit
else
    strConfigFolder = [pwd(),filesep,'Config',filesep];
    g_hWaitBar = handles.hListenAxes;
    fnResetWaitbar(g_hWaitBar);
    
    for k=1:length(aiSelectedRaw)
        fnSetWaitbarGlobal(k/length(aiSelectedRaw),1, 3);
        [strP,strSession]= fileparts(acSessions{aiSelectedRaw(k)}.m_strKofikoFullFilename);
        % Assume there is the "RAW" folder, and we want the one above it...
        if strP(end) == filesep()
            iIndex = find(strP(1:end-1) == filesep(),1,'last');
        else
            iIndex = find(strP == filesep(),1,'last');
        end
        strDataRootFolder = strP(1:iIndex);
        strctInputs.m_strDataRootFolder = strDataRootFolder;
        strctInputs.m_strConfigFolder   =strConfigFolder;
        strctInputs.m_strSession = strSession;
        fprintf('Launching %s...\n',strAnalysisEntryPoint);
        feval(strAnalysisEntryPoint, strctInputs);
        
        %         [Dummy1, acSessions{aiSelectedRaw(k)}] = fnGetSessionInformation(acSessions{aiSelectedRaw(k)}.m_strKofikoFullFilename);
        acSessions{aiSelectedRaw(k)}.acDataEntries = fnScanForData(acSessions{aiSelectedRaw(k)}.m_strKofikoFullFilename);
        
    end;
end

setappdata(handles.figure1,'acSessions',acSessions);
fnSaveDataBrowserConf(handles);
fnResetWaitbar(handles.hListenAxes);
fnInvalidateSessionList(handles);
fnInvalidateDataEntries(handles);

fprintf('Done!\n');
return;


function SortDataTable(hObject,strctTmp,handles)

function fnUpdateAllAttributes(handles)
acAllAttributes = getappdata(handles.figure1,'acAllAttributes');
acSessions = getappdata(handles.figure1,'acSessions');
iNumSessions = length(acSessions);

for iSessionIter=1:iNumSessions
    if isfield(acSessions{iSessionIter},'acDataEntries')
        for iDataEntryIter=1:length(acSessions{iSessionIter}.acDataEntries)
            if ~isempty(acSessions{iSessionIter}.acDataEntries{iDataEntryIter}.m_a2cAttributes)
                acNewAttributes = setdiff(acSessions{iSessionIter}.acDataEntries{iDataEntryIter}.m_a2cAttributes(1,:),acAllAttributes);
                if ~isempty(acNewAttributes)
                    acAllAttributes = [acAllAttributes;acNewAttributes'];
                end
            end
        end
    end
end
return;


% --- Executes on button press in hChangeAttributes.
function hChangeAttributes_Callback(hObject, eventdata, handles)
fnUpdateAllAttributes(handles);
% acAllAttributes = getappdata(handles.figure1,'acAllAttributes');
% abActive = ismember(acAllAttributes,acActiveAttributes);
% iNumAttr = length(acAllAttributes);
% a2cData = cell(iNumAttr,2);
% for iCellIter=1:iNumAttr
%     a2cData{iCellIter,1} = acAllAttributes{ iCellIter};
%     a2cData{iCellIter,2} = abActive(iCellIter);
% end
%
% hFig = figure;
% set(hFig,'Units','pixels');
% set(hFig,'toolbar','none');
% aiPos = get(hFig,'Position');
% set(hFig,'CloseRequestFcn',@fnUpdateAttributes)
%
% hTable=uitable('columneditable', [false true ],'Data',a2cData,'Position',[0 0 aiPos(3) aiPos(4)]);
% set(hFig,'UserData',{hTable, handles});
return;

% function fnUpdateAttributes(hFig,b)
% Tmp = get(hFig,'UserData');
% hTable = Tmp{1};
% handles = Tmp{2};
% a2cData = get(hTable,'Data');
%
% delete(hFig);
% acAllAttributes = a2cData(:,1);
% abSelectedAttributes = cat(1,a2cData{:,2}) > 0;
% acActiveAttributes= acAllAttributes(abSelectedAttributes);
% setappdata(handles.figure1,'acAllAttributes',acAllAttributes);
% setappdata(handles.figure1,'acActiveAttributes',acActiveAttributes);
% fnInvalidateDataEntries(handles);
%
% return;

function hCopyDown_Callback(hObject, eventdata, handles)
acDisplayedEntries = getappdata(handles.figure1,'acDisplayedEntries');
aiSelected = getappdata(handles.figure1,'aiSelectedData');
DataBrowserPopulation(acDisplayedEntries(aiSelected));
return;

function a2fColors =fnGetDefaultUnitColors()
a2fColors = [1,1,0;
    0,1,0;
    0,1,1;
    1,0,0;
    colorcube(50);
    colorcube(50);
    colorcube(50);
     colorcube(50);
      colorcube(50);
       colorcube(50);
        colorcube(50);
         colorcube(50);
          colorcube(50);];
return;
% --------------------------------------------------------------------
function hShowIntervalGraph_Callback(hObject, eventdata, handles)
acSessions = getappdata(handles.figure1,'acSessions');
aiSelectedRaw = getappdata(handles.figure1,'aiSelectedRaw');
for k=1:length(aiSelectedRaw)
    
    [strRawFolder,strSession]= fileparts(acSessions{aiSelectedRaw(k)}.m_strKofikoFullFilename);
    strSortedUnitsPath = [strRawFolder,filesep,'..',filesep,'Processed',filesep,'SortedUnits',filesep];
    astrctSortedFiles = dir([strSortedUnitsPath,strSession,'*-spikes_ch*.raw']);
    iNumSortedChannels = length(astrctSortedFiles);
    a2fAllIntervals = zeros(0,6); % Start,End, Y, ChannelIter, Channel Number, UniqueID
    iOffset = 0;
    aiYToChannel = zeros(1,0);
    aiOffsets = zeros(1,iNumSortedChannels);
    for iChannelIter=1:iNumSortedChannels
        strSpikeFile = [strSortedUnitsPath,astrctSortedFiles(iChannelIter).name];
        [astrctRAW, astrctChannelInfo(iChannelIter)] = fnReadDumpSpikeFile(strSpikeFile,'HeaderOnly');
        aiSortedIntervals = find(cat(1,astrctRAW.m_iUnitIndex) >0);
        astrctRAWSorted=astrctRAW(aiSortedIntervals);
        aiUnitVertical = fnGetIntervalVerticalValueAux(astrctRAWSorted);
        if isempty(aiUnitVertical)
            continue;
        end;
        iNumIntervals = length(aiUnitVertical);
        a2fIntervals = [cat(1,astrctRAWSorted.m_afInterval),iOffset + aiUnitVertical(:),...
            ones(iNumIntervals,1)*iChannelIter,ones(iNumIntervals,1)*astrctChannelInfo(iChannelIter).m_iChannelID,...
            cat(1,astrctRAWSorted.m_iUnitIndex)];
        
        aiYToChannel(1,unique(iOffset + aiUnitVertical(:))) = astrctChannelInfo(iChannelIter).m_iChannelID;
        
        a2fAllIntervals=[a2fAllIntervals;a2fIntervals];
        iOffset = max(a2fAllIntervals(:,3)) ;
        aiOffsets(iChannelIter) = iOffset;
    end
    %%
    fZero = min(a2fAllIntervals(:,1));
    a2fColors =fnGetDefaultUnitColors();
    hIntervalFigure = figure;
    set(hIntervalFigure,'name',strSession);
    clf;
    iNumIntervals = size(a2fAllIntervals,1);
    fHeight=0.2;
    hTimeLine=cla;
    hold on;
    set(gcf,'color',[1 1 1])
    ahIntervalPatch= zeros(1, iNumIntervals);
    ahIntervalText= zeros(1, iNumIntervals);
    for k=1:iNumIntervals
        fXstart = a2fAllIntervals(k,1)-fZero;
        fXend = a2fAllIntervals(k,2)-fZero;
        fY = a2fAllIntervals(k,3);
        ahIntervalPatch(k) = patch('xdata',[fXstart,fXstart,fXend,fXend],'ydata',...
            [fY-fHeight fY+fHeight,fY+fHeight,fY-fHeight],'facecolor',a2fColors(k,:),'parent',hTimeLine);
        ahIntervalText(k) = text((fXstart+fXend)/2,fY,sprintf('%d',a2fAllIntervals(k,6)),'parent',hTimeLine,'fontweight','bold');
    end
    iMaxY = length(aiYToChannel);
    fMaxX = max(a2fAllIntervals(:,2))-fZero;
    for k=1:length(aiOffsets)
        plot([0 fMaxX],[aiOffsets(k)+0.5,aiOffsets(k)+0.5],'k--');
    end
    
    set(hTimeLine,'ytick',1:iMaxY,'yticklabel',aiYToChannel);
    axis ij
    xlabel('Time (sec)');
    ylabel('Channel');
    %%
end

return;


% --------------------------------------------------------------------
function hAnalyzeDataEntrires_Callback(hObject, eventdata, handles)
acDisplayedEntries = getappdata(handles.figure1,'acDisplayedEntries');
aiSelected = getappdata(handles.figure1,'aiSelectedData');
acSelectedDataEntries = acDisplayedEntries(aiSelected);
iNumSelected = length(aiSelected);
for k=1:iNumSelected
    fprintf('%s\n',acSelectedDataEntries{k}.m_strFile);
end
return;


function fnUpdateMenus(handles)
strctConfig= getappdata(handles.figure1,'strctConfig');

if ~iscell(strctConfig.m_strctRAWPipelines.m_acPipeline)
    strctConfig.m_strctRAWPipelines.m_acPipeline = {strctConfig.m_strctRAWPipelines.m_acPipeline};
end
if ~iscell(strctConfig.m_strctProcessedPipelines.m_acPipeline)
    strctConfig.m_strctProcessedPipelines.m_acPipeline = {strctConfig.m_strctProcessedPipelines.m_acPipeline};
end
setappdata(handles.figure1,'strctConfig',strctConfig);


iNumPipelinesAnalysisAvil = length(strctConfig.m_strctRAWPipelines.m_acPipeline);
acOpt=cell(1,iNumPipelinesAnalysisAvil);
for k=1:iNumPipelinesAnalysisAvil
    acOpt{k} = strctConfig.m_strctRAWPipelines.m_acPipeline{k}.m_strName;
end
delete(get(handles.hRawAnalyzeLocally,'Children'));
delete(get(handles.hRawAnalyzeOnCluster,'Children'));

for k=1:length(acOpt)
    uimenu(handles.hRawAnalyzeLocally,'Label',acOpt{k},'callback',...
        {@fnPipelineCallback,strctConfig.m_strctRAWPipelines.m_acPipeline{k}.m_strFunc,handles,false});
    uimenu(handles.hRawAnalyzeOnCluster,'Label',acOpt{k},'callback',...
        {@fnPipelineCallback,strctConfig.m_strctRAWPipelines.m_acPipeline{k}.m_strFunc,handles,true});
end
% Processed pipeline
iNumPipelinesAnalysisAvil = length(strctConfig.m_strctProcessedPipelines.m_acPipeline);
delete(get(handles.hProcessedAnalyzeLocally,'Children'));
delete(get(handles.hProcessedAnalyzeCluster,'Children'));
acOpt=cell(1,iNumPipelinesAnalysisAvil);
for k=1:iNumPipelinesAnalysisAvil
    acOpt{k} = strctConfig.m_strctProcessedPipelines.m_acPipeline{k}.m_strName;
end
for k=1:length(acOpt)
    uimenu(handles.hProcessedAnalyzeLocally,'Label',acOpt{k},'callback',...
        {@fnPipelineCallback,strctConfig.m_strctRAWPipelines.m_acPipeline{k}.m_strFunc,handles,false});
    uimenu(handles.hProcessedAnalyzeCluster,'Label',acOpt{k},'callback',...
        {@fnPipelineCallback,strctConfig.m_strctRAWPipelines.m_acPipeline{k}.m_strFunc,handles,true});
end
return;




% --------------------------------------------------------------------
function hProcessedPipelinesMenuCallback_Callback(hObject, eventdata, handles)
strctConfig = fnMyXMLToStruct(fullfile('.', 'Config', 'DataBrowser.xml'));
setappdata(handles.figure1,'strctConfig',strctConfig);
fnUpdateMenus(handles);
return;

function hRawPipelinesMenuCallback_Callback(hObject, eventdata, handles)
strctConfig = fnMyXMLToStruct(fullfile('.', 'Config', 'DataBrowser.xml'));
setappdata(handles.figure1,'strctConfig',strctConfig);
fnUpdateMenus(handles);
return;

% --------------------------------------------------------------------
function DataEntries_Callback(hObject, eventdata, handles)


% --- Executes on button press in hRescanData.
function hRescanData_Callback(hObject, eventdata, handles)
hScanForData_Callback(hObject, eventdata, handles);


% --------------------------------------------------------------------
function hProcessedAnalyzeLocally_Callback(hObject, eventdata, handles)
% hObject    handle to hProcessedAnalyzeLocally (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function hProcessedAnalyzeCluster_Callback(hObject, eventdata, handles)
% hObject    handle to hProcessedAnalyzeCluster (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in hSortTime.
function hSortTime_Callback(hObject, eventdata, handles)
acSessions = getappdata(handles.figure1,'acSessions');
if isempty(acSessions)
    return;
end
acSubjects = fnCellStructToArray(acSessions,'m_strSubject');
acDates= fnCellStructToArray(acSessions,'m_strTimeDate');
[~,iSortInd] = sort(datenum(acDates));
setappdata(handles.figure1,'acSessions',acSessions(iSortInd));
fnInvalidateSessionList(handles);
return;


% --- Executes on button press in hSortSubject.
function hSortSubject_Callback(hObject, eventdata, handles)
acSessions = getappdata(handles.figure1,'acSessions');
if isempty(acSessions)
    return;
end
acSubjects = fnCellStructToArray(acSessions,'m_strSubject');
afDates= datenum(fnCellStructToArray(acSessions,'m_strTimeDate'));

aiSortIndAll = [];
[acUniqueSubjects,~,aiToUnique] = unique(acSubjects);
for k=1:length(acUniqueSubjects)
    aiInd = find(aiToUnique == k);
    [~, aiSortInd] = sort(afDates(aiInd));
    aiSortIndAll = [aiSortIndAll, aiInd(aiSortInd)];
end
setappdata(handles.figure1,'acSessions',acSessions(aiSortIndAll));
fnInvalidateSessionList(handles);
return;


% --------------------------------------------------------------------
function hDeleteEntriesFromDisk_Callback(hObject, eventdata, handles)
ButtonName = questdlg('Are you sure you want to permanently delete these entries?', ...
    'Warning', ...
    'Yes', 'No', 'No');
if ~strcmp(ButtonName,'Yes')
    return;
end;
acDisplayedEntries = getappdata(handles.figure1,'acDisplayedEntries');
aiSelected = getappdata(handles.figure1,'aiSelectedData');
acSelectedDataEntries = acDisplayedEntries(aiSelected);
iNumSelected = length(aiSelected);
for k=1:iNumSelected
    fprintf('Deleting %s\n',acSelectedDataEntries{k}.m_strFile);
    if exist(acSelectedDataEntries{k}.m_strFile,'file')
        delete(acSelectedDataEntries{k}.m_strFile);
    end
end
hScanForData_Callback(hObject, eventdata, handles);

return;


function hSelect_Callback(hObject, eventdata, handles)
acDisplayedEntries = getappdata(handles.figure1,'acDisplayedEntries');
aiSelected=getappdata(handles.figure1,'aiSelectedData');

acSelected = acDisplayedEntries(aiSelected);

acAllAttributes = [];
for iDataEntryIter=1:length(acSelected)
    acAllAttributes = [acAllAttributes, acSelected{iDataEntryIter}.m_a2cAttributes(1,:)];
end
acAttributes=unique(acAllAttributes);
iSelectedAttribute = listdlg('ListString',acAttributes);
if isempty(iSelectedAttribute)
    return;
end;
strSelectedAttribute = acAttributes{iSelectedAttribute};

acAttributeValue = cell(1, length(acSelected));
abHasValue = zeros(1,length(acSelected))>0;
for iDataEntryIter=1:length(acSelected)
    iIndex = find(ismember(acSelected{iDataEntryIter}.m_a2cAttributes(1,:), strSelectedAttribute));
    if ~isempty(iIndex)
        abHasValue(iDataEntryIter) = true;
        acAttributeValue{iDataEntryIter} = acSelected{iDataEntryIter}.m_a2cAttributes{2,iIndex};
    end
end
if isnumeric(acAttributeValue{1})
        % Search for matches...
    abSelected = zeros(1,  length(acDisplayedEntries)) > 0;
    abHasAttribute = zeros(1,length(acDisplayedEntries));
    for iDataEntryIter=1:length(acDisplayedEntries)
        if ~isempty(acDisplayedEntries{iDataEntryIter}.m_a2cAttributes)
            iIndex = find(ismember(acDisplayedEntries{iDataEntryIter}.m_a2cAttributes(1,:), strSelectedAttribute));
            if ~isempty(iIndex)
                abHasAttribute(iDataEntryIter) = true;
                abSelected(iDataEntryIter) =  acDisplayedEntries{iDataEntryIter}.m_a2cAttributes{2,iIndex} == acAttributeValue{1};
            end
        end
    end
    
else
    acGoodMatch = unique(acAttributeValue(abHasValue));
    if  length(acGoodMatch) ~= 1
        strAnswer = questdlg('Multiple values found for this attribute. Proceed with selection?','Warning','No','Yes','No');
        if isempty(strAnswer) || strcmp(strAnswer,'No')
            return;
        end;
    end;
    
    % Search for matches...
    abSelected = zeros(1,  length(acDisplayedEntries)) > 0;
    abHasAttribute = zeros(1,length(acDisplayedEntries));
    for iDataEntryIter=1:length(acDisplayedEntries)
        if ~isempty(acDisplayedEntries{iDataEntryIter}.m_a2cAttributes)
            iIndex = find(ismember(acDisplayedEntries{iDataEntryIter}.m_a2cAttributes(1,:), strSelectedAttribute));
            if ~isempty(iIndex)
                abHasAttribute(iDataEntryIter) = true;
                abSelected(iDataEntryIter) = ismember( acDisplayedEntries{iDataEntryIter}.m_a2cAttributes{2,iIndex},acGoodMatch) > 0;
            end
        end
    end
end

% Resort the data in the list....
aiNewSortList = [find(abHasAttribute&abSelected),find(abHasAttribute&~abSelected),find(~abHasAttribute)];

acDisplayedEntries = acDisplayedEntries(aiNewSortList);
setappdata(handles.figure1,'acDisplayedEntries',acDisplayedEntries);

fnInvalidateDataEntriesAux(handles);

hJTable2 = getappdata(handles.figure1,'hJTable2');
drawnow

% Unselect everything
try
    hJTable2.changeSelection(0, 0,false, false);
    hJTable2.changeSelection(sum(abSelected)-1,0 ,false, true);
    setappdata(handles.figure1,'aiSelectedData',1:sum(abSelected));
catch
end

return;


% --------------------------------------------------------------------
function Untitled_3_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function hAutoSortAllLocally_Callback(hObject, eventdata, handles)
acSessions = getappdata(handles.figure1,'acSessions');
aiSelectedRaw = getappdata(handles.figure1,'aiSelectedRaw');

fLongIntervalSec = 120;
iNumCoeffToTake = 5;
iMinimumClusterSize = 50;
iMaxCluster = 6;
fIgnoreRecordingAtDepthsLowerThanMM = 0;
fDiscardSpikesWithAmplitudeSmallerThan_uV = 20;
fMergeDistanceMM = 0.1; % Merge intervals that are shorter than 0.1 mm

for iSessionIter=1:length(aiSelectedRaw)
    [strRawFolder,strSession]= fileparts(acSessions{aiSelectedRaw(iSessionIter)}.m_strKofikoFullFilename);
    fnWorkerLog('Processing %s',strSession);
        
    if strRawFolder(end) ~= filesep()
        strRawFolder(end+1) = filesep();
    end
    
    astrctChannels = dir([strRawFolder,'*-spikes_ch*']);
    
    iNumChannels = length(astrctChannels);
    fnWorkerLog('%d channels found',iNumChannels);
    
    strSyncFile = [strRawFolder,strSession,'-sync.mat'];
    strAdvancerFile = [strRawFolder,strSession,'-Advancers.txt'];
    strStatServerFile =[strRawFolder,strSession,'-StatServerInfo.mat'];

    if ~exist(strSyncFile,'file')
        fnWorkerLog('Cannot auto sort session %s. Sync file is missing',strSession);
        continue;
    end
   strctTmp = load(strSyncFile);
   strctSync = strctTmp.strctSync;
   strctStatServer=load(strStatServerFile);
   iGlobalIntervalCounter = 0;
   strOutputPath = [strRawFolder,'..',filesep,'Processed',filesep,'SortedUnits',filesep];
   for iChannelIter=1:iNumChannels
        strSpikeFile = [strRawFolder,astrctChannels(iChannelIter).name];
        [~,strFile,strExt]=fileparts(astrctChannels(iChannelIter).name);
        strOutFileName = fullfile(strOutputPath,[strFile,'_sorted.raw']);
        
        [astrctRawUnits, strctChannelInfo] = fnReadDumpSpikeFile(strSpikeFile);
        afAllSpikeTimes_PLX = cat(1,astrctRawUnits.m_afTimestamps);
        iNumSpikesInThisChannel = length(afAllSpikeTimes_PLX);
        a2fAllSpikeWaveForms = cat(1,astrctRawUnits.m_a2fWaveforms);
        afAllSpikeAmplitude_uV = (max(a2fAllSpikeWaveForms,[],2)-min(a2fAllSpikeWaveForms,[],2))*1e3;
        afSpikeTS_Span_PLX = [min(afAllSpikeTimes_PLX),max(afAllSpikeTimes_PLX)]; % PLX TIme
        
        iAdvancerIndex = strctStatServer.g_strctNeuralServer.m_a2iChannelToGridHoleAdvancer(strctChannelInfo.m_iChannelID,3);
        
        a2cTemp = textread(strAdvancerFile);
        afTS_PLX = fnTimeZoneChange(a2cTemp(:,6),strctSync,'StatServer','Plexon');
        % iAdvancerIndex, fDepth, PlexonFrame, fEstimatedTimeStampPLXFile,fTS_MapClockNow,fTS_PTB
         aiInd = find(a2cTemp(:,1) == iAdvancerIndex);
         
        afTimeStampElectrodeMoved = afTS_PLX(aiInd);
        afDepthMM = a2cTemp(aiInd,2);
        % Resample to one second intervals.
        afTimeSpanSeconds = afSpikeTS_Span_PLX(1):afSpikeTS_Span_PLX(end);
        afInterpolatedDepthSec = interp1(afTimeStampElectrodeMoved,afDepthMM,afTimeSpanSeconds,'linear','extrap');
        afInterpolatedDepthSec(afTimeSpanSeconds<afTimeStampElectrodeMoved(1)) = afDepthMM(1);
        afInterpolatedDepthSec(afTimeSpanSeconds>afTimeStampElectrodeMoved(end)) = afDepthMM(end);
        
        
        % Find intervals....
        afAdvancerSpeed = [diff(afInterpolatedDepthSec),0] ;
        astrctStableIntervals = fnGetIntervals(afAdvancerSpeed < 0.001);
        % Merge stable intervals if they have a non-stable interval between
        % them in which the electorde moved less than Merge Distance
        astrctStableIntervalsAug = fnMergeIntervalsWithInterIntervalThreshold(astrctStableIntervals,fMergeDistanceMM, afAdvancerSpeed);
        
        afIntervalDepthMM = afInterpolatedDepthSec(cat(1,astrctStableIntervalsAug.m_iStart));
        % Find LONG stable intervals
        aiLongAndDeep = find(afIntervalDepthMM > fIgnoreRecordingAtDepthsLowerThanMM & ...
                             cat(1,astrctStableIntervalsAug.m_iLength)' > fLongIntervalSec);
        
        astrctIntervals = astrctStableIntervalsAug(aiLongAndDeep);
                         
%                          [afUniqueDepthMM, aiMappingToUnique, aiCount] = fnMyUnique(afInterpolatedDepthSec, fMergeDistanceMM);
        % Discard of short recording intervals (say, shorter than 30
        % seconds....
%         aiLongIntervals = find(aiCount > fLongIntervalSec);
        
            
        
        iNumIntervals = length(aiLongAndDeep);
        afLongIntervalsDepthMM = afIntervalDepthMM(aiLongAndDeep);
        fnWorkerLog('Found %d long (>%d sec) and deep (> %.2f mm) recording depths for channel %d (%s)', ...
            length(afLongIntervalsDepthMM), fLongIntervalSec, fIgnoreRecordingAtDepthsLowerThanMM,...
            strctChannelInfo.m_iChannelID,strctChannelInfo.m_strChannelName);
        clear astrctUnitIntervals;
        aiSpikeAssociation = zeros(1, iNumSpikesInThisChannel);
        a2fIntervalSpan = zeros(iNumIntervals,2);
        for iIntervalIter=1:iNumIntervals
            aiIntervalInd = astrctIntervals(iIntervalIter).m_iStart:astrctIntervals(iIntervalIter).m_iEnd;
            afIntervalTime_PLX = afTimeSpanSeconds(aiIntervalInd);
            a2fIntervalSpan(iIntervalIter,:) = [afIntervalTime_PLX(1),afIntervalTime_PLX(end)];
            % Find relevant spikes in that interval
            aiRelevantSpikesInd = find(afAllSpikeAmplitude_uV > fDiscardSpikesWithAmplitudeSmallerThan_uV & afAllSpikeTimes_PLX >= afIntervalTime_PLX(1) & afAllSpikeTimes_PLX <=afIntervalTime_PLX(end));
            if length(aiRelevantSpikesInd) > iMinimumClusterSize
                %             afRelevantSpikeTimes = afAllSpikeTimes_PLX(aiRelevantSpikesInd);
                a2fRelevantWaveForms = a2fAllSpikeWaveForms(aiRelevantSpikesInd,:);
                % Send off to klustakwik
                fnWorkerLog('Analyzing interval %d (%d spikes in %.2f Minutes)',iIntervalIter, length(aiRelevantSpikesInd), (afIntervalTime_PLX(end)-afIntervalTime_PLX(1))/60)
                
                % Extract features....
                a2fSortedAllWaveFormsZeroMean = bsxfun(@minus,a2fRelevantWaveForms,mean(a2fRelevantWaveForms,1));
                [coeff,~] = eig(a2fSortedAllWaveFormsZeroMean'*a2fSortedAllWaveFormsZeroMean);
                a2fPCACoeff = fliplr(coeff);
                
                 
                a2fPCAFeatures = a2fSortedAllWaveFormsZeroMean*a2fPCACoeff(:,1:iNumCoeffToTake);
                
                aiClusters = fndllKlustaKwikMatlabWrapper(a2fPCAFeatures',[],'MinClusters',1,'MaxClusters',iMaxCluster,'MaxPossibleClusters',iMaxCluster,'Verbose',0,'Screen',0);
                aiUniqueClusters = unique(aiClusters);
                aiNumSpikes = histc(aiClusters,aiUniqueClusters);
                aiUniqueClusters = aiUniqueClusters(aiNumSpikes > iMinimumClusterSize);
                % Create new intervals...
                iNumNewIntervals = length(aiUniqueClusters);
                fnWorkerLog('Klustakwik returned %d large clusters (> 50 spikes)',iNumNewIntervals);
                
                for iClusterIter=1:iNumNewIntervals
                    iGlobalIntervalCounter=iGlobalIntervalCounter+1;
                    aiSpikeAssociation(aiRelevantSpikesInd(aiClusters == aiUniqueClusters(iClusterIter))) = iGlobalIntervalCounter;
                end
                
            end
        end % Interval loop
        
        
        % Save sorted spikes to disk
        strctChannelInfo.m_bSorted = true;
        aiUniqueIDs = unique(aiSpikeAssociation);
        iNumIntervals = length(aiUniqueIDs);
        clear astrctSpikes
        % Prep the astrctSpikes structure
        for iUnitIter=1:iNumIntervals
            astrctSpikes(iUnitIter).m_iUnitIndex = aiUniqueIDs(iUnitIter);
            astrctSpikes(iUnitIter).m_afTimestamps = afAllSpikeTimes_PLX(aiSpikeAssociation == aiUniqueIDs(iUnitIter));
            astrctSpikes(iUnitIter).m_afInterval = [min( astrctSpikes(iUnitIter).m_afTimestamps), max( astrctSpikes(iUnitIter).m_afTimestamps)];
            astrctSpikes(iUnitIter).m_a2fWaveforms = a2fAllSpikeWaveForms(aiSpikeAssociation == aiUniqueIDs(iUnitIter),:);
        end
        fnWorkerLog('Dumping channel %d spikes to disk',strctChannelInfo.m_iChannelID);
        fnDumpChannelSpikes(strctChannelInfo,astrctSpikes, strOutFileName);
   end % Channel loop
    fnWorkerLog('Finished session %s',strSession);
end % Session loop

% --------------------------------------------------------------------
function hAutoSortAllOnCluster_Callback(hObject, eventdata, handles)
% hObject    handle to hAutoSortAllOnCluster (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
