function varargout = DesignGUI(varargin)
% DESIGNGUI MATLAB code for DesignGUI.fig
%      DESIGNGUI, by itself, creates a new DESIGNGUI or raises the existing
%      singleton*.
%
%      H = DESIGNGUI returns the handle to a new DESIGNGUI or the handle to
%      the existing singleton*.
%
%      DESIGNGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DESIGNGUI.M with the given input arguments.
%
%      DESIGNGUI('Property','Value',...) creates a new DESIGNGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DesignGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DesignGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DesignGUI

% Last Modified by GUIDE v2.5 05-Oct-2011 12:27:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DesignGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @DesignGUI_OutputFcn, ...
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


% --- Executes just before DesignGUI is made visible.
function DesignGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DesignGUI (see VARARGIN)

% Choose default command line output for DesignGUI
handles.output = hObject;
if length(varargin) >= 1
    strctDesign = varargin{1};
else
    strctDesign.m_astrctCond = [];
end
set(handles.figure1,'visible','on');
setappdata(handles.figure1,'strctOrigDesign',strctDesign);
setappdata(handles.figure1,'strctDesign',strctDesign);
fnInvalidateDesign(handles);


set(handles.figure1,'CloseRequestFcn',@fnCloseReq);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DesignGUI wait for user response (see UIRESUME)
uiwait(handles.figure1);
delete(handles.figure1);


function fnCloseReq(a,b)
% Do nothing.
return;

function fnInvalidateDesign(handles)
strctDesign = getappdata(handles.figure1,'strctDesign');
if isempty(strctDesign)
    set(handles.hConditionsList,'String',[]);
    set(handles.hBlockOrderTable,'Data',[]);
    return;
end    
astrctCond = strctDesign.m_astrctCond;
iNumCond = length(strctDesign.m_astrctCond);
if iNumCond == 0
acCondNames = {};    
else
    acCondNames = {strctDesign.m_astrctCond.m_strName};
end
% Update Cond

set(handles.hConditionsList,'String',acCondNames,'value',1,'min',1,'max',length(acCondNames));
% Update Cond order
iCounter = 1;
clear astrctIntervals
for iCondIter=1:length(astrctCond)
    for k=1:length(astrctCond(iCondIter).m_afStartTime)
        astrctIntervals(iCounter).m_iCondIndex = iCondIter;
        astrctIntervals(iCounter).m_strCondName = astrctCond(iCondIter).m_strName;
        astrctIntervals(iCounter).m_fStart = astrctCond(iCondIter).m_afStartTime(k);
        astrctIntervals(iCounter).m_fEnd = astrctCond(iCondIter).m_afStartTime(k)+astrctCond(iCondIter).m_afDuration(k);
        iCounter=iCounter+1;
    end
end
if length(astrctCond) == 0 || iCounter == 1
    set(handles.hBlockOrderTable,'visible','off');
    return;
else
    set(handles.hBlockOrderTable,'visible','on');
    [afDummy,aiSortInd]=sort(cat(1,astrctIntervals.m_fStart));
    astrctIntervalsSorted=astrctIntervals(aiSortInd);
    iNumIntervals = length(astrctIntervalsSorted);
    a2cData = cell(iNumIntervals,3);
    if ~isfield(strctDesign,'m_fTR_Sec')
        strctDesign.m_fTR_Sec = 2;
    end
    fTR = strctDesign.m_fTR_Sec;
    for iIntervalIter=1:iNumIntervals
        fDurationSec = astrctIntervalsSorted(iIntervalIter).m_fEnd-astrctIntervalsSorted(iIntervalIter).m_fStart;
        iDurationTRs = fDurationSec/fTR;
        a2cData{iIntervalIter,1} = astrctIntervalsSorted(iIntervalIter).m_strCondName;
        a2cData{iIntervalIter,2} = iDurationTRs;
        a2cData{iIntervalIter,3} = astrctIntervalsSorted(iIntervalIter).m_fStart/fTR;
    end
end
set(handles.hBlockOrderTable,'Data',a2cData,'ColumnName',{'Condition','Duration (TR)','Start (TR)'},...
    'ColumnFormat',{acCondNames,'numeric','numeric'},'ColumnEditable',[true true true],...
    'ColumnWidth',{200 80 80});

return;

% --- Outputs from this function are returned to the command line.
function varargout = DesignGUI_OutputFcn(hObject, eventdata, handles) 
global  g_TMP
varargout{1} = g_TMP;
clear global g_TMP
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


