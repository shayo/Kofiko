function varargout = SessionBrowser(varargin)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

% SESSIONBROWSER M-file for SessionBrowser.fig
%      SESSIONBROWSER, by itself, creates a new SESSIONBROWSER or raises the existing
%      singleton*.
%
%      H = SESSIONBROWSER returns the handle to a new SESSIONBROWSER or the handle to
%      the existing singleton*.
%
%      SESSIONBROWSER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SESSIONBROWSER.M with the given input arguments.
%
%      SESSIONBROWSER('Property','Value',...) creates a new SESSIONBROWSER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SessionBrowser_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SessionBrowser_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SessionBrowser

% Last Modified by GUIDE v2.5 02-Nov-2010 09:05:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @SessionBrowser_OpeningFcn, ...
    'gui_OutputFcn',  @SessionBrowser_OutputFcn, ...
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


% --- Executes just before SessionBrowser is made visible.
function SessionBrowser_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SessionBrowser (see VARARGIN)

dbstop if error

% Choose default command line output for SessionBrowser
handles.output = hObject;
% strMatFile = 'D:\Data\Doris\FinalTestWithMonkey\090911_174218_Rocco.mat';
% strPlexonFile = 'D:\Data\Doris\FinalTestWithMonkey\FinalTest_WithRocco.plx';
% fnLoadSession(handles, strMatFile, strPlexonFile);
% Update handles structure
iNumPanels = 5;
setappdata(handles.figure1,'bListening',0);
aiPos = get(handles.hDisplayPanel,'Position');
strUnits = get(handles.hDisplayPanel,'Units');
hParent = get(handles.hDisplayPanel,'Parent');
ahPanels = zeros(1,iNumPanels );
ahPanels(1) = handles.hDisplayPanel;
for k=2:iNumPanels
    ahPanels(k) = uipanel('units',strUnits,'Position',aiPos,'Visible','off','Parent',hParent);
end;

strctConfig = fnMyXMLToStruct(fullfile('.', 'Config', 'SessionBrowser.xml'));
setappdata(handles.figure1,'strctConfig',strctConfig);


hMenu = uicontextmenu;

for k=1:length(strctConfig.m_strctUnitUpdateFunctions.m_acUpdate)
    uimenu(hMenu,'label',    strctConfig.m_strctUnitUpdateFunctions.m_acUpdate{k}.m_strName, 'callback', {@fnRunUpdateFunction,handles,k});
end

set(handles.hUnitsList,'UIContextMenu',hMenu);


handles.ahPanels = ahPanels;
setappdata(handles.figure1,'iCurrPanel',1);
setappdata(handles.figure1,'iNumPanels',iNumPanels);
guidata(hObject, handles);
set(handles.figure1,'toolbar','figure');
set(handles.figure1,'WindowScrollWheelFcn',{@fnMouseWheel,handles});

% UIWAIT makes SessionBrowser wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function fnRunUpdateFunction(a,b,handles,iSelectedUpdate)
strctConfig = getappdata(handles.figure1,'strctConfig');
aiSelectedUnits = get(handles.hUnitsList,'value');
acUnits = getappdata(handles.figure1,'acUnits');
if isempty(acUnits)
    return;
end;
iNumUnits = length(acUnits);
iNumSelectedUnits = length(aiSelectedUnits);
for k=1:iNumSelectedUnits
    [strctUnit, bOverride] = feval(strctConfig.m_strctUnitUpdateFunctions.m_acUpdate{iSelectedUpdate}.m_strFunc, acUnits{aiSelectedUnits(k)});
    if bOverride
        acUnits{aiSelectedUnits(k)} = strctUnit;
    else
        acUnits{iNumUnits+k} = strctUnit;
    end
end
setappdata(handles.figure1,'acUnits',acUnits);
fnInvalidateUnitsList(handles);
s
return;



% --- Outputs from this function are returned to the command line.
function varargout = SessionBrowser_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;



% --- Executes on selection change in hRecSessionList.
function hRecSessionList_Callback(hObject, eventdata, handles)
return;


% --- Executes during object creation, after setting all properties.
function hRecSessionList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hRecSessionList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function hCollectUnitStatistics_Callback(hObject, eventdata, handles)
aiSelectedSessions = get(handles.hRecordedSessionsList,'value');
acUnits = getappdata(handles.figure1,'acUnits');
if ~isempty(acUnits)
    ButtonName = questdlg('Are you sure you want to override existing units?', ...
        'Warning', ...
        'Yes', 'No (Cancel)', 'No (Cancel)');
    drawnow update
    drawnow
    if strcmp(ButtonName,'Yes')
        fnCollectUnitStatistics(handles,aiSelectedSessions, false);
    end;
else
    fnCollectUnitStatistics(handles,aiSelectedSessions, false);
end

return;


function fnCollectUnitStatistics(handles,aiSelectedSessions, bAdd)
acSessions = getappdata(handles.figure1,'acSessions');
if isempty(acSessions)
    return;
end
strctConfig = fnMyXMLToStruct(fullfile('.', 'Config', 'SessionBrowser.xml'));
setappdata(handles.figure1,'strctConfig',strctConfig);

if bAdd
    acUnits = getappdata(handles.figure1,'acUnits');
    iUnitCounter = length(acUnits)+1;
