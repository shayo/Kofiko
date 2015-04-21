function varargout = SpikeSorter(varargin)
% SPIKESORTER M-file for SpikeSorter.fig
%      SPIKESORTER, by itself, creates a new SPIKESORTER or raises the existing
%      singleton*.
%
%      H = SPIKESORTER returns the handle to a new SPIKESORTER or the handle to
%      the existing singleton*.
%
%      SPIKESORTER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SPIKESORTER.M with the given input arguments.
%
%      SPIKESORTER('Property','Value',...) creates a new SPIKESORTER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SpikeSorter_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SpikeSorter_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SpikeSorter

% Last Modified by GUIDE v2.5 17-Jul-2013 10:27:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SpikeSorter_OpeningFcn, ...
                   'gui_OutputFcn',  @SpikeSorter_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    warning off
    gui_State.gui_Callback = str2func(varargin{1});
    warning on
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before SpikeSorter is made visible.
function SpikeSorter_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SpikeSorter (see VARARGIN)

% Choose default command line output for SpikeSorter
handles.output = hObject;

dbstop if error

hIntervalMenu = uicontextmenu;
itemm0 = uimenu(hIntervalMenu, 'Label', 'Squeeze Interval', 'Callback', {@fnSqueezeInterval,handles});
item0 = uimenu(hIntervalMenu, 'Label', 'Split', 'Callback', {@fnSplitUnit,handles});
item1 = uimenu(hIntervalMenu, 'Label', 'Delete', 'Callback', {@fnDeleteInterval,handles});
item2 = uimenu(hIntervalMenu, 'Label', 'Merge', 'Callback', {@fnMergeIntervals,handles});
item3 = uimenu(hIntervalMenu, 'Label', 'Remove All Spikes', 'Callback', {@fnClearUnitSpikes,handles});
item4 = uimenu(hIntervalMenu, 'Label', 'Clean Outliers', 'Callback', {@fnCleanUnitSpikes,handles});
item5 = uimenu(hIntervalMenu, 'Label', 'Change Color', 'Callback', {@fnChangeUnitColor,handles});
item6 = uimenu(hIntervalMenu, 'Label', 'Toggle Visible', 'Callback', {@fnToggleVisibility,handles});
hIntervalMenu2 = uicontextmenu;
item1 = uimenu(hIntervalMenu2, 'Label', 'New Interval', 'Callback', {@fnAddNewInterval,handles});
setappdata(handles.figure1,'hIntervalMenu',hIntervalMenu);
setappdata(handles.figure1,'hIntervalMenu2',hIntervalMenu2);
set(handles.figure1,'CloseRequestFcn',@fnMyClose)

setappdata(handles.figure1,'bControlDown',false);
setappdata(handles.figure1,'bShiftDown',false);

%% Read Raw units from plexon
% strRawFolder = 'D:\Data\Doris\Electrophys\Houdini\Axial Probe\110616_161910\RAW\';
% strRawFolder = 'D:\Data\Doris\Electrophys\Houdini\Targeting ML and PL 2011\New Recordings New Format\110613\RAW\';

% attempt to load the sync file

if isempty(varargin)
    strRawFolder=uigetdir();
%    aiInd = find(strRawFolder == filesep);
    strSessionName = '';
else
    %[strRawFolder,strSessionName] =fileparts( varargin{1});
    strRawFolder = varargin{1};
    strSessionName=varargin{2};
end
set(handles.figure1,'Name', strSessionName);
if strRawFolder(end) ~= filesep()
    strRawFolder(end+1) = filesep();
end
strSyncFile = [strRawFolder,strSessionName,'-sync.mat'];
if exist(strSyncFile,'file')
    strctTmp = load(strSyncFile);
    setappdata(handles.figure1,'strctSync',strctTmp.strctSync);
else
    setappdata(handles.figure1,'strctSync',[]);
end

setappdata(handles.figure1,'strRawFolder',strRawFolder);
setappdata(handles.figure1,'strSessionName',strSessionName);

bNoFiles = fnScanAndUpdateFileList(handles);
if bNoFiles
    delete(handles.figure1);
    return;
end;

fnChangeChannel(handles);

%fnInitializeFirstTime(handles,strRawFolder);
    


set(handles.figure1,'WindowButtonMotionFcn',@fnMouseMove);
set(handles.figure1,'WindowButtonDownFcn',@fnMouseDown);
set(handles.figure1,'WindowButtonUpFcn',@fnMouseUp);
set(handles.figure1,'WindowScrollWheelFcn',@fnMouseWheel);
set(handles.figure1,'KeyPressFcn',@fnKeyDown);
set(handles.figure1,'KeyReleaseFcn',@fnKeyUp);
set(handles.figure1,'Units','pixels');
set(handles.figure1,'UserData',handles);
set(handles.hPCA,'Units','pixels');
set(handles.hPCA,'visible','off');
set(handles.hWaves,'visible','off');
set(handles.hWaves,'Units','pixels','color',[0 0 0]);
set(handles.hTimeLine,'units','pixels','UIContextmenu',hIntervalMenu2);
hold(handles.hPCA,'on');
hold(handles.hWaves,'on');

fnInvalidateIntervals(handles,true);
fnInvalidatePCA(handles,false,true);
% Update handles structure
guidata(hObject, handles);




% UIWAIT makes SpikeSorter wait for user response (see UIRESUME)
% uiwait(handles.figure1);



function fnMyClose(src,evnt)
try
handles = get(src,'userdata');
acUnitAssociation = getappdata(handles.figure1,'acUnitAssociation');
acIntervals = getappdata(handles.figure1,'acIntervals');
if length(acUnitAssociation) > 1 || length(acIntervals) > 1
    % Need to save things first (!!!)
    Answer=questdlg('Changed were made to this channel. Save?','Warning!','Save','Discard','Save');
    if strcmp(Answer,'Save')
        fnSaveCurrentChannel(handles);
    end
end
catch
end
delete(gcf)
  
return;


function [astrctIntervals,aiNewAssoc] = fnGenerateDefaultIntervals(strctSync,astrctRawUnits,afSortedAllTS)
% Simplest approach first..
aiNewAssoc = zeros(1, length(afSortedAllTS));

if isempty(strctSync)
    aiAvailableUnits = cat(1,astrctRawUnits.m_iUnitIndex);
    aiNonZero = find(aiAvailableUnits ~= 0);
    
    for k=1:length(aiNonZero)
        iUniqueID = aiAvailableUnits(aiNonZero(k));
        aiNewAssoc(ismember(afSortedAllTS, astrctRawUnits(aiNonZero(k)).m_afTimestamps)) = iUniqueID;
        astrctIntervals(k) =  fnBuildNewInterval(...
            astrctRawUnits(aiNonZero(k)).m_afInterval(1),...
            astrctRawUnits(aiNonZero(k)).m_afInterval(2),...
            iUniqueID, fnGetDefaultUnitColors(iUniqueID));
    end
else
    % Split units using frames...
    aiAvailableUnits = cat(1,astrctRawUnits.m_iUnitIndex);
    aiNonZero = find(aiAvailableUnits ~= 0);
    
    iCounter = 1;
    iNumFrames = length(strctSync.m_strctKofikoToPlexon.m_afStartFrameTS_PLX);
    for iUnitIter=1:length(aiNonZero)
        for iFrameIter=1:iNumFrames
            aiInd = find(astrctRawUnits(aiNonZero(iUnitIter)).m_afTimestamps >= strctSync.m_strctKofikoToPlexon.m_afStartFrameTS_PLX(iFrameIter) & ...
                astrctRawUnits(aiNonZero(iUnitIter)).m_afTimestamps <= strctSync.m_strctKofikoToPlexon.m_afEndFrameTS_PLX(iFrameIter));
            if ~isempty(aiInd)
                % Add unit!
                fMin = min(astrctRawUnits(aiNonZero(iUnitIter)).m_afTimestamps(aiInd));
                fMax = max(astrctRawUnits(aiNonZero(iUnitIter)).m_afTimestamps(aiInd));
                aiNewAssoc(ismember(afSortedAllTS, astrctRawUnits(aiNonZero(iUnitIter)).m_afTimestamps)) = iCounter;
                astrctIntervals(iCounter) =  fnBuildNewInterval(fMin,fMax,iCounter, fnGetDefaultUnitColors(iCounter));
                iCounter=iCounter+1;
            end
        end
    end
end
if ~isempty(aiNonZero)
aiUnitVertical = fnGetIntervalVerticalValue(astrctIntervals,false);
for k=1:length(aiNonZero)
    astrctIntervals(k).m_iVerticalStack = aiUnitVertical(k);
end
else
    astrctIntervals = [];
end
return;

function fnSqueezeInterval(a,b,handles)
strctGUIParams = getappdata(handles.figure1,'strctGUIParams');
if isempty(strctGUIParams.m_aiSelectedIntervals) ||  length(strctGUIParams.m_aiSelectedIntervals) ~= 1
    return;
end
astrctUnitIntervals = fnGetIntervals(handles);
aiSpikeToUniqueID = fnGetUnitAssociation(handles);

afSortedAllTS = getappdata(handles.figure1,'afSortedAllTS');

aiRelevantSpikes = find(aiSpikeToUniqueID == astrctUnitIntervals(strctGUIParams.m_aiSelectedIntervals).m_iUniqueID);
astrctUnitIntervals(strctGUIParams.m_aiSelectedIntervals).m_fStartTS_Plexon = max(astrctUnitIntervals(strctGUIParams.m_aiSelectedIntervals).m_fStartTS_Plexon,min(afSortedAllTS(aiRelevantSpikes)));
astrctUnitIntervals(strctGUIParams.m_aiSelectedIntervals).m_fEndTS_Plexon = min(astrctUnitIntervals(strctGUIParams.m_aiSelectedIntervals).m_fEndTS_Plexon,max(afSortedAllTS(aiRelevantSpikes)));

fnUpdateIntervals(handles,astrctUnitIntervals,false);
fnInvalidateIntervalsAux(handles,astrctUnitIntervals,false,true);
fnInvalidatePCA(handles,false,false);
return;

function fnToggleVissible(handles)
fnToggleVisibility([],[],handles);
return;

function fnToggleVisibility(a,b,handles)
strctGUIParams = getappdata(handles.figure1,'strctGUIParams');
if isempty(strctGUIParams.m_aiSelectedIntervals) ||  length(strctGUIParams.m_aiSelectedIntervals) ~= 1
    return;
end
astrctUnitIntervals = fnGetIntervals(handles);
astrctUnitIntervals(strctGUIParams.m_aiSelectedIntervals).m_bVisible= ~astrctUnitIntervals(strctGUIParams.m_aiSelectedIntervals).m_bVisible;

fnUpdateIntervals(handles,astrctUnitIntervals,false);
fnInvalidateIntervalsAux(handles,astrctUnitIntervals,false,true);
fnInvalidatePCA(handles,false,false);
return;

function fnChangeUnitColor(a,b,handles)
strctGUIParams = getappdata(handles.figure1,'strctGUIParams');
if isempty(strctGUIParams.m_aiSelectedIntervals) ||  length(strctGUIParams.m_aiSelectedIntervals) ~= 1
    return;
end
afColor=uisetcolor();
if length(afColor) < 3
    return;
end

astrctUnitIntervals = fnGetIntervals(handles);
astrctUnitIntervals(strctGUIParams.m_aiSelectedIntervals).m_afColor = afColor;

fnUpdateIntervals(handles,astrctUnitIntervals,false);
fnInvalidateIntervalsAux(handles,astrctUnitIntervals,false,true);
fnInvalidatePCA(handles,false,false);
return;

function fnClearUnitSpikes(a,b,handles)
strctGUIParams = getappdata(handles.figure1,'strctGUIParams');
if isempty(strctGUIParams.m_aiSelectedIntervals) ||  length(strctGUIParams.m_aiSelectedIntervals) ~= 1
    return;
end
aiSpikeToUniqueID = fnGetUnitAssociation(handles);
astrctUnitIntervals = fnGetIntervals(handles);
aiSpikeToUniqueID(aiSpikeToUniqueID==astrctUnitIntervals(strctGUIParams.m_aiSelectedIntervals).m_iUniqueID)=0;
fnUpdateSpikeAssociation(handles,aiSpikeToUniqueID);
fnInvalidatePCA(handles,false,false);

return;

function fnCleanUnitSpikes(a,b,handles)
strctGUIParams = getappdata(handles.figure1,'strctGUIParams');
if isempty(strctGUIParams.m_aiSelectedIntervals) ||  length(strctGUIParams.m_aiSelectedIntervals) ~= 1
    return;
end

astrctUnitIntervals = fnGetIntervals(handles);
strctInterval = astrctUnitIntervals(strctGUIParams.m_aiSelectedIntervals);
% afSortedAllTS = getappdata(handles.figure1,'afSortedAllTS');
% aiAllSpikesInInterval = find(afSortedAllTS >= strctInterval.m_fStartTS_Plexon& afSortedAllTS <= strctInterval.m_fEndTS_Plexon);\

a2fPCA = getappdata(handles.figure1,'a2fPCA');

% Stationary clean

aiSpikeToUniqueID = fnGetUnitAssociation(handles);
abIntervalSpikes = aiSpikeToUniqueID == strctInterval.m_iUniqueID;

afRobustMean = median(a2fPCA(abIntervalSpikes,:),1);
X = [a2fPCA(abIntervalSpikes,1), a2fPCA(abIntervalSpikes,2)];
Xt = [X(:,1)-afRobustMean(1), X(:,2)-afRobustMean(2)];
X11= median(Xt(:,1).^2);
X12 =median(Xt(:,1).*Xt(:,2));
X22 =median(Xt(:,2).*Xt(:,2));
a2fRobustCov = [X11,X12;X12,X22];    
a2fCov=a2fRobustCov;%Xt'*Xt * 1/size(Xt,1);
[V,E]=eig(a2fCov);
afDist1 = abs((Xt * V(:,1)) / sqrt(E(1)));
afDist2 = abs((Xt * V(:,2)) / sqrt(E(4)));
abOutliers = sqrt(afDist1.^2 + afDist2.^2) > 3;

aiIntervalSpikes = find(abIntervalSpikes);
aiOutliers = aiIntervalSpikes(abOutliers);

aiSpikeToUniqueID(aiOutliers) = 0;
fnUpdateSpikeAssociation(handles,aiSpikeToUniqueID);
fnInvalidatePCA(handles,false,false);

