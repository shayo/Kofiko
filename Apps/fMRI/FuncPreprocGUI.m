function varargout = FuncPreprocGUI(varargin)
% FUNCPREPROCGUI M-file for FuncPreprocGUI.fig
%      FUNCPREPROCGUI, by itself, creates a new FUNCPREPROCGUI or raises the existing
%      singleton*.
%
%      H = FUNCPREPROCGUI returns the handle to a new FUNCPREPROCGUI or the handle to
%      the existing singleton*.
%
%      FUNCPREPROCGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FUNCPREPROCGUI.M with the given input arguments.
%
%      FUNCPREPROCGUI('Property','Value',...) creates a new FUNCPREPROCGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FuncPreprocGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FuncPreprocGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FuncPreprocGUI

% Last Modified by GUIDE v2.5 07-Mar-2011 09:26:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FuncPreprocGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @FuncPreprocGUI_OutputFcn, ...
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


% --- Executes just before FuncPreprocGUI is made visible.
function FuncPreprocGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FuncPreprocGUI (see VARARGIN)

% Choose default command line output for FuncPreprocGUI
handles.output = hObject;
addpath('/space/opt/freesurfer/fsfast/toolbox');
addpath('/space/opt/freesurfer/matlab');


strConfigFile = 'FuncPreprocGUI.xml';
acParams = fnReadParamsFromXML(strConfigFile);

handles.acParams = acParams;
set(handles.figure1,'visible','on');
fnSetTableFromParams(handles.hParamTable, handles.acParams);

fnInvalidate(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes FuncPreprocGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);




% --- Outputs from this function are returned to the command line.
function varargout = FuncPreprocGUI_OutputFcn(hObject, eventdata, handles) 
% varargou/home/user/Code/fmripipeline/MRI_Pipelinet  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function fnInvalidate(handles)

strInputFolder= fnParseString(fnGetParameterValue(handles.acParams, 'UnpackedRoot'),[]);
fnSetListWithDirectories(handles.hUnpackedListbox, strInputFolder,false);


% --- Executes on selection change in hUnpackedListbox.
function hUnpackedListbox_Callback(hObject, eventdata, handles)
if strcmp(get(handles.figure1,'SelectionType'),'open')
    % Change folder
    strInputFolder= fnParseString(fnGetParameterValue(handles.acParams, 'UnpackedRoot'),[]);
    iSelected = get(hObject,'value');
    acAllNames= get(hObject,'string');
    
    strCurrcd=pwd();
    cd(strInputFolder);
    cd(acAllNames{iSelected});
    strNewInputFolder=pwd();
    cd(strCurrcd);
    strNewInputFolder = [strNewInputFolder,'/'];
    handles.acParams = fnSetParameterValue(handles.acParams, 'UnpackedRoot',strNewInputFolder);
    guidata(hObject, handles);
    fnSetTableFromParams(handles.hParamTable, handles.acParams);
    fnInvalidate(handles);
else
    strInputFolder= fnParseString(fnGetParameterValue(handles.acParams, 'UnpackedRoot'),[]);
    iSelected = get(handles.hUnpackedListbox,'value');
    acAllNames= get(handles.hUnpackedListbox,'string');
    
    strCurrcd=pwd();
    cd(strInputFolder);
    cd(acAllNames{iSelected});
    strNewInputFolder=pwd();
    cd(strCurrcd);
    strDirectoryToRead = [strNewInputFolder,'/'];
    
    fnParseDirectoryStructure(strDirectoryToRead,handles);
end


function fnInvalidateMotionTemplatePanel(handles)
strctMotionTemplate=getappdata(handles.figure1,'strctMotionTemplate');
iNumTimePoints = size(strctMotionTemplate.m_a4fVolume,4);
set(handles.hTimeSlider,'value',strctMotionTemplate.m_iSelectedTimePoint,'min',1,'max',iNumTimePoints);
ahImageHandles = getappdata(handles.figure1,'ahImageHandles');