else
    acUnits = cell(0);
    iUnitCounter = 1;
end;

%hWaitBar = waitbar(0,'Computing units statistics, please wait...');

cla(handles.hListenAxes);
set(handles.hListenAxes,'Color','k','Xlim',[0 1],'YLim',[0 1],'YTick',[],'XTick',[]);

aiNumExperiments = fnCellStructToArray(acSessions(aiSelectedSessions),'m_iNumRecordedExperiments');
iTotalNumberOfExperiments = sum(aiNumExperiments);
iGlobalExperimentIter = 1;
rectangle('Position',[0 0 iGlobalExperimentIter/(1+iTotalNumberOfExperiments)  1], 'Parent',handles.hListenAxes,'FaceColor','r');

for iSessionIter=1:length(aiSelectedSessions)
    fprintf('Reading Kofiko File %s...',acSessions{aiSelectedSessions(iSessionIter)}.m_strUID);
    strctKofiko = load(acSessions{aiSelectedSessions(iSessionIter)}.m_strKofikoFileName);
    fprintf('Done!\n');
    if ~isfield(strctKofiko,'g_strctAppConfig') && ~isfield(strctKofiko, 'ExperimentRecord')
			 
			
		
        % This is not a kofiko file!
        fprintf('Could not analyze file %s  - not a kofiko file?!?!?\n',acSessions{aiSelectedSessions(iSessionIter)}.m_strKofikoFileName);
        continue
    end
    
	if isfield(strctKofiko, 'ExperimentRecord')
		
	
    if ~isfield(strctKofiko.g_strctAppConfig,'m_strTimeDate')
        strctTmp = dir(acSessions{aiSelectedSessions(iSessionIter)}.m_strKofikoFileName);
        strctKofiko.g_strctAppConfig.m_strTimeDate = strctTmp.date;
    end;
    
    %% Analyze Beahvior for the entire (!) session file. 
    % Basically, ignore "Experiments", which are only used for
    % electrophsiology timestamping...
                  
    fprintf('Collecting behavioral data from the entire session...\n');
    for iParadigmIter=1:length(strctConfig.m_strctParadigmsAnalysis.m_acParadigmAnalysis)
        if isfield(strctConfig.m_strctParadigmsAnalysis.m_acParadigmAnalysis{iParadigmIter}.m_strctGeneral,'m_strBehaviorStatisticsScript') && ...
                ~isempty(strctConfig.m_strctParadigmsAnalysis.m_acParadigmAnalysis{iParadigmIter}.m_strctGeneral.m_strBehaviorStatisticsScript)
            acUnitsStat = feval(strctConfig.m_strctParadigmsAnalysis.m_acParadigmAnalysis{iParadigmIter}.m_strctGeneral.m_strBehaviorStatisticsScript,...
                strctKofiko,strctConfig.m_strctParadigmsAnalysis.m_acParadigmAnalysis{iParadigmIter});
            iNumUnits = length(acUnitsStat);
            for j=1:iNumUnits
                acUnits{iUnitCounter} = acUnitsStat{j};
                acUnits{iUnitCounter}.m_strKofikoFileName = acSessions{aiSelectedSessions(iSessionIter)}.m_strKofikoFileName;
                acUnits{iUnitCounter}.m_strPlexonFileName = [];
                iUnitCounter = iUnitCounter + 1;
            end;
        end
    end
    fprintf('Done!\n');
    %%
    bSingleFile = isfield(acSessions{aiSelectedSessions(iSessionIter)},'m_strPlexonFileName');
    
    
    if bSingleFile
        
        if isempty(acSessions{aiSelectedSessions(iSessionIter)}.m_strPlexonFileName)
            % This was probably recorded in the scanner....
            [astrctExperiments] = fnExtractSessionInfoNoPlexon(strctKofiko);
            strctPlexon = [];
            
        else
            strctPlexon = fnReadPlexonFileAllCh(acSessions{aiSelectedSessions(iSessionIter)}.m_strPlexonFileName,strctConfig.m_strctChannels);
            [astrctExperiments,strctPlexon] = fnExtractSessionInfo(strctKofiko, strctPlexon, strctKofiko.g_strctSystemCodes);
        end
        
            iNumRecordingExperiments = length(astrctExperiments);
            fprintf('%d Recorded Experiments found\n',iNumRecordingExperiments);
            if iNumRecordingExperiments > 0
                for iExpIter=1:iNumRecordingExperiments
                    rectangle('Position',[0 0 iGlobalExperimentIter/(iTotalNumberOfExperiments+1)  1], 'Parent',handles.hListenAxes,'FaceColor','r');
                    iGlobalExperimentIter = iGlobalExperimentIter + 1;
                    drawnow
                    fprintf('Analyzing recorded experiment %d...\n',iExpIter);
                    acUnitsStat = fnCollectUnitStats(strctConfig,strctKofiko, strctPlexon, astrctExperiments(iExpIter),iExpIter);
                    iNumUnits = length(acUnitsStat);
                    for j=1:iNumUnits
                        acUnits{iUnitCounter} = acUnitsStat{j};
                        acUnits{iUnitCounter}.m_strKofikoFileName = acSessions{aiSelectedSessions(iSessionIter)}.m_strKofikoFileName;
                        acUnits{iUnitCounter}.m_strPlexonFileName = acSessions{aiSelectedSessions(iSessionIter)}.m_strPlexonFileName;
                        iUnitCounter = iUnitCounter + 1;
                    end;
                    setappdata(handles.figure1,'acUnits',acUnits);
                    fnInvalidateUnitsList(handles);
                end;
            end
      
    else
        iNumPlexonFrames = length(acSessions{aiSelectedSessions(iSessionIter)}.m_acstrPlexonFileNames);
        if length(aiSelectedSessions) == 1
            
            acExp = cell(1,iNumPlexonFrames);
            for iTmpIter=1:iNumPlexonFrames
                acExp{iTmpIter} = sprintf('Experiment %d',iTmpIter);
            end;
            [aiSelection, bOK]=listdlg('PromptString','Select Experiments','SelectionMode','multiple','ListString',acExp,'InitialValue',1:iNumPlexonFrames);
            drawnow update
            drawnow
            if bOK
                aiSelectedFrames = aiSelection;
            else
                aiSelectedFrames = 1:iNumPlexonFrames;
            end
        else
            aiSelectedFrames = 1:iNumPlexonFrames;
        end
        iTotalNumberOfExperiments = length(aiSelectedFrames);
        
        for iFrameIter=aiSelectedFrames
            
            rectangle('Position',[0 0 iGlobalExperimentIter/(iTotalNumberOfExperiments+1)  1], 'Parent',handles.hListenAxes,'FaceColor','r');
            iGlobalExperimentIter = iGlobalExperimentIter + 1;
            drawnow
            strctPlexon = fnReadPlexonFileAllCh(acSessions{aiSelectedSessions(iSessionIter)}.m_acstrPlexonFileNames{iFrameIter}, strctConfig.m_strctChannels);
            
            %             strctPlexon = fnReadPlexonFile(acSessions{aiSelectedSessions(iSessionIter)}.m_acstrPlexonFileNames{iFrameIter}, ...
            %                 {strctConfig.m_strctChannels.m_strPhotodiode, strctConfig.m_strctChannels.m_strEyeX,strctConfig.m_strctChannels.m_strEyeY,...
            %                 strctConfig.m_strctChannels.m_strLFP1,strctConfig.m_strctChannels.m_strJuice}, {'Photodiode','EyeX','EyeY','AD01','Juice'}, true);
            [strctExperiment,strctPlexon,iSession] = fnExtractSingleSessionInfo(strctKofiko, ...
                strctPlexon, strctKofiko.g_strctSystemCodes, iFrameIter);
            
            
                
            if isempty(strctExperiment)
                fprintf('FAILED TO Extract information for experiment %d\n',iFrameIter);
                continue;
            end;
            %  try
            fprintf('Analyzing recorded experiment %d...\n',iFrameIter);
            acUnitsStat = fnCollectUnitStats(strctConfig,strctKofiko, strctPlexon, strctExperiment,iSession);
            iNumUnits = length(acUnitsStat);
            if iNumUnits > 0
                for j=1:iNumUnits
                    acUnits{iUnitCounter} = acUnitsStat{j};
                    acUnits{iUnitCounter}.m_strKofikoFileName = acSessions{aiSelectedSessions(iSessionIter)}.m_strKofikoFileName;
                    acUnits{iUnitCounter}.m_strPlexonFileName = acSessions{aiSelectedSessions(iSessionIter)}.m_acstrPlexonFileNames{iFrameIter};
                    iUnitCounter = iUnitCounter + 1;
                end;
                
                setappdata(handles.figure1,'acUnits',acUnits);
                fnInvalidateUnitsList(handles);
            end
            %             catch
            %                 errordlg(sprintf('CRASHED during the attempt to extract units from recorded experiment %d (%s)',iFrameIter,...
            %                     acSessions{aiSelectedSessions(iSessionIter)}.m_acstrPlexonFileNames{iFrameIter}));
            %             end
        end
        
    end
    
    