% --- Executes on button press in hNewCondition.
function hNewCondition_Callback(hObject, eventdata, handles)
strctDesign = getappdata(handles.figure1,'strctDesign');
iNumCond = length(strctDesign.m_astrctCond);

prompt={'Enter name for new condition:'};
name='New Name';
numlines=1;
defaultanswer={sprintf('Condition %d',iNumCond+1)};
answer=inputdlg(prompt,name,numlines,defaultanswer);
if isempty(answer)
    return;
end;

strctDesign.m_astrctCond(iNumCond+1).m_strName = answer{1};
strctDesign.m_astrctCond(iNumCond+1).m_afStartTime = [];
strctDesign.m_astrctCond(iNumCond+1).m_afDuration = [];
setappdata(handles.figure1,'strctDesign',strctDesign);
fnInvalidateDesign(handles)
return;       

 

% --- Executes during object creation, after setting all properties.
function hDesignName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hDesignName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hSave_Callback(hObject, eventdata, handles)
global  g_TMP
g_TMP{1} = getappdata(handles.figure1,'strctDesign');
g_TMP{2} = true;
uiresume(gcbf);
return;

function hCancel_Callback(hObject, eventdata, handles)
global g_TMP
g_TMP{1} = getappdata(handles.figure1,'strctOrigDesign');
g_TMP{2} = false;
uiresume(gcbf);
return;


function hMergeCond_Callback(hObject, eventdata, handles)
strctDesign = getappdata(handles.figure1,'strctDesign');
aiSelectedToMerge = get(handles.hConditionsList,'value');
strctNewCondition.m_strName = 'Merged';
strctNewCondition.m_afStartTime = [];
strctNewCondition.m_afDuration = [];
for k=1:length(aiSelectedToMerge)
    strctNewCondition.m_afStartTime = [strctNewCondition.m_afStartTime,strctDesign.m_astrctCond(aiSelectedToMerge(k)).m_afStartTime];
    strctNewCondition.m_afDuration= [strctNewCondition.m_afDuration,strctDesign.m_astrctCond(aiSelectedToMerge(k)).m_afDuration];
end

[afSortedTime, aiSortInd] = sort(strctNewCondition.m_afStartTime);
strctNewCondition.m_afStartTime = strctNewCondition.m_afStartTime(aiSortInd);
strctNewCondition.m_afDuration = strctNewCondition.m_afDuration(aiSortInd);
strctDesign.m_astrctCond(aiSelectedToMerge) = [];
strctDesign.m_astrctCond = [strctNewCondition,strctDesign.m_astrctCond];

afMinStart = zeros(1,length(strctDesign.m_astrctCond));
for k=1:length(strctDesign.m_astrctCond)
    afMinStart(k) = min(strctDesign.m_astrctCond(k).m_afStartTime);
end
[afDummy, aiSortInd] = sort(afMinStart);
strctDesign.m_astrctCond=strctDesign.m_astrctCond(aiSortInd);


setappdata(handles.figure1,'strctDesign',strctDesign);
fnInvalidateDesign(handles)

return;



% --- Executes on button press in hRenameCond.
function hRenameCond_Callback(hObject, eventdata, handles)
strctDesign = getappdata(handles.figure1,'strctDesign');
aiSelectedToRename = get(handles.hConditionsList,'value');
if length(aiSelectedToRename) > 1
    h=msgbox('You need to rename each condition one at a time!');
    waitfor(h)
    return;
end;


prompt={'Enter name for new condition:'};
name='New Name';
numlines=1;
defaultanswer={strctDesign.m_astrctCond(aiSelectedToRename).m_strName};
answer=inputdlg(prompt,name,numlines,defaultanswer);
if isempty(answer)
    return;
end;
strctDesign.m_astrctCond(aiSelectedToRename).m_strName = answer{1};
setappdata(handles.figure1,'strctDesign',strctDesign);
fnInvalidateDesign(handles)

return;


% --- Executes when entered data in editable cell(s) in hBlockOrderTable.
function hBlockOrderTable_CellEditCallback(hObject, eventdata, handles)
setappdata(handles.figure1,'a2iSelectedInd',eventdata.Indices);
a2cNewData = get(hObject,'Data');
strctDesign = getappdata(handles.figure1,'strctDesign');
acConditionNames = {strctDesign.m_astrctCond.m_strName};
iNumEntries = size(a2cNewData,1);
% Zero out all entires
for k=1:length(acConditionNames)
    strctDesign.m_astrctCond(k).m_afStartTime = [];
    strctDesign.m_astrctCond(k).m_afDuration = [];
