function varargout = FuncAnal(varargin)
% FUNCANAL MATLAB code for FuncAnal.fig
%      FUNCANAL, by itself, creates a new FUNCANAL or raises the existing
%      singleton*.
%
%      H = FUNCANAL returns the handle to a new FUNCANAL or the handle to
%      the existing singleton*.
%
%      FUNCANAL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FUNCANAL.M with the given input arguments.
%
%      FUNCANAL('Property','Value',...) creates a new FUNCANAL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FuncAnal_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FuncAnal_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FuncAnal

% Last Modified by GUIDE v2.5 06-Oct-2011 17:40:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @FuncAnal_OpeningFcn, ...
    'gui_OutputFcn',  @FuncAnal_OutputFcn, ...
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


% --- Executes just before FuncAnal is made visible.
function FuncAnal_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FuncAnal (see VARARGIN)

% Choose default command line output for FuncAnal
handles.output = hObject;
set(handles.figure1,'visible','on');
%strSessionRootFolder = '/space/data/shayo/cooked/2011/111003Houdini';
%addpath('D:\Code\Doris\MRI\PublicLib\FreeSurfer_Matlab');
strSessionRootFolder = varargin{1};%'D:\Data\Doris\MRI\deleteme\111003Houdini';
setappdata(handles.figure1,'strSessionRootFolder',strSessionRootFolder);

fnScanBoldFolders(handles);

fnScanAnalysesFolders(handles);

