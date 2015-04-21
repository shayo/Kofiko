function varargout = DataBrowserPopulation(varargin)
% DATABROWSERPOPULATION MATLAB code for DataBrowserPopulation.fig
%      DATABROWSERPOPULATION, by itself, creates a new DATABROWSERPOPULATION or raises the existing
%      singleton*.
%
%      H = DATABROWSERPOPULATION returns the handle to a new DATABROWSERPOPULATION or the handle to
%      the existing singleton*.
%
%      DATABROWSERPOPULATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DATABROWSERPOPULATION.M with the given input arguments.
%
%      DATABROWSERPOPULATION('Property','Value',...) creates a new DATABROWSERPOPULATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DataBrowserPopulation_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DataBrowserPopulation_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DataBrowserPopulation

% Last Modified by GUIDE v2.5 20-Apr-2012 08:38:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DataBrowserPopulation_OpeningFcn, ...
                   'gui_OutputFcn',  @DataBrowserPopulation_OutputFcn, ...
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

function fnSelection(hObject,strctTmp,handles)
aiSelected = get(hObject,'SelectedRows')+1;
setappdata(handles.figure1,'aiSelected',aiSelected);
return;

% --- Executes just before DataBrowserPopulation is made visible.
function DataBrowserPopulation_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DataBrowserPopulation (see VARARGIN)

% Choose default command line output for DataBrowserPopulation
handles.output = hObject;
if ~isempty(varargin{1})
   acPopulation = varargin{1};
   fnAddData(handles,acPopulation);
end



set(handles.figure1,'visible','on');
warning off
hJTable1 = fnGetJavaHandle(handles.hPopTable);
set(hJTable1,'DoubleBuffered','on');
hJTable1.setNonContiguousCellSelection(false);
hJTable1.setColumnSelectionAllowed(false);
hJTable1.setRowSelectionAllowed(true);
% hJTable = handle(hJTable, 'CallbackProperties');
set(hJTable1, 'MousePressedCallback', {@fnSelection, handles});
set(hJTable1, 'MouseDraggedCallback', {@fnSelection, handles});
set(hJTable1, 'KeyPressedCallback', {@fnSelection, handles});
set(hJTable1, 'KeyPressedCallback', {@fnDisplayEntries, handles});
setappdata(handles.figure1,'hJTable1',hJTable1);
warning on


% Display population attributes in table


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DataBrowserPopulation wait for user response (see UIRESUME)
% uiwait(handles.figure1);




function fnAddData(handles,acNewData)
acPopulation = getappdata(handles.figure1,'acPopulation');

acExistingDataFiles = fnCellStructToArray(acPopulation,'m_strFile');
acNewDataFiles= fnCellStructToArray(acNewData,'m_strFile');
acNewDataUnique = acNewData(~ismember(acNewDataFiles,acExistingDataFiles));

[abReplace,aiLoc] = ismember(acExistingDataFiles,acNewDataFiles);
if ~isempty(abReplace)
    acPopulation(find(aiLoc)) = acNewData(aiLoc(aiLoc>0));
end
acPopulation = [acPopulation,acNewDataUnique];
setappdata(handles.figure1,'acPopulation',acPopulation);

fnInvalidate(handles);

return;

function fnInvalidate(handles)
acPopulation = getappdata(handles.figure1,'acPopulation');

iNumEntries = length(acPopulation);

acAllAttributes = [];
% Build attributes from the highlighted sessions...
for iIter=1:length(acPopulation)
            acAllAttributes = [acAllAttributes, acPopulation{iIter}.m_a2cAttributes(1,:)];
end
acAttributes=unique(acAllAttributes);
% Prioritize certain attributes.
acPrioritize ={'Subject','TimeDate','Channel','Unit','Paradigm','List','Design'};
acAttributes=[acPrioritize(ismember(acPrioritize,intersect(acAttributes, acPrioritize))), setdiff(acAttributes,acPrioritize)];

iNumColumns = length(acAttributes);
a2cData = cell(iNumEntries,iNumColumns);

for iIter=1:iNumEntries
        for iAttrIter=1:length(acAttributes)
            [bAttributeExist, strValue] = fnFindAttribute( acPopulation{iIter}.m_a2cAttributes, acAttributes{iAttrIter});
            if bAttributeExist
                a2cData{iIter,iAttrIter} = strValue;
            else
                a2cData{iIter,iAttrIter} = 'N/A';
            end
        end