% 
%      
% figure(10);
% clf;
% plot(X(:,1),X(:,2),'b.');
% hold on;
% fnDrawEllipses(gca,afRobustMean',a2fCov,[0 1 0],2,[-Inf Inf],[-Inf Inf]);
% plot(X(abOutliers,1),X(abOutliers,2),'ro');

% How many Std is each spike ?
return;

function fnUpdateSpikeAssociation(handles,aiSpikeToUniqueID)
acUnitAssociation = getappdata(handles.figure1,'acUnitAssociation');
fnSubmitChange(handles,{'Spikes'});
iNumEntries = length(acUnitAssociation);
acUnitAssociation{iNumEntries+1} = aiSpikeToUniqueID;
setappdata(handles.figure1,'acUnitAssociation',acUnitAssociation);
return;


function fnAddNewInterval(a,b,handles)
iNewUniqueValue = getappdata(handles.figure1,'iMaxUniqueID')+1;
strctMouseDownOp = getappdata(handles.figure1,'strctLastMouseDownOp');
strctGUIParams = getappdata(handles.figure1,'strctGUIParams');
astrctUnitIntervals = fnGetIntervals(handles);
afColor  = fnGetDefaultUnitColors(iNewUniqueValue);

fNewStartTS = astrctUnitIntervals(1).m_fStartTS_Plexon;
fNewEndTS = astrctUnitIntervals(1).m_fEndTS_Plexon;    

astrctUnitIntervals(end+1) = fnBuildNewInterval(...
    fNewStartTS, fNewEndTS,...
    iNewUniqueValue,afColor  );

strctGUIParams.m_aiSelectedIntervals = length(astrctUnitIntervals);
setappdata(handles.figure1,'strctGUIParams',strctGUIParams);

fnUpdateIntervals(handles,astrctUnitIntervals,false);
setappdata(handles.figure1,'iMaxUniqueID',iNewUniqueValue);
fnInvalidateIntervalsAux(handles,astrctUnitIntervals,false,true);
fnInvalidateIntervals(handles,true);
return;


function fnMergeIntervals(a,b,handles)
strctGUIParams = getappdata(handles.figure1,'strctGUIParams');
if ~isempty(strctGUIParams.m_aiSelectedIntervals) &&  length(strctGUIParams.m_aiSelectedIntervals)>1
    astrctUnitIntervals = fnGetIntervals(handles);
    aiSpikeToUniqueID = fnGetUnitAssociation(handles);
    
    % First, find the start and end 
    fNewStartTS = min(cat(1,astrctUnitIntervals(strctGUIParams.m_aiSelectedIntervals).m_fStartTS_Plexon));
    fNewEndTS = max(cat(1,astrctUnitIntervals(strctGUIParams.m_aiSelectedIntervals).m_fEndTS_Plexon));
    % Set a new ID for this unit
    iMaxUniqueID = getappdata(handles.figure1,'iMaxUniqueID');
    iNewUniqueValue = iMaxUniqueID+1;
    % Assign spikes to new unit
    afColor = [0 0 0];
    for k=1:length(strctGUIParams.m_aiSelectedIntervals)
        aiSpikeToUniqueID(aiSpikeToUniqueID== astrctUnitIntervals(strctGUIParams.m_aiSelectedIntervals(k)).m_iUniqueID) = iNewUniqueValue;
        afColor = afColor + astrctUnitIntervals(strctGUIParams.m_aiSelectedIntervals(k)).m_afColor;
    end
    afColor  = afColor  / length(strctGUIParams.m_aiSelectedIntervals);
    setappdata(handles.figure1,'iMaxUniqueID',iNewUniqueValue);
    
    fnUpdateSpikeAssociation(handles,aiSpikeToUniqueID);
    % Remove intervals
    astrctUnitIntervals(strctGUIParams.m_aiSelectedIntervals) = [];
    % Set new interval
    astrctUnitIntervals(end+1) = fnBuildNewInterval(fNewStartTS, fNewEndTS,iNewUniqueValue,afColor  );
    
    % Update Y interval
    
    fnUpdateIntervals(handles,astrctUnitIntervals,false);

    acUndoOperations = getappdata(handles.figure1,'acUndoOperations');
    acUndoOperations = [acUndoOperations(1:end-2), { {'Spikes','Intervals'}}];
    setappdata(handles.figure1,'acUndoOperations',acUndoOperations);
    

    fnInvalidateIntervalsAux(handles,astrctUnitIntervals,false,true);
    fnInvalidatePCA(handles,false,false);
end

return;

function strctInterval = fnBuildNewInterval(fStartTS, fEndTS,iNewUniqueValue,afColor )
strctInterval.m_iUniqueID = iNewUniqueValue;
strctInterval.m_fStartTS_Plexon = fStartTS;
strctInterval.m_fEndTS_Plexon = fEndTS;
strctInterval.m_afColor = afColor;
strctInterval.m_iVerticalStack = 1;
strctInterval.m_bVisible = true;
return;

 
function fnDeleteInterval(a,b,handles)
strctGUIParams = getappdata(handles.figure1,'strctGUIParams');
if ~isempty(strctGUIParams.m_aiSelectedIntervals)
    astrctUnitIntervals = fnGetIntervals(handles);
    
    aiSpikeToUniqueID = fnGetUnitAssociation(handles);
    % Clear up asssciation...
    
    for k=1:length(strctGUIParams.m_aiSelectedIntervals)
        aiSpikeToUniqueID(aiSpikeToUniqueID==astrctUnitIntervals(strctGUIParams.m_aiSelectedIntervals(k)).m_iUniqueID) = 0;
    end;
    fnUpdateSpikeAssociation(handles,aiSpikeToUniqueID);
    
    astrctUnitIntervals(strctGUIParams.m_aiSelectedIntervals) = [];
    fnUpdateIntervals(handles,astrctUnitIntervals,false);
    astrctUnitIntervals = fnGetIntervals(handles);
    acUndoOperations = getappdata(handles.figure1,'acUndoOperations');
    acUndoOperations = [acUndoOperations(1:end-2), { {'Spikes','Intervals'}}];
    setappdata(handles.figure1,'acUndoOperations',acUndoOperations);
    
    strctGUIParams.m_aiSelectedIntervals = [];
    setappdata(handles.figure1,'strctGUIParams',strctGUIParams);
        
    fnInvalidateIntervalsAux(handles,astrctUnitIntervals,true,true);
    fnInvalidatePCA(handles,false,false);
end

return;


function aiSpikeToUniqueID = fnGetUnitAssociation(handles)
acUnitAssociation = getappdata(handles.figure1,'acUnitAssociation');
aiSpikeToUniqueID = acUnitAssociation{end};
return;

function astrctUnitIntervals = fnGetIntervals(handles)
acIntervals = getappdata(handles.figure1,'acIntervals');
astrctUnitIntervals = acIntervals{end};
return;

function bInsideRect = fnInsideRect(pt2fMouse, aiRect)
bInsideRect =  pt2fMouse(1) >= aiRect(1) && pt2fMouse(1) <= aiRect(1)+aiRect(3) &&  ...
        pt2fMouse(2) >= aiRect(2) && pt2fMouse(2) <= aiRect(2)+aiRect(4);
return;

function fnMouseWheel(obj,eventdata)
handles=get(obj,'UserData');

Tmp=get(handles.figure1,'CurrentPoint');
pt2fMouse = round(Tmp(1,1:2));

aiTimelineRect = get(handles.hTimeLine,'Position');
aiPCARect = get(handles.hPCA,'Position');
aiWaveRect = get(handles.hWaves,'Position');


if fnInsideRect(pt2fMouse,aiTimelineRect)
    strctGUIParams = getappdata(handles.figure1,'strctGUIParams');
    Tmp=get(handles.hTimeLine,'CurrentPoint');
    fZoomAtTimePoint = Tmp(1);
    
    fCurrentZoom = strctGUIParams.m_afTimeRange(2)-strctGUIParams.m_afTimeRange(1);
    
    if  eventdata.VerticalScrollCount < 0
         strctGUIParams.m_afTimeRange(1) = fZoomAtTimePoint-fCurrentZoom * 1.5;
         strctGUIParams.m_afTimeRange(2) = fZoomAtTimePoint+fCurrentZoom * 1.5;
     else
        strctGUIParams.m_afTimeRange(1) = fZoomAtTimePoint-fCurrentZoom * 0.5;
        strctGUIParams.m_afTimeRange(2) = fZoomAtTimePoint+fCurrentZoom * 0.5;
    end
    afSortedAllTS = getappdata(handles.figure1,'afSortedAllTS');

        astrctIntervals =  fnGetIntervals(handles);
        if ~isempty(astrctIntervals)
            fMaxIntervalTS = max(cat(1,astrctIntervals.m_fEndTS_Plexon));
        else
            fMaxIntervalTS = -Inf;
        end
        
    strctGUIParams.m_afTimeRange(1) = max(0, strctGUIParams.m_afTimeRange(1));
    strctGUIParams.m_afTimeRange(2) = min(max(fMaxIntervalTS, afSortedAllTS(end)), strctGUIParams.m_afTimeRange(2));
    
    if strctGUIParams.m_afTimeRange(2)-strctGUIParams.m_afTimeRange(1) > 60 * 10
        % Move viewing interval
        fViewingLength = astrctIntervals(1).m_fEndTS_Plexon - astrctIntervals(1).m_fStartTS_Plexon;
        % New viewing center
        astrctIntervals(1).m_fStartTS_Plexon = fZoomAtTimePoint-fViewingLength/2;
        astrctIntervals(1).m_fEndTS_Plexon = fZoomAtTimePoint+fViewingLength/2;
        
        fnUpdateIntervals(handles,astrctIntervals,true);
        setappdata(handles.figure1,'strctGUIParams',strctGUIParams);
         fnInvalidateIntervals(handles,true);
        
    end

elseif fnInsideRect(pt2fMouse,aiPCARect)
    Tmp=get(handles.hPCA,'CurrentPoint');
    pt2fZoomAtPoint = round(Tmp(1,1:2));
 
    strctGUIParams = getappdata(handles.figure1,'strctGUIParams');
    
    if  eventdata.VerticalScrollCount < 0
        fScale = 1.1;
    else
        fScale = 0.9;
    end;
    
     
    a2fPCA = getappdata(handles.figure1,'a2fPCA');
    fMinX = min(a2fPCA(:,1));
    fMaxX = max(a2fPCA(:,1));
    fMinY = min(a2fPCA(:,2));
    fMaxY = max(a2fPCA(:,2));
   
    fXZoom = fScale*(strctGUIParams.m_afRangePCA(2)-strctGUIParams.m_afRangePCA(1));
    fYZoom = fScale*(strctGUIParams.m_afRangePCA(4)-strctGUIParams.m_afRangePCA(3));

    
    strctGUIParams.m_afRangePCA = [...
        min(fMaxX, max(fMinX,pt2fZoomAtPoint(1) - fXZoom/2)),...
        max(fMinX, min(fMaxX,pt2fZoomAtPoint(1) + fXZoom/2)),...
        min(fMaxY, max(fMinY,pt2fZoomAtPoint(2) - fYZoom/2)),...
        max(fMinY, min(fMaxY,pt2fZoomAtPoint(2) + fYZoom/2))];
    
    
    setappdata(handles.figure1,'strctGUIParams',strctGUIParams);
    fnInvalidatePCA(handles,false,true);
    
elseif fnInsideRect(pt2fMouse,aiWaveRect)
% fprintf('Inside Wave rect\n');
end

return




function [iIntervalIndex, strWhere] = fnMouseOnInterval(handles)
astrctUnitIntervals = fnGetIntervals(handles);
afSortedAllTS = getappdata(handles.figure1,'afSortedAllTS');
if ~isempty(astrctUnitIntervals)
    fZero = max(0,min([afSortedAllTS(1); cat(1,astrctUnitIntervals.m_fStartTS_Plexon)]));
else
    fZero = afSortedAllTS(1);
end

fHeight=0.2;
iNumIntervals = length(astrctUnitIntervals);
Tmp=get(handles.hTimeLine,'CurrentPoint');
%    set(handles.hTimeLine,'ytick',0:0.1:3,'yticklabel',[])
pt2fMouseTime = round(Tmp(1,1:2));
iIntervalIndex = [];
strWhere = [];
set(handles.figure1, 'Pointer', 'arrow');
for iIntervalIter=1:iNumIntervals
    fStartX = astrctUnitIntervals(iIntervalIter).m_fStartTS_Plexon-fZero;
    fEndX = astrctUnitIntervals(iIntervalIter).m_fEndTS_Plexon-fZero;
    fStartY = astrctUnitIntervals(iIntervalIter).m_iVerticalStack-fHeight;
    fEndY = astrctUnitIntervals(iIntervalIter).m_iVerticalStack+fHeight;
    if pt2fMouseTime(1) >= fStartX && pt2fMouseTime(1) <= fEndX &&  pt2fMouseTime(2) >= fStartY &&  pt2fMouseTime(2) <= fEndY
        
        fLength = fEndX-fStartX;
        if pt2fMouseTime(1) >= fStartX && pt2fMouseTime(1) <= fStartX+fLength*0.2
          %  fprintf('Inside Left side of Interval %d\n',astrctUnitIntervals(iIntervalIter).m_iUniqueID);
            set(handles.figure1, 'Pointer', 'left');
            strWhere = 'Left';
        elseif pt2fMouseTime(1) >= fStartX+fLength*0.8
         %   fprintf('Inside Right side of Interval %d\n',astrctUnitIntervals(iIntervalIter).m_iUniqueID);
            set(handles.figure1, 'Pointer', 'right');
            strWhere = 'Right';
        else
            %fprintf('Inside Center of Interval %d\n',astrctUnitIntervals(iIntervalIter).m_iUniqueID);
            set(handles.figure1, 'Pointer', 'fleur');
            strWhere = 'Center';
        end
        
        iIntervalIndex = iIntervalIter;
        break;
    end
end
return;

    
function [strWindow, pt2fPositionInWindow, hHandle] = fnGetActiveWindow(handles)
       
aiTimelineRect = get(handles.hTimeLine,'Position');
aiPCARect = get(handles.hPCA,'Position');
aiWaveRect = get(handles.hWaves,'Position');
pt2fMouse = get(handles.figure1,'CurrentPoint');
strWindow = [];
pt2fPositionInWindow = [];
hHandle=[];
if fnInsideRect(pt2fMouse,aiTimelineRect)
    strWindow = 'Timeline';
    Tmp = get(handles.hTimeLine,'CurrentPoint');
    pt2fPositionInWindow = Tmp(1,1:2);
    hHandle = handles.hTimeLine;
elseif fnInsideRect(pt2fMouse,aiPCARect)
    strWindow = 'PCA';
    Tmp = get(handles.hPCA,'CurrentPoint');
    pt2fPositionInWindow = Tmp(1,1:2);
    hHandle = handles.hPCA;
elseif fnInsideRect(pt2fMouse,aiWaveRect)
     Tmp  = get(handles.hWaves,'CurrentPoint');
     pt2fPositionInWindow = Tmp(1,1:2);
    strWindow = 'Waves';
    hHandle = handles.hWaves;
else
    
end
return;


function fnMouseMove(obj,eventdata)
handles=get(obj,'UserData');
setappdata(handles.figure1,'bMouseMoved',true);

strctMousePrevOp = getappdata(handles.figure1,'strctMousePrevOp');
strctMouseOp.m_pt2fPositionInFigure = get(handles.figure1,'CurrentPoint');
[strctMouseOp.m_strWindow, strctMouseOp.m_pt2fPositionInWindow,strctMouseOp.m_hAxes] = fnGetActiveWindow(handles);
if strcmp(strctMouseOp.m_strWindow,'Timeline')
    [strctMouseOp.m_iIntervalIndex, strctMouseOp.m_strWhere] = fnMouseOnInterval(handles);
end

strctMouseDownOp = getappdata(handles.figure1,'strctMouseDownOp');
strctGUIParams = getappdata(handles.figure1,'strctGUIParams');
if isempty(strctMouseDownOp) || isempty(strctMouseDownOp.m_strWindow)
    setappdata(handles.figure1,'strctMousePrevOp',strctMouseOp);
    return;
end;

if strcmp(strctGUIParams.m_strMouseMode,'TwoClickLineObject') &&  strcmp(strctMouseDownOp.m_strWindow,strctMouseOp.m_strWindow)
    hTwoClickObjectTempLine = getappdata(handles.figure1,'hTwoClickObjectTempLine');
    if ~isempty(hTwoClickObjectTempLine) && ishandle(hTwoClickObjectTempLine)
          set(hTwoClickObjectTempLine,'xdata',...
             [strctMouseDownOp.m_pt2fPositionInWindow(1),strctMouseOp.m_pt2fPositionInWindow(1)],...
             'ydata',[strctMouseDownOp.m_pt2fPositionInWindow(2),strctMouseOp.m_pt2fPositionInWindow(2)]);
       else
         hTwoClickObjectTempLine = plot(strctMouseDownOp.m_hAxes,...
             [strctMouseDownOp.m_pt2fPositionInWindow(1),strctMouseOp.m_pt2fPositionInWindow(1)],...
             [strctMouseDownOp.m_pt2fPositionInWindow(2),strctMouseOp.m_pt2fPositionInWindow(2)],'r','LineWidth',2);
         setappdata(handles.figure1,'hTwoClickObjectTempLine',hTwoClickObjectTempLine);
     end;     
end

if strcmp(strctGUIParams.m_strMouseMode,'ContourObject') && strcmp(strctMouseDownOp.m_strWindow,strctMouseOp.m_strWindow)
    hContourObject = getappdata(handles.figure1,'hContourObject');
    if ~isempty(hContourObject) && ishandle(hContourObject)
        afX = get(hContourObject,'xdata');
        afY = get(hContourObject,'ydata');
        
%         if strctMouseOp.m_pt2fPositionInWindow(1) ~= afX(end) && strctMouseOp.m_pt2fPositionInWindow(2) ~= afY(end)
            set(hContourObject,'xdata',[ afX, strctMouseOp.m_pt2fPositionInWindow(1)],...
                'ydata', [afY, strctMouseOp.m_pt2fPositionInWindow(2)]);
            
%         end
    else
        hContourObject = plot(strctMouseDownOp.m_hAxes,...
            [strctMouseDownOp.m_pt2fPositionInWindow(1),strctMouseOp.m_pt2fPositionInWindow(1)],...
            [strctMouseDownOp.m_pt2fPositionInWindow(2),strctMouseOp.m_pt2fPositionInWindow(2)],'r','LineWidth',2);
        setappdata(handles.figure1,'hContourObject',hContourObject);
    end;
end
% Mouse is moving while pressed!
switch strctMouseDownOp.m_strWindow
    case 'PCA'
    case 'Timeline'
        switch strctGUIParams.m_strMouseMode
            case 'IntervalChange'
            if strcmp(strctMouseDownOp.m_strWindow,strctMouseOp.m_strWindow) && ...
                ~isempty(strctMouseDownOp.m_iIntervalIndex) 
                afSortedAllTS = getappdata(handles.figure1,'afSortedAllTS');
                
                astrctUnitIntervals = fnGetIntervals(handles);
                if ~isempty(astrctUnitIntervals)
                    fZero = max(0,min([afSortedAllTS(1); cat(1,astrctUnitIntervals.m_fStartTS_Plexon)]));
                else
                    fZero = afSortedAllTS(1);
                end
                
 
                  switch strctMouseDownOp.m_strWhere
                    case 'Left'
                        strctMouseDownOp.m_astrctIntervals(strctMouseDownOp.m_iIntervalIndex).m_fStartTS_Plexon = ...
                            min(strctMouseDownOp.m_astrctIntervals(strctMouseDownOp.m_iIntervalIndex).m_fEndTS_Plexon - 5, strctMouseOp.m_pt2fPositionInWindow(1)+fZero);
                     case 'Right'
                        strctMouseDownOp.m_astrctIntervals(strctMouseDownOp.m_iIntervalIndex).m_fEndTS_Plexon = ...
                            max(strctMouseDownOp.m_astrctIntervals(strctMouseDownOp.m_iIntervalIndex).m_fStartTS_Plexon + 5, strctMouseOp.m_pt2fPositionInWindow(1)+fZero);
                       % strctGUIParams.m_fCurrentTime = strctMouseDownOp.m_astrctIntervals(strctMouseDownOp.m_iIntervalIndex).m_fEndTS_Plexon-strctGUIParams.m_fTimeWindowSec;
                    case 'Center'

                        if ~isempty(strctMousePrevOp)
                            fDelta = strctMouseOp.m_pt2fPositionInWindow(1)-strctMouseDownOp.m_pt2fPositionInWindow(1);
                            strctMouseDownOp.m_astrctIntervals(strctMouseDownOp.m_iIntervalIndex).m_fStartTS_Plexon = ...
                                strctMouseDownOp.m_astrctIntervalsBefore(strctMouseDownOp.m_iIntervalIndex).m_fStartTS_Plexon+fDelta;
                            strctMouseDownOp.m_astrctIntervals(strctMouseDownOp.m_iIntervalIndex).m_fEndTS_Plexon = ...
                                strctMouseDownOp.m_astrctIntervalsBefore(strctMouseDownOp.m_iIntervalIndex).m_fEndTS_Plexon+fDelta;
                        end
                  end
                
               setappdata(handles.figure1,'strctMouseDownOp',strctMouseDownOp);
               setappdata(handles.figure1,'strctGUIParams',strctGUIParams);
               fnInvalidateIntervalsAux(handles,strctMouseDownOp.m_astrctIntervals,false,false);
               fnInvalidatePCA(handles,true,false);
            else
                if isempty(strctMouseOp.m_strWindow)
                    afDelta = strctMouseOp.m_pt2fPositionInFigure-strctMousePrevOp.m_pt2fPositionInFigure;
                    fZoomSec = strctGUIParams.m_afTimeRange(2)-strctGUIParams.m_afTimeRange(1);
                    fShift = afDelta(1) * fZoomSec /100;
                    fShowWindowLen = strctMouseDownOp.m_astrctIntervals(1).m_fEndTS_Plexon- strctMouseDownOp.m_astrctIntervals(1).m_fStartTS_Plexon;
                    afSortedAllTS = getappdata(handles.figure1,'afSortedAllTS');
                    % Is shift legal?
                    
                    if strctGUIParams.m_afTimeRange(2)+fShift <= afSortedAllTS(end)&& ...
                            strctGUIParams.m_afTimeRange(1)+fShift >=0
                    
                        strctMouseDownOp.m_astrctIntervals(1).m_fStartTS_Plexon =strctMouseDownOp.m_astrctIntervals(1).m_fStartTS_Plexon + fShift;
                        strctMouseDownOp.m_astrctIntervals(1).m_fEndTS_Plexon  =strctMouseDownOp.m_astrctIntervals(1).m_fEndTS_Plexon + fShift;
                        setappdata(handles.figure1,'strctMouseDownOp',strctMouseDownOp);
                        strctGUIParams.m_afTimeRange = strctGUIParams.m_afTimeRange+fShift;
                        setappdata(handles.figure1,'strctGUIParams',strctGUIParams);
                        fnInvalidateIntervalsAux(handles,strctMouseDownOp.m_astrctIntervals,true,true);
                            fnInvalidatePCA(handles,true,false);

                    end
                end;
             end
        end
    case 'Wave'
        
end

setappdata(handles.figure1,'strctMousePrevOp',strctMouseOp);
return;

function strMouseClick = fnGetClickType(hFigure)
strMouseType = get(hFigure,'selectiontype');
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

function fnMouseDown(obj,eventdata)
handles=get(obj,'UserData');
astrctIntervals = fnGetIntervals(handles);
strctMouseOp.m_strMouseClick = fnGetClickType(handles.figure1);
strctMouseOp.m_astrctIntervals  = astrctIntervals;
strctMouseOp.m_astrctIntervalsBefore  = astrctIntervals;
strctMouseOp.m_pt2fPositionInFigure = get(handles.figure1,'CurrentPoint');
[strctMouseOp.m_strWindow, strctMouseOp.m_pt2fPositionInWindow,strctMouseOp.m_hAxes] = fnGetActiveWindow(handles);
[strctMouseOp.m_iIntervalIndex, strctMouseOp.m_strWhere] = fnMouseOnInterval(handles);

setappdata(handles.figure1,'bMouseMoved',false);

setappdata(handles.figure1,'strctMouseOp',strctMouseOp);
setappdata(handles.figure1,'strctMousePrevOp',strctMouseOp);

setappdata(handles.figure1,'strctMouseDownOp',strctMouseOp);

strctGUIParams = getappdata(handles.figure1,'strctGUIParams');
if isempty(strctMouseOp.m_strWindow)
    return;
end;
switch strctMouseOp.m_strWindow
    case 'PCA'
        strctGUIParams.m_strMouseMode = 'ContourObject';
        
        bControlDown = getappdata(handles.figure1,'bControlDown');
        bShiftDown = getappdata(handles.figure1,'bShiftDown');

        
        
     if  bControlDown &&  bShiftDown
              strctGUIParams.m_strMouseCallback = @fnRemoveWavesContourAll;
        elseif  bControlDown &&  ~bShiftDown
            strctGUIParams.m_strMouseCallback = @fnRemoveWavesContour;
        elseif ~bControlDown &&  bShiftDown
            strctGUIParams.m_strMouseCallback = @fnAddWavesContourOnlyUnsorted;
        elseif ~bControlDown &&  ~bShiftDown
              strctGUIParams.m_strMouseCallback = @fnAddWavesContour;
        end        
        
      
            setappdata(handles.figure1,'strctGUIParams',strctGUIParams);
    case 'Timeline'
        if ~isempty(strctMouseOp.m_iIntervalIndex) 
            strctGUIParams.m_strMouseMode = 'IntervalChange';
        end
        setappdata(handles.figure1,'strctGUIParams',strctGUIParams);
    case 'Waves'
        strctGUIParams.m_strMouseMode = 'TwoClickLineObject';
        bControlDown = getappdata(handles.figure1,'bControlDown');
        bShiftDown = getappdata(handles.figure1,'bShiftDown');
           
        if  bControlDown &&  bShiftDown
              strctGUIParams.m_strMouseCallback = @fnRemoveWavesAll;
        elseif  bControlDown &&  ~bShiftDown
            strctGUIParams.m_strMouseCallback = @fnRemoveWaves;
        elseif ~bControlDown &&  bShiftDown
            strctGUIParams.m_strMouseCallback = @fnAddWavesOnlyUnsorted;
        elseif ~bControlDown &&  ~bShiftDown
              strctGUIParams.m_strMouseCallback = @fnAddWaves;
        end
        
        setappdata(handles.figure1,'strctGUIParams',strctGUIParams);
    otherwise
            strctGUIParams.m_strMouseMode = 'Browse';
            setappdata(handles.figure1,'strctGUIParams',strctGUIParams);
            
end


return;


function fnMouseUp(obj,eventdata)
handles=get(obj,'UserData');
strctMouseUpOp.m_pt2fPositionInFigure = get(handles.figure1,'CurrentPoint');
[strctMouseUpOp.m_strWindow, strctMouseUpOp.m_pt2fPositionInWindow,strctMouseUpOp.m_hAxes] = fnGetActiveWindow(handles);
[strctMouseUpOp.m_iIntervalIndex, strctMouseUpOp.m_strWhere] = fnMouseOnInterval(handles);
setappdata(handles.figure1,'strctMouseUpOp',strctMouseUpOp);

strctGUIParams = getappdata(handles.figure1,'strctGUIParams');
strctMouseDownOp = getappdata(handles.figure1,'strctMouseDownOp');

bMouseMoved = getappdata(handles.figure1,'bMouseMoved');
setappdata(handles.figure1,'strctLastMouseDownOp',strctMouseDownOp);
setappdata(handles.figure1,'strctMouseDownOp',[]);



hTwoClickObjectTempLine = getappdata(handles.figure1,'hTwoClickObjectTempLine');
if ~isempty(hTwoClickObjectTempLine) && ishandle(hTwoClickObjectTempLine)
    delete(hTwoClickObjectTempLine)
    setappdata(handles.figure1,'hTwoClickObjectTempLine',[]);
end;
 

hContourObject = getappdata(handles.figure1,'hContourObject');
if ~isempty(hContourObject) && ishandle(hContourObject)
    afX=get(hContourObject,'xdata');
    afY=get(hContourObject,'ydata');
    a2fContour = [afX;afY];
    delete(hContourObject);
    setappdata(handles.figure1,'hContourObject',[]);
else 
    a2fContour = [];
end

     

if isempty(strctMouseDownOp) || isempty(strctMouseDownOp.m_strWindow)
  strctGUIParams.m_strMouseMode = 'Browse';
setappdata(handles.figure1,'strctGUIParams',strctGUIParams);
   
 
    return;
end;

if strcmp(strctGUIParams.m_strMouseMode,'TwoClickLineObject')
    feval(strctGUIParams.m_strMouseCallback,handles, strctMouseDownOp.m_pt2fPositionInWindow,strctMouseUpOp.m_pt2fPositionInWindow)
end

if strcmp(strctGUIParams.m_strMouseMode,'ContourObject') && ~isempty(a2fContour)
    feval(strctGUIParams.m_strMouseCallback,handles, a2fContour)
end

switch strctMouseDownOp.m_strWindow
    case 'PCA'
        
    case 'Timeline'
        
        switch strctGUIParams.m_strMouseMode
            case 'IntervalChange'
                if bMouseMoved && ~isempty(strctGUIParams.m_aiSelectedIntervals)
                    if strctGUIParams.m_aiSelectedIntervals(1) == 1
                        fnUpdateIntervals(handles,strctMouseDownOp.m_astrctIntervals,true);
                    else
                       fnUpdateIntervals(handles,strctMouseDownOp.m_astrctIntervals,false);
                    end
                    fnInvalidateIntervals(handles,false);
                else
                    % Set unit in focus (?)
                    
                    bControlDown = getappdata(handles.figure1,'bControlDown');
                    if bControlDown
                        iIndx = setdiff(find(strctGUIParams.m_aiSelectedIntervals == strctMouseDownOp.m_iIntervalIndex),1);
                        if ~isempty(iIndx)
                            strctGUIParams.m_aiSelectedIntervals(iIndx) = [];
                        else
                            strctGUIParams.m_aiSelectedIntervals =[strctGUIParams.m_aiSelectedIntervals,strctGUIParams.m_aiSelectedIntervals,strctMouseDownOp.m_iIntervalIndex];
                        end
                    else
                        
                        if isempty(strctGUIParams.m_aiSelectedIntervals) || (length(strctGUIParams.m_aiSelectedIntervals) == 1 && strctGUIParams.m_aiSelectedIntervals == 1) || strcmp(strctMouseDownOp.m_strMouseClick,'DoubleClick')
                            % Bring viewing interval to this unit...
                            strctMouseDownOp.m_astrctIntervals(1).m_fStartTS_Plexon = strctMouseDownOp.m_astrctIntervals(strctMouseDownOp.m_iIntervalIndex).m_fStartTS_Plexon;
                            strctMouseDownOp.m_astrctIntervals(1).m_fEndTS_Plexon= strctMouseDownOp.m_astrctIntervals(strctMouseDownOp.m_iIntervalIndex).m_fEndTS_Plexon;
                            fnUpdateIntervals(handles,strctMouseDownOp.m_astrctIntervals,true);
                        end
                        strctGUIParams.m_aiSelectedIntervals = strctMouseDownOp.m_iIntervalIndex;
                    end
                    
                    if length(strctGUIParams.m_aiSelectedIntervals) == 1
                        
                        afSortedAllTS = getappdata(handles.figure1,'afSortedAllTS');
                        aiUnitAsso = fnGetUnitAssociation(handles);
                        afSpikeTimeDiffMS = 1e3*diff(afSortedAllTS(aiUnitAsso == strctMouseDownOp.m_astrctIntervals(strctGUIParams.m_aiSelectedIntervals).m_iUniqueID));
                        afTime = 0:30;
                        afSpikeHist = histc(afSpikeTimeDiffMS,afTime);
                        hold(handles.hISI,'off');
                        if isempty(afSpikeHist)
                            cla(handles.hISI);
                            set(handles.hPercentContamination,'string', '');
                        else
                            hold(handles.hISI,'on');
                            abShortTime = afTime < 2;
                            bar(afTime(abShortTime),afSpikeHist(abShortTime),'parent',handles.hISI,'edgecolor','none','facecolor','r');
                            set(handles.hISI,'xlim',[0 afTime(end)]);
                            bar(afTime,afSpikeHist,'parent',handles.hISI,'edgecolor','none','facecolor','b');
                            set(handles.hPercentContamination,'string', sprintf('%.2f%% < 2ms, Total = %d',sum(afSpikeHist(abShortTime))/length(afSpikeTimeDiffMS)*1e2,1+length(afSpikeTimeDiffMS)));
                        end
                        
                     end
                    
                    setappdata(handles.figure1,'strctGUIParams',strctGUIParams);
                    fnInvalidateIntervals(handles,false);
                    fnInvalidatePCA(handles,false,false);
                end
            case 'Browse'
                if strcmp(strctMouseDownOp.m_strMouseClick,'Left')
                    
                    bControlDown = getappdata(handles.figure1,'bControlDown'); 
                    if ~isempty(bControlDown) && bControlDown && ~isempty(strctMouseDownOp.m_iIntervalIndex)
                        iIndx = setdiff(find(strctGUIParams.m_aiSelectedIntervals == strctMouseDownOp.m_iIntervalIndex),1);
                        if ~isempty(iIndx)
                            strctGUIParams.m_aiSelectedIntervals(iIndx) = [];
                        else
                            strctGUIParams.m_aiSelectedIntervals =[strctGUIParams.m_aiSelectedIntervals,strctGUIParams.m_aiSelectedIntervals,strctMouseDownOp.m_iIntervalIndex];
                        end
                    else
                        strctGUIParams.m_aiSelectedIntervals = strctMouseDownOp.m_iIntervalIndex;
                    end
                    
                    setappdata(handles.figure1,'strctGUIParams',strctGUIParams);
                    fnInvalidateIntervals(handles,false);
                    fnInvalidatePCA(handles,false,false);
                end

           end
        strctGUIParams.m_strMouseMode = 'Browse';
    case 'Waves'
       strctGUIParams.m_strMouseMode = 'Browse';
       
end
setappdata(handles.figure1,'strctGUIParams',strctGUIParams);

return;


function fnHighlightActiveSpike(handles, iSelectedSpike)
a2fPCA = getappdata(handles.figure1,'a2fPCA');

return;

function aiUnitVertical = fnGetIntervalVerticalValue(astrctUnitIntervals,bIgnoreFirst)
% Ignore the first entry.
if bIgnoreFirst
    astrctUnitIntervals = astrctUnitIntervals(2:end);
end
if isempty(astrctUnitIntervals)
    aiUnitVertical = 1;
    return;
end;

% Determine the vertical value for each unit...
MaxUnitsAtSameTimePoints = 50;
abVerticalOccupied = zeros(1,MaxUnitsAtSameTimePoints)> 0;
iNumUnitIntervals = length(astrctUnitIntervals);
aiUnitVertical = zeros(1,iNumUnitIntervals);
afAllStart = cat(1,astrctUnitIntervals.m_fStartTS_Plexon);
afAllEnd = cat(1,astrctUnitIntervals.m_fEndTS_Plexon);
[afTimeSteps,aiUnitInd] = sort( [afAllStart;afAllEnd]);

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
if bIgnoreFirst
    aiUnitVertical = [max(aiUnitVertical)+1,aiUnitVertical];
end
return;

function fnInvalidateIntervals(handles,bMoveTimeAxis)
astrctUnitIntervals = fnGetIntervals(handles);
fnInvalidateIntervalsAux(handles,astrctUnitIntervals,bMoveTimeAxis,false);
return;

function fnInvalidateIntervalsAux(handles,astrctUnitIntervals,bMoveTimeAxis,bForceRedraw)
strctGUIParams=getappdata(handles.figure1,'strctGUIParams');
afSortedAllTS = getappdata(handles.figure1,'afSortedAllTS');
if ~isempty(astrctUnitIntervals)
    fZero = max(0,min([afSortedAllTS(1); cat(1,astrctUnitIntervals.m_fStartTS_Plexon)]));
else
    fZero = afSortedAllTS(1);
end

iNumIntervals = length(astrctUnitIntervals);
fHeight=0.2;
hIntervalMenu = getappdata(handles.figure1,'hIntervalMenu');
ahIntervalPatch = getappdata(handles.figure1,'ahIntervalPatch');
iMaxHeight = max(cat(1,astrctUnitIntervals.m_iVerticalStack));

if isempty(ahIntervalPatch) || bForceRedraw
    cla(handles.hTimeLine);
    hold(handles.hTimeLine,'on');
    hIntervalMenu2 = getappdata(handles.figure1,'hIntervalMenu2');
    set(handles.hTimeLine,'uicontextmenu',hIntervalMenu2);
    ahIntervalPatch= zeros(1, iNumIntervals);
    ahIntervalText= zeros(1, iNumIntervals);
    for k=1:iNumIntervals
        fXstart = astrctUnitIntervals(k).m_fStartTS_Plexon-fZero;
        fXend = astrctUnitIntervals(k).m_fEndTS_Plexon-fZero;
        fY = astrctUnitIntervals(k).m_iVerticalStack;
        if k>=2
            ahIntervalPatch(k) = patch('xdata',[fXstart,fXstart,fXend,fXend],'ydata',...
                [fY-fHeight fY+fHeight,fY+fHeight,fY-fHeight],'facecolor',astrctUnitIntervals(k).m_afColor,'parent',handles.hTimeLine,'UIContextMenu',hIntervalMenu);
            ahIntervalText(k) = text((fXstart+fXend)/2,fY,sprintf('%d',astrctUnitIntervals(k).m_iUniqueID),'parent',handles.hTimeLine,'fontweight','bold','UIContextMenu',hIntervalMenu);
        else
               if sum(strctGUIParams.m_aiSelectedIntervals == k) > 0
        
            ahIntervalPatch(k) = patch('xdata',[fXstart,fXstart,fXend,fXend],'ydata',...
                [0 iMaxHeight+fHeight,iMaxHeight+fHeight,0],'facecolor',astrctUnitIntervals(k).m_afColor,'parent',handles.hTimeLine,'UIContextMenu',hIntervalMenu2,'LineWidth',3,'EdgeColor',[0.4 0 0.4]);
               else
            ahIntervalPatch(k) = patch('xdata',[fXstart,fXstart,fXend,fXend],'ydata',...
                [0 iMaxHeight+fHeight,iMaxHeight+fHeight,0],'facecolor',astrctUnitIntervals(k).m_afColor,'parent',handles.hTimeLine,'UIContextMenu',hIntervalMenu2);
                   
               end
        end
    end
    setappdata(handles.figure1,'ahIntervalPatch',ahIntervalPatch);
    setappdata(handles.figure1,'ahIntervalText',ahIntervalText);
    
else
    ahIntervalText = getappdata(handles.figure1,'ahIntervalText');
    
    for k=1:iNumIntervals
        if k>=2
            fXstart = astrctUnitIntervals(k).m_fStartTS_Plexon-fZero;
            fXend = astrctUnitIntervals(k).m_fEndTS_Plexon-fZero;
            fY = astrctUnitIntervals(k).m_iVerticalStack;
            if sum(strctGUIParams.m_aiSelectedIntervals == k) > 0
                set(ahIntervalPatch(k),'xdata',[fXstart,fXstart,fXend,fXend],'ydata',...
                    [fY-fHeight fY+fHeight,fY+fHeight,fY-fHeight],'LineWidth',3,'EdgeColor',[0.4 0 0.4]);
            else
                set(ahIntervalPatch(k),'xdata',[fXstart,fXstart,fXend,fXend],'ydata',...
                    [fY-fHeight fY+fHeight,fY+fHeight,fY-fHeight],'LineWidth',1,'EdgeColor',[0 0 0]);
            end
            set(ahIntervalText(k),'Position',[(fXstart+fXend)/2,fY]);
        else
            fXstart = astrctUnitIntervals(k).m_fStartTS_Plexon-fZero;
            fXend = astrctUnitIntervals(k).m_fEndTS_Plexon-fZero;
            fY = astrctUnitIntervals(k).m_iVerticalStack;
            set(ahIntervalPatch(k),'xdata',[fXstart,fXstart,fXend,fXend],'ydata',...
                [0 iMaxHeight+fHeight,iMaxHeight+fHeight,0],'LineWidth',3,'EdgeColor',[0.4 0 0.4]);
        end
    end
    
end
strctAdvancer = getappdata(handles.figure1,'strctAdvancer');
if ~isempty(strctAdvancer) && bForceRedraw
    afSqueeze = (strctAdvancer.m_afDepthMM-min(strctAdvancer.m_afDepthMM(:)))/(max(strctAdvancer.m_afDepthMM)-min(strctAdvancer.m_afDepthMM));
    plot(strctAdvancer.m_afTimeStampElectrodeMoved-fZero, afSqueeze+iMaxHeight-1,'parent',handles.hTimeLine);
    
end

if bMoveTimeAxis
    set(handles.hTimeLine,'xlim',[strctGUIParams.m_afTimeRange(1),strctGUIParams.m_afTimeRange(2)+0.01],'ylim',[0 iMaxHeight+fHeight] );
end

return;

function fnKeyDown(obj,eventdata)
handles = get(obj,'UserData');
if ~isempty(eventdata.Key) && strcmp(eventdata.Key,'control')
    setappdata(handles.figure1,'bControlDown',true);
    set(handles.figure1,'Pointer','cross');
end;

if ~isempty(eventdata.Key) && strcmp(eventdata.Key,'shift')
    setappdata(handles.figure1,'bShiftDown',true);
    set(handles.figure1,'Pointer','fullcrosshair');
end;

fnSetOpModeTitle(handles);

switch eventdata.Key
    case 'v'
        fnToggleVissible(handles);
    case 'k'
        if ~isempty(eventdata.Modifier) && strcmp(eventdata.Modifier{1},'shift')
            fnKlustaKwik(handles,true);
        else
            fnKlustaKwik(handles,false);
        end
    case 'delete'
        fnDeleteInterval([],[],handles);
    case 'rightarrow'
        if ~isempty(eventdata.Modifier) && strcmp(eventdata.Modifier{1},'shift')
        else
            strctGUIParams=getappdata(handles.figure1,'strctGUIParams');
            strctGUIParams.m_afTimeRange = strctGUIParams.m_afTimeRange + 100;
            setappdata(handles.figure1,'strctGUIParams',strctGUIParams);
            fnInvalidateIntervals(handles,true);
        end
    case 'leftarrow'
        if ~isempty(eventdata.Modifier) && strcmp(eventdata.Modifier{1},'shift')
          else        
            strctGUIParams=getappdata(handles.figure1,'strctGUIParams');
            strctGUIParams.m_afTimeRange = strctGUIParams.m_afTimeRange - 100;
            setappdata(handles.figure1,'strctGUIParams',strctGUIParams);
            fnInvalidateIntervals(handles,true);
        end
    case 'space'
        afSortedAllTS = getappdata(handles.figure1,'afSortedAllTS');
        a2fSortedAllWaveForms = getappdata(handles.figure1,'a2fSortedAllWaveForms');

        astrctUnitIntervals = fnGetIntervals(handles);
        abVisibility = cat(1,astrctUnitIntervals.m_bVisible);
        aiUnitAssociation = fnGetUnitAssociation(handles);
        
        abSpikesVisible = ones(size(aiUnitAssociation))>0;
        aiNotVisible = find(~abVisibility);
        for k=1:length(aiNotVisible)
           abSpikesVisible( aiUnitAssociation==    astrctUnitIntervals(aiNotVisible(k)).m_iUniqueID) =0;
        end

        % Find all waves that intersect the line AND the time interval marked!
        fCurrentTime=astrctUnitIntervals(1).m_fStartTS_Plexon;
        fTimeWindowSec=astrctUnitIntervals(1).m_fEndTS_Plexon-astrctUnitIntervals(1).m_fStartTS_Plexon;
        
        abValidSpikes = afSortedAllTS >= fCurrentTime & afSortedAllTS <= fCurrentTime+fTimeWindowSec & abSpikesVisible(:);
        
        
        if ~isempty(eventdata.Modifier) && strcmp(eventdata.Modifier{1},'shift')
            % Feature based PCA ?
            [afMax,aiIndMax]=max(a2fSortedAllWaveForms,[],2);
            [afMin,aiIndMin]=min(a2fSortedAllWaveForms,[],2);
            a2fPCA = [afMax-afMin, aiIndMax-aiIndMin];
        else
            a2fSortedAllWaveFormsZeroMean = bsxfun(@minus,a2fSortedAllWaveForms,mean(a2fSortedAllWaveForms,1));
            [coeff,loads] = eig(a2fSortedAllWaveFormsZeroMean(abValidSpikes,:)'*a2fSortedAllWaveFormsZeroMean(abValidSpikes,:));
            %afLoads = flipud(diag(ignore));
            a2fPCACoeff = fliplr(coeff);
            a2fPCA = a2fSortedAllWaveFormsZeroMean*a2fPCACoeff(:,1:2)*loads(1:2,1:2);
        end

    strctGUIParams = getappdata(handles.figure1,'strctGUIParams');
    
    fCenter1=median(a2fPCA(:,1));
fCenter2=median(a2fPCA(:,2));
fStd1=mad(a2fPCA(:,1));
fStd2=mad(a2fPCA(:,2));
fMin1 = fCenter1-5*fStd1;
fMin2 = fCenter2-5*fStd2;
fMax1 = fCenter1+5*fStd1;
fMax2 = fCenter2+5*fStd2;


    strctGUIParams.m_afRangePCA = [fMin1, fMax1,fMin2,fMax2];%[min(a2fPCA(:,1)), max(a2fPCA(:,1)), min(a2fPCA(:,2)), max(a2fPCA(:,2))];
    setappdata(handles.figure1,'strctGUIParams',strctGUIParams);
    
        setappdata(handles.figure1,'a2fPCA',a2fPCA);
        fnInvalidatePCA(handles,false,true);
        
        
        
        
    case 'z'
        if ~isempty(eventdata.Modifier) && strcmp(eventdata.Modifier{1},'control')
            fnUndo(handles);
        end
    case 's'
        if ~isempty(eventdata.Modifier) && strcmp(eventdata.Modifier{1},'control')
            fnSaveCurrentChannel(handles);
        end
        
end

return;

function fnKlustaKwik(handles, bAskClusterNum)
afSortedAllTS = getappdata(handles.figure1,'afSortedAllTS');
a2fSortedAllWaveForms = getappdata(handles.figure1,'a2fSortedAllWaveForms');
astrctUnitIntervals = fnGetIntervals(handles);


abVisibility = cat(1,astrctUnitIntervals.m_bVisible);
aiUnitAssociation = fnGetUnitAssociation(handles);

abSpikesVisible = ones(size(aiUnitAssociation))>0;
aiNotVisible = find(~abVisibility);
for k=1:length(aiNotVisible)
    abSpikesVisible( aiUnitAssociation==    astrctUnitIntervals(aiNotVisible(k)).m_iUniqueID) =0;
end

% Find all waves that intersect the line AND the time interval marked!
fCurrentTime=astrctUnitIntervals(1).m_fStartTS_Plexon;
fTimeWindowSec=astrctUnitIntervals(1).m_fEndTS_Plexon-astrctUnitIntervals(1).m_fStartTS_Plexon;

abValidSpikes = afSortedAllTS >= fCurrentTime & afSortedAllTS <= fCurrentTime+fTimeWindowSec & abSpikesVisible(:);

% Extract features....

    a2fSortedAllWaveFormsZeroMean = bsxfun(@minus,a2fSortedAllWaveForms(abValidSpikes,:),mean(a2fSortedAllWaveForms(abValidSpikes,:),1));
    [coeff,loads] = eig(a2fSortedAllWaveFormsZeroMean'*a2fSortedAllWaveFormsZeroMean);
    a2fPCACoeff = fliplr(coeff);
    
   
   % Crop all intervals outside the viewing interval and delete the ones
   % that are completely inside....
   afViewingRange = [astrctUnitIntervals(1).m_fStartTS_Plexon, astrctUnitIntervals(1).m_fEndTS_Plexon];
   iNumIntervals = length(  astrctUnitIntervals);
   abIntervalsToDelete = zeros(1,iNumIntervals)>0;
   fEps = 2;
 for iIntervalIter=2:iNumIntervals
   if astrctUnitIntervals( iIntervalIter).m_fEndTS_Plexon < afViewingRange(1) || ...
       astrctUnitIntervals( iIntervalIter).m_fStartTS_Plexon > afViewingRange(2)  || ...
    ~astrctUnitIntervals( iIntervalIter).m_bVisible
       continue;
   end;
   % interval either intersects or fully inside.
   
   if astrctUnitIntervals( iIntervalIter).m_fStartTS_Plexon >= afViewingRange(1)-fEps && ...
       astrctUnitIntervals( iIntervalIter).m_fEndTS_Plexon <= afViewingRange(2)+fEps 
        abIntervalsToDelete(iIntervalIter) = true;
   else
       % Just crop...
       if astrctUnitIntervals( iIntervalIter).m_fStartTS_Plexon <  afViewingRange(1)
           % Crop end
           astrctUnitIntervals( iIntervalIter).m_fEndTS_Plexon = afViewingRange(1);
           aiUnitAssociation(aiUnitAssociation == astrctUnitIntervals( iIntervalIter).m_iUniqueID & afSortedAllTS > afViewingRange(1)) = 0;
       else
           astrctUnitIntervals( iIntervalIter).m_fStartTS_Plexon = afViewingRange(2);
           aiUnitAssociation(aiUnitAssociation(:)' == astrctUnitIntervals( iIntervalIter).m_iUniqueID & afSortedAllTS(:)' < afViewingRange(2)) = 0;
       end
   end
 end
astrctUnitIntervals = astrctUnitIntervals(~abIntervalsToDelete);
aiSpikesToModify = find(abValidSpikes);

%%
    iNumCoeffToTake = 5;
    iMinimumClusterSize = 100;
    iMaxCluster = 10;
    if bAskClusterNum    
          prompt={'Maximum number of clusters:','Drop cluster with less than X spikes'};
          name='Inputs for KlustaKwik';
          numlines=1;
          defaultanswer={num2str(iMaxCluster), num2str(iMinimumClusterSize)};
           answer=inputdlg(prompt,name,numlines,defaultanswer);
            if isempty(answer)
                return;
            end;
            iMaxCluster = str2num(answer{1});
            iMinimumClusterSize = str2num(answer{2});
    end
    
    a2fPCAFeatures = a2fSortedAllWaveFormsZeroMean*a2fPCACoeff(:,1:iNumCoeffToTake)*loads(1:iNumCoeffToTake,1:iNumCoeffToTake);
    fprintf('Launching KlustaKwik...\n');
    aiClusters = fndllKlustaKwikMatlabWrapper(a2fPCAFeatures',[],'MinClusters',1,'MaxClusters',iMaxCluster,'MaxPossibleClusters',iMaxCluster,'Verbose',0,'Screen',0);
    aiUniqueClusters = unique(aiClusters);
    aiNumSpikes = histc(aiClusters,aiUniqueClusters);
    aiUniqueClusters = aiUniqueClusters(aiNumSpikes > iMinimumClusterSize);
    
    % Create new intervals...
    iNumNewIntervals = length(aiUniqueClusters);
    iMaxUniqueID = getappdata(handles.figure1,'iMaxUniqueID');
    
    for iIter=1:iNumNewIntervals
        aiUnitAssociation(aiSpikesToModify(aiClusters == aiUniqueClusters(iIter))) = iMaxUniqueID+iIter;
        afColor  = fnGetDefaultUnitColors(iMaxUniqueID+iIter);
        astrctUnitIntervals(end+1) = fnBuildNewInterval(...
            afViewingRange(1), afViewingRange(2),...
            iMaxUniqueID+iIter,afColor  );
    end
    setappdata(handles.figure1,'iMaxUniqueID',iMaxUniqueID+iNumNewIntervals);
    %   histc(aiClusters, aiUniqueClusters)
%%
 fnUpdateIntervals(handles,astrctUnitIntervals, false);
 fnUpdateSpikeAssociation(handles,aiUnitAssociation);
fnInvalidateIntervalsAux(handles,astrctUnitIntervals,false,true);
fnInvalidateIntervals(handles,true);
fnInvalidatePCA(handles,false,true);
return;


function fnUndo(handles)
acUndoOperations = getappdata(handles.figure1,'acUndoOperations');
if ~isempty(acUndoOperations)
    for k=length(acUndoOperations{end}):-1:1 % do in reverse
        strWhat = acUndoOperations{end}{k};
        switch strWhat
            case 'Intervals';
                % Rollback intervals
                acIntervals = getappdata(handles.figure1,'acIntervals');
                if length(acIntervals) > 1
                    acIntervals=acIntervals(1:end-1);
                    setappdata(handles.figure1,'acIntervals',acIntervals);
                    fnInvalidateIntervalsAux(handles,acIntervals{end},false,true);
                    fnInvalidatePCA(handles,false,false);
                end
            case 'Spikes'
                acUnitAssociation = getappdata(handles.figure1,'acUnitAssociation');
                if length(acUnitAssociation) > 1
                    acUnitAssociation = acUnitAssociation(1:end-1);
                    setappdata(handles.figure1,'acUnitAssociation',acUnitAssociation);
                    fnInvalidatePCA(handles,false,false);
                end;
        end
    end
    acUndoOperations = acUndoOperations(1:end-1);
    setappdata(handles.figure1,'acUndoOperations',acUndoOperations);
end

return;


function fnInvalidatePCA(handles, bUseMouseMove, bForceRedraw)
if ~exist('bUseMouseMove','var')
    bUseMouseMove = false;
end;
a2fPCA = getappdata(handles.figure1,'a2fPCA');
strctGUIParams=getappdata(handles.figure1,'strctGUIParams');

acUnitAssociation = getappdata(handles.figure1,'acUnitAssociation');
a2fSortedAllWaveForms = getappdata(handles.figure1,'a2fSortedAllWaveForms');
hPCARaster = getappdata(handles.figure1,'hPCARaster');

afSortedAllTS = getappdata(handles.figure1,'afSortedAllTS');

if bUseMouseMove 
     strctMouseDownOp = getappdata(handles.figure1,'strctMouseDownOp');
    astrctUnitIntervals = strctMouseDownOp.m_astrctIntervals;
else
    astrctUnitIntervals = fnGetIntervals(handles);
end
fCurrentTime=astrctUnitIntervals(1).m_fStartTS_Plexon;
fTimeWindowSec=astrctUnitIntervals(1).m_fEndTS_Plexon-astrctUnitIntervals(1).m_fStartTS_Plexon;

iStartInd = find(afSortedAllTS >= fCurrentTime,1,'first');
iEndInd = find(afSortedAllTS <= fCurrentTime+fTimeWindowSec,1,'last');
%set(hPCARaster,'xdata',a2fPCA(iStartInd:iEndInd,1),...
%    'ydata',a2fPCA(iStartInd:iEndInd,2));

a2fReducedData = a2fPCA(iStartInd:iEndInd,:);
a2fReducedWaves = a2fSortedAllWaveForms(iStartInd:iEndInd,:);
aiReducedSpikeAssociation = acUnitAssociation{end}(iStartInd:iEndInd);

aiUnitsInRange = unique(aiReducedSpikeAssociation);
%%
iNumPtsX = 200;
iNumPtsY = 200;

afRangeX = linspace(strctGUIParams.m_afRangePCA(1),strctGUIParams.m_afRangePCA(2),iNumPtsX);
afRangeY = linspace(strctGUIParams.m_afRangePCA(3),strctGUIParams.m_afRangePCA(4),iNumPtsY);

afRangeXwave = [1 40];




iNumUnitsInRange=length(aiUnitsInRange);
% fSmoothingKernel = 1;
%a2fSmoothingKernel = fspecial('gaussian',[fSmoothingKernel fSmoothingKernel],fSmoothingKernel/3);
a3fSmoothDist = zeros(length(afRangeY),length(afRangeX),length(aiUnitsInRange));
a2fMean = zeros(2,iNumUnitsInRange);
a3fCov = zeros(2,2,iNumUnitsInRange);
a3fWaves = zeros(iNumPtsY,iNumPtsX,iNumUnitsInRange);

if isempty(a2fReducedWaves)
    afRangeYwave = [-0.1 0.1];
else
    fCenter=median(a2fReducedWaves(:));
    fStd=mad(a2fReducedWaves(:));
    afRangeYwave=fCenter+8*[-fStd fStd];
end
% bMicroVoltsWaveforms = max(a2fReducedWaves(:)) < 10;
% if bMicroVoltsWaveforms
%     afRangeYwave = [-0.1 0.1];
% else
%     afRangeYwave = [-2048 2048];
% end

aiIntervalsUniqueID = cat(1,astrctUnitIntervals.m_iUniqueID);

for iIter=1:iNumUnitsInRange
    iUnitOfInterest = aiUnitsInRange(iIter);
    iIndex = find(aiIntervalsUniqueID == iUnitOfInterest);
    if isempty(iIndex) ||  (~isempty(iIndex) && astrctUnitIntervals(iIndex).m_bVisible == true)
        
        afSpikePCAX = a2fReducedData(aiReducedSpikeAssociation == iUnitOfInterest,1);
        afSpikePCAY = a2fReducedData(aiReducedSpikeAssociation == iUnitOfInterest,2);
        a2fUnitWaves = -a2fReducedWaves(aiReducedSpikeAssociation == iUnitOfInterest,:);
        
        afAllRangeX = linspace(min(afSpikePCAX),max(afSpikePCAX),iNumPtsX);
        afAllRangeY = linspace(min(afSpikePCAY),max(afSpikePCAY),iNumPtsY);

        
        a3fWaves(:,:,iIter) = sqrt(Bresenham(a2fUnitWaves, afRangeXwave([1,end]), iNumPtsX,afRangeYwave([1,end]), iNumPtsY));
        
        
        [a2fMean(:,iIter), a3fCov(:,:,iIter)]=fnFitGaussian([afSpikePCAX(:),afSpikePCAY(:)]);
                
        a2fDist  = hist2(afSpikePCAX,afSpikePCAY,afRangeX,afRangeY);
        
        a2fTemp= hist2(afSpikePCAX,afSpikePCAY,afAllRangeX,afAllRangeY);
        
        a2fSmooth = (a2fDist);%conv2(a2fDist,a2fSmoothingKernel,'same');
        a3fSmoothDist(:,:,iIter) = a2fSmooth/max(a2fTemp(:));%-min(a2fSmooth(:))) / (max(a2fSmooth(:))-min(a2fSmooth(:)));
        a3fWaves(:,:,iIter) = a3fWaves(:,:,iIter) / max(max(a3fWaves(:,:,iIter)));
    end
end

% Build the color scheme
fScale = 3;
a3fColorDist = zeros(length(afRangeY),length(afRangeX),3);
a2fUnitColors = zeros(iNumUnitsInRange,3);

a2fColorWavePlot = zeros(iNumPtsY,iNumPtsX,3);
for iIter=1:iNumUnitsInRange
    iUniqueID = aiUnitsInRange(iIter);
    if iUniqueID == 0
        afColor = [1,1,1];
    else
        
        iIndex = find(cat(1,astrctUnitIntervals.m_iUniqueID) == iUniqueID);
        if isempty(iIndex)
            continue;
        end;
            afColor = astrctUnitIntervals(iIndex).m_afColor;
     end
    a2fUnitColors(iIter,:) = afColor;
    a3fColorDistUnit = zeros(length(afRangeY),length(afRangeX),3);
    a3fColorWaveUnit = zeros(iNumPtsY,iNumPtsX,3);
    for k=1:3
        a3fColorDistUnit(:,:,k) = a3fSmoothDist(:,:,iIter) * afColor(k);
        a3fColorWaveUnit(:,:,k) = a3fWaves(:,:,iIter) * afColor(k);
    end
    
    a3fColorDist = min(1,max(a3fColorDist, + sqrt(a3fColorDistUnit)));
    a2fColorWavePlot = min(1,max(a2fColorWavePlot, + sqrt(a3fColorWaveUnit)));
    %ahWaves = [ahWaves; plot(handles.hWaves,1:40,a3fWaves(1:aiNumWaves(iIter),:,iIter),'color',afColor)];
    

end

hWaves = getappdata(handles.figure1,'hWaves');

if bForceRedraw
   if ~isempty( hPCARaster) && ishandle(hPCARaster)
       delete(hPCARaster)
       hPCARaster = [];
   end;
    if ~isempty( hWaves) && ishandle(hWaves)
       delete(hWaves)
       hWaves = [];
   end;
end

if isempty(hWaves)
      hWaves = imagesc(afRangeXwave,afRangeYwave,a2fColorWavePlot,'parent',handles.hWaves);
      setappdata(handles.figure1,'hWaves',hWaves);
else
    set(hWaves,'cdata', a2fColorWavePlot);
end
% if bMicroVoltsWaveforms
    set (handles.hWaves,'ylim',afRangeYwave);
% else
%      set (handles.hWaves,'ylim',[-2048 2048]);
% end

%%


if isempty(hPCARaster)
    set(handles.hPCA,'xlim',[afRangeX(1), afRangeX(end)+eps],'ylim',[afRangeY(1),afRangeY(end)]);
    hPCARaster = imagesc(afRangeX,afRangeY,a3fColorDist,'parent',handles.hPCA);
    setappdata(handles.figure1,'hPCARaster',hPCARaster);

else
    set(hPCARaster,'cdata',a3fColorDist,'xdata',afRangeX,'ydata',afRangeY);
    hold on;
    
    
    ahHandles = getappdata(handles.figure1,'ahEllipses');
    if ~isempty(ahHandles)
        delete(ahHandles(ishandle(ahHandles)));
    end;
    
    ahHandles = fnDrawEllipses(handles.hPCA,a2fMean,a3fCov,a2fUnitColors,2,afRangeX,afRangeY);
    setappdata(handles.figure1,'ahEllipses',ahHandles);
end

%%

return;

function fnKeyUp(obj,eventdata)
handles = get(obj,'UserData');
if ~isempty(eventdata.Key) && strcmp(eventdata.Key,'control')
    setappdata(handles.figure1,'bControlDown',false);
     set(handles.figure1, 'Pointer', 'arrow');
end;


if ~isempty(eventdata.Key) && strcmp(eventdata.Key,'shift')
    setappdata(handles.figure1,'bShiftDown',false);
    set(handles.figure1,'Pointer','arrow');
end;

fnSetOpModeTitle(handles);
return;

function fnSetOpModeTitle(handles)
bControlDown = getappdata(handles.figure1,'bControlDown');
bShiftDown = getappdata(handles.figure1,'bShiftDown');
if  bControlDown &&  bShiftDown
    set(handles.figure1,'Name','Remove all spikes ');
elseif  bControlDown &&  ~bShiftDown
    set(handles.figure1,'Name','Remove Sorted Spikes (selected unit only)');
elseif ~bControlDown &&  bShiftDown
     set(handles.figure1,'Name','Add Only Unsorted Spikes');
elseif ~bControlDown &&  ~bShiftDown
    set(handles.figure1,'Name','Add Spikes');
end


function WindowScrollWheelFcn(obj,eventdata)
return;


function fnUpdateUnitAssociation(handles,aiSpikeToUnitAssociation)
fnSubmitChange(handles,{'Spikes'});
acUnitAssociation = getappdata(handles.figure1,'acUnitAssociation');
iNumEntries = length(acUnitAssociation);
acUnitAssociation{iNumEntries+1} = aiSpikeToUnitAssociation;
setappdata(handles.figure1,'acUnitAssociation',acUnitAssociation);
return;





function fnSubmitChange(handles,strWhatHasChanged)
acUndoOperations = getappdata(handles.figure1,'acUndoOperations');
acUndoOperations{end+1} = strWhatHasChanged;
setappdata(handles.figure1,'acUndoOperations',acUndoOperations);
return;

function fnUpdateIntervals(handles,astrctUnitIntervals, bOverride)
acIntervals = getappdata(handles.figure1,'acIntervals');
if bOverride
    acIntervals{end} = astrctUnitIntervals;
    setappdata(handles.figure1,'acIntervals',acIntervals);
    return;
end

fnSubmitChange(handles,{'Intervals'});
iNumEntries = length(acIntervals);

% Update the Y value...
aiUnitVertical = fnGetIntervalVerticalValue(astrctUnitIntervals,true);
for k=1:length(astrctUnitIntervals)
    astrctUnitIntervals(k).m_iVerticalStack = aiUnitVertical(k);
end;

acIntervals{iNumEntries+1} = astrctUnitIntervals;
setappdata(handles.figure1,'acIntervals',acIntervals);
return;

function fnChangeWaves(handles,P1,P2, bInclude, bOnlyUnsorted)
strctGUIParams =getappdata(handles.figure1,'strctGUIParams');
if length(strctGUIParams.m_aiSelectedIntervals) > 1 
    return;
end;
astrctUnitIntervals = fnGetIntervals(handles);

if isempty(strctGUIParams.m_aiSelectedIntervals) || ( length(strctGUIParams.m_aiSelectedIntervals) == 1 && strctGUIParams.m_aiSelectedIntervals == 1)
    % Add new interval

    if isempty(P2) || norm(P1-P2) == 0
        return;
    end
    iNewUniqueValue = getappdata(handles.figure1,'iMaxUniqueID')+1;
    afColor  = rand(1,3);
    astrctUnitIntervals(end+1) = fnBuildNewInterval(...
        astrctUnitIntervals(1).m_fStartTS_Plexon, astrctUnitIntervals(1).m_fEndTS_Plexon, iNewUniqueValue,afColor );
    
    strctGUIParams.m_aiSelectedIntervals=length(astrctUnitIntervals);
    setappdata(handles.figure1,'strctGUIParams',strctGUIParams);
    fnUpdateIntervals(handles,astrctUnitIntervals,false);
    setappdata(handles.figure1,'iMaxUniqueID',iNewUniqueValue);
    fnInvalidateIntervalsAux(handles,astrctUnitIntervals,false,true);
    fnInvalidateIntervals(handles,true);

end

a2fSortedAllWaveForms = getappdata(handles.figure1,'a2fSortedAllWaveForms');
afSortedAllTS = getappdata(handles.figure1,'afSortedAllTS');
% Find all waves that intersect the line AND the time interval marked!
fCurrentTime=astrctUnitIntervals(1).m_fStartTS_Plexon;
fTimeWindowSec=astrctUnitIntervals(1).m_fEndTS_Plexon-astrctUnitIntervals(1).m_fStartTS_Plexon;

iStartInd = find(afSortedAllTS >= fCurrentTime,1,'first');
iEndInd = find(afSortedAllTS <= fCurrentTime+fTimeWindowSec,1,'last');
a2fReducedWaves = -a2fSortedAllWaveForms(iStartInd:iEndInd,:);
aiUnitAssociation = fnGetUnitAssociation(handles);
aiReducedSpikeAssociation = aiUnitAssociation(iStartInd:iEndInd);


abVisibleSpike = ones(1, length(aiReducedSpikeAssociation)) > 0;
aiInvisibleClusters = find( ~cat(1,astrctUnitIntervals.m_bVisible)); % Do not apply things on invisible clusters (!!!)

for k=1:length(aiInvisibleClusters)
    abVisibleSpike( aiReducedSpikeAssociation == astrctUnitIntervals(aiInvisibleClusters(k)).m_iUniqueID ) = 0;
end


afLineSegment = [P1,P2];
abIntersect = LineIntersection(a2fReducedWaves, afLineSegment);
% 
% figure(20);
% clf;
% subplot(2,1,1);
% plot(a2fReducedWaves','k');
% subplot(2,1,2);hold on;
% plot(a2fReducedWaves(~abIntersect,:)','k');
% plot(a2fReducedWaves(~abIntersect,:)','r');
% plot(afLineSegment([1,3]),afLineSegment([2,4]),'g');
% 
% plot(a2fReducedWaves(8,:)','c');
% 
% find(a2fReducedWaves(:, 	7) > 1500 & abIntersect',1,'first')
% abIntersect = LineIntersection(a2fReducedWaves([1:8],:), afLineSegment);

% 
% figure(11);
%  iDebug = find(~abIntersect,1,'first')
% clf;
% plot(a2fReducedWaves(iDebug,:),'b');
% hold on;
% plot(afLineSegment([1,3]),afLineSegment([2,4]),'r');
% abIntersect = LineIntersection(a2fReducedWaves(iDebug,:), afLineSegment);

if bInclude
    if bOnlyUnsorted
        aiReducedSpikeAssociation(abVisibleSpike & abIntersect & aiReducedSpikeAssociation(:)' == 0) = astrctUnitIntervals(strctGUIParams.m_aiSelectedIntervals).m_iUniqueID;
    else
        aiReducedSpikeAssociation(abVisibleSpike & abIntersect) = astrctUnitIntervals(strctGUIParams.m_aiSelectedIntervals).m_iUniqueID;
    end
else
    if ~bOnlyUnsorted
        if min(strctGUIParams.m_aiSelectedIntervals) <= length(astrctUnitIntervals)
            aiReducedSpikeAssociation(abVisibleSpike & abIntersect & aiReducedSpikeAssociation(:)' ==astrctUnitIntervals(strctGUIParams.m_aiSelectedIntervals).m_iUniqueID ) = 0;
        end
    else
        aiReducedSpikeAssociation(abVisibleSpike & abIntersect ) = 0;
    end
end
aiUnitAssociation(iStartInd:iEndInd) = aiReducedSpikeAssociation;
fnUpdateUnitAssociation(handles,aiUnitAssociation);
fnInvalidatePCA(handles,false,false);
return;

function fnAddWavesOnlyUnsorted(handles,P1,P2)
fnChangeWaves(handles,P1,P2,true,true);
return;

function fnAddWaves(handles,P1,P2)
fnChangeWaves(handles,P1,P2,true,false);
return;


function fnRemoveWavesAll(handles,P1,P2)
fnChangeWaves(handles,P1,P2,false,true);
return;

function fnRemoveWaves(handles,P1,P2)
fnChangeWaves(handles,P1,P2,false,false);
return;

function fnChangeWavesContour(handles, a2fContour, bInclude, bOnlyUnsorted)

strctGUIParams =getappdata(handles.figure1,'strctGUIParams');

if length(strctGUIParams.m_aiSelectedIntervals) > 1 
    return;
end;
astrctUnitIntervals = fnGetIntervals(handles);

if isempty(strctGUIParams.m_aiSelectedIntervals) || ( length(strctGUIParams.m_aiSelectedIntervals) == 1 && strctGUIParams.m_aiSelectedIntervals == 1)
% Add a new interval
iNewUniqueValue = getappdata(handles.figure1,'iMaxUniqueID')+1;
afColor  = rand(1,3);
astrctUnitIntervals(end+1) = fnBuildNewInterval(astrctUnitIntervals(1).m_fStartTS_Plexon, astrctUnitIntervals(1).m_fEndTS_Plexon, iNewUniqueValue,afColor );

strctGUIParams.m_aiSelectedIntervals=length(astrctUnitIntervals);
setappdata(handles.figure1,'strctGUIParams',strctGUIParams);
fnUpdateIntervals(handles,astrctUnitIntervals,false);
setappdata(handles.figure1,'iMaxUniqueID',iNewUniqueValue);
fnInvalidateIntervalsAux(handles,astrctUnitIntervals,false,true);
fnInvalidateIntervals(handles,true);
    
end;

a2fPCA = getappdata(handles.figure1,'a2fPCA');

afSortedAllTS = getappdata(handles.figure1,'afSortedAllTS');
astrctUnitIntervals = fnGetIntervals(handles);
% Find all waves that intersect the line AND the time interval marked!
fCurrentTime=astrctUnitIntervals(1).m_fStartTS_Plexon;
fTimeWindowSec=astrctUnitIntervals(1).m_fEndTS_Plexon-astrctUnitIntervals(1).m_fStartTS_Plexon;

iStartInd = find(afSortedAllTS >= fCurrentTime,1,'first');
iEndInd = find(afSortedAllTS <= fCurrentTime+fTimeWindowSec,1,'last');
aiUnitAssociation = fnGetUnitAssociation(handles);
aiReducedSpikeAssociation = aiUnitAssociation(iStartInd:iEndInd);
abVisibleSpike = ones(1, length(aiReducedSpikeAssociation)) > 0;
aiInvisibleClusters = find( ~cat(1,astrctUnitIntervals.m_bVisible)); % Do not apply things on invisible clusters (!!!)

for k=1:length(aiInvisibleClusters)
    abVisibleSpike( aiReducedSpikeAssociation == astrctUnitIntervals(aiInvisibleClusters(k)).m_iUniqueID ) = 0;
end

a2fReducedPCA = a2fPCA(iStartInd:iEndInd,:);

iNumPtsX = 200;
iNumPtsY = 200;
afRangeX = linspace(strctGUIParams.m_afRangePCA(1),strctGUIParams.m_afRangePCA(2),iNumPtsX);
afRangeY = linspace(strctGUIParams.m_afRangePCA(3),strctGUIParams.m_afRangePCA(4),iNumPtsY);
a2bPCAMask=roipoly(afRangeX,afRangeY, zeros(length(afRangeY),length(afRangeX)), a2fContour(1,:),a2fContour(2,:));

abIntersect = interp2(afRangeX,afRangeY,double(a2bPCAMask),a2fReducedPCA(:,1),a2fReducedPCA(:,2))'> 0.5;

if bInclude
    if bOnlyUnsorted
        aiReducedSpikeAssociation(abVisibleSpike & abIntersect & aiReducedSpikeAssociation' == 0) = astrctUnitIntervals(strctGUIParams.m_aiSelectedIntervals).m_iUniqueID;
    else
        aiReducedSpikeAssociation(abVisibleSpike &  abIntersect) = astrctUnitIntervals(strctGUIParams.m_aiSelectedIntervals).m_iUniqueID;
    end
else
   if bOnlyUnsorted
     aiReducedSpikeAssociation(abVisibleSpike & abIntersect & aiReducedSpikeAssociation' ==astrctUnitIntervals(strctGUIParams.m_aiSelectedIntervals).m_iUniqueID ) = 0;
   else
       aiReducedSpikeAssociation(abVisibleSpike & abIntersect ) = 0;
   end
end
aiUnitAssociation(iStartInd:iEndInd) = aiReducedSpikeAssociation;
fnUpdateUnitAssociation(handles,aiUnitAssociation);
fnInvalidatePCA(handles,false,false);

return;

function fnAddWavesContourOnlyUnsorted(handles, a2fContour)
 fnChangeWavesContour(handles, a2fContour, true, true);
return;

function fnAddWavesContour(handles, a2fContour)
 fnChangeWavesContour(handles, a2fContour, true, false);
return;

function  fnRemoveWavesContourAll(handles, a2fContour)
fnChangeWavesContour(handles, a2fContour, false, false);
return;

function fnRemoveWavesContour(handles, a2fContour)
fnChangeWavesContour(handles, a2fContour, false, true);
return;



% --- Outputs from this function are returned to the command line.
function varargout = SpikeSorter_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%varargout{1} = handles.output;


% --- Executes on button press in hAddUnit.
function hAddUnit_Callback(hObject, eventdata, handles)
% hObject    handle to hAddUnit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in hDeleteUnit.
function hDeleteUnit_Callback(hObject, eventdata, handles)
% hObject    handle to hDeleteUnit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function hChannelsList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hChannelsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in hAddSpikes.
function hAddSpikes_Callback(hObject, eventdata, handles)
% hObject    handle to hAddSpikes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in hRemoveSpikes.
function hRemoveSpikes_Callback(hObject, eventdata, handles)
% hObject    handle to hRemoveSpikes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in hTrack.
function hTrack_Callback(hObject, eventdata, handles)
% hObject    handle to hTrack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in hUndo.
function hUndo_Callback(hObject, eventdata, handles)
% hObject    handle to hUndo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in hSave.
function hSave_Callback(hObject, eventdata, handles)


 
% --------------------------------------------------------------------
function hOpenFile_Callback(hObject, eventdata, handles)
% hObject    handle to hOpenFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function hSaveFile_Callback(hObject, eventdata, handles)
fnSaveCurrentChannel(handles);
return;

function fnSaveCurrentChannel(handles)
strSpikeFile = getappdata(handles.figure1,'strSpikeFile');
[strPath,strFile]=fileparts(strSpikeFile);

if get(handles.hUnsorted,'value') == 0
    % Sorted units. don't change folder...
    strOutputPath = [strPath,filesep];
    strOutFileName = strSpikeFile;
else
    % Raw unit. save files under processed
  % Was this an unsorted file or not ?
    strOutputPath = [strPath,filesep,'..',filesep,'Processed',filesep,'SortedUnits',filesep];
    strOutFileName = fullfile(strOutputPath,[strFile,'_sorted.raw']);
    fnScanAndUpdateFileList(handles);
end

if ~exist(strOutputPath,'dir')
    mkdir(strOutputPath);
end;


astrctUnitIntervals = fnGetIntervals(handles);
% Discard the first interval. It is the dummy controller
afSortedAllTS = getappdata(handles.figure1,'afSortedAllTS');
a2fSortedAllWaveForms = getappdata(handles.figure1,'a2fSortedAllWaveForms');
aiSpikeToUniqueID = fnGetUnitAssociation(handles);


% m_iUnitIndex
% m_afTimestamps
% m_iChannel
% m_afInterval
% m_a2fWaveforms

% Assign all spikes that are outside all interval label zero (?)

strctChannelInfo = getappdata(handles.figure1,'strctChannelInfo');
strctChannelInfo.m_bSorted = true;

iNumIntervals = length(astrctUnitIntervals)-1;
% Prep the astrctSpikes structure
for iUnitIter=1:iNumIntervals
    astrctSpikes(iUnitIter).m_iUnitIndex = astrctUnitIntervals(iUnitIter+1).m_iUniqueID;
    astrctSpikes(iUnitIter).m_afInterval = ...
        [astrctUnitIntervals(iUnitIter+1).m_fStartTS_Plexon,...
        astrctUnitIntervals(iUnitIter+1).m_fEndTS_Plexon];
    
    astrctSpikes(iUnitIter).m_afTimestamps = afSortedAllTS(aiSpikeToUniqueID == astrctSpikes(iUnitIter).m_iUnitIndex);
    astrctSpikes(iUnitIter).m_a2fWaveforms = a2fSortedAllWaveForms(aiSpikeToUniqueID == astrctSpikes(iUnitIter).m_iUnitIndex,:);
end
% Add all non-sorted spikes as a dummy interval
afUnsortedTS = afSortedAllTS(aiSpikeToUniqueID == 0);
if ~isempty(afUnsortedTS)
    
    astrctSpikes(iNumIntervals+1).m_iUnitIndex = 0;
    astrctSpikes(iNumIntervals+1).m_afInterval = [min(afUnsortedTS), max(afUnsortedTS)];
    astrctSpikes(iNumIntervals+1).m_afTimestamps = afUnsortedTS;
    astrctSpikes(iNumIntervals+1).m_a2fWaveforms = a2fSortedAllWaveForms(aiSpikeToUniqueID == 0,:);
end
if exist(strOutFileName,'file')
    [strF,strP]=uiputfile(strOutFileName);
    if strF(1) ~= 0
        fnDumpChannelSpikes(strctChannelInfo,astrctSpikes, [strP,strF]);
    else
        return;
    end
else
    fnDumpChannelSpikes(strctChannelInfo,astrctSpikes, strOutFileName);
end
% Discard undo
setappdata(handles.figure1,'acUndoOperations',{});
acIntervals = getappdata(handles.figure1,'acIntervals');
acIntervals = acIntervals(end);
setappdata(handles.figure1,'acIntervals',acIntervals);

acUnitAssociation = getappdata(handles.figure1,'acUnitAssociation');
acUnitAssociation = acUnitAssociation(end);
setappdata(handles.figure1,'acUnitAssociation',acUnitAssociation);
fprintf('Saved!\n');
return;

function afColor =fnGetDefaultUnitColors(iUniqueID)
Cube50=colorcube(50);
a2fColors = [1,1,0;
             0,1,0;
             0,1,1;
             1,0,0;
            Cube50(1:18,:)];
        afColor = a2fColors(1+mod(iUniqueID, 21),:);
return;


function hUnitTypeController_SelectionChangeFcn(hObject, eventdata, handles)
fnScanAndUpdateFileList(handles);
fnChangeChannel(handles);

return;





function bNoFiles = fnScanAndUpdateFileList(handles)
strRawFolder = getappdata(handles.figure1,'strRawFolder');
strSessionName = getappdata(handles.figure1,'strSessionName');
if strRawFolder(end) ~= filesep()
    strRawFolder(end+1) = filesep();
end;
if ~isempty(strSessionName)
    astrctRawFiles = dir([strRawFolder,strSessionName,'*-spikes_ch*.raw']);
else
    astrctRawFiles = dir([strRawFolder,strSessionName,'*_Spikes.raw']);
end
bNoFiles = false;
if isempty(astrctRawFiles)
    bNoFiles = true;
    return;
end;

acFileNamesRAW = {astrctRawFiles.name};
setappdata(handles.figure1,'acFileNamesRAW',acFileNamesRAW);
strSortedUnitsPath = [strRawFolder,filesep,'..',filesep,'Processed',filesep,'SortedUnits',filesep];
if ~isempty(strSessionName)
    astrctSortedFiles = dir([strSortedUnitsPath,strSessionName,'*-spikes_ch*.raw']);
else
    astrctSortedFiles = dir([strSortedUnitsPath,'*-spikes_ch*.raw']);
end
acFileNamesSorted = {astrctSortedFiles.name};

if isempty(acFileNamesSorted)
    set(handles.hSorted,'enable','off');
else
    set(handles.hSorted,'enable','on');
end


setappdata(handles.figure1,'acFileNamesSorted',acFileNamesSorted);
bSortedListActive = get(handles.hSorted,'value');
if ~bSortedListActive
    set(handles.hChannelsList,'string',acFileNamesRAW,'value',1);
else
    set(handles.hChannelsList,'string',acFileNamesSorted,'value',1);
end

if isempty(acFileNamesRAW)
    setappdata(handles.figure1,'strSession',[]);
        set(handles.hUseAnnotation,'enable','off');
else
    iIndex = strfind(acFileNamesRAW{1},'-spikes_ch');
    strSession = acFileNamesRAW{1}(1:iIndex-1);
    setappdata(handles.figure1,'strSession',strSession);
    strActiveUnitFile = [strRawFolder,strSession,'-ActiveUnits.txt'];
    if exist(strActiveUnitFile,'file')
        set(handles.hUseAnnotation,'enable','on');
    else
        set(handles.hUseAnnotation,'enable','off','value',0);
    end
end
return;


% --- Executes on button press in hUseAnnotation.
function hUseAnnotation_Callback(hObject, eventdata, handles)
fnChangeChannel(handles);
return;

% --- Executes on selection change in hChannelsList.
function hChannelsList_Callback(hObject, eventdata, handles)
fnChangeChannel(handles);

return;

function fnChangeChannel(handles)
% Save first ?
acUnitAssociation = getappdata(handles.figure1,'acUnitAssociation');
acIntervals = getappdata(handles.figure1,'acIntervals');
if length(acUnitAssociation) > 1 || length(acIntervals) > 1
    % Need to save things first (!!!)
    dbg = 1;    
    Answer=questdlg('Changed were made to this channel. Save?','Warning!','Save','Discard','Save');
    if strcmp(Answer,'Save')
        fnSaveCurrentChannel(handles);
    end
end

% Switch active channel!
strRawFolder = getappdata(handles.figure1,'strRawFolder');

iSelectedFile = get(handles.hChannelsList,'value');
if isempty(iSelectedFile)
    % TODO: Clear screen
    return;
end;
    
bSortedListActive = get(handles.hSorted,'value');

if ~bSortedListActive
    % Load RAW File
    acFileNamesRAW = getappdata(handles.figure1,'acFileNamesRAW');
    strSpikeFile = [strRawFolder,acFileNamesRAW{iSelectedFile}];
    % Generate intervals
    
else
   acFileNamesSorted = getappdata(handles.figure1,'acFileNamesSorted');
   strSortedUnitsPath = [strRawFolder,filesep,'..',filesep,'Processed',filesep,'SortedUnits',filesep];
   strSpikeFile = [strSortedUnitsPath,acFileNamesSorted{iSelectedFile}];
end
setappdata(handles.figure1,'strSpikeFile',strSpikeFile);
[astrctRawUnits, strctChannelInfo] = fnReadDumpSpikeFile(strSpikeFile);
setappdata(handles.figure1,'strctChannelInfo',strctChannelInfo);

iNumRawUnits = length(astrctRawUnits);

afAllTS = cat(1,astrctRawUnits.m_afTimestamps);
iNumSpikes = length(afAllTS);
a2fAllWaveForms = cat(1,astrctRawUnits.m_a2fWaveforms);
aiSpikeToRawUnitAssociation = zeros(iNumSpikes,1);
aiSpiketoChannelAssociation = zeros(iNumSpikes,1);
iCounter=1;
for iUnitIter=1:iNumRawUnits
    iNumSpikesInThisUnit = length(astrctRawUnits(iUnitIter).m_afTimestamps);
    aiSpikeToRawUnitAssociation(iCounter:iCounter+iNumSpikesInThisUnit-1) = astrctRawUnits(iUnitIter).m_iUnitIndex;
    aiSpiketoChannelAssociation(iCounter:iCounter+iNumSpikesInThisUnit-1) = strctChannelInfo.m_iChannelID;
    iCounter = iCounter + iNumSpikesInThisUnit;
end

[afSortedAllTS, aiSortInd] = sort(afAllTS);
a2fSortedAllWaveForms=a2fAllWaveForms(aiSortInd,:);
aiSortedSpikeToRawUnitAssociation=aiSpikeToRawUnitAssociation(aiSortInd);

%%
setappdata(handles.figure1,'acUnitAssociation',{aiSortedSpikeToRawUnitAssociation});

%%

%% PCA
a2fSortedAllWaveFormsZeroMean = bsxfun(@minus,a2fSortedAllWaveForms,mean(a2fSortedAllWaveForms,1));
[coeff,loads] = eig(a2fSortedAllWaveFormsZeroMean'*a2fSortedAllWaveFormsZeroMean);
%afLoads = flipud(diag(ignore));
a2fPCACoeff = fliplr(coeff);
a2fPCA = a2fSortedAllWaveFormsZeroMean*a2fPCACoeff(:,1:2)*loads(1:2,1:2);
setappdata(handles.figure1,'afSortedAllTS',afSortedAllTS);
setappdata(handles.figure1,'a2fPCA',a2fPCA);
setappdata(handles.figure1,'a2fSortedAllWaveForms',a2fSortedAllWaveForms);

 
%% Generate default intervals....
 strctSync = getappdata(handles.figure1,'strctSync');
if bSortedListActive
   if length(astrctRawUnits) >1
        astrctIntervals = fnGenerateDefaultIntervals([],astrctRawUnits,afSortedAllTS);
   else
        astrctIntervals = [];
   end
else
   % if annotation button is active and annotation is available, then
   % use it to label things for the first time...
%    strSession = getappdata(handles.figure1,'strSession');
    
    
        [strRawFolder,strTmp] =fileparts( strSpikeFile);
        strSession = strTmp(1:find(strTmp == '-',1,'first')-1);
        setappdata(handles.figure1,'strSession',strSession);

    
    if ~isempty(strSession) && get(handles.hUseAnnotation,'value')
        % Annotation is available.
        
        astrctIntervals = fnReadActiveUnits(handles,strRawFolder,strSession);
      
    else
        % no annotation available. 
        [astrctIntervals,aiNewAssoc] = fnGenerateDefaultIntervals(strctSync,astrctRawUnits,afSortedAllTS);
         setappdata(handles.figure1,'acUnitAssociation',{aiNewAssoc});

    end

end


        if ~isempty(astrctIntervals)
            fMaxIntervalTS = max(cat(1,astrctIntervals.m_fEndTS_Plexon));
        else
            fMaxIntervalTS = -Inf;
        end
        
strctGUIParams.m_afTimeRange = [afSortedAllTS(1),max(fMaxIntervalTS,afSortedAllTS(end))];
strctGUIParams.m_strMouseMode = 'Browse';
% Remove outliers?
fCenter1=median(a2fPCA(:,1));
fCenter2=median(a2fPCA(:,2));
fStd1=mad(a2fPCA(:,1));
fStd2=mad(a2fPCA(:,2));
fMin1 = fCenter1-5*fStd1;
fMin2 = fCenter2-5*fStd2;
fMax1 = fCenter1+5*fStd1;
fMax2 = fCenter2+5*fStd2;

strctGUIParams.m_afRangePCA = [fMin1,fMax1,fMin2,fMax2];%[min(a2fPCA(:,1)),max(a2fPCA(:,1)),min(a2fPCA(:,2)),max(a2fPCA(:,2))];
strctGUIParams.m_aiSelectedIntervals = 1;
               
setappdata(handles.figure1,'strctGUIParams',strctGUIParams);



if isempty(astrctIntervals)
    iMaxUniqueID = 1;
else
    iMaxUniqueID = 1+max(cat(1,astrctIntervals.m_iUniqueID));
end
setappdata(handles.figure1,'iMaxUniqueID',iMaxUniqueID);

%%

if min(diff(afSortedAllTS)) > 10

    % Pick a unique (?) color for each unit
    fTimwWindow = 120*30000;
else
    fTimwWindow = 120;
end

strctNewInterval =  fnBuildNewInterval(...
    afSortedAllTS(1), afSortedAllTS(1)+fTimwWindow,...
    -1,[0.5 0.5 0.5]);

if isempty(astrctIntervals)
    strctNewInterval.m_iVerticalStack  = 1;
else
    strctNewInterval.m_iVerticalStack = max(cat(1,astrctIntervals.m_iVerticalStack))+1;
end


setappdata(handles.figure1,'acIntervals',{[strctNewInterval,astrctIntervals]});
setappdata(handles.figure1,'acUndoOperations',{});


% Is there an advancer file available to see when we moved the electrode?
strSession = getappdata(handles.figure1,'strSession');
strAdvancerFile = [strRawFolder,filesep,strSession,'-Advancers.txt'];
strSyncFile = [strRawFolder,filesep,strSession,'-sync.mat'];
strStatServerFile =[strRawFolder,filesep,strSession,'-StatServerInfo.mat'];
if exist(strAdvancerFile,'file') && exist(strSyncFile,'file') && exist(strStatServerFile,'file')
    load(strSyncFile);
    strctStatServer=load(strStatServerFile);
    iAdvancerIndex = strctStatServer.g_strctNeuralServer.m_a2iChannelToGridHoleAdvancer(strctChannelInfo.m_iChannelID,3);
    a2cTemp = textread(strAdvancerFile);
    afTS_PLX = fnTimeZoneChange(a2cTemp(:,6),strctSync,'StatServer','Plexon');
    % iAdvancerIndex, fDepth, PlexonFrame, fEstimatedTimeStampPLXFile,fTS_MapClockNow,fTS_PTB
    aiInd = find(a2cTemp(:,1) == iAdvancerIndex);
    strctAdvancer.m_afTimeStampElectrodeMoved = afTS_PLX(aiInd);
    strctAdvancer.m_afDepthMM = a2cTemp(aiInd,2);
    setappdata(handles.figure1,'strctAdvancer',strctAdvancer);
else
    setappdata(handles.figure1,'strctAdvancer',[]);
end
%

fnInvalidateIntervalsAux(handles,[strctNewInterval,astrctIntervals],true,true);

fnInvalidatePCA(handles,false,true);


return;



function astrctIntervals = fnReadActiveUnits(handles,strRawFolder,strSession)
strSyncFile = fullfile(strRawFolder, [strSession,'-sync.mat']);
strActiveUnitsFile = fullfile(strRawFolder,[strSession,'-ActiveUnits.txt']);
%% Read real-time unit annotation
if exist(strSyncFile,'file')
    strctTmp =  load(strSyncFile);
    strctSync  =strctTmp.strctSync;
else
    strctSync = [];
end

a2fActiveUnitsTable = textread(strActiveUnitsFile);
astrctAnnotatedIntervals = fnActiveUnitTableToIntervals(a2fActiveUnitsTable, strctSync,strSession,strRawFolder);


acUnitAssociation = getappdata(handles.figure1,'acUnitAssociation');
afSortedAllTS = getappdata(handles.figure1,'afSortedAllTS');
strctChannelInfo = getappdata(handles.figure1,'strctChannelInfo');

iNumSpikes = length(acUnitAssociation{1});

%% Relabel spikes according to unit annotation...
aiSpikeToUnitAssociation = zeros(iNumSpikes,1);
iNumIntervals = length(astrctAnnotatedIntervals);
abRelevantIntervals      = zeros(iNumIntervals,1)>0;
for iMarkedUnitIter=1:iNumIntervals
    aiMatchedSpikes = find(afSortedAllTS >= astrctAnnotatedIntervals(iMarkedUnitIter).m_fStartTS_Plexon & afSortedAllTS <= astrctAnnotatedIntervals(iMarkedUnitIter).m_fEndTS_Plexon & ...
        strctChannelInfo.m_iChannelID == astrctAnnotatedIntervals(iMarkedUnitIter).m_iChannel & ...
        astrctAnnotatedIntervals(iMarkedUnitIter).m_iUnit == acUnitAssociation{1});

        abRelevantIntervals(iMarkedUnitIter) = strctChannelInfo.m_iChannelID == astrctAnnotatedIntervals(iMarkedUnitIter).m_iChannel;
    if ~isempty(aiMatchedSpikes)        
        aiSpikeToUnitAssociation(aiMatchedSpikes) = astrctAnnotatedIntervals(iMarkedUnitIter).m_iUniqueID;
    end
end

setappdata(handles.figure1,'acUnitAssociation',{aiSpikeToUnitAssociation});
% Set a new unit association
iMaxUniqueID = 1+max(cat(1,astrctAnnotatedIntervals.m_iUniqueID));
setappdata(handles.figure1,'iMaxUniqueID',iMaxUniqueID);
astrctRelevantIntervals = astrctAnnotatedIntervals(abRelevantIntervals);
if isempty(astrctRelevantIntervals)
    astrctIntervals = [];
    return;
end;

for k=1:length(astrctRelevantIntervals)
   astrctIntervals(k) =  fnBuildNewInterval(...
    astrctRelevantIntervals(k).m_fStartTS_Plexon,astrctRelevantIntervals(k).m_fEndTS_Plexon,...
        astrctRelevantIntervals(k).m_iUniqueID,         fnGetDefaultUnitColors(astrctRelevantIntervals(k).m_iUniqueID));
end
aiUnitVertical = fnGetIntervalVerticalValue(astrctIntervals,false);
for k=1:length(astrctIntervals)
    astrctIntervals(k).m_iVerticalStack = aiUnitVertical(k);
end;
return;




function fnSplitUnit(a,b,handles)
strctGUIParams = getappdata(handles.figure1,'strctGUIParams');
if isempty(strctGUIParams.m_aiSelectedIntervals) || length(strctGUIParams.m_aiSelectedIntervals) > 1 || strctGUIParams.m_aiSelectedIntervals == 1
    return;
end;
astrctUnitIntervals = fnGetIntervals(handles);
iUnitOfInterest = astrctUnitIntervals(strctGUIParams.m_aiSelectedIntervals).m_iUniqueID;
aiSpikeToUniqueID = fnGetUnitAssociation(handles);
a2fSortedAllWaveForms = getappdata(handles.figure1,'a2fSortedAllWaveForms');
aiRelevantSpikes = find(aiSpikeToUniqueID == iUnitOfInterest);
a2fWaves = a2fSortedAllWaveForms(aiRelevantSpikes,:);
% Remove outliers from waves to get a cleaner PCA space?
iNumWaves = size(a2fWaves,1);
afMedian = median(a2fWaves,1);
afStd = mad(a2fWaves,1);

hWaveFigure=figure;
clf;
plot(a2fWaves','k');
hold on;
plot(afMedian,'r');
plot(afMedian+4*afStd,'r--');
plot(afMedian-4*afStd,'r--');

a2bValid = ...
a2fWaves >= repmat(afMedian-4*afStd,iNumWaves,1) & ...
a2fWaves <= repmat(afMedian+4*afStd,iNumWaves,1) ;

abValid = all(a2bValid,2);

a2fValidWaves = a2fWaves(abValid,:);

a2fSortedAllWaveFormsZeroMean = bsxfun(@minus,a2fValidWaves,mean(a2fValidWaves,1));
[coeff,loeads] = eig(a2fSortedAllWaveFormsZeroMean'*a2fSortedAllWaveFormsZeroMean);
%afLoads = flipud(diag(ignore));
a2fPCACoeff = fliplr(coeff);
a2fPCA = a2fSortedAllWaveFormsZeroMean*a2fPCACoeff(:,1:2)*loads(1:2,1:2);

hPCAFig = figure;
plot(a2fPCA(:,1),a2fPCA(:,2),'k.');
[xi, yi, bCanceled] = fnCreateWaitModePolygon(gca,'Finish');
if bCanceled
    close(hWaveFigure);
    return;
end;

afRangeX = linspace(min(a2fPCA(:,2)),max(a2fPCA(:,2)),200);
afRangeY = linspace(min(a2fPCA(:,1)),max(a2fPCA(:,1)),200);

a2bPCAMask=roipoly(afRangeX,afRangeY, zeros(length(afRangeY),length(afRangeX)), xi,yi);
abInside = interp2(afRangeX,afRangeY,a2bPCAMask, a2fPCA(:,1),a2fPCA(:,2)) > 0.5;
close(hPCAFig);
close(hWaveFigure);

% Now, split....
% First, remove spikes outside the selected region!.

figure;
clf;
hold on;
plot(a2fValidWaves(abInside,:)','k');
plot(a2fValidWaves(~abInside,:)','r');
% 
% figure;
% plot(a2fPCA(:,1),a2fPCA(:,2),'k.');
% hold on;
% plot(xi,yi,'r');
% plot(a2fPCA(abInside,1),a2fPCA(abInside,2),'r.');


iNewUniqueValue = getappdata(handles.figure1,'iMaxUniqueID')+1;
aiSpikeToUniqueID(aiRelevantSpikes(~abInside)) = iNewUniqueValue;

afColor  = fnGetDefaultUnitColors(iNewUniqueValue);

astrctUnitIntervals(end+1) = fnBuildNewInterval(...
    astrctUnitIntervals(strctGUIParams.m_aiSelectedIntervals).m_fStartTS_Plexon, ...
    astrctUnitIntervals(strctGUIParams.m_aiSelectedIntervals).m_fEndTS_Plexon,...
    iNewUniqueValue,afColor  );

strctGUIParams.m_aiSelectedIntervals = length(astrctUnitIntervals);
setappdata(handles.figure1,'strctGUIParams',strctGUIParams);

fnUpdateUnitAssociation(handles,aiSpikeToUniqueID);

fnUpdateIntervals(handles,astrctUnitIntervals,false);
setappdata(handles.figure1,'iMaxUniqueID',iNewUniqueValue);
astrctUnitIntervals = fnGetIntervals(handles);
fnInvalidateIntervalsAux(handles,astrctUnitIntervals,true,true);
fnInvalidatePCA(handles,false,true);
return;



function hSortOnCluster_Callback(hObject, eventdata, handles)
dbg = 1;


% a2fPCA = getappdata(handles.figure1,'a2fPCA');
% acUnitAssociation = getappdata(handles.figure1,'acUnitAssociation');
% a2fSortedAllWaveForms = getappdata(handles.figure1,'a2fSortedAllWaveForms');
% afSortedAllTS = getappdata(handles.figure1,'afSortedAllTS');
%     astrctUnitIntervals = fnGetIntervals(handles);
% fCurrentTime=astrctUnitIntervals(1).m_fStartTS_Plexon;
% fTimeWindowSec=astrctUnitIntervals(1).m_fEndTS_Plexon-astrctUnitIntervals(1).m_fStartTS_Plexon;
% 
% iStartInd = find(afSortedAllTS >= fCurrentTime,1,'first');
% iEndInd = find(afSortedAllTS <= fCurrentTime+fTimeWindowSec,1,'last');
% 
% a2fReducedData = a2fPCA(iStartInd:iEndInd,:);
% a2fReducedWaves = a2fSortedAllWaveForms(iStartInd:iEndInd,:);
% aiReducedSpikeAssociation = acUnitAssociation{end}(iStartInd:iEndInd);
% 
% aiUnitsInRange = setdiff(unique(aiReducedSpikeAssociation),0);
% 
% iNumUnitsInRange = length(aiUnitsInRange);
% 
% iNumPtsInWave = size(a2fReducedWaves,2);
% iNumReducedWaves = size(a2fReducedWaves,1);
% a2fAvgWaveForm = zeros(iNumUnitsInRange,iNumPtsInWave);
% % Estimate mean...
% for k=1:iNumUnitsInRange
%     a2fAvgWaveForm(k,:) = mean(a2fReducedWaves(aiReducedSpikeAssociation == aiUnitsInRange(k),:));
% end
% 
% % Compute Distances...
% a2fDistancesToCluster = zeros(iNumReducedWaves, iNumUnitsInRange);
% for k=1:iNumUnitsInRange
%     a2fDistancesToCluster(:,k) = sqrt(sum((a2fReducedWaves - repmat(a2fAvgWaveForm(k,:),iNumReducedWaves,1)).^2,2));
% end
% [afMinDistance, aiClusterAssociation]=min(a2fDistancesToCluster,[],2);
% 
% aiNewSpikeAssociation = acUnitAssociation{end};
% aiNewSpikeAssociation(iStartInd:iEndInd) = aiUnitsInRange(aiClusterAssociation);
% 
% fnUpdateUnitAssociation(handles,aiNewSpikeAssociation);
% fnInvalidatePCA(handles,false,true);

return;