astrctAnalysis = getappdata(handles.figure1,'astrctAnalysis' );
if ~isempty(astrctAnalysis)
    fnSetActiveAnalysis(handles,astrctAnalysis(1).m_strName);
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes FuncAnal wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function fnScanBoldFolders(handles)
fprintf('Scanning BOLD folders...');
strSessionRootFolder = getappdata(handles.figure1,'strSessionRootFolder');
astrctDir = dir([strSessionRootFolder,'/bold']);
acNames = {astrctDir.name};
aiPotentiallyBOLDFolders = find(~ismember(acNames,{'.','..'}) & cat(1,astrctDir.isdir)');
% Runs should have at least one NIFTI file in them and should have three identifiying numbers
iNumPotentialRuns = length(aiPotentiallyBOLDFolders);
acStemsInRun = cell(1,iNumPotentialRuns);
abHasOneStem = zeros(1,iNumPotentialRuns) > 0;
for k=1:iNumPotentialRuns
    iRunNumber = str2num(acNames{aiPotentiallyBOLDFolders(k)});
    bNumberFolder = ~isempty(iRunNumber) & iRunNumber > 0 & iRunNumber < 900;
    if bNumberFolder
        astrctStems = dir([strSessionRootFolder,'/bold/',acNames{aiPotentiallyBOLDFolders(k)},'/*.nii']);
        acStemsInRun{k} = {astrctStems.name};
        abHasOneStem(k) = ~isempty(astrctStems);
    end
end
acValidRunNames = acNames(aiPotentiallyBOLDFolders(abHasOneStem));
acStemsInValidRuns = acStemsInRun(abHasOneStem);
iNumValidRuns = length(acValidRunNames);
% Find all possible stems
acStems = unique(cat(2,acStemsInRun{:}));
iNumUniqueStems = length(acStems);
a2bStemsInRuns = zeros(iNumValidRuns, iNumUniqueStems) > 0;
for iRunIter=1:iNumValidRuns
    a2bStemsInRuns(iRunIter,:) = ismember(acStems,acStemsInValidRuns{iRunIter} );
end
% Attempt to read the number of TRs and TR length....

acHeader = cell(1,iNumValidRuns);
for iIter=1:iNumValidRuns
    % Take first stem available...
    strBOLD= [strSessionRootFolder,'/bold/',acValidRunNames{iIter},'/',acStems{find(a2bStemsInRuns(iIter,:),1,'first')}];
    fprintf('%s ',acValidRunNames{iIter});
    acHeader{iIter} = MRIread(strBOLD,1);
end

% Attempt to read eye motion information...
acDistToFixation = cell(1,iNumValidRuns);
for iIter=1:iNumValidRuns
    % Take first stem available...
    strGazeFile= [strSessionRootFolder,'/bold/',acValidRunNames{iIter},'/dist_to_fixation.mat'];
    if exist(strGazeFile,'file')
        strctTmp = load(strGazeFile);
        acDistToFixation{iIter} = strctTmp.afAverageFixationDist;
    end
end

% Attempt to read time point exclusion file
acTPEF = cell(1,iNumValidRuns);
for iIter=1:iNumValidRuns
    % Take first stem available...
    strTpefFile= [strSessionRootFolder,'/bold/',acValidRunNames{iIter},'/tpef'];
    if exist(strTpefFile,'file')
        hFileID = fopen(strTpefFile,'r+');
        Tmp = textscan(hFileID,'%f');
        fclose(hFileID);
        acTPEF{iIter} = Tmp{1};
    end
end


% Attempt to read the motion parameters file. Assume it is stored in fmc.mcdat
acMotion = cell(1,iNumValidRuns);
for iIter=1:iNumValidRuns
    strMotionFile = [strSessionRootFolder,'/bold/',acValidRunNames{iIter},'/fmc.mcdat'];
    if exist(strMotionFile,'file')
        hFileID = fopen(strMotionFile,'r+');
        Tmp = textscan(hFileID,'%d %f %f %f %f %f %f %f %f %f');
        fclose(hFileID);
        a2fRigidTrans = cat(2,Tmp{2:7});
        acMotion{iIter} = a2fRigidTrans;
        %  The AFNI 3dvolreg output mcdat file will have the following 10 columns:
        %   1. n      : time point
        %   2. roll   : rotation about the column (?) axis (degrees CCW)
        %   3. pitch  : rotation about the row (?) axis (degrees CCW)
        %   4. yaw    : rotation about the slice (?) axis (degrees CCW)
        %   5. dcol   : displacement in the column direction (mm)
        %   6. drow   : displacement in the row direction (mm)
        %   7. dslice : displacement in the slice direction (mm)
        %   8. rmsold : RMS difference between input frame and reference frame
        %   9. rmsnew : RMS difference between output frame and reference frame
        %   10. trans : translation (mm) = sqrt(dslice^2 + dcol^2 + drow^2)
    end
end
strctRuns.m_acTPEF = acTPEF;
strctRuns.m_acValidRunNames = acValidRunNames;
strctRuns.m_acStems = acStems;
strctRuns.m_a2bStemsInRuns = a2bStemsInRuns;
strctRuns.m_acMotion = acMotion;
strctRuns.m_acHeader = acHeader;
strctRuns.m_acDistToFixation = acDistToFixation;
setappdata(handles.figure1,'strctRuns',strctRuns);
fprintf('Done!\n');
return;


function fnScanAnalysesFolders(handles)
% Identify how many existing analyses are there
strSessionRootFolder = getappdata(handles.figure1,'strSessionRootFolder');
strctRuns = getappdata(handles.figure1,'strctRuns');

astrctDir = dir([strSessionRootFolder,'/analyses']);
acNames = {astrctDir.name};
aiPotentiallyAnalysisFolders = find(~ismember(acNames,{'.','..'}) & cat(1,astrctDir.isdir)');
% an Analysis folder must contain the "df" file....
if isempty(aiPotentiallyAnalysisFolders)
    astrctAnalysis = [];
    setappdata(handles.figure1,'astrctAnalysis',astrctAnalysis );
    return;
end

abHasTheFreeSurferFiles = zeros(1, length(aiPotentiallyAnalysisFolders)) > 0;
for iIter=1:length(aiPotentiallyAnalysisFolders)
    astrctFilesDF = dir([strSessionRootFolder, '/analyses/',acNames{aiPotentiallyAnalysisFolders(iIter)},'/df']);
    astrctFilesSF = dir([strSessionRootFolder, '/analyses/',acNames{aiPotentiallyAnalysisFolders(iIter)},'/sf']);
    abHasTheFreeSurferFiles(iIter) = ~isempty(astrctFilesDF) & ~isempty(astrctFilesSF);
end

acAnalysesNames = acNames(aiPotentiallyAnalysisFolders(abHasTheFreeSurferFiles));
iNumAnal = length(acAnalysesNames);
for iIter=1:iNumAnal
    astrctAnalysis (iIter).m_strName = acAnalysesNames{iIter};
    % Step 1. Check for runfile existence
    strAnalysisFolder = [strSessionRootFolder, '/analyses/',astrctAnalysis(iIter).m_strName];
    if exist([strAnalysisFolder,'/runlist'],'file')
        hFileID = fopen([strAnalysisFolder,'/runlist'],'r');
        Tmp = textscan(hFileID,'%s');
        fclose(hFileID);
        astrctAnalysis (iIter).m_acRuns = Tmp{1};
    else
        astrctAnalysis (iIter).m_acRuns = [];
    end
    % Step 2. Check for stem
    if exist([strAnalysisFolder,'/stem'],'file')
        hFileID = fopen([strAnalysisFolder,'/stem'],'r+');
        Tmp = textscan(hFileID,'%s');
        fclose(hFileID);
        astrctAnalysis (iIter).m_strStem = Tmp{1}{1};
    else
        astrctAnalysis (iIter).m_strStem = '';
    end
    
    % Step 3. Check for design matrix
    strDesignFile = [strAnalysisFolder,'/paradigmfile_',astrctAnalysis(iIter).m_strName];
    if exist(strDesignFile,'file')
        hFileID = fopen(strDesignFile,'r');
        Tmp = textscan(hFileID,'%f %d %f %s');        
        fclose(hFileID);
        astrctAnalysis (iIter).m_strctDesign = fnFreesurferDesignToMatlabFormat(Tmp);
        aiRunIndex = find(ismember(strctRuns.m_acValidRunNames, astrctAnalysis(iIter).m_acRuns));
        astrctAnalysis (iIter).m_strctDesign.m_fTR_Sec = strctRuns.m_acHeader{aiRunIndex(1)}.tr/1000;
        
    else
        astrctAnalysis (iIter).m_strctDesign = [];
    end
    % Step 4. Check for contrasts
    strContrastFile = [strAnalysisFolder,'/contrasts_',astrctAnalysis(iIter).m_strName,'.mat'];
    if exist(strContrastFile,'file')
        Tmp = load(strContrastFile);
        astrctAnalysis (iIter).m_astrctContrasts= Tmp.astrctContrasts;
    else
        astrctAnalysis (iIter).m_astrctContrasts= [];
    end
    
end

setappdata(handles.figure1,'astrctAnalysis',astrctAnalysis );

return;





function fnSetActiveAnalysis(handles, strAnalysisName)
astrctAnalysis=getappdata(handles.figure1,'astrctAnalysis');
acAllAnalysisNames = {astrctAnalysis.m_strName};
iAnalysisIndex = find(ismember(acAllAnalysisNames,strAnalysisName));
set(handles.hAnalList,'string',acAllAnalysisNames,'value',iAnalysisIndex);

% Set all available stems and the selected one.
strctRuns=getappdata(handles.figure1,'strctRuns');

iStemIndex = find(ismember(strctRuns.m_acStems, astrctAnalysis(iAnalysisIndex).m_strStem));
if isempty(iStemIndex)
    % Take default one....
    iStemIndex = find(ismember(strctRuns.m_acStems,'fmcu.nii'));
    if isempty(iStemIndex)
        iStemIndex = 1;
    end
    % Modify analysis....
    astrctAnalysis(iAnalysisIndex).m_strStem = strctRuns.m_acStems{iStemIndex};
    setappdata(handles.figure1,'astrctAnalysis',astrctAnalysis);
    fnWriteAnalysisToDisk(handles, iAnalysisIndex);
end
set(handles.hStemsList,'String',strctRuns.m_acStems,'value',iStemIndex);

% Make sure selected runs are actually available!


% Update runs...

acRunsWithStem = strctRuns.m_acValidRunNames(strctRuns.m_a2bStemsInRuns(:,iStemIndex));

acSelectedRuns = intersect(astrctAnalysis(iAnalysisIndex).m_acRuns,acRunsWithStem);
if length(acSelectedRuns) ~= length(astrctAnalysis(iAnalysisIndex).m_acRuns)
    h=msgbox('Some selected runs are missing. Removing them!');
    waitfor(h);
    astrctAnalysis(iAnalysisIndex).m_acRuns = acSelectedRuns;
    setappdata(handles.figure1,'astrctAnalysis',astrctAnalysis);
    fnWriteAnalysisToDisk(handles, iAnalysisIndex);
end

acRemainingRuns = setdiff(acRunsWithStem, acSelectedRuns);

set(handles.hAvailRunList, 'string',acRemainingRuns,'value',1,'min',1,'max',length(acRemainingRuns));
set(handles.hSelectedRunList,'string',acSelectedRuns,'value',1,'min',1,'max',length(acSelectedRuns));

% Plot the selected runs motion?
cla(handles.axes1);

setappdata(handles.figure1,'acPlottedRuns',acSelectedRuns);
fnPlotRuns(handles);

if ~isempty(astrctAnalysis(iAnalysisIndex).m_strctDesign)
    
    % Fill in the information....
    acConditionNames = {astrctAnalysis(iAnalysisIndex).m_strctDesign.m_astrctCond.m_strName};
    set(handles.hConditionsList,'string',acConditionNames,'value',1,'min',1,'max',length(acConditionNames));
    fnPlotBlockOrder(handles,astrctAnalysis(iAnalysisIndex).m_strctDesign.m_astrctCond,astrctAnalysis(iAnalysisIndex).m_astrctContrasts,0,astrctAnalysis(iAnalysisIndex).m_strctDesign.m_fTR_Sec);
else
    cla(handles.axes2);
    set(handles.hConditionsList,'string',[],'value',1);
end

% Update contrast information
if ~isempty(astrctAnalysis(iAnalysisIndex).m_astrctContrasts)
    acContrastNames = {astrctAnalysis(iAnalysisIndex).m_astrctContrasts.m_strName};
    set(handles.hContrastList,'string',acContrastNames,'value',1);
else
    set(handles.hContrastList,'string',[],'value',1);
end
return;

function fnPlotBlockOrder(handles, astrctCond, astrctContrasts, iContrastIndex, fTR_Sec)
% Convert to intervals...
iCounter = 1;
clear astrctIntervals
for iCondIter=1:length(astrctCond)
    for k=1:length(astrctCond(iCondIter).m_afStartTime)
        astrctIntervals(iCounter).m_iCondIndex = iCondIter;
        astrctIntervals(iCounter).m_strCondName = astrctCond(iCondIter).m_strName;
        astrctIntervals(iCounter).m_fStart = astrctCond(iCondIter).m_afStartTime(k)/fTR_Sec;
        astrctIntervals(iCounter).m_fEnd = (astrctCond(iCondIter).m_afStartTime(k)+astrctCond(iCondIter).m_afDuration(k))/fTR_Sec;
        iCounter=iCounter+1;
    end
end
[afDummy,aiSortInd]=sort(cat(1,astrctIntervals.m_fStart));
astrctIntervalsSorted=astrctIntervals(aiSortInd);
aiBlockVertical = fnGetIntervalVerticalValue(astrctIntervalsSorted); % in case of block overlap....

Tmp = colorcube(8+length(astrctCond));
a2fBlockColors = Tmp(1:end-8,:);
cla(handles.axes2);
hold(handles.axes2,'on');
% Draw blocks.

if iContrastIndex > 0
    aiPos = find(ismember({astrctCond.m_strName},     astrctContrasts(iContrastIndex).m_acPos));
    aiNeg = find(ismember({astrctCond.m_strName},     astrctContrasts(iContrastIndex).m_acNeg));
end

for iInterval=1:length(astrctIntervalsSorted)
    x=astrctIntervalsSorted(iInterval).m_fStart;
    w=astrctIntervalsSorted(iInterval).m_fEnd-astrctIntervalsSorted(iInterval).m_fStart;
    y=aiBlockVertical(iInterval);
    h=1;
    if iContrastIndex == 0 
        afColor = a2fBlockColors(astrctIntervalsSorted(iInterval).m_iCondIndex,:);
    else
        if sum(aiPos == astrctIntervalsSorted(iInterval).m_iCondIndex) > 0
            afColor = [74,126,187]/255;
        elseif sum(aiNeg == astrctIntervalsSorted(iInterval).m_iCondIndex) > 0
            afColor =[190,75,72]/255;
        else
            afColor =[1 1 1];
        end
     end
    rectangle('Position',[x,y,w,h],'facecolor',afColor,'parent',handles.axes2);
    strCondname = astrctIntervalsSorted(iInterval).m_strCondName;
    strCondname(strCondname=='_') = ' ';
    text(x+w/2,y+h/6,strCondname ,'rotation',90,'fontsize',8,'horizontalalignment','left') 
end
set(handles.axes2,'xlim',[0 max(cat(1,astrctIntervals.m_fEnd))],'ylim',[1 max(aiBlockVertical)+1]);
xlabel(handles.axes2,'TR');
ylabel(handles.axes2,'Condition');
set(handles.axes2,'ytickLabel',[]);

return;

function aiUnitVertical = fnGetIntervalVerticalValue(astrctIntervals)
% Determine the vertical value for each unit...
MaxUnitsAtSameTimePoints = 10;
abVerticalOccupied = zeros(1,MaxUnitsAtSameTimePoints)> 0;
iNumUnitIntervals = length(astrctIntervals);
aiUnitVertical = zeros(1,iNumUnitIntervals);
afAllStart = cat(1,astrctIntervals.m_fStart);
afAllEnd = cat(1,astrctIntervals.m_fEnd);
[afTimeSteps,aiUnitInd] = sort( [afAllStart;afAllEnd]);
for k=1:length(afTimeSteps)-1
    if afTimeSteps(k) == afTimeSteps(k+1) && aiUnitInd(k+1) > iNumUnitIntervals
        tmp=aiUnitInd(k);
        aiUnitInd(k)=aiUnitInd(k+1);
        aiUnitInd(k+1) = tmp;
    end
end

for iTimeStepIter=1:length(afTimeSteps);
    iInterval = aiUnitInd(iTimeStepIter);
    bStart = true;
    if iInterval > iNumUnitIntervals
        iInterval=iInterval-iNumUnitIntervals;
        bStart = false;
    end
    % Find the first empty slot
    if bStart
        iVerticalIndex = find(abVerticalOccupied == false,1,'first');
        aiUnitVertical(iInterval) = iVerticalIndex;
        abVerticalOccupied(iVerticalIndex) = true;
    else
        iVerticalIndex = aiUnitVertical(iInterval);
        abVerticalOccupied(iVerticalIndex) = false;
    end
    
    
end

return;


function   fnWriteAnalysisToDisk(handles, iAnalysisIndex)
astrctAnalysis=getappdata(handles.figure1,'astrctAnalysis');
strSessionRootFolder = getappdata(handles.figure1,'strSessionRootFolder');
strAnalysisFolder = [strSessionRootFolder,'/analyses/',astrctAnalysis(iAnalysisIndex).m_strName];
strStemFile = [strAnalysisFolder,'/stem'];
strParadigmFile = [strAnalysisFolder,'/paradigmfile_',astrctAnalysis(iAnalysisIndex).m_strName];
strRunListFile = [strAnalysisFolder,'/runlist'];
% Write down the stem file.
hFileID = fopen(strStemFile,'wb+');
fprintf(hFileID,'%s\n',astrctAnalysis(iAnalysisIndex).m_strStem);
fclose(hFileID);
% Write down runs
hFileID = fopen(strRunListFile,'wb+');
for iIter=1:length(astrctAnalysis(iAnalysisIndex).m_acRuns)
    fprintf(hFileID,'%s\n',astrctAnalysis(iAnalysisIndex).m_acRuns{iIter});
end
fclose(hFileID);
% Write down paradigm file....
% TODO....
if ~isempty(astrctAnalysis(iAnalysisIndex).m_strctDesign)
       astrctCond = astrctAnalysis(iAnalysisIndex).m_strctDesign.m_astrctCond;
  
           

       % Update Cond order
       iCounter = 1;
       clear astrctIntervals
       for iCondIter=1:length(astrctCond)
           for k=1:length(astrctCond(iCondIter).m_afStartTime)
               astrctIntervals(iCounter).m_iCondIndex = iCondIter-1;
               astrctIntervals(iCounter).m_strCondName = astrctCond(iCondIter).m_strName;
               astrctIntervals(iCounter).m_fStart = astrctCond(iCondIter).m_afStartTime(k);
               astrctIntervals(iCounter).m_fEnd = astrctCond(iCondIter).m_afStartTime(k)+astrctCond(iCondIter).m_afDuration(k);
               astrctIntervals(iCounter).m_fDuration= astrctCond(iCondIter).m_afDuration(k);
               iCounter=iCounter+1;
           end
       end
       [afDummy,aiSortInd]=sort(cat(1,astrctIntervals.m_fStart));
       astrctIntervalsSorted=astrctIntervals(aiSortInd);
        hFileID = fopen(strParadigmFile,'w+');
        for k=1:length(astrctIntervalsSorted)
            fprintf(hFileID,'%10.2f %10.2f %10.2f %s\n',astrctIntervalsSorted(k).m_fStart, astrctIntervalsSorted(k).m_iCondIndex,...
                astrctIntervalsSorted(k).m_fDuration,astrctIntervalsSorted(k).m_strCondName);
        end
    fclose(hFileID);
   
end


% Update contrast file...
strSessionRootFolder = getappdata(handles.figure1,'strSessionRootFolder');
strAnalysisFolder = [strSessionRootFolder, '/analyses/',astrctAnalysis(iAnalysisIndex).m_strName];
strContrastFile = [strAnalysisFolder,'/contrasts_',astrctAnalysis(iAnalysisIndex).m_strName,'.mat'];
astrctContrasts = astrctAnalysis(iAnalysisIndex).m_astrctContrasts;
save(strContrastFile,'astrctContrasts');


return;

% --- Outputs from this function are returned to the command line.
function varargout = FuncAnal_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in hStemsList.
function hStemsList_Callback(hObject, eventdata, handles)
% Modify stem.
% This will erase all selected runs information!
astrctAnalysis=getappdata(handles.figure1,'astrctAnalysis');
if isempty(astrctAnalysis)
    return;
end;
iAnalysisIndex = get(handles.hAnalList,'value');
acStems = get(handles.hStemsList,'string');
iSelectedNewStem = get(handles.hStemsList,'value');
astrctAnalysis(iAnalysisIndex).m_strStem = acStems{iSelectedNewStem};
setappdata(handles.figure1,'astrctAnalysis',astrctAnalysis);
fnWriteAnalysisToDisk(handles, iAnalysisIndex);
fnSetActiveAnalysis(handles, astrctAnalysis(iAnalysisIndex).m_strName);
return;

% --- Executes during object creation, after setting all properties.
function hStemsList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hStemsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in hAvailRunList.
function hAvailRunList_Callback(hObject, eventdata, handles)
% hObject    handle to hAvailRunList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns hAvailRunList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hAvailRunList


% --- Executes during object creation, after setting all properties.
function hAvailRunList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hAvailRunList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in hAddRuns.
function hAddRuns_Callback(hObject, eventdata, handles)
astrctAnalysis=getappdata(handles.figure1,'astrctAnalysis');
iSelectedAnalysis =get(handles.hAnalList,'value');

acAvailRuns = get(handles.hAvailRunList,'String');
aiSelectedRunsToAdd = get(handles.hAvailRunList,'value');
acRunsToAdd = acAvailRuns(aiSelectedRunsToAdd);
acRemaining = setdiff(acAvailRuns,acRunsToAdd);
set(handles.hAvailRunList,'String',acRemaining,'value',1,'min',1,'max',length(acRemaining));

astrctAnalysis(iSelectedAnalysis).m_acRuns = unique([astrctAnalysis(iSelectedAnalysis).m_acRuns(:)',acRunsToAdd(:)']);
setappdata(handles.figure1,'astrctAnalysis',astrctAnalysis);
fnWriteAnalysisToDisk(handles, iSelectedAnalysis);

set(handles.hSelectedRunList,'string',astrctAnalysis(iSelectedAnalysis).m_acRuns,'value',1,'min',1,'max',length(astrctAnalysis(iSelectedAnalysis).m_acRuns));
return;


% --- Executes on selection change in hConditionsList.
function hConditionsList_Callback(hObject, eventdata, handles)
% hObject    handle to hConditionsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns hConditionsList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hConditionsList


% --- Executes during object creation, after setting all properties.
function hConditionsList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hConditionsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in hSelectedRunList.
function hSelectedRunList_Callback(hObject, eventdata, handles)
% hObject    handle to hSelectedRunList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns hSelectedRunList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hSelectedRunList


% --- Executes during object creation, after setting all properties.
function hSelectedRunList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hSelectedRunList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in hRemoveRuns.
function hRemoveRuns_Callback(hObject, eventdata, handles)
astrctAnalysis=getappdata(handles.figure1,'astrctAnalysis');
iSelectedAnalysis =get(handles.hAnalList,'value');

acSelectedRuns = get(handles.hSelectedRunList,'String');
aiSelectedRunsToRemove = get(handles.hSelectedRunList,'value');
acRunsToRemove = acSelectedRuns(aiSelectedRunsToRemove);

acRemaining = setdiff(acSelectedRuns,acRunsToRemove);
set(handles.hSelectedRunList,'String',acRemaining,'value',1,'min',1,'max',length(acRemaining));

astrctAnalysis(iSelectedAnalysis).m_acRuns = acRemaining;
setappdata(handles.figure1,'astrctAnalysis',astrctAnalysis);
fnWriteAnalysisToDisk(handles, iSelectedAnalysis);

acPrev = get(handles.hAvailRunList,'string');
acNewAvil = unique([acPrev;acRunsToRemove]);
set(handles.hAvailRunList,'string',acNewAvil,'value',1,'min',1,'max',length(acNewAvil));
return;


% --- Executes during object creation, after setting all properties.
function hThresholdSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hThresholdSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in hPosCond.
function hPosCond_Callback(hObject, eventdata, handles)
% hObject    handle to hPosCond (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns hPosCond contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hPosCond


% --- Executes during object creation, after setting all properties.
function hPosCond_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hPosCond (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in hBodyMotion.
function hBodyMotion_Callback(hObject, eventdata, handles)
% hObject    handle to hBodyMotion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hBodyMotion


% --- Executes on selection change in hNegCond.
function hNegCond_Callback(hObject, eventdata, handles)
% hObject    handle to hNegCond (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns hNegCond contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hNegCond


% --- Executes during object creation, after setting all properties.
function hNegCond_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hNegCond (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in hContrastList.
function hContrastList_Callback(hObject, eventdata, handles)
iSelectedContrast = get(handles.hContrastList,'value');
astrctAnalysis = getappdata(handles.figure1,'astrctAnalysis');
iAnalysisIndex = get(handles.hAnalList,'value');
if isempty(astrctAnalysis)
    return;
end;
if isempty(iSelectedContrast)
    iSelectedContrast = 0;
end

fnPlotBlockOrder(handles, astrctAnalysis(iAnalysisIndex).m_strctDesign.m_astrctCond,astrctAnalysis(iAnalysisIndex).m_astrctContrasts , iSelectedContrast,astrctAnalysis(iAnalysisIndex).m_strctDesign.m_fTR_Sec);
return;

% --- Executes during object creation, after setting all properties.
function hContrastList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hContrastList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on selection change in hAnalList.
function hAnalList_Callback(hObject, eventdata, handles)
astrctAnalysis=getappdata(handles.figure1,'astrctAnalysis');
if isempty(astrctAnalysis)
    return;
end;
iSelectedAnalysis =get(handles.hAnalList,'value');
fnSetActiveAnalysis(handles,astrctAnalysis(iSelectedAnalysis).m_strName);
return;


% --- Executes during object creation, after setting all properties.
function hAnalList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hAnalList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in hNewAnalysis.
function hNewAnalysis_Callback(hObject, eventdata, handles)
prompt={'Enter name for new analysis:'};
name='New Analysis';
numlines=1;
defaultanswer={'anal'};
answer=inputdlg(prompt,name,numlines,defaultanswer);
if isempty(answer)
    return;
end;

strNewAnalysisName = answer{1};
fnCreateNewAnalysis(handles,strNewAnalysisName);
fnScanAnalysesFolders(handles);
fnSetActiveAnalysis(handles,strNewAnalysisName);

return;


function fnCreateNewAnalysis(handles,strNewAnalysisName)
strSessionRootFolder = getappdata(handles.figure1,'strSessionRootFolder');
if strSessionRootFolder(end) == '/'
    strSessionRootFolder = strSessionRootFolder(1:end-1);
end;

iIndex = find(strSessionRootFolder == '\' | strSessionRootFolder == '/',1,'last');
strSessionName = strSessionRootFolder(iIndex+1:end);
strDataHome = strSessionRootFolder(1:iIndex-1);
strAnalysisFolder = [strSessionRootFolder,'/analyses/',strNewAnalysisName];
if exist(strAnalysisFolder,'dir')
    ans=questdlg({'Warning. This analysis already exist!','Override?'},'Question','Yes','No','No');
    if ~strcmpi(ans,'yes')
        return;
    end
end
% Step 1. Make folder
mkdir(strAnalysisFolder);
% Step 2. genedate the df file...
hFileID = fopen([strAnalysisFolder,'/df'],'w+');
fprintf(hFileID,'%s\n',strDataHome);
fclose(hFileID);
% Step 3. generate the sf file
hFileID = fopen([strAnalysisFolder,'/sf'],'w+');
fprintf(hFileID,'%s\n',strSessionName);
fclose(hFileID);
% Step 4. Make the "subjectname" file
strSubjectFile = [strSessionRootFolder,'/subjectname'];
if ~exist(strSubjectFile,'file')
    hFileID = fopen(strSubjectFile,'w+');
    fprintf(hFileID,'%s\n',strSessionName);
    fclose(hFileID);
end

return;
% --- Executes on button press in hContrastsOnly.
function hContrastsOnly_Callback(hObject, eventdata, handles)
fnGLMandContrastsAux(handles, false);

% --- Executes on button press in hPlotAvailRuns.
function hPlotAvailRuns_Callback(hObject, eventdata, handles)
aiSelected = get(handles.hAvailRunList,'value');
acSelected = get(handles.hAvailRunList,'string');
if isempty(acSelected)
    return;
end;
acSelectedRunsToPlot = acSelected(aiSelected);
setappdata(handles.figure1,'acPlottedRuns',acSelectedRunsToPlot);
fnPlotRuns(handles);

% --- Executes on button press in hPlotSelected.
function hPlotSelected_Callback(hObject, eventdata, handles)
aiSelected = get(handles.hSelectedRunList,'value');
acSelected = get(handles.hSelectedRunList,'string');
if isempty(acSelected)
    
    return
end
acSelectedRunsToPlot = acSelected(aiSelected);
setappdata(handles.figure1,'acPlottedRuns',acSelectedRunsToPlot);
fnPlotRuns(handles);

function fnPlotRuns(handles)
strctRuns = getappdata(handles.figure1,'strctRuns');
acSelectedRunsToPlot = getappdata(handles.figure1,'acPlottedRuns');
if isempty(acSelectedRunsToPlot)
    return;
end;
aiSelectedRunInd = find(ismember(strctRuns.m_acValidRunNames, acSelectedRunsToPlot));
abValues = [get(handles.hBodyMotion,'value'),get(handles.hBodyMotionRelative,'value'),get(handles.hEyeDist,'value')];

fThresholdValue = get(handles.hThresholdSlider,'value');

iSelectedViewType = find(abValues);
cla(handles.axes1);
hold(handles.axes1,'on');
acMarkers = {'+','o','*','.','x','s','d','^','v','>','<','p'};
iNumRunsToPlot = length(aiSelectedRunInd);
a2fColors = lines(iNumRunsToPlot);
switch iSelectedViewType
    case 1
        % Plot absolute motion profiles.
        ahHandles = zeros(1,iNumRunsToPlot);
        acLegend = cell(1,iNumRunsToPlot);
        
        for k=1:iNumRunsToPlot
            a2fMotion = strctRuns.m_acMotion{aiSelectedRunInd(k)};
            iMarker = mod(k, length(acMarkers)-1)+1;
            if ~isempty(a2fMotion)
                iNumTRs = size(a2fMotion,1);
                afCurve = sqrt(sum(a2fMotion(:,1:3).^2,2));
                
                if ~isempty(strctRuns.m_acTPEF{aiSelectedRunInd(k)})
                    afCurve(strctRuns.m_acTPEF{aiSelectedRunInd(k)}) = NaN;
                    fPercentRemain = 100-(length(strctRuns.m_acTPEF{aiSelectedRunInd(k)}) / length(afCurve) * 100);
                else
                    fPercentRemain = 100;
                end
                
                
                
                ahHandles(k)=plot(handles.axes1,1:iNumTRs,afCurve,'color',a2fColors(k,:),'marker',acMarkers{iMarker});
                acLegend{k} = sprintf('%s (%.2f%%)',strctRuns.m_acValidRunNames{aiSelectedRunInd(k)},fPercentRemain);
            else
                ahHandles(k)=plot(handles.axes1,0,0,'color',a2fColors(k,:),'marker',acMarkers{iMarker});
                acLegend{k} = [strctRuns.m_acValidRunNames{aiSelectedRunInd(k)},' Missing'];
            end
        end
        plot(handles.axes1,[0 iNumTRs],[fThresholdValue fThresholdValue],'r-','LineWidth',2);
        set(handles.axes1,'xlim',[0 iNumTRs],'ylim',[0 1]);
        legend(handles.axes1,ahHandles,acLegend,'fontsize',7,'location','northeastoutside');
        xlabel(handles.axes1,'TR');
        ylabel(handles.axes1,'Translation (mm)');
    case 2
        
        % Plot absolute motion profiles.
        ahHandles = zeros(1,iNumRunsToPlot);
        acLegend = cell(1,iNumRunsToPlot);
        
        for k=1:iNumRunsToPlot
            a2fMotion = strctRuns.m_acMotion{aiSelectedRunInd(k)};
            iMarker = mod(k, length(acMarkers)-1)+1;
            if ~isempty(a2fMotion)
                iNumTRs = size(a2fMotion,1);
                afCurve = sqrt(sum(a2fMotion(:,1:3).^2,2));
                afCurve = afCurve - mean(afCurve);
                
                
                  if ~isempty(strctRuns.m_acTPEF{aiSelectedRunInd(k)})
                      afCurve(strctRuns.m_acTPEF{aiSelectedRunInd(k)}) = NaN;
                    fPercentRemain = 100-(length(strctRuns.m_acTPEF{aiSelectedRunInd(k)}) / length(afCurve) * 100);
                else
                    fPercentRemain = 100;
                end
                        
                
                ahHandles(k)=plot(handles.axes1,1:iNumTRs,afCurve,'color',a2fColors(k,:),'marker',acMarkers{iMarker});
               acLegend{k} = sprintf('%s (%.2f%%)',strctRuns.m_acValidRunNames{aiSelectedRunInd(k)},fPercentRemain);
                   
            else
                ahHandles(k)=plot(handles.axes1,0,0,'color',a2fColors(k,:),'marker',acMarkers{iMarker});
                acLegend{k} = [strctRuns.m_acValidRunNames{aiSelectedRunInd(k)},' Missing'];
            end
        end
       plot(handles.axes1,[0 iNumTRs],[fThresholdValue fThresholdValue],'r-','LineWidth',2);
       plot(handles.axes1,[0 iNumTRs],-[fThresholdValue fThresholdValue],'r-','LineWidth',2);
        
        set(handles.axes1,'xlim',[0 iNumTRs],'ylim',[-1 1]);
        legend(handles.axes1,ahHandles,acLegend,'fontsize',7,'location','northeastoutside');
        xlabel(handles.axes1,'TR');
        ylabel(handles.axes1,'Translation (mm)');
        
    case 3
        if ~isfield(strctRuns,'m_acDistToFixation')
            fnAddEyeMotionInfo(handles);
        end
        if isfield(strctRuns,'m_acDistToFixation')

        % Plot absolute motion profiles.
        ahHandles = zeros(1,iNumRunsToPlot);
        acLegend = cell(1,iNumRunsToPlot);
        iNumTRs = 1;
        for k=1:iNumRunsToPlot
            afCurve = strctRuns.m_acDistToFixation{aiSelectedRunInd(k)};
            
            
            if ~isempty(strctRuns.m_acTPEF{aiSelectedRunInd(k)})
                      afCurve(strctRuns.m_acTPEF{aiSelectedRunInd(k)}) = NaN;
               fPercentRemain = 100-(length(strctRuns.m_acTPEF{aiSelectedRunInd(k)}) / length(afCurve) * 100);
            else
                fPercentRemain = 100;
            end
            
                           
            iMarker = mod(k, length(acMarkers)-1)+1;
            if ~isempty(afCurve)
                iNumTRs = length(afCurve);
                ahHandles(k)=plot(handles.axes1,1:iNumTRs,afCurve,'color',a2fColors(k,:),'marker',acMarkers{iMarker});
                acLegend{k} = sprintf('%s (%.2f%%)',strctRuns.m_acValidRunNames{aiSelectedRunInd(k)},fPercentRemain);
                
            else
                ahHandles(k)=plot(handles.axes1,0,0,'color',a2fColors(k,:),'marker',acMarkers{iMarker});
                acLegend{k} = [strctRuns.m_acValidRunNames{aiSelectedRunInd(k)},' Missing'];
            end
        end
        set(handles.axes1,'xlim',[0 iNumTRs],'ylim',[0 600]);
       plot(handles.axes1,[0 iNumTRs],[fThresholdValue fThresholdValue],'r-','LineWidth',2);
        
        legend(handles.axes1,ahHandles,acLegend,'fontsize',7,'location','northeastoutside');
        xlabel(handles.axes1,'TR');
        ylabel(handles.axes1,'Dist From Fix (pix)');            
            
            
            
        end
        
end

return;

function fnAddEyeMotionInfo(handles)
strSessionRootFolder = getappdata(handles.figure1,'strSessionRootFolder');
strKofikoFolder = [strSessionRootFolder,'/kofiko/'];
if ~exist(strKofikoFolder,'dir');
    h=msgbox({'Kofiko file is missing. Please generate the following folder:', strKofikoFolder,'And then copy there the mat log file from kofiko.'});
    waitfor(h);
    return;
end;


% Do we have any mat files there?
astrctMatFiles = dir([strSessionRootFolder,'/kofiko/*.mat']);
if isempty(astrctMatFiles)
    h=msgbox({'Could not locate any matlab files in the kofiko folder:', strKofikoFolder,'Please copy the mat log file from kofiko.'});
    waitfor(h);
    return;
end

strParsedKofikoFile= [strSessionRootFolder,'/kofiko/RecordedRuns.mat'];
if exist(strParsedKofikoFile,'file')
    ans =questdlg('Kofiko runs already exist. Parse Kofiko file again?','Question','Yes','No','Yes');
    if isempty(ans)
        return;
    end;
    if strcmpi(ans,'Yes')
        astrctKofikoRuns = fnParseKofiko(strKofikoFolder,'--force');
    else
        Tmp=load(strParsedKofikoFile);
        astrctKofikoRuns = Tmp.astrctRuns;
    end
else
    astrctKofikoRuns = fnParseKofiko(strKofikoFolder,'--force');
end

iNumKofikoRuns = length(astrctKofikoRuns);
acKofikoEntry = cell(1,iNumKofikoRuns+1);
for k=1:iNumKofikoRuns
    if isfield(astrctKofikoRuns(k),'m_strImageList')
        acKofikoEntry{k}  = sprintf('%s, %s : %d TRs',astrctKofikoRuns(k).m_strUserDescription,astrctKofikoRuns(k).m_strImageList,   astrctKofikoRuns(k).m_iNumberOfCountedTRs);
    else
        acKofikoEntry{k}  = sprintf('%s, %s : %d TRs',astrctKofikoRuns(k).m_strUserDescription,astrctKofikoRuns(k).m_strDesignName,   astrctKofikoRuns(k).m_iNumberOfCountedTRs);
    end
end;
acKofikoEntry{iNumKofikoRuns+1} = 'N/A';

strctRuns = getappdata(handles.figure1,'strctRuns');
aiEPIToKofiko = fnMatchEPIRunsToKofikoRuns(strctRuns.m_acHeader, astrctKofikoRuns);
iNumEPI = length(aiEPIToKofiko);
a2cTableData = cell(iNumEPI,3);
for iIter=1:iNumEPI
    a2cTableData{iIter,1} = strctRuns.m_acValidRunNames{iIter};
    a2cTableData{iIter,2} = strctRuns.m_acHeader{iIter}.nframes;
    if aiEPIToKofiko(iIter) == 0
        a2cTableData{iIter,3} = 'N/A';
    else
        a2cTableData{iIter,3} = acKofikoEntry{aiEPIToKofiko(iIter)};
    end
end
hFig = figure;
t=uitable('Units','normalized','Position',[0 0.1 1 0.9],'Data',a2cTableData,'ColumnName',{'EPI Run','# TR','Kofiko Entry'},...
    'ColumnFormat',{'char','numeric',acKofikoEntry},'ColumnEditable',[false false true],'parent',hFig,...
    'ColumnWidth',{50,50,500});
while(1)
    b=uicontrol('Style', 'pushbutton', 'String', 'Done','Units','normalized','Position', [0 0 0.1 0.1],'parent',hFig,'callback','uiresume(gcbf)');
    uiwait(gcf);
    if ~ishandle(t)
        return;
    end;
    a2cData = get(t,'Data');
    % Match Third column....
    aiEPIToKofiko = zeros(1,iNumEPI);
    for k=1:iNumEPI
        iIndex = find(ismember(acKofikoEntry,a2cData{k,3}));
        if iIndex == length(acKofikoEntry)
            aiEPIToKofiko(k) = 0; % N/A
        else
            aiEPIToKofiko(k) = iIndex;
        end
    end
    if length(unique(aiEPIToKofiko(aiEPIToKofiko>0))) == length(aiEPIToKofiko(aiEPIToKofiko>0))
        break;
    end
    h=msgbox('Different runs were mapped to the same kofiko experiment. This is impossible!');
    waitfor(h);
end
% OK, finally, we have the matching!
delete(hFig);

% save information....
acDistToFixation = cell(1,iNumEPI);
for iIter=1:iNumEPI
    if aiEPIToKofiko(iIter) > 0
        afAverageFixationDist = astrctKofikoRuns(aiEPIToKofiko(iIter)).m_afAverageFixationDist;
        acDistToFixation{iIter} = afAverageFixationDist;
        strEyeTrackingFile = [strSessionRootFolder,'/bold/',strctRuns.m_acValidRunNames{iIter},'/dist_to_fixation.mat'];
        save(strEyeTrackingFile,'afAverageFixationDist');
    end
end
strctRuns.m_acDistToFixation = acDistToFixation;
setappdata(handles.figure1,'strctRuns',strctRuns);

return;


% --- Executes on button press in hBrainMaskTool.
function hBrainMaskTool_Callback(hObject, eventdata, handles)
strSessionRootFolder = getappdata(handles.figure1,'strSessionRootFolder');
strBoldFolder = [strSessionRootFolder,'/bold/'];
warning off
InteractiveBrainMask(strBoldFolder);
warning on



% --- Executes on button press in hShowSelectedInJIP.
function hShowSelectedInJIP_Callback(hObject, eventdata, handles)
aiSelected = get(handles.hSelectedRunList,'value');
acSelected = get(handles.hSelectedRunList,'string');
if isempty(acSelected)
    return;
end;
acSelectedRunsToPlot = acSelected(aiSelected);
setappdata(handles.figure1,'acPlottedRuns',acSelectedRunsToPlot);
fnPlotRuns(handles);
fnShowWithJIP(handles)
return;

% --- Executes on button press in hShowAvailableInJIP.
function hShowAvailableInJIP_Callback(hObject, eventdata, handles)
aiSelected = get(handles.hAvailRunList,'value');
acSelected = get(handles.hAvailRunList,'string');
if isempty(acSelected)
    return;
end;
acSelectedRunsToPlot = acSelected(aiSelected);
setappdata(handles.figure1,'acPlottedRuns',acSelectedRunsToPlot);
fnPlotRuns(handles);
fnShowWithJIP(handles)
return;

function fnShowWithJIP(handles)
strctRuns = getappdata(handles.figure1,'strctRuns');
acSelectedRunsToPlot = getappdata(handles.figure1,'acPlottedRuns');
if isempty(acSelectedRunsToPlot)
    return;
end;
aiSelectedRunInd = find(ismember(strctRuns.m_acValidRunNames, acSelectedRunsToPlot));

iAnalysisIndex =get(handles.hAnalList,'value');
astrctAnalysis=getappdata(handles.figure1,'astrctAnalysis');
strSessionRootFolder = getappdata(handles.figure1,'strSessionRootFolder');
strBoldFolder = [strSessionRootFolder,'/bold/'];

for k=1:length(aiSelectedRunInd)  
    strBOLDFile = [strBoldFolder,strctRuns.m_acValidRunNames{aiSelectedRunInd(k)},'/',astrctAnalysis(iAnalysisIndex).m_strStem];
    system(['xd ',strBOLDFile,' -y &']);
end



% --- Executes on button press in hGazeInformation.
function hGazeInformation_Callback(hObject, eventdata, handles)
fnAddEyeMotionInfo(handles);
fnPlotRuns(handles);
return;



function hRemPosCond_Callback(hObject, eventdata, handles)
acAvailCond = get(handles.hPosCond,'string');
if isempty(acAvailCond)
    return;
end;
aiSelecCond = get(handles.hPosCond,'value');
acCondFrom = acAvailCond(aiSelecCond);

acCondTo = get(handles.hConditionsList,'string');
acCondTo = [acCondTo(:)',acCondFrom(:)'];
acRemaining = setdiff(acAvailCond, acCondFrom);
set(handles.hConditionsList,'string',acCondTo,'value',1,'min',1,'max',length(acCondTo));
set(handles.hPosCond,'string',acRemaining,'value',1,'min',1,'max',length(acRemaining));
return;

function hAddPosCond_Callback(hObject, eventdata, handles)
acAvailCond = get(handles.hConditionsList,'string');
if isempty(acAvailCond)
    return;
end;
aiSelecCond = get(handles.hConditionsList,'value');
acCondFrom = acAvailCond(aiSelecCond);
acCondTo = get(handles.hPosCond,'string');
acCondTo = [acCondTo(:)',acCondFrom(:)'];
acRemaining = setdiff(acAvailCond, acCondFrom);
set(handles.hPosCond,'string',acCondTo,'value',1,'min',1,'max',length(acCondTo));
set(handles.hConditionsList,'string',acRemaining,'value',1,'min',1,'max',length(acRemaining));
return;

function hRemNegCond_Callback(hObject, eventdata, handles)
acAvailCond = get(handles.hNegCond,'string');
if isempty(acAvailCond)
    return;
end;

aiSelecCond = get(handles.hNegCond,'value');
acCondFrom = acAvailCond(aiSelecCond);

acCondTo = get(handles.hConditionsList,'string');
acCondTo = [acCondTo(:)',acCondFrom(:)'];
acRemaining = setdiff(acAvailCond, acCondFrom);
set(handles.hConditionsList,'string',acCondTo,'value',1,'min',1,'max',length(acCondTo));
set(handles.hNegCond,'string',acRemaining,'value',1,'min',1,'max',length(acRemaining));
return;

function hAddNegCond_Callback(hObject, eventdata, handles)
acAvailCond = get(handles.hConditionsList,'string');
if isempty(acAvailCond)
    return;
end;
aiSelecCond = get(handles.hConditionsList,'value');
acCondFrom = acAvailCond(aiSelecCond);
acCondTo = get(handles.hNegCond,'string');
acCondTo = [acCondTo(:)',acCondFrom(:)'];
acRemaining = setdiff(acAvailCond, acCondFrom);
set(handles.hNegCond,'string',acCondTo,'value',1,'min',1,'max',length(acCondTo));
set(handles.hConditionsList,'string',acRemaining,'value',1,'min',1,'max',length(acRemaining));
return;


function hAddNewContrast_Callback(hObject, eventdata, handles)
astrctAnalysis = getappdata(handles.figure1,'astrctAnalysis');
iSelectedAnalysis =get(handles.hAnalList,'value');
if isempty(astrctAnalysis)
    return;
end;
iNumContrasts = length(astrctAnalysis(iSelectedAnalysis).m_astrctContrasts);

acConditionNames = {astrctAnalysis(iSelectedAnalysis).m_strctDesign.m_astrctCond.m_strName};

strctNewContrast.m_acPos = get(handles.hPosCond,'string');
strctNewContrast.m_acNeg = get(handles.hNegCond,'string');

aiPos = find(ismember(acConditionNames, strctNewContrast.m_acPos))-1;
aiNeg = find(ismember(acConditionNames, strctNewContrast.m_acNeg))-1;
strPos = num2str(aiPos);
strNeg = num2str(aiNeg);
strPos(strPos == ' ') = [];
strNeg(strNeg == ' ') = [];
% Automatic construct contrast name
strctNewContrast.m_strName = ['c',strPos,'_',strNeg];

if isempty(astrctAnalysis(iSelectedAnalysis).m_astrctContrasts)
    astrctAnalysis(iSelectedAnalysis).m_astrctContrasts = strctNewContrast;
else
    
    % make sure it is not on the list....
    if sum(ismember({astrctAnalysis(iSelectedAnalysis).m_astrctContrasts.m_strName},strctNewContrast.m_strName)) > 0
        h=msgbox('This contrast already exist!');
        waitfor(h);
        return;
    end;
    
    astrctAnalysis(iSelectedAnalysis).m_astrctContrasts(iNumContrasts+1) = strctNewContrast;
end
setappdata(handles.figure1,'astrctAnalysis',astrctAnalysis);   
iNewContrast = length(astrctAnalysis(iSelectedAnalysis).m_astrctContrasts);

% Update contrast list...
acContrastNames = {astrctAnalysis(iSelectedAnalysis).m_astrctContrasts.m_strName};
set(handles.hContrastList,'string',acContrastNames,'value',iNewContrast);
fnPlotBlockOrder(handles,astrctAnalysis(iSelectedAnalysis).m_strctDesign.m_astrctCond,astrctAnalysis(iSelectedAnalysis).m_astrctContrasts,iNewContrast,astrctAnalysis(iSelectedAnalysis).m_strctDesign.m_fTR_Sec);


% Update contrast file...
strSessionRootFolder = getappdata(handles.figure1,'strSessionRootFolder');
strAnalysisFolder = [strSessionRootFolder, '/analyses/',astrctAnalysis(iSelectedAnalysis).m_strName];
strContrastFile = [strAnalysisFolder,'/contrasts_',astrctAnalysis(iSelectedAnalysis).m_strName,'.mat'];
astrctContrasts = astrctAnalysis(iSelectedAnalysis).m_astrctContrasts;
save(strContrastFile,'astrctContrasts');

% Clear pos and neg list....
set(handles.hNegCond,'string',[],'value',1);
set(handles.hPosCond,'string',[],'value',1);
set(handles.hConditionsList,'string',acConditionNames,'value',1,'min',1,'max',length(acConditionNames));

return;



function hRemoveContrast_Callback(hObject, eventdata, handles)
astrctAnalysis = getappdata(handles.figure1,'astrctAnalysis');
iSelectedAnalysis =get(handles.hAnalList,'value');
iSelectedContrast = get(handles.hContrastList,'value');
if isempty(astrctAnalysis)
    return;
end;
astrctAnalysis(iSelectedAnalysis).m_astrctContrasts(iSelectedContrast) = [];
setappdata(handles.figure1,'astrctAnalysis',astrctAnalysis);   

% Update contrast list...
acContrastNames = {astrctAnalysis(iSelectedAnalysis).m_astrctContrasts.m_strName};
set(handles.hContrastList,'string',acContrastNames,'value',1);

iNumRemaining = length(astrctAnalysis(iSelectedAnalysis).m_astrctContrasts);
fnPlotBlockOrder(handles,astrctAnalysis(iSelectedAnalysis).m_strctDesign.m_astrctCond,astrctAnalysis(iSelectedAnalysis).m_astrctContrasts,iNumRemaining,astrctAnalysis(iSelectedAnalysis).m_strctDesign.m_fTR_Sec);

% Update contrast file...
strSessionRootFolder = getappdata(handles.figure1,'strSessionRootFolder');
strAnalysisFolder = [strSessionRootFolder, '/analyses/',astrctAnalysis(iSelectedAnalysis).m_strName];
strContrastFile = [strAnalysisFolder,'/contrasts_',astrctAnalysis(iSelectedAnalysis).m_strName,'.mat'];
astrctContrasts = astrctAnalysis(iSelectedAnalysis).m_astrctContrasts;
save(strContrastFile,'astrctContrasts');



function hGenerateDesignMatrix_Callback(hObject, eventdata, handles)
astrctAnalysis = getappdata(handles.figure1,'astrctAnalysis');
iSelectedAnalysis =get(handles.hAnalList,'value');
if isempty(astrctAnalysis)
    return;
end
    
if isempty(astrctAnalysis(iSelectedAnalysis).m_strctDesign)
    
    if  isempty(astrctAnalysis(iSelectedAnalysis).m_acRuns)
         h=msgbox('Please add at least one run before editing the design.');
        waitfor(h);
        return;
    end
    
    strctDesign.m_astrctCond = [];
    strctRuns = getappdata(handles.figure1,'strctRuns');
    aiRunIndex = find(ismember(strctRuns.m_acValidRunNames, astrctAnalysis(iSelectedAnalysis).m_acRuns));
    strctDesign.m_fTR_Sec = strctRuns.m_acHeader{aiRunIndex(1)}.tr/1000;
    astrctAnalysis(iSelectedAnalysis).m_strctDesign = strctDesign;
end

acTmp= DesignGUI(astrctAnalysis(iSelectedAnalysis).m_strctDesign);
strctDesign = acTmp{1};
bChanged = acTmp{2};
if bChanged
    astrctAnalysis(iSelectedAnalysis).m_strctDesign  = strctDesign;
    % Remove all contrasts
    astrctAnalysis(iSelectedAnalysis).m_astrctContrasts = [];
    % Also annonce that GLM is no longer valid!
    setappdata(handles.figure1,'astrctAnalysis',astrctAnalysis);
    fnWriteAnalysisToDisk(handles, iSelectedAnalysis);
    fnSetActiveAnalysis(handles,astrctAnalysis(iSelectedAnalysis).m_strName);
    
end
return;


% --- Executes on button press in hImportFromFile.
function hImportFromFile_Callback(hObject, eventdata, handles)
[strFile,strPath]=uigetfile();
strDesignFile = fullfile(strPath,strFile);

try
hFileID = fopen(strDesignFile,'r');
Tmp = textscan(hFileID,'%f %d %f %s');
fclose(hFileID);
strctDesign = fnFreesurferDesignToMatlabFormat(Tmp);
catch
    h=msgbox('Failed to parse this file. Are you sure it has four columns and is freesurfer-style?');
    waitfor(h);
    return;
end

astrctAnalysis = getappdata(handles.figure1,'astrctAnalysis');
iSelectedAnalysis =get(handles.hAnalList,'value');  
astrctAnalysis (iSelectedAnalysis).m_strctDesign = strctDesign;
aiRunIndex = find(ismember(strctRuns.m_acValidRunNames, astrctAnalysis(iSelectedAnalysis).m_acRuns));
astrctAnalysis (iSelectedAnalysis).m_strctDesign.m_fTR_Sec = strctRuns.m_acHeader{aiRunIndex(1)}.tr/1000;
        
setappdata(handles.figure1,'astrctAnalysis',astrctAnalysis);
fnWriteAnalysisToDisk(handles, iSelectedAnalysis);
fnSetActiveAnalysis(handles,astrctAnalysis(iSelectedAnalysis).m_strName);
return;


function hImportDesignMatrix_Callback(hObject, eventdata, handles)
astrctAnalysis = getappdata(handles.figure1,'astrctAnalysis');
iSelectedAnalysis =get(handles.hAnalList,'value');
if isempty(astrctAnalysis)
    return;
end;

if isempty(astrctAnalysis(iSelectedAnalysis).m_acRuns)
    h=msgbox('Please add at least one run before editing the design.');
    waitfor(h);
    return;
end
strSessionRootFolder=getappdata(handles.figure1,'strSessionRootFolder');
strParsedKofikoFile= [strSessionRootFolder,'/kofiko/RecordedRuns.mat'];
if ~exist(strParsedKofikoFile,'file')
    h=msgbox({'Kofiko information is missing.',...
        ['1. Try to copy the log file to ',strSessionRootFolder,'/kofiko/'],...
        '2. Then click on import gaze & runs from kofiko'});
    waitfor(h);
    return;
end;
Tmp = load(strParsedKofikoFile);

if ~isempty(astrctAnalysis(iSelectedAnalysis).m_acRuns)
        strctRuns = getappdata(handles.figure1,'strctRuns');

    aiEPIToKofiko = fnMatchEPIRunsToKofikoRuns(strctRuns.m_acHeader, Tmp.astrctRuns);
    aiRunIndex = find(ismember(strctRuns.m_acValidRunNames, astrctAnalysis(iSelectedAnalysis).m_acRuns));
    iKofikoRun = aiEPIToKofiko(aiRunIndex(1));
    
    acConditionOrder = Tmp.astrctRuns(iKofikoRun).m_acBlockOrder;
    
    
    fTRSec = Tmp.astrctRuns(iKofikoRun).m_fTR_MS/1000;
     acCondNames= unique(acConditionOrder);
    iNumCond = length(acCondNames);
    iNumBlocks = length(acConditionOrder);
    
    afBlockOnset = cumsum([0,Tmp.astrctRuns(iKofikoRun).m_aiNumTRsPerBlock * fTRSec]);
    
    afStart = afBlockOnset(1:end-1);
    %[0:iNumBlocks] * Tmp.astrctRuns(iKofikoRun).m_aiNumTRsPerBlock  * fTRSec;
    afEnd = afBlockOnset(2:end);%afStart+ Tmp.astrctRuns(iKofikoRun).m_iNumTRsPerBlock * fTRSec;
    
    
    afMinStart = zeros(1,iNumCond);
    for iCondIter=1:iNumCond 
        strctDesign.m_astrctCond(iCondIter).m_strName =  acCondNames{iCondIter};
        aiInd = find(ismember(acConditionOrder, acCondNames{iCondIter}));
        strctDesign.m_astrctCond(iCondIter).m_afStartTime = afStart(aiInd);
        strctDesign.m_astrctCond(iCondIter).m_afDuration = afEnd(aiInd)-afStart(aiInd);
        afMinStart(iCondIter) = min(strctDesign.m_astrctCond(iCondIter).m_afStartTime);
    end
    % Sort conditions by their first apperance.
    [afDummy, aiSortInd]= sort(afMinStart);
    strctDesign.m_astrctCond = strctDesign.m_astrctCond(aiSortInd);
    strctDesign.m_fTR_Sec = strctRuns.m_acHeader{aiRunIndex(1)}.tr/1000;
    astrctAnalysis(iSelectedAnalysis).m_strctDesign = strctDesign;
    setappdata(handles.figure1,'astrctAnalysis',astrctAnalysis);
    fnWriteAnalysisToDisk(handles, iSelectedAnalysis);
    fnSetActiveAnalysis(handles,astrctAnalysis(iSelectedAnalysis).m_strName);
else
    
    h = msgbox('Please add at least one run so we could know which design was active...');
    waitfor(h);
end
return;


function hRunGLMandContrasts_Callback(hObject, eventdata, handles)
fnGLMandContrastsAux(handles, true);

function fnGLMandContrastsAux(handles, bRunGLM)
iAnalysisIndex =get(handles.hAnalList,'value');
astrctAnalysis=getappdata(handles.figure1,'astrctAnalysis');

fnWriteTPEFToDisk(handles);

%% Double check that everything is ok....

% Check that all selected runs have the same number of frames
strctRuns = getappdata(handles.figure1,'strctRuns');

aiSelectedRuns = find(ismember(strctRuns.m_acValidRunNames,astrctAnalysis(iAnalysisIndex).m_acRuns));
iNumRuns = length(aiSelectedRuns);
aiNumTR=  zeros(1,iNumRuns);
for k=1:iNumRuns
    aiNumTR(k) = strctRuns.m_acHeader{aiSelectedRuns(k)}.nframes;
end;
if length(unique(aiNumTR)) ~= 1
    h=msgbox('Some runs that you added have a different number of TRs from the rest of the runs!');
    for k=1:iNumRuns
        fprintf('%s : %d TR \n', strctRuns.m_acValidRunNames{aiSelectedRuns(k)},aiNumTR(k));
    end
    waitfor(h);
    return;
end


% Warn the user if some runs have too many time exclusion point...
% TODO...

%%
strSessionRootFolder = getappdata(handles.figure1,'strSessionRootFolder');
if strSessionRootFolder(end) == filesep
    strSessionRootFolder = strSessionRootFolder(1:end-1);
end;
strAnalysisFolder = [strSessionRootFolder,'/analyses/',astrctAnalysis(iAnalysisIndex).m_strName];
strStemFile = [strAnalysisFolder,'/stem'];
strParadigmFile = [strAnalysisFolder,'/paradigmfile_',astrctAnalysis(iAnalysisIndex).m_strName];
strRunListFile = [strAnalysisFolder,'/runlist'];

iIndex = find(strSessionRootFolder == '\' | strSessionRootFolder == '/',1,'last');
strSessionName = strSessionRootFolder(iIndex+1:end);
strDataHome = strSessionRootFolder(1:iIndex-1);
bRunOnCluster = get(handles.hRunOnCluster,'value');

% Generate the script:
strParadigmFile   = ['paradigmfile_',astrctAnalysis(iAnalysisIndex).m_strName];
strAnalysisName = astrctAnalysis(iAnalysisIndex).m_strName;
fTR_Sec = astrctAnalysis(iAnalysisIndex).m_strctDesign.m_fTR_Sec;
iNumCond = length(astrctAnalysis(iAnalysisIndex).m_strctDesign.m_astrctCond);
strRunListFile = 'runlist';
strStem = astrctAnalysis(iAnalysisIndex).m_strStem;
strBrainMask = 'brain_mask.nii';
strDataRootFolder = strDataHome;

strCmdFile = [strAnalysisFolder,'/runglm_and_contrasts.csh'];
hFileID = fopen(strCmdFile,'w+');
fprintf(hFileID,'#! /bin/csh -f\n');
fprintf(hFileID,'setenv SUBJECTS_DIR "%s"',strDataRootFolder);
fprintf(hFileID,'\n');
fprintf(hFileID,'set AnalysisName = "%s"\n',strAnalysisName);
fprintf(hFileID,'set ParadigmDesignFile = "%s"\n', strParadigmFile);
fprintf(hFileID,'set TR = %.2f\n', fTR_Sec);
fprintf(hFileID,'set NumberOfConditions = %d\n',iNumCond-1);
fprintf(hFileID,'set GammaFit = "0 8"\n');
fprintf(hFileID,'set GammaExp = "0.3"\n');
fprintf(hFileID,'set RunListFile = "%s"\n',strRunListFile);
fprintf(hFileID,'set FuncStem = "%s"\n',strStem);
fprintf(hFileID,'set MaskStem = "%s"\n',strBrainMask);
fprintf(hFileID,'\n');
fprintf(hFileID,'cd %s\n',strAnalysisFolder);
if bRunGLM
fprintf(hFileID,'echo Generating design...\n\n');
fprintf(hFileID,'mkanalysis-sess    \\\n');
fprintf(hFileID,'    -analysis $AnalysisName \\\n');
fprintf(hFileID,'    -native         \\\n');
fprintf(hFileID,'    -event-related  \\\n');
fprintf(hFileID,'    -paradigm  $ParadigmDesignFile \\\n');
fprintf(hFileID,'    -TR $TR \\\n');
fprintf(hFileID,'    -nconditions $NumberOfConditions \\\n');
fprintf(hFileID,'    -gammafit $GammaFit\\\n');
fprintf(hFileID,'    -gammaexp $GammaExp \\\n');
fprintf(hFileID,'    -polyfit 2 \\\n');
fprintf(hFileID,'    -mcextreg \\\n');
fprintf(hFileID,'    -acfbins 10 \\\n');
fprintf(hFileID,'    -fsd bold \\\n');
fprintf(hFileID,'    -runlistfile $RunListFile \\\n');
fprintf(hFileID,'    -funcstem $FuncStem \\\n');
fprintf(hFileID,'    -mask $MaskStem \\\n');
fprintf(hFileID,'    -fwhm 0 \\\n');
fprintf(hFileID,'    -refeventdur $TR \\\n');
fprintf(hFileID,'    -tpef tpef\\\n');
fprintf(hFileID,'    -force\n');

end
fprintf(hFileID,'\n\n\n');
fprintf(hFileID,'# Contrasts Section\n\n');
fprintf(hFileID,'echo Generating contrasts...\n');

 iNumContrasts = length(astrctAnalysis(iAnalysisIndex).m_astrctContrasts);
 acConditionNames = {astrctAnalysis(iAnalysisIndex).m_strctDesign.m_astrctCond.m_strName};
 
for iContrastIter=1:iNumContrasts
    strContrastName = astrctAnalysis(iAnalysisIndex).m_astrctContrasts(iContrastIter).m_strName;
    
    aiPosCond = find(ismember(acConditionNames, astrctAnalysis(iAnalysisIndex).m_astrctContrasts(iContrastIter).m_acPos))-1;
    aiNegCond = find(ismember(acConditionNames, astrctAnalysis(iAnalysisIndex).m_astrctContrasts(iContrastIter).m_acNeg))-1;
    
    strCmd = ['mkcontrast-sess -analysis ',strAnalysisName,' -contrast ',strContrastName,' '];
    for k=1:length(aiPosCond)
        strCmd = [strCmd,'-a ', num2str(aiPosCond(k)),' '];
    end
    for k=1:length(aiNegCond)
        strCmd = [strCmd,'-c ', num2str(aiNegCond(k)),' '];
    end        
    
    fprintf(hFileID,'%s\n',strCmd);
end
fprintf(hFileID,'\n\n\n');

if bRunGLM
    fprintf(hFileID,'echo Computing average functionals volume...\n\n');
    
    fprintf(hFileID,'mri_xvolavg ');
    strAvgFolder = [strSessionRootFolder,'/bold/avg/'];
    if ~exist(strAvgFolder,'dir')
        mkdir(strAvgFolder);
    end;
    strAverageFuncFile = [strSessionRootFolder,'/bold/avg/',astrctAnalysis(iAnalysisIndex).m_strName,'_avgfunc.nii'];
    
    for iRunIter=1:iNumRuns
        % copy the mean val from the correct stem in each run...
        strRun = astrctAnalysis(iAnalysisIndex).m_acRuns{iRunIter};
        fprintf(hFileID,'--vol %s \\\n',[strSessionRootFolder,'/bold/',strRun,'/',astrctAnalysis(iAnalysisIndex).m_strStem,' ']);
    end
    fprintf(hFileID,' --out %s \n',strAverageFuncFile);
end

fprintf(hFileID,'\n\n\n');
if bRunGLM
fprintf(hFileID,'echo Running GLM fit...\n\n');
    fprintf(hFileID,'selxavg3-sess -analysis %s -sf sf -df df -no-con-ok -no-preproc -overwrite\n',strAnalysisName);
else
    % Run only the contrast
    fprintf(hFileID,'selxavg3-sess -analysis %s -sf sf -df df  -contrasts-only -no-preproc -overwrite\n',strAnalysisName);
end


fclose(hFileID);

system(['chmod 744 ',strCmdFile]);

% Free Surfer crap...
fprintf('Distributing files to run folders...\n');
% Copy the run file to the bold directory...
copyfile([strAnalysisFolder,'/runlist'],[strSessionRootFolder,'/bold'],'f')
iNumRuns = length(astrctAnalysis(iAnalysisIndex).m_acRuns);
[strDummy,strStem, strDummy]=fileparts(astrctAnalysis(iAnalysisIndex).m_strStem);

for iRunIter=1:iNumRuns
    % copy the mean val from the correct stem in each run...
    strRun = astrctAnalysis(iAnalysisIndex).m_acRuns{iRunIter};
    copyfile([strSessionRootFolder,'/bold/',strRun,'/',strStem,'.meanval'],...
        [strSessionRootFolder,'/bold/',strRun,'/global.meanval.dat'],'f');

    copyfile([strAnalysisFolder,'/',strParadigmFile],...
        [strSessionRootFolder,'/bold/',strRun,'/',strParadigmFile],'f');
    
end

if ~bRunOnCluster
    system(strCmdFile);
else
    strJobUID = [strSessionName,'_',astrctAnalysis(iAnalysisIndex).m_strName];
    strJobFolder = [strSessionRootFolder,'/jobs'];
    strCommand = sprintf('qsub -V %s -N %s -e %s -o %s', ...
        strCmdFile,strJobUID,strJobFolder,strJobFolder);
    
    [Dummy, strJobID] = system(strCommand);
    
    % Make sure we got it submited
    bOK = Dummy == 0;
    
    if bOK
        EOL = 10;
        if strJobID(end) == EOL
            strJobID = strJobID(1:end-1);
        end;
        fprintf('Job Submitted successfuly. Job ID Number: %s\n',strJobID);
    else
        fprintf('Failed to submit job:\n');
        fprintf('%s\n',strJobID);
        strJobID = [];
    end
    
end

return;


% --- Executes on button press in hRunOnCluster.
function hRunOnCluster_Callback(hObject, eventdata, handles)
% hObject    handle to hRunOnCluster (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hRunOnCluster



% --- Executes on button press in hShowContrast.
function hShowContrast_Callback(hObject, eventdata, handles)
iAnalysisIndex =get(handles.hAnalList,'value');
astrctAnalysis=getappdata(handles.figure1,'astrctAnalysis');
strSessionRootFolder = getappdata(handles.figure1,'strSessionRootFolder');
if isempty(astrctAnalysis)
    return;
end;
strAnalysisFolder = [strSessionRootFolder,'/bold/',astrctAnalysis(iAnalysisIndex).m_strName];

strAvgFuncFile = [strSessionRootFolder,'/bold/avg/',astrctAnalysis(iAnalysisIndex).m_strName,'_avgfunc.nii'];
 
if ~exist(strAvgFuncFile,'file')
    h=msgbox('Average run file is missing. Did you run the GLM analysis?');
    waitfor(h);
    return;
end;

iSelectedContrast = get(handles.hContrastList,'value');
acContrasts = get(handles.hContrastList,'string');
strContrastName = acContrasts{iSelectedContrast};

strContrastFile =[strAnalysisFolder,'/',strContrastName,'/sig.nii'];
if ~exist(strContrastFile,'file')
    h=msgbox('Contrast file is missing. Did the GLM finish running?');
    waitfor(h);
    return;
end;

system(['xd ',strAvgFuncFile,' -p ',strContrastFile,' -y &']);
return;



function hThresholdSlider_Callback(hObject, eventdata, handles)
fnPlotRuns(handles);

function hExcludeTimePoints_Callback(hObject, eventdata, handles)
strctRuns = getappdata(handles.figure1,'strctRuns');
astrctAnalysis=getappdata(handles.figure1,'astrctAnalysis');
iAnalysisIndex =get(handles.hAnalList,'value');
abValues = [get(handles.hBodyMotion,'value'),get(handles.hBodyMotionRelative,'value'),get(handles.hEyeDist,'value')];
iSelectedViewType = find(abValues);
fThreshold = get(handles.hThresholdSlider,'value');

aiSelectedRuns = find(ismember(strctRuns.m_acValidRunNames,astrctAnalysis(iAnalysisIndex).m_acRuns));

for iRunIter=1:length(aiSelectedRuns)
    switch iSelectedViewType
        case 1
             % Remove anything above threshold
            a2fMotion = strctRuns.m_acMotion{aiSelectedRuns(iRunIter)};
            if ~isempty(a2fMotion)
                afCurve = sqrt(sum(a2fMotion(:,1:3).^2,2));
                aiInd = find(afCurve > fThreshold);
              if ~isempty(aiInd)
                   strctRuns.m_acTPEF{aiSelectedRuns(iRunIter)} = unique([strctRuns.m_acTPEF{aiSelectedRuns(iRunIter)}(:)', aiInd(:)']);
                end
            end
        case 2
           % Remove anything above threshold
            a2fMotion = strctRuns.m_acMotion{aiSelectedRuns(iRunIter)};
            if ~isempty(a2fMotion)
               afCurve = sqrt(sum(a2fMotion(:,1:3).^2,2));
                afCurve = afCurve - mean(afCurve);
                aiInd = find(afCurve > fThreshold | afCurve < -fThreshold);
                 if ~isempty(aiInd)
                    strctRuns.m_acTPEF{aiSelectedRuns(iRunIter)} = unique([strctRuns.m_acTPEF{aiSelectedRuns(iRunIter)}(:)', aiInd(:)']);
                end
            end
        case 3
            
            
            if isfield(strctRuns,'m_acDistToFixation')
                
                afCurve = strctRuns.m_acDistToFixation{aiSelectedRuns(iRunIter)};
                
                 aiInd = find(afCurve > fThreshold );
                 if ~isempty(aiInd)
                    % Convert TRs to actual time points
                    strctRuns.m_acTPEF{aiSelectedRuns(iRunIter)} = unique([strctRuns.m_acTPEF{aiSelectedRuns(iRunIter)}(:)', aiInd(:)']);                    
                end
            end
            
            
            
    end
    
            
    
    
    
end


setappdata(handles.figure1,'strctRuns',strctRuns);
fnWriteTPEFToDisk(handles);

fnPlotRuns(handles);
return;

function fnWriteTPEFToDisk(handles)
strSessionRootFolder = getappdata(handles.figure1,'strSessionRootFolder');
strctRuns = getappdata(handles.figure1,'strctRuns');
for iIter=1:length(strctRuns.m_acValidRunNames)
   strTpefFile= [strSessionRootFolder,'/bold/',strctRuns.m_acValidRunNames{iIter},'/tpef'];
   hFileID = fopen(strTpefFile,'w+');
   for k=1:length(strctRuns.m_acTPEF{iIter})
       fprintf(hFileID,'%d\n',strctRuns.m_acTPEF{iIter}(k));
   end
   fclose(hFileID);
end
return;


function hClearTimePointExclsuion_Callback(hObject, eventdata, handles)
strctRuns = getappdata(handles.figure1,'strctRuns');
astrctAnalysis=getappdata(handles.figure1,'astrctAnalysis');
iAnalysisIndex =get(handles.hAnalList,'value');

aiSelectedRuns = find(ismember(strctRuns.m_acValidRunNames,astrctAnalysis(iAnalysisIndex).m_acRuns));

for iRunIter=1:length(aiSelectedRuns)
    
     strctRuns.m_acTPEF{aiSelectedRuns(iRunIter)} = [];
end
setappdata(handles.figure1,'strctRuns',strctRuns);
fnWriteTPEFToDisk(handles);

fnPlotRuns(handles);
return;


% --- Executes when selected object is changed in hDisplayPanel.
function hDisplayPanel_SelectionChangeFcn(hObject, eventdata, handles)
abValues = [get(handles.hBodyMotion,'value'),get(handles.hBodyMotionRelative,'value'),get(handles.hEyeDist,'value')];
iSelectedViewType = find(abValues);
switch iSelectedViewType
    case 1
        set(handles.hThresholdSlider,'min',0,'max',1,'value',0.5);
    case 2
        set(handles.hThresholdSlider,'min',0,'max',1,'value',0.5);
    case 3
        set(handles.hThresholdSlider,'min',0,'max',800,'value',200);
        
end

fnPlotRuns(handles);