if isempty(ahImageHandles)
    ahHandles = [handles.axes1,handles.axes2,handles.axes3,handles.axes4,handles.axes5];
    iNumAxis = length(ahHandles);
    ahImageHandles = zeros(1,iNumAxis);
    I = zeros(size(strctMotionTemplate.m_a4fVolume,1),size(strctMotionTemplate.m_a4fVolume,2));
    for k=1:iNumAxis
        ahImageHandles(k) = image([],[],I,'parent', ahHandles(k));
        axis(ahHandles(k),'off');
    end
    colormap gray
    setappdata(handles.figure1,'ahImageHandles',ahImageHandles);
end

aiTimePoints = strctMotionTemplate.m_iSelectedTimePoint-2:strctMotionTemplate.m_iSelectedTimePoint+2;
for k=1:5
    if aiTimePoints(k)<=0 || aiTimePoints(k)> iNumTimePoints
        I = zeros(size(strctMotionTemplate.m_a4fVolume,1),size(strctMotionTemplate.m_a4fVolume,2));
    else
        I= strctMotionTemplate.m_a4fVolume(:,:,...
            strctMotionTemplate.m_iSelectedSlice,aiTimePoints(k));
    end
    set(ahImageHandles(k),'cdata',I,'CDataMapping','scaled');
end

    

function acArray = fnArrayToCellArray(Array)
iNumElements = length(Array);
acArray = cell(1,iNumElements);
for k=1:iNumElements 
acArray{k} = Array(k);    
end
return;

function [iSelectedTimePoint,a4fVolume] = FindStableTimePointForMotionCorrection(strBOLDFile)
% This is too big to read....

strctMRI = fnMyMRIread(strBOLDFile,0,60); % Read only the first 60 volumes...
iNumTimeFrames = size(strctMRI.vol,4);
a4fVolume=strctMRI.vol;
a3fMeanVol = mean(a4fVolume,4);
a4fMean = repmat(a3fMeanVol,[1,1,1,iNumTimeFrames]);
afDistToMean = abs(squeeze(mean(mean(mean(a4fMean-a4fVolume,1),2),3)));
afSmoothDist=conv(afDistToMean,1/4*ones(4,1),'same');
% find minimum AND not near edges.
iMargin = ceil( (1/10)*iNumTimeFrames);
afSmoothDist([1:iMargin, (iNumTimeFrames-iMargin):iNumTimeFrames]) = Inf;
[fDummy,iSelectedTimePoint] = min(afSmoothDist);
return;



function [acFieldMapOptions, acSelectedFieldMap, aiMatchingFieldMapInd]= fnMatchFieldMapToBOLD(aiRunInd,aiFieldMapInd)
iNumRuns = length(aiRunInd);
iNumFieldMapsAvailable = length(aiFieldMapInd)/2;
acFieldMapOptions = cell(1,1+iNumFieldMapsAvailable);
acFieldMapOptions{1+iNumFieldMapsAvailable} = 'N/A';
for k=1:iNumFieldMapsAvailable
    acFieldMapOptions{k} = sprintf('[%d,%d]',aiFieldMapInd(2*(k-1)+1),aiFieldMapInd(2*(k-1)+2));
end


aiMatchingFieldMapInd = zeros(1,iNumRuns);
acSelectedFieldMap = cell(1,iNumRuns);
for k=1:iNumRuns
    if isempty(aiFieldMapInd)
         aiMatchingFieldMapInd(k) = 0;
        acSelectedFieldMap{k} = 'N/A';
    else
        
    % Find nearest field map
    aiDistToFieldMap = aiRunInd(k) - aiFieldMapInd;
    fMinDist = min(abs(aiDistToFieldMap));
    aiNearBy = find(abs(aiDistToFieldMap) == fMinDist);
    if length(aiNearBy) > 1
        aiNearBy = aiNearBy(1);
    end;
    
    % TODO : take care of the B0,Func,B0 Sequence
    
    if mod(aiNearBy,2) == 1
        aiMatchingFieldMapInd(k) = aiFieldMapInd(aiNearBy);
    else
        aiMatchingFieldMapInd(k) = aiFieldMapInd(aiNearBy-1);
    end
    acSelectedFieldMap{k} = sprintf('[%d,%d]',aiMatchingFieldMapInd(k),aiMatchingFieldMapInd(k)+1);
    end