end

for iIter=1:iNumEntries
    % Find which condition number it is
    iCondIndex = find(ismember(acConditionNames, a2cNewData{iIter,1}));
    strctDesign.m_astrctCond(iCondIndex).m_afStartTime = [strctDesign.m_astrctCond(iCondIndex).m_afStartTime, a2cNewData{iIter,3}*strctDesign.m_fTR_Sec];
    strctDesign.m_astrctCond(iCondIndex).m_afDuration= [strctDesign.m_astrctCond(iCondIndex).m_afDuration, a2cNewData{iIter,2}*strctDesign.m_fTR_Sec];
end

setappdata(handles.figure1,'strctDesign',strctDesign);
fnInvalidateDesign(handles)
return;

% --- Executes on button press in hAddBlock.
function hAddBlock_Callback(hObject, eventdata, handles)
strctDesign = getappdata(handles.figure1,'strctDesign');

aiCurrCond = get(handles.hConditionsList,'value');
iSelectedCondition= aiCurrCond(1);
astrctCond = strctDesign.m_astrctCond;
% Convert to intervals...
iCounter = 1;
clear astrctIntervals
for iCondIter=1:length(astrctCond)
    for k=1:length(astrctCond(iCondIter).m_afStartTime)
        astrctIntervals(iCounter).m_iCondIndex = iCondIter;
        astrctIntervals(iCounter).m_strCondName = astrctCond(iCondIter).m_strName;
        astrctIntervals(iCounter).m_fStart = astrctCond(iCondIter).m_afStartTime(k);
        astrctIntervals(iCounter).m_fEnd = astrctCond(iCondIter).m_afStartTime(k)+astrctCond(iCondIter).m_afDuration(k);
        iCounter=iCounter+1;
    end
end
if iCounter == 1
    fStartTime = 0;
else
    fStartTime = max(cat(1,astrctIntervals.m_fEnd));
end;

strctDesign.m_astrctCond(iSelectedCondition).m_afStartTime(end+1) = fStartTime;
strctDesign.m_astrctCond(iSelectedCondition).m_afDuration(end+1) = 12 * strctDesign.m_fTR_Sec; % Default number of TRs

setappdata(handles.figure1,'strctDesign',strctDesign);
fnInvalidateDesign(handles)
return;


function hRemoveBlocks_Callback(hObject, eventdata, handles)
a2iSelectedInd = getappdata(handles.figure1,'a2iSelectedInd');
aiEntriesToRemove = a2iSelectedInd(:,1);
strctDesign = getappdata(handles.figure1,'strctDesign');
acConditionNames = {strctDesign.m_astrctCond.m_strName};
a2cData = get(handles.hBlockOrderTable,'Data');

for iIter=1:length(aiEntriesToRemove)
        iCondIndex = find(ismember(acConditionNames, a2cData{aiEntriesToRemove(iIter),1}));
        fStartTime = a2cData{aiEntriesToRemove(iIter),3}*strctDesign.m_fTR_Sec;
        iIndexToRemove = find(strctDesign.m_astrctCond(iCondIndex).m_afStartTime == fStartTime);
        strctDesign.m_astrctCond(iCondIndex).m_afStartTime(iIndexToRemove) = [];
        strctDesign.m_astrctCond(iCondIndex).m_afDuration(iIndexToRemove) = [];
end

setappdata(handles.figure1,'strctDesign',strctDesign);
fnInvalidateDesign(handles)
return;



% --- Executes when selected cell(s) is changed in hBlockOrderTable.
function hBlockOrderTable_CellSelectionCallback(hObject, eventdata, handles)
setappdata(handles.figure1,'a2iSelectedInd',eventdata.Indices);

% --- Executes on button press in hDeleteCond.
function hDeleteCond_Callback(hObject, eventdata, handles)
strctDesign = getappdata(handles.figure1,'strctDesign');
aiSelectedConditions = get(handles.hConditionsList,'value');
strctDesign.m_astrctCond(aiSelectedConditions) = [];
setappdata(handles.figure1,'strctDesign',strctDesign);
fnInvalidateDesign(handles)
return;