end

set(handles.hPopTable,'Data',a2cData,'ColumnName',acAttributes,'columnWidth',{150});

return;


% --- Outputs from this function are returned to the command line.
function varargout = DataBrowserPopulation_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function hRemoveFromPopulation_Callback(hObject, eventdata, handles)
acPopulation = getappdata(handles.figure1,'acPopulation');
hJTable1 = getappdata(handles.figure1,'hJTable1');
aiSelected = hJTable1.getSelectedRows+1;
if ~isempty(acPopulation)
    acPopulation(aiSelected(aiSelected <= length(acPopulation))) = [];
    setappdata(handles.figure1,'acPopulation',acPopulation);
    fnInvalidate(handles);
end
return;

% --------------------------------------------------------------------
function hPopulationMenu_Callback(hObject, eventdata, handles)
strctConfig = fnMyXMLToStruct(fullfile('.', 'Config', 'DataBrowser.xml'));
if ~iscell(strctConfig.m_strctPopulationPipelines.m_acPipeline)
    strctConfig.m_strctPopulationPipelines.m_acPipeline = {strctConfig.m_strctPopulationPipelines.m_acPipeline};
end
setappdata(handles.figure1,'strctConfig',strctConfig);

% Update menus.
fnUpdateMenus(handles);




function fnUpdateMenus(handles)
strctConfig= getappdata(handles.figure1,'strctConfig');

iNumPipelinesAnalysisAvil = length(strctConfig.m_strctPopulationPipelines.m_acPipeline);
acOpt=cell(1,iNumPipelinesAnalysisAvil);
for k=1:iNumPipelinesAnalysisAvil
    acOpt{k} = strctConfig.m_strctPopulationPipelines.m_acPipeline{k}.m_strName;
end
delete(get(handles.hPopulationMenu,'Children'));

for k=1:length(acOpt)
    uimenu(handles.hPopulationMenu,'Label',acOpt{k},'callback',...
        {@fnPipelineCallback,strctConfig.m_strctPopulationPipelines.m_acPipeline{k}.m_strFunc,handles});
 end

return;

function fnPipelineCallback(a,b,hAnal,handles)
acPopulation = getappdata(handles.figure1,'acPopulation');
feval(hAnal, acPopulation)
return



% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function hLoad_Callback(hObject, eventdata, handles)
[strFile,strPath]=uigetfile('Population.mat');
if strFile(1) ==0
    return
end
fprintf('Loading list of data entries from %s...',fullfile(strPath,strFile))
strctTmp = load(fullfile(strPath,strFile));
if ~isfield(strctTmp,'acPopulation')
    h=msgbox('Wrong file type');
    waitfor(h);
    return;
end;
setappdata(handles.figure1,'acPopulation',strctTmp.acPopulation);
fnInvalidate(handles);
fprintf('Done!\n');


% --------------------------------------------------------------------
function hSave_Callback(hObject, eventdata, handles)
acPopulation = getappdata(handles.figure1,'acPopulation');
[strFile,strPath]=uiputfile('Population.mat');
fprintf('Saving list of data entries to %s...',fullfile(strPath,strFile))
save(fullfile(strPath,strFile),'acPopulation');
fprintf('Done!\n');
return;

% --------------------------------------------------------------------
function hCopy_Callback(hObject, eventdata, handles)
% hObject    handle to hCopy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





function fnDisplayEntries(hObject,strctTmp,handles)
acDisplayedEntries = getappdata(handles.figure1,'acPopulation');
hJTable1 = getappdata(handles.figure1,'hJTable1');
aiSelected = hJTable1.getSelectedRows+1;

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


function fnOpenPanels(hFig)
iNumPanels = 5;
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


function PopulationContextMenu_Callback(hObject, eventdata, handles)


function hPrintLocation_Callback(hObject, eventdata, handles)
acPopulation = getappdata(handles.figure1,'acPopulation');
hJTable1 = getappdata(handles.figure1,'hJTable1');
aiSelected = hJTable1.getSelectedRows+1;

for k=1:length(aiSelected)
    acPopulation{aiSelected(k)}.m_strFile
end