end

return;



function [aiFieldMapInd,acstrFieldmapFileNames] = fnScanDirectoryForFieldMapScans(strRoot,handles)
strFieldMapSubfolder = fnParseString(fnGetParameterValue(handles.acParams, 'Subfolder_Fieldmap'),[]);
strFieldMapStem= fnParseString(fnGetParameterValue(handles.acParams, 'Fieldmap_Stem'),[]);


aiFieldMapInd = [];
acstrFieldmapFileNames = [];
if ~exist([strRoot,strFieldMapSubfolder],'dir')
    return;
end;

astrctDir = dir([strRoot,strFieldMapSubfolder]);
abIsDir = cat(1,astrctDir.isdir);
astrctFolders = astrctDir(abIsDir);

iNumFolders = length(astrctFolders);
abExist = zeros(1,iNumFolders) > 0;
aiSequenceNumber = zeros(1,iNumFolders);
acstrFieldmapFileNames = cell(1,iNumFolders);
for k=1:length(astrctFolders)
    strFieldmapfile = fullfile(strRoot,strFieldMapSubfolder,astrctFolders(k).name, strFieldMapStem);
    abExist(k) = exist(strFieldmapfile ,'file')>0;
    if abExist(k)
        aiSequenceNumber(k) = str2num(astrctFolders(k).name);
        acstrFieldmapFileNames{k} = strFieldmapfile;
    end
end

aiFieldMapInd = aiSequenceNumber(abExist);
acstrFieldmapFileNames = acstrFieldmapFileNames(abExist);

return;




% --- Executes during object creation, after setting all properties.
function hUnpackedListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hUnpackedListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function hTimeSlider_Callback(hObject, eventdata, handles)
% hObject    handle to hTimeSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function hTimeSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hTimeSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function hSlicesSlider_Callback(hObject, eventdata, handles)
% hObject    handle to hSlicesSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function hSlicesSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hSlicesSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function fnParseDirectoryStructure(strDirectoryToRead,handles)
% Search for bold runs under the specified sub folder
strBoldSubfolder= fnParseString(fnGetParameterValue(handles.acParams, 'Subfolder_BOLD'),[]);
strFuncStem = fnParseString(fnGetParameterValue(handles.acParams, 'Functional_Stem'),[]);
astrctDir = dir([strDirectoryToRead,strBoldSubfolder]);

[aiFieldMapInd, acstrFieldMapFils] = fnScanDirectoryForFieldMapScans([strDirectoryToRead],handles);
if isempty(astrctDir)
    set(handles.hRunTable,'visible','off');