end;
rectangle('Position',[0 0 1  1], 'Parent',handles.hListenAxes,'FaceColor','r');

%close(hWaitBar);
setappdata(handles.figure1,'acUnits',acUnits);

fnInvalidateUnitsList(handles);
fprintf('Finished!\n');
return;

function fnInvalidateSelectedUnitsList(handles)
aiSelectedUnits = getappdata(handles.figure1,'aiSelectedUnits');
acUnits = getappdata(handles.figure1,'acUnits');
% strList = '';
% for k=1:length(aiSelectedUnits)
%     strCurr = sprintf('%03d (Exp %2d) [%10s], [%10s], Ch %d:%d',k,acUnits{aiSelectedUnits(k)}.m_iRecordedSession(1),...
%         acUnits{aiSelectedUnits(k)}.m_strImageListDescrip, acUnits{aiSelectedUnits(k)}.m_strRecordedTimeDate,...
%         acUnits{aiSelectedUnits(k)}.m_iChannel(1),acUnits{k}.m_iUnitID(1));
%     strList = [strList, '|',strCurr];
%     fprintf('%s\n',strCurr);
% end;
% set(handles.hUnitList2,'string',strList(2:end),'value',1,'min',1,'max',length(aiSelectedUnits));
fnInvalidateUnitsListAux(handles.hUnitList2,acUnits(aiSelectedUnits))
return;


