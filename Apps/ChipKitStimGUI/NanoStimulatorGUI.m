function varargout = NanoStimulatorGUI(varargin)
% NANOSTIMULATORGUI MATLAB code for NanoStimulatorGUI.fig
%      NANOSTIMULATORGUI, by itself, creates a new NANOSTIMULATORGUI or raises the existing
%      singleton*.
%
%      H = NANOSTIMULATORGUI returns the handle to a new NANOSTIMULATORGUI or the handle to
%      the existing singleton*.
%
%      NANOSTIMULATORGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NANOSTIMULATORGUI.M with the given input arguments.
%
%      NANOSTIMULATORGUI('Property','Value',...) creates a new NANOSTIMULATORGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before NanoStimulatorGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to NanoStimulatorGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help NanoStimulatorGUI

% Last Modified by GUIDE v2.5 24-Sep-2012 13:32:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @NanoStimulatorGUI_OpeningFcn, ...
    'gui_OutputFcn',  @NanoStimulatorGUI_OutputFcn, ...
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


% --- Executes just before NanoStimulatorGUI is made visible.
function NanoStimulatorGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to NanoStimulatorGUI (see VARARGIN)

% Choose default command line output for NanoStimulatorGUI
handles.output = hObject;
dbstop if error
strctParams=getappdata(handles.figure1,'strctParams');
if isempty(strctParams) 
    strctParams.m_strIP = '192.168.50.17';
    strctParams.m_strPort = '5000';
    strctParams.m_hSocket = msconnect(strctParams.m_strIP,str2num(strctParams.m_strPort),1); % try to connect.
    
    if 0
        % MODIFY IP address in rom!
        TCP_MODIFY_IP = 19;
        mssendraw(strctParams.m_hSocket,uint8([sprintf('%02d 192 168 50 17',TCP_MODIFY_IP),0]));
        S=fnRecvString(strctParams.m_hSocket, 1);
        TCP_MODIFY_PORT = 20;
        mssendraw(strctParams.m_hSocket,uint8([sprintf('%02d 5000',TCP_MODIFY_PORT),0]));
        S=fnRecvString(strctParams.m_hSocket, 1);
    end
    
    
    bConnected = fnStimulatorOnline(strctParams.m_hSocket);
    if bConnected
        set(handles.hStatus,'String','Online','Foregroundcolor','g','backgroundcolor','k');
        [strctParams.m_astrctChannels,strctParams.m_acPresetNames]=fnReadParametersFromStimulator(strctParams.m_hSocket);
    else
        strctParams.m_astrctChannels = [];
    strctParams.m_acPresetNames = [];
            set(handles.hStatus,'String','Offline','Foregroundcolor','r','backgroundcolor','k');
    end
end
setappdata(handles.figure1,'strctParams',strctParams);

fnInvalidate(handles);
set(handles.figure1,'CloseRequestFcn',@fnProperShutdown);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes NanoStimulatorGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function fnProperShutdown(hObj,b)
strctParams=getappdata(hObj,'strctParams');
if ~isempty(strctParams)
    msclose(strctParams.m_hSocket);
end
delete(hObj);
return;

function strString = fnMicronsToString(iMicrons)
if (iMicrons <= 1000)
    strString = sprintf('%d usec',iMicrons);
else if (iMicrons > 1000 && iMicrons < 1000000)
        strString = sprintf('%.2f ms',iMicrons/1000);
    else
        strString = sprintf('%.2f sec',iMicrons/1000000);
    end
end

return