else
    set(handles.hRunTable,'visible','on');
    
    astrctSubFolders = astrctDir(cat(1,astrctDir.isdir));
    iNumSubFolders = length(astrctSubFolders);
    abExist = zeros(1,iNumSubFolders) > 0;
    acHeaders = cell(1,iNumSubFolders);
    aiNumTimePoints = zeros(1,iNumSubFolders);
    acRunNames = cell(1,iNumSubFolders);
    acstrTimePoints = cell(1,iNumSubFolders);
    aiFolderInd = zeros(1,iNumSubFolders);
    acBOLDFileNames = cell(1,iNumSubFolders);
    acDICOMhdr = cell(1,iNumSubFolders);
    for iSubFolderIter=1:iNumSubFolders
      acBOLDFileNames{iSubFolderIter} = fullfile([strDirectoryToRead,strBoldSubfolder],astrctSubFolders(iSubFolderIter).name, strFuncStem);
      strFuncFileName = acBOLDFileNames{iSubFolderIter};
      abExist(iSubFolderIter) = exist(strFuncFileName,'file')>0;
      if abExist(iSubFolderIter)
          aiFolderInd(iSubFolderIter) = str2num(astrctSubFolders(iSubFolderIter).name);
          acHeaders{iSubFolderIter} = MRIread(strFuncFileName,true);
          %acDICOMhdr{iSubFolderIter} = fnReadDump([strFuncFileName,'-infodump.dat']);
          aiNumTimePoints(iSubFolderIter) = acHeaders{iSubFolderIter}.nframes;
          acstrTimePoints{iSubFolderIter} = num2str(aiNumTimePoints(iSubFolderIter));
          acRunNames{iSubFolderIter} = astrctSubFolders(iSubFolderIter).name;
      end
    end

    iNumRuns = sum(abExist);
    aiNumTimePoints=aiNumTimePoints(abExist);
    aiFolderInd=aiFolderInd(abExist);
    acHeaders=acHeaders(abExist);
    acDICOMhdr = acDICOMhdr(abExist);
    acstrTimePoints=acstrTimePoints(abExist);
    acRunNames=acRunNames(abExist);
    acBOLDFileNames=acBOLDFileNames(abExist);
    
    % Assume same TR for all scans. 
    iMostLikelyCorrectNumberOfTRsForThisRun = mode(aiNumTimePoints);
    abSelected = zeros(1,iNumRuns)>0;
    for k=1:iNumRuns
        abSelected(k) = aiNumTimePoints(k) == iMostLikelyCorrectNumberOfTRsForThisRun;
     end;
     acSelected = fnArrayToCellArray(abSelected);

    % Attach field maps...
    aiRunInd = aiFolderInd;
    
    iSelectedTemplateRun = find(abSelected,1,'first');
    abSelectedTemplateRun = zeros(1, iNumRuns) > 0;
    abSelectedTemplateRun(iSelectedTemplateRun) = true;
    acSelectedTemplate = fnArrayToCellArray(abSelectedTemplateRun);

    strctMotionTemplate.m_iSelectedTemplateRun = aiRunInd(iSelectedTemplateRun);
    strctMotionTemplate.m_strBOLDFile = acBOLDFileNames{iSelectedTemplateRun};
    [strctMotionTemplate.m_iSelectedTimePoint,strctMotionTemplate.m_a4fVolume] = ...
        FindStableTimePointForMotionCorrection(strctMotionTemplate.m_strBOLDFile); % Use first run
    
   strctMotionTemplate.m_iSelectedSlice = round(size(strctMotionTemplate.m_a4fVolume,3)/2);
     
    [acFieldMapOptions, acSelectedFieldMap, aiMatchingFieldMapInd]= fnMatchFieldMapToBOLD(aiRunInd,aiFieldMapInd);
       
    % Prepare table 
    columnname =   {'# TRs', 'Process','Fieldmap','Motion Template'};
    columnformat = {'numeric', 'logical',acFieldMapOptions, 'logical'};
    columneditable =  [false  true true,true]; 
    acData = cell(iNumRuns,4);
    acData(:,1) = acstrTimePoints;
    acData(:,2) =acSelected;
    acData(:,3) = acSelectedFieldMap;
    acData(:,4) =acSelectedTemplate;
    
    set(handles.hRunTable,'Data',acData,'ColumnName',columnname,'ColumnFormat',columnformat,...
        'ColumnEditable',columneditable,'RowName',acRunNames);
    
    setappdata(handles.figure1,'strctMotionTemplate',strctMotionTemplate);
    fnInvalidateMotionTemplatePanel(handles);
    
    setappdata(handles.figure1,'acBOLDFileNames',acBOLDFileNames);
    setappdata(handles.figure1,'aiFieldMapInd',aiFieldMapInd);
    setappdata(handles.figure1,'acstrFieldMapFils',acstrFieldMapFils);
    setappdata(handles.figure1,'acHeaders',acHeaders);
    setappdata(handles.figure1,'acDICOMhdr',acDICOMhdr);
end

return;


% --- Executes on button press in hSubmitButton.
function hSubmitButton_Callback(hObject, eventdata, handles)
acJobs = getappdata(handles.figure1,'acJobs');