function fnInvalidateUnitsListAux(handle,acUnits)
if isempty(acUnits)
   set(handle,'string','','value',1);
   return;
end

strList = '';

for k=1:length(acUnits)
    
    if isfield(acUnits{k},'m_iRecordedSession')
        strCurr = sprintf('[%03d] %10s, %10s, (Exp %2d) Ch %3d:%3d, [%10s], [%10s] ',k,acUnits{k}.m_strRecordedTimeDate,acUnits{k}.m_strSubject,acUnits{k}.m_iRecordedSession(1),...
            acUnits{k}.m_iChannel(1),acUnits{k}.m_iUnitID(1),acUnits{k}.m_strParadigm, acUnits{k}.m_strParadigmDesc);
    else
        strCurr = sprintf('[%03d] %10s, %10s, [%10s], [%10s] %d Trials',...
            k,acUnits{k}.m_strRecordedTimeDate,acUnits{k}.m_strSubject,acUnits{k}.m_strParadigm, acUnits{k}.m_strParadigmDesc,acUnits{k}.m_iNumTrials);
        
    end
    strList = [strList, '|',strCurr];
end;
set(handle,'string',strList(2:end),'value',1,'min',1,'max',length(acUnits));
return;

function fnInvalidateUnitsList(handles)
acUnits = getappdata(handles.figure1,'acUnits');
fnInvalidateUnitsListAux(handles.hUnitsList,acUnits);
return;



function strFolder = fnGetDefaultSearchFolder(handles)
strctConfig = getappdata(handles.figure1,'strctConfig');
if exist(strctConfig.m_strctDirectories.m_strDataFolder,'dir')
    strFolder = strctConfig.m_strctDirectories.m_strDataFolder;
elseif exist(strctConfig.m_strctDirectories.m_strAlternativeDataFolder,'dir')
    strFolder = strctConfig.m_strctDirectories.m_strAlternativeDataFolder;
else
    strFolder = '.';
end
return;


% --------------------------------------------------------------------
function hAddFolder_Callback(hObject, eventdata, handles)
strDefualtSearchFolder = fnGetDefaultSearchFolder(handles);
strPath = uigetdir(strDefualtSearchFolder);
acFiles = dir(fullfile(strPath,'*.mat'));
for k=1:length(acFiles)
    fnAddSession(handles,fullfile( strPath,acFiles(k).name));
end;
return;

% --------------------------------------------------------------------
function hAddFolderRec_Callback(hObject, eventdata, handles)

strDefualtSearchFolder = fnGetDefaultSearchFolder(handles);
strPath = uigetdir(strDefualtSearchFolder);
if strPath(1) == 0
    return;
end;
acFiles = fnGetAllFilesRecursive(strPath,'.mat');


cla(handles.hListenAxes);
set(handles.hListenAxes,'Color','k','Xlim',[0 1],'YLim',[0 1],'YTick',[],'XTick',[]);


for k=1:length(acFiles)
    fnAddSession(handles,acFiles{k});
    rectangle('Position',[0 0 k/(length(acFiles))  1], 'Parent',handles.hListenAxes,'FaceColor','r');
    drawnow    
end;

return;

% --------------------------------------------------------------------
function hRemoveSession_Callback(hObject, eventdata, handles)
aiSelectedSessions = get(handles.hRecordedSessionsList,'value');
acSessions = getappdata(handles.figure1,'acSessions');
if isempty(acSessions)
    return;
end;
acSessions(aiSelectedSessions) = [];
setappdata(handles.figure1,'acSessions',acSessions);
set(handles.hRecordedSessionsList,'value',1);
fnInvalidateSessionList(handles);

return;


function Untitled_8_Callback(hObject, eventdata, handles)
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
fnAddSession(handles,[strPath,strFile]);
return;

function acPlexonFiles = fnGetPlexonFrameFiles(strKofikoFileName)
%astrctPlexFiles = dir([strKofikoFullFileName(1:end-4),'_spl_f*']);
%astrctPlexFiles2 = dir([strKofikoFullFileName(1:end-4),'_part*.plx']);
%bMultipleFilesExist = ~isempty(astrctPlexFiles) || ~isempty(astrctPlexFiles2);
[strPath,strSession,strExt] = fileparts(strKofikoFileName);
if strPath(end) ~= '\'
    strPath(end+1) = '\';
end


if ~fnIsCompatibleWithCondor(strPath,strSession)
    fnMakeCompatibleWithCondor(strPath,strSession);
end

astrctNewPlexonFiles=dir([strPath,strSession,'_part_*.plx']);

acPlexonFiles = cell(1,length(astrctNewPlexonFiles));
for k=1:length(astrctNewPlexonFiles)
    acPlexonFiles{k} = [strPath,strSession,'_part_',num2str(k-1),'.plx'];
end

return;


function fnAddSession(handles, strKofikoFullFileName)

% Verify this is a Kofiko file....
warning off
X=load(strKofikoFullFileName ,'g_strctDAQParams','g_strctSystemCodes');
warning on
if ~isfield(X,'g_strctDAQParams')
    fprintf('Cannot add %s to the list. This is not a valid kofiko file!\n',strKofikoFullFileName);
    return;