function fnInvalidate(handles)
strctParams = getappdata(handles.figure1,'strctParams');
NUM_CHANNELS = 2;
a2cData = cell(10,NUM_CHANNELS);
if ~isempty(strctParams.m_astrctChannels)
    for iChannel=1:NUM_CHANNELS
        a2cData{1,iChannel} = sprintf('%.2f Hz',strctParams.m_astrctChannels(iChannel).m_fPulseFrequencyHz);
        a2cData{2,iChannel} = fnMicronsToString(strctParams.m_astrctChannels(iChannel).m_iPulse_Width_Microns);
        a2cData{3,iChannel} = fnMicronsToString(strctParams.m_astrctChannels(iChannel).m_iTrain_Length_Microns);
        a2cData{4,iChannel} = sprintf('%.2f Hz',strctParams.m_astrctChannels(iChannel).m_fTrain_Freq_Hz);
        a2cData{5,iChannel} = sprintf('%d',strctParams.m_astrctChannels(iChannel).m_iNumTrains_Per_Trigger);
        a2cData{6,iChannel} = sprintf('%d',strctParams.m_astrctChannels(iChannel).m_bSecondPulse);
        a2cData{7,iChannel} = fnMicronsToString(strctParams.m_astrctChannels(iChannel).m_iSecond_Pulse_Delay_Microns);
        a2cData{8,iChannel} = fnMicronsToString(strctParams.m_astrctChannels(iChannel).m_iSecond_Pulse_Width_Microns);
        a2cData{9,iChannel} = fnMicronsToString(strctParams.m_astrctChannels(iChannel).m_iTriggerDelay_Microns);
        a2cData{10,iChannel} = sprintf('%.2f',strctParams.m_astrctChannels(iChannel).m_fAmplitude);
        a2cData{11,iChannel} = sprintf('%d',strctParams.m_astrctChannels(iChannel).m_bActive);
    end
end
acRowNames = {'Pulse Frequency','Pulse Width','Train Length','Train Frequency','Num Trains per pulse','Second Pulse','2nd Pulse Delay','2nd Pulse Width','Trigger Delay','Amplitude','Active'};
set(handles.hTable,'RowName',acRowNames,'Data',a2cData,'ColumnEditable',[true true],'CellEditCallback',{@fnCellEditCallback, handles});
set(handles.hPresetList,'String',strctParams.m_acPresetNames);

set(handles.hIPaddr,'String',strctParams.m_strIP);
set(handles.hPortaddr,'String',strctParams.m_strPort);
% Plot trains.

cla(handles.hAxes);
hold on;
for iChannel=1:2
if strctParams.m_astrctChannels(iChannel).m_iTrain_Length_Microns  < 0
    continue;
end
    if strctParams.m_astrctChannels(iChannel).m_iTrain_Length_Microns <= 1000
    afTimeUsec =  0:strctParams.m_astrctChannels(iChannel).m_iTrain_Length_Microns;
elseif strctParams.m_astrctChannels(iChannel).m_iTrain_Length_Microns <= 1000000
    afTimeUsec = 0:10:strctParams.m_astrctChannels(iChannel).m_iTrain_Length_Microns;
else
    afTimeUsec = 0:1000:strctParams.m_astrctChannels(iChannel).m_iTrain_Length_Microns;
end
abOutput = fnSimulate_Train(strctParams.m_astrctChannels(iChannel),afTimeUsec);
if iChannel == 1
    plot(afTimeUsec, double(abOutput)*5,'parent',handles.hAxes,'LineWidth',2,'Color','y');
else
    plot(afTimeUsec, 6+double(abOutput)*5,'parent',handles.hAxes,'LineWidth',2,'Color','c');
end
set(handles.hAxes,'Color',[ 0 0 0]);
set(handles.hAxes,'ylim',[-1 12],'xlim',[afTimeUsec(1)-10,afTimeUsec(end)+10])
end

return


function iMicrons = fnParseStringToMicrons(str)
Res=sscanf(str,'%f %*s');
Multiplier=1;
if ~isempty(strfind(lower(str),'usec'))
    Multiplier=1;
elseif ~isempty(strfind(lower(str),'ms'))
    Multiplier=1000;
elseif ~isempty(strfind(lower(str),'sec'))
    Multiplier=1000000;
end
iMicrons = round(Res*Multiplier);
return;


function Hz = fnParseStringToHz(str)
Hz=sscanf(str,'%f %*s');
return;


function fnCellEditCallback(o, strctEvent,handles)
strctParams = getappdata(handles.figure1,'strctParams');

UDP_MODIFY_PULSE_FREQ = 1;
UDP_MODIFY_PULSE_WIDTH = 2;
UDP_MODIFY_SECOND_PULSE = 3;
UDP_MODIFY_TRAIN_LENGTH = 4;
UDP_MODIFY_TRAIN_FREQ = 5;
UDP_MODIFY_NUM_TRAINS = 6;
UDP_MODIFY_TRIG_DELAY = 7;
UDP_MODIFY_SECOND_PULSE_WIDTH = 8;
UDP_MODIFY_SECOND_PULSE_DELAY = 9;
UDP_MODIFY_AMPLITUDE = 10;
UDP_TOGGLE_CHANNEL_ACTIVE = 14;

