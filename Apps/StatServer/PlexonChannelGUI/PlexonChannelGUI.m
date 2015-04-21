function varargout = PlexonChannelGUI(varargin)
% PLEXONCHANNELGUI M-file for PlexonChannelGUI.fig
%      PLEXONCHANNELGUI, by itself, creates a new PLEXONCHANNELGUI or raises the existing
%      singleton*.
%
%      H = PLEXONCHANNELGUI returns the handle to a new PLEXONCHANNELGUI or the handle to
%      the existing singleton*.
%
%      PLEXONCHANNELGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLEXONCHANNELGUI.M with the given input arguments.
%
%      PLEXONCHANNELGUI('Property','Value',...) creates a new PLEXONCHANNELGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PlexonChannelGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PlexonChannelGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PlexonChannelGUI

% Last Modified by GUIDE v2.5 14-Sep-2012 16:10:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PlexonChannelGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @PlexonChannelGUI_OutputFcn, ...
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


% --- Executes just before PlexonChannelGUI is made visible.
function PlexonChannelGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PlexonChannelGUI (see VARARGIN)

% Choose default command line output for PlexonChannelGUI
handles.output = hObject;

acSpikeChannelNames = varargin{1};
acAnalogChannelNames = varargin{2};
aiActiveAnalogChannels = varargin{3};

iNumSpikeChannels = length(acSpikeChannelNames);