end
iNumRecordedExperiments = sum(X.g_strctDAQParams.LastStrobe.Buffer == X.g_strctSystemCodes.m_iStartRecord);


strctSession.m_strKofikoFileName = strKofikoFullFileName;
[strPath,strFile] = fileparts(strKofikoFullFileName);
strctSession.m_strUID = strFile;
strctSession.m_iNumRecordedExperiments = iNumRecordedExperiments;
strSinglePlexonFileName = [strKofikoFullFileName(1:end-3),'plx'];
bSingleFileExist = exist(strSinglePlexonFileName,'file');

astrctPlexFiles = dir([strKofikoFullFileName(1:end-4),'_spl_f*']);
astrctPlexFiles2 = dir([strKofikoFullFileName(1:end-4),'_part*.plx']);
bMultipleFilesExist = ~isempty(astrctPlexFiles) || ~isempty(astrctPlexFiles2);

if ~bSingleFileExist && ~bMultipleFilesExist
    strctSession.m_strPlexonFileName = []; % No PLX file - a behavioral experiment or MRI experiment....
    strctSession.m_iNumPlexonFiles = 0;
elseif  bSingleFileExist && ~bMultipleFilesExist
    fprintf('%s - single PLX file found\n',strFile);
    strctSession.m_strPlexonFileName = [strKofikoFullFileName(1:end-3),'plx'];
    strctSession.m_iNumPlexonFiles = 1;
elseif  ~bSingleFileExist && bMultipleFilesExist
    fprintf('%s - Multiple PLX files were found\n',strFile);
    strctSession.m_acstrPlexonFileNames = fnGetPlexonFrameFiles(strKofikoFullFileName);
    strctSession.m_iNumPlexonFiles = length(strctSession.m_acstrPlexonFileNames);
elseif  bSingleFileExist && bMultipleFilesExist
    fprintf('%s - Both single and multiple PLX files were found. Taking the split version.\n',strFile);
    strctSession.m_acstrPlexonFileNames = fnGetPlexonFrameFiles(strKofikoFullFileName);
    strctSession.m_iNumPlexonFiles = length(strctSession.m_acstrPlexonFileNames);
    
    if length(strctSession.m_acstrPlexonFileNames) ~= strctSession.m_iNumRecordedExperiments
        h=errordlg(sprintf('Session %s : %d Exp found in Kofiko, but %d Plx files are present',...
            strctSession.m_strUID,  strctSession.m_iNumRecordedExperiments, length(strctSession.m_acstrPlexonFileNames)));
        waitfor(h);
    end
end

acSessions = getappdata(handles.figure1,'acSessions');
iNumSessions = length(acSessions);
acSessions{iNumSessions+1} = strctSession;

setappdata(handles.figure1,'acSessions',acSessions);
fnInvalidateSessionList(handles);
return;


function fnInvalidateSessionList(handles)
acSessions = getappdata(handles.figure1,'acSessions');


strList = '';

for k=1:length(acSessions)
    strList = [strList, '|', sprintf('%s (%02d) Recorded Experiments',acSessions{k}.m_strUID,acSessions{k}.m_iNumRecordedExperiments)];
    
end;
set(handles.hRecordedSessionsList,'string',strList(2:end),'value',1,'min',1,'max',length(acSessions));
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
function hSortByParadigmType_Callback(hObject, eventdata, handles)
acUnits = getappdata(handles.figure1,'acUnits');
aiSelectedUnits = getappdata(handles.figure1,'aiSelectedUnits');
if isempty(aiSelectedUnits)
    return;
end;
iNumUnits = length(acUnits);
aiType = zeros(1,iNumUnits);
for k=1:iNumUnits
    switch acUnits{k}.m_strImageListDescrip
        case 'FOB'
            aiType(k) = 0;
        case 'Sinha'
            aiType(k) = 1;
        otherwise
            aiType(k) = 2;
    end;
end;
[afDummy, aiSortedIndices] = sort(aiType);
acUnits = acUnits(aiSortedIndices);
aiSelectedUnits = aiSortedIndices(aiSelectedUnits);
setappdata(handles.figure1,'aiSelectedUnits',aiSelectedUnits);
setappdata(handles.figure1,'acUnits',acUnits);
fnInvalidateUnitsList(handles);
fnInvalidateSelectedUnitsList(handles);
return;


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
aiMousePos = get(handles.figure1,'CurrentPoint');
aiDisplayRect = get(handles.hDisplayPanel,'Position');
if ~(aiMousePos(1) >= aiDisplayRect(1) && ...
        aiMousePos(2) >= aiDisplayRect(2) && ...
        aiMousePos(1) <= aiDisplayRect(1)+aiDisplayRect(3) && ...
        aiMousePos(2) <= aiDisplayRect(2)+aiDisplayRect(4))
    
    return;
end;


iCurrPanel = getappdata(handles.figure1,'iCurrPanel');
iNumPanels = getappdata(handles.figure1,'iNumPanels');
iCurrPanel = iCurrPanel + b.VerticalScrollCount;
if iCurrPanel > iNumPanels
    iCurrPanel  = 1;
end;
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