% UDP_SOFT_TRIGGER = 11;
% UDP_SAVE_PRESET = 12;
% UDP_LOAD_PRESET = 13;

fnClearMessageQueue(strctParams.m_hSocket);

iChannel = strctEvent.Indices(1,2);
iField= strctEvent.Indices(1,1);
switch iField
    case 1
        strctParams.m_astrctChannels(iChannel).m_fPulseFrequencyHz=fnParseStringToHz(strctEvent.NewData);
        mssendraw(strctParams.m_hSocket,uint8([sprintf('%02d %d %.2f',UDP_MODIFY_PULSE_FREQ,iChannel-1,strctParams.m_astrctChannels(iChannel).m_fPulseFrequencyHz),0]));
    case 2
        strctParams.m_astrctChannels(iChannel).m_iPulse_Width_Microns=fnParseStringToMicrons(strctEvent.NewData);
        mssendraw(strctParams.m_hSocket,uint8([sprintf('%02d %d %d',UDP_MODIFY_PULSE_WIDTH,iChannel-1,strctParams.m_astrctChannels(iChannel).m_iPulse_Width_Microns),0]));
    case 3
        strctParams.m_astrctChannels(iChannel).m_iTrain_Length_Microns=fnParseStringToMicrons(strctEvent.NewData);
        mssendraw(strctParams.m_hSocket,uint8([sprintf('%02d %d %d',UDP_MODIFY_TRAIN_LENGTH,iChannel-1,strctParams.m_astrctChannels(iChannel).m_iTrain_Length_Microns),0]));
    case 4
        strctParams.m_astrctChannels(iChannel).m_fTrain_Freq_Hz=fnParseStringToHz(strctEvent.NewData);
        mssendraw(strctParams.m_hSocket,uint8([sprintf('%02d %d %.2f',UDP_MODIFY_TRAIN_FREQ,iChannel-1,strctParams.m_astrctChannels(iChannel).m_fTrain_Freq_Hz),0]));
    case 5
        strctParams.m_astrctChannels(iChannel).m_iNumTrains_Per_Trigger=fnParseStringToMicrons(strctEvent.NewData);
        mssendraw(strctParams.m_hSocket,uint8([sprintf('%02d %d %d',UDP_MODIFY_NUM_TRAINS,iChannel-1,strctParams.m_astrctChannels(iChannel).m_iNumTrains_Per_Trigger),0]));
    case 6
        strctParams.m_astrctChannels(iChannel).m_bSecondPulse=fnParseStringToMicrons(strctEvent.NewData);
        mssendraw(strctParams.m_hSocket,uint8([sprintf('%02d %d %d',UDP_MODIFY_SECOND_PULSE,iChannel-1,strctParams.m_astrctChannels(iChannel).m_bSecondPulse),0]));
    case 7
        strctParams.m_astrctChannels(iChannel).m_iSecond_Pulse_Delay_Microns=fnParseStringToMicrons(strctEvent.NewData);
        mssendraw(strctParams.m_hSocket,uint8([sprintf('%02d %d %d',UDP_MODIFY_SECOND_PULSE_DELAY,iChannel-1,strctParams.m_astrctChannels(iChannel).m_iSecond_Pulse_Delay_Microns),0]));
    case 8
        strctParams.m_astrctChannels(iChannel).m_iSecond_Pulse_Width_Microns=fnParseStringToMicrons(strctEvent.NewData);
        mssendraw(strctParams.m_hSocket,uint8([sprintf('%02d %d %d',UDP_MODIFY_SECOND_PULSE_WIDTH,iChannel-1,strctParams.m_astrctChannels(iChannel).m_iSecond_Pulse_Width_Microns),0]));
    case 9
        strctParams.m_astrctChannels(iChannel).m_iTriggerDelay_Microns=fnParseStringToMicrons(strctEvent.NewData);
        mssendraw(strctParams.m_hSocket,uint8([sprintf('%02d %d %d',UDP_MODIFY_TRIG_DELAY,iChannel-1,strctParams.m_astrctChannels(iChannel).m_iTriggerDelay_Microns),0]));
    case 10
        strctParams.m_astrctChannels(iChannel).m_fAmplitude=fnParseStringToHz(strctEvent.NewData);
        mssendraw(strctParams.m_hSocket,uint8([sprintf('%02d %d %.2f',UDP_MODIFY_AMPLITUDE,iChannel-1,strctParams.m_astrctChannels(iChannel).m_fAmplitude),0]));
    case 11
        strctParams.m_astrctChannels(iChannel).m_bActive=fnParseStringToMicrons(strctEvent.NewData);
        mssendraw(strctParams.m_hSocket,uint8([sprintf('%02d %d %f',UDP_TOGGLE_CHANNEL_ACTIVE,iChannel-1,strctParams.m_astrctChannels(iChannel).m_bActive),0]));