iNumJobs = length(acJobs);
for iJobIter=1:iNumJobs
    strctJob = acJobs{iJobIter};
    FuncPreprocSubmit(strctJob.m_astrctRuns, strctJob.m_strctMotionTemplate, strctJob.m_acParams);
end

setappdata(handles.figure1,'acJobs',[]);
fnInvalidateJobQueue(handles);




% --- Executes on button press in hRemoveFromQueue.
function hRemoveFromQueue_Callback(hObject, eventdata, handles)
% hObject    handle to hRemoveFromQueue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in hAddToQueue.
function hAddToQueue_Callback(hObject, eventdata, handles)
iSelected = get(handles.hUnpackedListbox,'value');
acAllNames= get(handles.hUnpackedListbox,'string');
acParams = handles.acParams;
acParams = fnSetParameterValue(acParams,'SessionID',acAllNames{iSelected});


strctMotionTemplate = getappdata(handles.figure1,'strctMotionTemplate');
acBOLDFileNames = getappdata(handles.figure1,'acBOLDFileNames');
aiFieldMapInd = getappdata(handles.figure1,'aiFieldMapInd');
acstrFieldMapFils = getappdata(handles.figure1,'acstrFieldMapFils');
acHeaders = getappdata(handles.figure1,'acHeaders');
acDICOMhdr = getappdata(handles.figure1,'acDICOMhdr');
%

% prepare the runs that need to be processed     
acData = get(handles.hRunTable,'Data');
abSelectedToProcess = cat(1,acData{:,2}) > 0;
aiSelectedRuns = find(abSelectedToProcess);

iSelectedTemplate = find(cat(1,acData{:,4}) > 0);

strctMotionTemplate.m_iFromRunIndex = find(aiSelectedRuns == iSelectedTemplate(1));

iNumRuns = sum(abSelectedToProcess);
clear astrctRuns
for iRunIter=1:iNumRuns
   strctRun.m_strEPI = acBOLDFileNames{ aiSelectedRuns(iRunIter) };
   [strPath,strFile]=fileparts(strctRun.m_strEPI);
   strctRun.m_strRunFolder = strPath(1+find(strPath=='/',1,'last'):end);
      
   if strcmpi(acData{aiSelectedRuns(iRunIter),3},'N/A')
       strctRun.m_strFieldMag = [];
       strctRun.m_strFieldPhase = [];
   else
        aiMagPhase=sscanf(acData{aiSelectedRuns(iRunIter),3},'[%d,%d]');
        strctRun.m_strFieldMag = acstrFieldMapFils{aiFieldMapInd==aiMagPhase(1)};
        strctRun.m_strFieldPhase = acstrFieldMapFils{aiFieldMapInd==aiMagPhase(2)};
   end
   strctRun.m_strctFS_hdr = acHeaders{aiSelectedRuns(iRunIter)};
   strctRun.m_strctDICOM = acDICOMhdr{aiSelectedRuns(iRunIter)};
   astrctRuns(iRunIter) = strctRun;
end   

strctJob.m_strSessionID = acAllNames{iSelected};
strctJob.m_astrctRuns = astrctRuns;
strctJob.m_strctMotionTemplate = strctMotionTemplate;
strctJob.m_acParams = acParams;


acJobs = getappdata(handles.figure1,'acJobs');
iNumJobs = length(acJobs);

acJobs{iNumJobs+1} = strctJob;

setappdata(handles.figure1,'acJobs',acJobs);

fnInvalidateJobQueue(handles);

return;


function fnInvalidateJobQueue(handles)
acJobs = getappdata(handles.figure1,'acJobs');
iNumJobs = length(acJobs);

a2cData = cell(iNumJobs,2);
for iJobIter=1:iNumJobs
    a2cData{iJobIter,1} = acJobs{iJobIter}.m_strSessionID;
    a2cData{iJobIter,2} = length(acJobs{iJobIter}.m_astrctRuns);
end
set(handles.hQueueTable,'Data',a2cData,'ColumnName',{'Session','Num Runs'},...
    'ColumnWidth',{160 100})

return;