% --- Executes on button press in hCopyDown.
function hCopyDown_Callback(hObject, eventdata, handles)
aiSelectedUnits = getappdata(handles.figure1,'aiSelectedUnits');
aiSelected = get(handles.hUnitsList,'value');
aiSelectedUnits = unique([aiSelectedUnits(:);aiSelected(:)]);
setappdata(handles.figure1,'aiSelectedUnits',aiSelectedUnits);
fnInvalidateSelectedUnitsList(handles);
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
acUnits = acUnits(aiSelectedUnits);
save([strPath,strFile],'astrctUnitInfo','acUnits');

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


% --------------------------------------------------------------------
function Untitled_11_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function hListenMenu_Callback(hObject, eventdata, handles)
strctPlexServerConfig = fnMyXMLToStruct('.\Config\PlexonServer.xml');
strctConfig = getappdata(handles.figure1,'strctConfig');

setappdata(handles.figure1,'bListening',1);


while (1)
    bListening = getappdata(handles.figure1,'bListening');
    if ~bListening
        break;
    end;
    
    srvsock = mslisten(strctPlexServerConfig.m_strctPlexonServer.m_fPort);
    if srvsock == -1
        errordlg('Problem with the port!');
        return;
    end;
    sock = -1;
    k= 1;
    set(handles.hListenAxes,'Color','k','Xlim',[0 1],'YLim',[0 1],'YTick',[],'XTick',[]);
    set(handles.hListenMenu,'Enable','off');
    while(1)
        bListening = getappdata(handles.figure1,'bListening');
        if ~bListening
            break;
        end;
        rectangle('Position',[0 0 k/10 1], 'Parent',handles.hListenAxes,'FaceColor','r');
        k=k+1;
        if k > 11
            delete(get(handles.hListenAxes,'Children'));
            k = 1;
        end;
        
        [sock,ip] = msaccept(srvsock,0.1);  % Block
        if sock > 0
            break;
        end;
        drawnow update
    end
    
    if sock > 0
        strctKofiko = msrecv(sock,10);
        msclose(sock);
        if isempty(strctKofiko)
            errordlg('Failed to recv information from Kofiko (paradigm too big?!?!?');
        else
            
            [strPath, strFile] = fileparts(strctKofiko.g_strctAppConfig.m_strLogFileName);
            strPlexonFile = [strctPlexServerConfig.m_strctDirectories.m_strDataFolder,strFile,'.plx'];
            
            if ~exist(strPlexonFile,'file')
                errordlg(sprintf('Could not find %s',strPlexonFile))
            else
                acChannelNames = {strctConfig.m_strctChannels.m_strEyeX,...
                    strctConfig.m_strctChannels.m_strEyeY,...
                    strctConfig.m_strctChannels.m_strPhotodiode,...
                    strctConfig.m_strctChannels.m_strLFP1,...
                    strctConfig.m_strctChannels.m_strJuice};
                
                
                strTmpPlexonFile = [strctPlexServerConfig.m_strctDirectories.m_strDataFolder,'Temp.plx'];
                copyfile(strPlexonFile,strTmpPlexonFile);
                
                strctPlexon = fnReadPlexonFileAllCh(strTmpPlexonFile, strctConfig.m_strctChannels);
                
                %             strctPlexon = fnReadPlexonFile(strTmpPlexonFile, ...
                %                 {strctConfig.m_strctChannels.m_strPhotodiode, strctConfig.m_strctChannels.m_strEyeX,strctConfig.m_strctChannels.m_strEyeY,...
                %                 strctConfig.m_strctChannels.m_strLFP1,strctConfig.m_strctChannels.m_strJuice}, {'Photodiode','EyeX','EyeY','AD01','Juice'}, true);
                
                [astrctSession,strctPlexon] = fnExtractSessionInfo(strctKofiko, strctPlexon, strctKofiko.g_strctSystemCodes);
                iNumRecordingSessions = length(astrctSession);
                
                acNames = cell(1,iNumRecordingSessions );
                for k=1:iNumRecordingSessions
                    acNames{k} = sprintf('Exp %d, %s',k,astrctSession(k).m_strParadigmName);
                end
                
                [aiSelection,bOK] = listdlg('PromptString','Select a file:',...
                    'SelectionMode','multiple',...
                    'ListString',acNames,'ListSize',[500, 300]);
                
                if bOK
                    acUnits = getappdata(handles.figure1,'acUnits');
                    iUnitCounter = length(acUnits) + 1;
                    for iSessionIter=1:length(aiSelection)
                        acUnitsStat = fnCollectUnitStats(strctConfig,strctKofiko, strctPlexon, astrctSession(aiSelection(iSessionIter)),aiSelection(iSessionIter));
                        iNumUnits = length(acUnitsStat);
                        for j=1:iNumUnits
                            acUnits{iUnitCounter} = acUnitsStat{j};
                            acUnits{iUnitCounter}.m_strKofikoFileName = '';
                            acUnits{iUnitCounter}.m_strPlexonFileName = '';
                            iUnitCounter = iUnitCounter + 1;
                        end;
                    end;
                    setappdata(handles.figure1,'acUnits',acUnits);
                    fnInvalidateUnitsList(handles);
                    
                end
            end
        end
    end
    msclose(srvsock);
end


return;


% --------------------------------------------------------------------
function hStopListen_Callback(hObject, eventdata, handles)
setappdata(handles.figure1,'bListening',0);
set(handles.hListenMenu,'Enable','on');
return;