end
S=fnRecvString(strctParams.m_hSocket, 0.5);
bSuccessful = strncmpi(S,'OK!',3);
if bSuccessful
    setappdata(handles.figure1,'strctParams',strctParams );
end
fnInvalidate(handles);
return;


function fnClearMessageQueue(hSocket)
while (1)
    T=msrecvraw(hSocket,100,0.1);
    if isempty(T)
        break;
    end;
end
return;


function bConnected = fnStimulatorOnline(hSocket)
fnClearMessageQueue(hSocket);
UDP_PING = 18;
mssendraw(hSocket,uint8([sprintf('%02d',UDP_PING),0]));
S=fnRecvString(hSocket, 0.5);
bConnected = strncmpi(S,'OK!',3);
return;


function S=fnRecvString(hSocket, iTimeOut)
tic
iCounter = 1;
S=char();
while toc < iTimeOut
    T=msrecvraw(hSocket,1,0);
    if ~isempty(T)
       if T == 10
           S=S(1:end-1); % get rid of #13
           break;
       end
       S(iCounter) = char(T); 
       iCounter=iCounter+1;
    end
end
return;

function [astrctChannel,acPresetNames] = fnReadParametersFromStimulator(hSocket)
fnClearMessageQueue(hSocket);

NUM_CHANNELS = 2;
NUM_PRESETS = 6;
UDP_GET_CURRENT_SETTINGS = 15;
UDP_GET_PRESET_NAMES = 16;

mssendraw(hSocket,uint8([sprintf('%02d',UDP_GET_CURRENT_SETTINGS),0]));
for iChannel=1:NUM_CHANNELS
    S=fnRecvString(hSocket, 1);astrctChannel(iChannel).m_fPulseFrequencyHz = str2num(S);
    
    S=fnRecvString(hSocket, 1);astrctChannel(iChannel).m_iPulse_Width_Microns = str2num(S);
    S=fnRecvString(hSocket, 1);astrctChannel(iChannel).m_iTrain_Length_Microns = str2num(S);
    S=fnRecvString(hSocket, 1);astrctChannel(iChannel).m_fTrain_Freq_Hz = str2num(S);
    S=fnRecvString(hSocket, 1);astrctChannel(iChannel).m_iNumTrains_Per_Trigger = str2num(S);
    S=fnRecvString(hSocket, 1);astrctChannel(iChannel).m_bSecondPulse = str2num(S);
    S=fnRecvString(hSocket, 1);astrctChannel(iChannel).m_iSecond_Pulse_Delay_Microns = str2num(S);
    S=fnRecvString(hSocket, 1);astrctChannel(iChannel).m_iSecond_Pulse_Width_Microns = str2num(S);
    S=fnRecvString(hSocket, 1);astrctChannel(iChannel).m_iTriggerDelay_Microns = str2num(S);
    S=fnRecvString(hSocket, 1);astrctChannel(iChannel).m_fAmplitude = str2num(S);
    S=fnRecvString(hSocket, 1);astrctChannel(iChannel).m_bActive = str2num(S);
end
S=fnRecvString(hSocket, 1);
fnClearMessageQueue(hSocket);
mssendraw(hSocket,uint8([sprintf('%02d',UDP_GET_PRESET_NAMES),0]));
acPresetNames = cell(1,NUM_PRESETS);
for k=1:NUM_PRESETS
    acPresetNames{k} = fnRecvString(hSocket, 1);