% Automatically try to infer which spike channels are active (stupid
% plexon, why can't they give this information as well?!?!?)
acActiveAnalogChannels = acAnalogChannelNames(aiActiveAnalogChannels); % ordering is important!

% Filter out names that we know are not linked to spiking channels...
acRemainingChannelNames = setdiff(acActiveAnalogChannels,{'EyeX','EyeY','Eye Pupil','Juice','Photodiode','Motion','Grass_Train','Grass_Train2','Stimulation_Trig','Stimulation_Trig2'});

aiSpikeToAnalogMapping = zeros(1,iNumSpikeChannels);
abActiveSpikeChannel = zeros(1,iNumSpikeChannels) > 0;
if ismember('LFP01',acRemainingChannelNames)
   % Shay's new rig configuration. 
   for iChannelIter=1:iNumSpikeChannels
       iIndex = find(ismember( acActiveAnalogChannels,sprintf('LFP%02d',iChannelIter)));
       if ~isempty(iIndex)
            aiSpikeToAnalogMapping(iChannelIter) = iIndex;
       end
       abActiveSpikeChannel(iChannelIter) = ismember(sprintf('LFP%02d',iChannelIter), acRemainingChannelNames);
   end
   
else
    % Assume old rig configuration. Search for "AD01"
    for iChannelIter=1:iNumSpikeChannels
        iIndex = find(ismember( acRemainingChannelNames,sprintf('AD%02d',iChannelIter)));
        if ~isempty(iIndex)
            aiSpikeToAnalogMapping(iChannelIter) = iIndex;
        end
        abActiveSpikeChannel(iChannelIter) = ismember(sprintf('AD%02d',iChannelIter), acRemainingChannelNames);
     end
end
strctPlexon.m_acActiveAnalogChannels = acActiveAnalogChannels;
strctPlexon.m_acSpikeChannelNames = acSpikeChannelNames;
strctPlexon.m_acAnalogChannelNames = acAnalogChannelNames;
strctPlexon.m_abActiveSpikeChannel = abActiveSpikeChannel;
strctPlexon.m_aiSpikeToAnalogMapping = aiSpikeToAnalogMapping;

setappdata(handles.figure1,'strctPlexon',strctPlexon);
fnUpdateTable(handles,strctPlexon);

fnLoadPresets(handles);
    
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PlexonChannelGUI wait for user response (see UIRESUME)
uiwait(handles.figure1);



function fnUpdateTable(handles, strctPlexon)
iNumSpikeChannels = length(strctPlexon.m_acSpikeChannelNames);
a2cData = cell(iNumSpikeChannels,3);
for k=1:iNumSpikeChannels
    a2cData{k,1} = strctPlexon.m_acSpikeChannelNames{k};
    if strctPlexon.m_aiSpikeToAnalogMapping(k) > 0
        a2cData{k,2} = strctPlexon.m_acActiveAnalogChannels{strctPlexon.m_aiSpikeToAnalogMapping(k)};
    else
        a2cData{k,2} = 'N/A';
    end
    
    a2cData{k,3} = strctPlexon.m_abActiveSpikeChannel(k);
end

set(handles.hChannelTable,'Data',a2cData,...
    'ColumnFormat',{'char',[strctPlexon.m_acActiveAnalogChannels,'N/A'],'logical'},...
    'ColumnName',{'Spike Channel Name','Corresponding Analog LFP Channel','Enabled'},...
    'ColumnEditable',[false true true]);

return;



% --- Outputs from this function are returned to the command line.
function varargout = PlexonChannelGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isempty(handles)
    varargout{1} = [];
else
    varargout{1} = handles.output;
    delete(handles.figure1);
end
    
    
return;


% --- Executes on selection change in hPreset.
function hPreset_Callback(hObject, eventdata, handles)
% hObject    handle to hPreset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns hPreset contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hPreset


% --- Executes during object creation, after setting all properties.
function hPreset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hPreset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function strctPlexon=fnUpdatePlexonStructFromTable(handles)
strctPlexon = getappdata(handles.figure1,'strctPlexon');
a2cData = get(handles.hChannelTable,'Data');

iNumChannels = size(a2cData,1);
for iChannelIter=1:iNumChannels
    strctPlexon.m_abActiveSpikeChannel(iChannelIter) = a2cData{iChannelIter,3};
    iIndex = find(ismember(strctPlexon.m_acActiveAnalogChannels, a2cData{iChannelIter,2}));
    if isempty(iIndex)
        strctPlexon.m_aiSpikeToAnalogMapping(iChannelIter) = 0;
    else
        strctPlexon.m_aiSpikeToAnalogMapping(iChannelIter) = iIndex;
    end
    
end
setappdata(handles.figure1,'strctPlexon',strctPlexon);
return;

% --- Executes on button press in hSavePreset.
function hSavePreset_Callback(hObject, eventdata, handles)
strctPlexon = fnUpdatePlexonStructFromTable(handles);

prompt={'Enter the name for your new preset'};
name='Preset name';
numlines=1;
defaultanswer={'New Preset'};

answer=inputdlg(prompt,name,numlines,defaultanswer);
if isempty(answer)
    return;
end;

fnUpdatePresets(handles,strctPlexon,answer{1});
return;

function fnUpdatePresets(handles,strctPlexon,strPresetName)
strPresetFile = '.\Config\PlexonPreset.mat';
acPresets = getappdata(handles.figure1,'acPresets');
if isempty(acPresets)
    acPresets{1}.m_strName = strPresetName;
    acPresets{1}.m_strctPlexon = strctPlexon;
else
    iNewEntry = length(acPresets)+1;
    acPresets{iNewEntry}.m_strName = strPresetName;
    acPresets{iNewEntry}.m_strctPlexon = strctPlexon;
end
setappdata(handles.figure1,'acPresets',acPresets);
save(strPresetFile,'acPresets');
fnLoadPresets(handles);
return;

function fnLoadPresets(handles)
strPresetFile = '.\Config\PlexonPreset.mat';
if exist(strPresetFile,'file')
    strctTmp = load(strPresetFile);
    setappdata(handles.figure1,'acPresets',strctTmp.acPresets);
else
    setappdata(handles.figure1,'acPresets',[]);
end
acPresets = getappdata(handles.figure1,'acPresets');
% Update preset box
iNumPresets = length(acPresets);
if iNumPresets == 0
    set(handles.hPreset,'enable','off');
    set(handles.hLoadPreset,'enable','off');
else
    set(handles.hPreset,'enable','on');
    set(handles.hLoadPreset,'enable','on');
    acName = cell(1,iNumPresets);
    for k=1:iNumPresets
        acName{k} = acPresets{k}.m_strName;
    end
    set(handles.hPreset,'String',acName,'value',1);
end
return;


% --- Executes on button press in hLoadPreset.
function hLoadPreset_Callback(hObject, eventdata, handles)
acPresets = getappdata(handles.figure1,'acPresets');
iSelectedPreset = get(handles.hPreset,'value');

strctPlexon = getappdata(handles.figure1,'strctPlexon');
aiActiveChannels = find(strctPlexon.m_abActiveSpikeChannel);
for k=1:length(aiActiveChannels)
    % Find the channel names on the existing preset?
    
    iIndex = find(ismember(acPresets{iSelectedPreset}.m_strctPlexon.m_acSpikeChannelNames, strctPlexon.m_acSpikeChannelNames{aiActiveChannels(k)}));
    if ~isempty(iIndex)
        % good, we can potentially match the LFP channel
        strLFP = acPresets{iSelectedPreset}.m_strctPlexon.m_acActiveAnalogChannels{        acPresets{iSelectedPreset}.m_strctPlexon.m_aiSpikeToAnalogMapping(iIndex)};
        iLFPChannelIndex = find(ismember(strctPlexon.m_acActiveAnalogChannels,strLFP));
        if ~isempty(iLFPChannelIndex)
            strctPlexon.m_aiSpikeToAnalogMapping(aiActiveChannels(k)) = iLFPChannelIndex;
        end
    end
end

       
 % Test whether we can apply the preset. This will depend on which channels
 % are active...
setappdata(handles.figure1,'strctPlexon',strctPlexon );
fnUpdateTable(handles, strctPlexon);
return;



function hContinue_Callback(hObject, eventdata, handles)
% Verify all active channels have corresponding LFP channel....
strctPlexon=fnUpdatePlexonStructFromTable(handles);

if ~all(strctPlexon.m_aiSpikeToAnalogMapping(strctPlexon.m_abActiveSpikeChannel) > 0)
   h=msgbox('You have active channels without corresponding LFP channel. Cannot Continue!'); 
   waitfor(h); 
   return;
end
handles.output = strctPlexon;
guidata(hObject, handles);
uiresume(handles.figure1);
return;


% --- Executes on button press in hDeletePreset.
function hDeletePreset_Callback(hObject, eventdata, handles)
% hObject    handle to hDeletePreset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
strPresetFile = '.\Config\PlexonPreset.mat';

acPresets = getappdata(handles.figure1,'acPresets');
if ~isempty(acPresets)
    iPresetIndex = get(handles.hPreset,'value');
    acPresets(iPresetIndex) = [];
    setappdata(handles.figure1,'acPresets',acPresets);
    save(strPresetFile,'acPresets');
    fnLoadPresets(handles);
end
return;


% --- Executes on button press in hEnableTetrodeMode.
function hEnableTetrodeMode_Callback(hObject, eventdata, handles)
% hObject    handle to hEnableTetrodeMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hEnableTetrodeMode