% --------------------------------------------------------------------
function hUnitsMenu_Callback(hObject, eventdata, handles)
% hObject    handle to hUnitsMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function hMergeUnits_Callback(hObject, eventdata, handles)
aiSelectedUnits = get(handles.hUnitsList,'value');
acUnits = getappdata(handles.figure1,'acUnits');
acMergeList = getappdata(handles.figure1,'acMergeList');

if ~( strcmp(acUnits{aiSelectedUnits(1)}.m_strParadigmDesc,'FOB') && strcmp(acUnits{aiSelectedUnits(2)}.m_strParadigmDesc,'Sinha'))
    errorbox('Cannot merge');
    return;
end;

strctMerge.m_strctFOBUnit.m_strRecordedTimeDate = acUnits{aiSelectedUnits(1)}.m_strRecordedTimeDate;
strctMerge.m_strctFOBUnit.m_iRecordedSession = acUnits{aiSelectedUnits(1)}.m_iRecordedSession;
strctMerge.m_strctFOBUnit.m_iChannel = acUnits{aiSelectedUnits(1)}.m_iChannel;
strctMerge.m_strctFOBUnit.m_iUnitID = acUnits{aiSelectedUnits(1)}.m_iUnitID;

strctMerge.m_strctSinhaUnit.m_strRecordedTimeDate = acUnits{aiSelectedUnits(2)}.m_strRecordedTimeDate;
strctMerge.m_strctSinhaUnit.m_iRecordedSession = acUnits{aiSelectedUnits(2)}.m_iRecordedSession;
strctMerge.m_strctSinhaUnit.m_iChannel = acUnits{aiSelectedUnits(2)}.m_iChannel;
strctMerge.m_strctSinhaUnit.m_iUnitID = acUnits{aiSelectedUnits(2)}.m_iUnitID;

if isempty(acMergeList)
    acMergeList = strctMerge;
else
    acMergeList(end+1) = strctMerge;
end;

setappdata(handles.figure1,'acMergeList',acMergeList);
fnInvalidateMergeList(handles);

return;


% --- Executes on selection change in hMergeList.
function hMergeList_Callback(hObject, eventdata, handles)
acMergeList = getappdata(handles.figure1,'acMergeList');
if isempty(acMergeList)
    return;
end;
acUnits = getappdata(handles.figure1,'acUnits');
iSelectedMergedUnits = get(handles.hMergeList,'value');
strctMerge = acMergeList(iSelectedMergedUnits);

iNumUnits = length(acUnits);
abFOBUnit = zeros(1,iNumUnits)>0;
abSinhaUnit = zeros(1,iNumUnits)>0;
for k=1:iNumUnits
    abFOBUnit(k) = strcmp(strctMerge.m_strctFOBUnit.m_strRecordedTimeDate, acUnits{k}.m_strRecordedTimeDate) && ...
        strctMerge.m_strctFOBUnit.m_iRecordedSession(1) == acUnits{k}.m_iRecordedSession(1) && ...
        strctMerge.m_strctFOBUnit.m_iChannel(1) == acUnits{k}.m_iChannel(1) && ...
        strctMerge.m_strctFOBUnit.m_iUnitID(1) == acUnits{k}.m_iUnitID(1);
    abSinhaUnit(k) = strcmp(strctMerge.m_strctSinhaUnit.m_strRecordedTimeDate, acUnits{k}.m_strRecordedTimeDate) && ...
        strctMerge.m_strctSinhaUnit.m_iRecordedSession(1) == acUnits{k}.m_iRecordedSession(1) && ...
        strctMerge.m_strctSinhaUnit.m_iChannel(1) == acUnits{k}.m_iChannel(1) && ...
        strctMerge.m_strctSinhaUnit.m_iUnitID(1) == acUnits{k}.m_iUnitID(1);
end
set(handles.hUnitsList,'Value',find(abFOBUnit | abSinhaUnit));
return;

% --- Executes during object creation, after setting all properties.
function hMergeList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hMergeList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function hRemoveFromMergeList_Callback(hObject, eventdata, handles)
% hObject    handle to hRemoveFromMergeList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function hSaveMergeList_Callback(hObject, eventdata, handles)
acMergeList = getappdata(handles.figure1,'acMergeList');
strFolder = fnGetDefaultSearchFolder(handles);
[strFile,strPath] = uiputfile(fullfile(strFolder,'MergeUnitList.mat'));
if strFile(1) ~= 0
    save([strPath,strFile],'acMergeList');
end
return;

% --------------------------------------------------------------------
function MergeMenu_Callback(hObject, eventdata, handles)

% strFolder = fnGetDefaultSearchFolder(handles);
% [strFile,strPath] = uigetfile([strFolder,'MergeUnitList.mat']);
% if strFile(1) ~= 0
%    save([strPath,strFile],'acMergeList');
% end