end
return;


% --- Outputs from this function are returned to the command line.
function varargout = NanoStimulatorGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in hTrigCh1.
function hTrigCh1_Callback(hObject, eventdata, handles)
strctParams = getappdata(handles.figure1,'strctParams');
UDP_SOFT_TRIGGER = 11;
fnClearMessageQueue(strctParams.m_hSocket);
mssendraw(strctParams.m_hSocket,uint8([sprintf('%02d %d',UDP_SOFT_TRIGGER,0),0]));
S=fnRecvString(strctParams.m_hSocket, 1);
if isempty(S)
    fnLostConnection(handles);
else
    set(handles.hStatus,'String','Online','Foregroundcolor','g','backgroundcolor','k');
    
end
return;



% --- Executes on button press in hTrigCh2.
function hTrigCh2_Callback(hObject, eventdata, handles)
strctParams = getappdata(handles.figure1,'strctParams');
UDP_SOFT_TRIGGER = 11;
fnClearMessageQueue(strctParams.m_hSocket);
mssendraw(strctParams.m_hSocket,uint8([sprintf('%02d %d',UDP_SOFT_TRIGGER,1),0]));
S=fnRecvString(strctParams.m_hSocket, 1);
if isempty(S)
    fnLostConnection(handles);
else
    set(handles.hStatus,'String','Online','Foregroundcolor','g','backgroundcolor','k');
end

return;

% --- Executes on button press in hTriggerAll.
function hTriggerAll_Callback(hObject, eventdata, handles)
strctParams = getappdata(handles.figure1,'strctParams');
UDP_SOFT_TRIGGER = 11;
fnClearMessageQueue(strctParams.m_hSocket);
mssendraw(strctParams.m_hSocket,uint8([sprintf('%02d %d',UDP_SOFT_TRIGGER,0),0]));
mssendraw(strctParams.m_hSocket,uint8([sprintf('%02d %d',UDP_SOFT_TRIGGER,1),0]));
S=fnRecvString(strctParams.m_hSocket, 1);
if isempty(S)
    fnLostConnection(handles);
else
    set(handles.hStatus,'String','Online','Foregroundcolor','g','backgroundcolor','k');
    
end
return;

% --- Executes on selection change in hPresetList.
function hPresetList_Callback(hObject, eventdata, handles)
% hObject    handle to hPresetList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns hPresetList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hPresetList


% --- Executes during object creation, after setting all properties.
function hPresetList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hPresetList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in hLoadPreset.
function hLoadPreset_Callback(hObject, eventdata, handles)
% hObject    handle to hLoadPreset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




function hIPaddr_Callback(hObject, eventdata, handles)
% hObject    handle to hIPaddr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hIPaddr as text
%        str2double(get(hObject,'String')) returns contents of hIPaddr as a double


% --- Executes during object creation, after setting all properties.
function hIPaddr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hIPaddr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hPortaddr_Callback(hObject, eventdata, handles)
% hObject    handle to hPortaddr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hPortaddr as text
%        str2double(get(hObject,'String')) returns contents of hPortaddr as a double


% --- Executes during object creation, after setting all properties.
function hPortaddr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hPortaddr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in hConnect.
function hConnect_Callback(hObject, eventdata, handles)
strctParams.m_strIP = get(handles.hIPaddr,'string');
strctParams.m_strPort = get(handles.hPortaddr,'string');
strctParams.m_hSocket = msconnect(strctParams.m_strIP,str2num(strctParams.m_strPort)); % try to connect.
bConnected = fnStimulatorOnline(strctParams.m_hSocket);
if bConnected
    set(handles.hStatus,'String','Online','Foregroundcolor','g','backgroundcolor','k');
    [strctParams.m_astrctChannels,strctParams.m_acPresetNames]=fnReadParametersFromStimulator(strctParams.m_hSocket);
    
else
    strctParams.m_astrctChannels = [];
    strctParams.m_acPresetNames = [];
    set(handles.hStatus,'String','Offline','Foregroundcolor','r','backgroundcolor','k');
end

setappdata(handles.figure1,'strctParams',strctParams);

fnInvalidate(handles);
return;

function fnLostConnection(handles)
set(handles.hStatus,'String','Offline','Foregroundcolor','r','backgroundcolor','k');
% strctParams.m_astrctChannels = [];
% strctParams.m_acPresetNames = [];
% strctParams.m_hSocket = 0;
% set(handles.hStatus,'String','Offline','Foregroundcolor','r','backgroundcolor','k');
% setappdata(handles.figure1,'strctParams',strctParams);
% fnInvalidate(handles);

return





function abOutput = fnSimulate_Train(strctChannel,afTimeUsec)
abOutput = zeros(size(afTimeUsec))>0;
State = 0;
bLevelHigh = false;
for i=1:length(afTimeUsec)
    micros = afTimeUsec(i);
    t = micros;
    if (State == 0 && t > 0)
        State = 1;
    end
    
    if (State == 1)
        NumTrains = strctChannel.m_iNumTrains_Per_Trigger;
        Train_Start_TS = t;
        if (strctChannel.m_iTriggerDelay_Microns == 0)
            State = 4;
        else
            State = 2;
        end
    end
    
    if (State == 2)
        if (t-Train_Start_TS > strctChannel.m_iTriggerDelay_Microns)
            Train_Start_TS = micros;
            State = 4;
            
        end
    end
       
    if (State == 4)
        if (( (t-Train_Start_TS) < strctChannel.m_iTrain_Length_Microns))
            bLevelHigh = true;
            Pulse_Start_TS = micros;
            State = 5;
        else
            State = 8;
        end
    end
    
    
    if (State == 5)
        if (t-Pulse_Start_TS > strctChannel.m_iPulse_Width_Microns)
            bLevelHigh = false;
            State = 6;
        end
    end
    
    if (State == 6)
        if (strctChannel.m_bSecondPulse)
            SecondPulse_TS=micros;
            State = 9;
        else
            State = 7;
        end
    end
    
    if (State == 7)
        if (t-Pulse_Start_TS > 1.0/strctChannel.m_fPulseFrequencyHz*1000000)
            State = 4;
        end
    end
    
    if (State == 8)
        if (t-Train_Start_TS > 1.0/strctChannel.m_fTrain_Freq_Hz*1000000)
            if (NumTrains == -1)
                State = 4;
                Train_Start_TS = micros;
            else if (NumTrains == 1)
                    State = 0;
                else
                    State = 4;
                    Train_Start_TS = micros;
                    NumTrains=NumTrains-1;
                end
            end
        end
    end
    
    
    if (State == 9)
        if (t-SecondPulse_TS > strctChannel.m_iSecond_Pulse_Delay_Microns)
            bLevelHigh = true;
            SecondPulse_TS = micros;
            State = 10;
        end
    end
    
    if (State == 10)
        if (t-SecondPulse_TS > strctChannel.m_iSecond_Pulse_Width_Microns)
            bLevelHigh = false;
            State = 7;
        end
    end
    abOutput(i) = bLevelHigh;
end

return


function hSavePreset_Callback(hObject, eventdata, handles)
acPresetNames = get(handles.hPresetList,'string');
iPresetIndex = get(handles.hPresetList,'value');

prompt={'Preset Name'};
name='Preset Name';
numlines=1;
defaultanswer=acPresetNames(iPresetIndex);
answer=inputdlg(prompt,name,numlines,defaultanswer);
if isempty(answer)
    return;
end;
answer{1}(answer{1} == ' ') = '_';
acPresetNames{iPresetIndex} = answer{1};
set(handles.hPresetList,'String',acPresetNames);
strctParams = getappdata(handles.figure1,'strctParams');

TCP_MODIFY_PRESET_NAME= 17;
mssendraw(strctParams.m_hSocket,uint8([sprintf('%02d %d %s',TCP_MODIFY_PRESET_NAME,iPresetIndex-1,acPresetNames{iPresetIndex}),0]));
S=fnRecvString(strctParams.m_hSocket, 1);

TCP_SAVE_PRESET = 12;
mssendraw(strctParams.m_hSocket,uint8([sprintf('%02d %d',TCP_SAVE_PRESET,iPresetIndex-1),0]));
S=fnRecvString(strctParams.m_hSocket, 1);