function fnInvalidateMergeList(handles)
acMergeList = getappdata(handles.figure1,'acMergeList');
iNumMerges = length(acMergeList);
acDesc = cell(1,iNumMerges);
strOpt= '';
for k=1:iNumMerges
    acDesc{k} = sprintf('%s %d-%d AND %d-%d',...
        acMergeList(k).m_strctFOBUnit.m_strRecordedTimeDate,...
        acMergeList(k).m_strctFOBUnit.m_iRecordedSession,   acMergeList(k).m_strctFOBUnit.m_iUnitID,...
        acMergeList(k).m_strctSinhaUnit.m_iRecordedSession,   acMergeList(k).m_strctSinhaUnit.m_iUnitID);
    strOpt = [strOpt,'|',acDesc{k}];
end
set(handles.hMergeList,'String',strOpt(2:end) );

return;


% --------------------------------------------------------------------
function hLoadMergeList_Callback(hObject, eventdata, handles)
strFolder = fnGetDefaultSearchFolder(handles);
[strFile,strPath] = uigetfile(fullfile(strFolder, 'MergeUnitList.mat'));
if strFile(1) ~= 0
    strctTmp = load([strPath,strFile],'acMergeList');
    setappdata(handles.figure1,'acMergeList',strctTmp.acMergeList);
    fnInvalidateMergeList(handles)
end
return;
% --------------------------------------------------------------------
function hGenerateMergeUnits_Callback(hObject, eventdata, handles)
%aiSelectedtoMerge = get(handles.hMergeList,'value');
acMergeList = getappdata(handles.figure1,'acMergeList');
acUnits = getappdata(handles.figure1,'acUnits');
iNumUnits = length(acUnits);

iNumUnitsToMerge = length(acMergeList);%length(aiSelectedtoMerge);
acNewUnits = cell(1, iNumUnitsToMerge);
for iMergeIter=1:iNumUnitsToMerge
    strctMerge = acMergeList((iMergeIter));
    
    abFOBUnit = zeros(1,iNumUnits)>0;
    abSinhaUnit = zeros(1,iNumUnits)>0;
    for k=1:iNumUnits
        abFOBUnit(k) = strcmp(strctMerge.m_strctFOBUnit.m_strRecordedTimeDate, acUnits{k}.m_strRecordedTimeDate) && ...
            length(strctMerge.m_strctFOBUnit.m_iRecordedSession) == length(acUnits{k}.m_iRecordedSession) && ...
            strctMerge.m_strctFOBUnit.m_iRecordedSession == acUnits{k}.m_iRecordedSession && ...
            strctMerge.m_strctFOBUnit.m_iChannel == acUnits{k}.m_iChannel && ...
            strctMerge.m_strctFOBUnit.m_iUnitID == acUnits{k}.m_iUnitID;
        abSinhaUnit(k) = strcmp(strctMerge.m_strctSinhaUnit.m_strRecordedTimeDate, acUnits{k}.m_strRecordedTimeDate) && ...
            length(strctMerge.m_strctSinhaUnit.m_iRecordedSession) == length(acUnits{k}.m_iRecordedSession ) && ...
            strctMerge.m_strctSinhaUnit.m_iRecordedSession == acUnits{k}.m_iRecordedSession && ...
            strctMerge.m_strctSinhaUnit.m_iChannel == acUnits{k}.m_iChannel && ...
            strctMerge.m_strctSinhaUnit.m_iUnitID == acUnits{k}.m_iUnitID;
    end
    iFOBUnit = find(abFOBUnit);
    iSinhaUnit = find(abSinhaUnit);
    if length(iFOBUnit) == 1 && length(iSinhaUnit) == 1
        acNewUnits{iMergeIter} = fnMergeFOB_And_Sinha(acUnits{iFOBUnit},  acUnits{iSinhaUnit});
    else
        fprintf('Cannot merge %s because part of the units are missing \n',strctMerge.m_strctFOBUnit.m_strRecordedTimeDate);
        acNewUnits{iMergeIter} = [];
    end
end

acUnits = [acUnits, acNewUnits];
setappdata(handles.figure1,'acUnits',acUnits);
fnInvalidateUnitsList(handles);
return;


% --------------------------------------------------------------------
function hShowExperiment_Callback(hObject, eventdata, handles)
acUnits = getappdata(handles.figure1,'acUnits');
aiSelected = get(handles.hUnitsList,'value'); 
for k=1:length(aiSelected)
    fnPlotExperiment(acUnits{aiSelected(k)});
end;


% --------------------------------------------------------------------
function Untitled_12_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --------------------------------------------------------------------
function Untitled_14_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_14 (see GCBO)
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
function Untitled_15_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function hAnalyzeOnCluster_Callback(hObject, eventdata, handles)
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


% --------------------------------------------------------------------
function hPopulationMenuClick_Callback(hObject, eventdata, handles)
strctConfig = fnMyXMLToStruct(fullfile('.', 'Config', 'SessionBrowser.xml'));
setappdata(handles.figure1,'strctConfig',strctConfig);

iNumPopulationAnalysisAvil = length(strctConfig.m_strctPopulationAnalysis.m_acAnalysis);
acOpt=cell(1,iNumPopulationAnalysisAvil);
for k=1:iNumPopulationAnalysisAvil
    acOpt{k} = strctConfig.m_strctPopulationAnalysis.m_acAnalysis{k}.m_strName;     
end
delete(get(hObject,'Children'));
for k=1:length(acOpt)
    uimenu(hObject,'Label',acOpt{k},'callback',{@fnPopulationCallback,handles,k});
end

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
