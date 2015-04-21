function varargout = RemoteClient(varargin)
% REMOTECLIENT M-file for RemoteClient.fig
%      REMOTECLIENT, by itself, creates a new REMOTECLIENT or raises the existing
%      singleton*.
%
%      H = REMOTECLIENT returns the handle to a new REMOTECLIENT or the handle to
%      the existing singleton*.
%
%      REMOTECLIENT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in REMOTECLIENT.M with the given input arguments.
%
%      REMOTECLIENT('Property','Value',...) creates a new REMOTECLIENT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RemoteClient_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RemoteClient_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RemoteClient

% Last Modified by GUIDE v2.5 14-Oct-2010 14:08:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RemoteClient_OpeningFcn, ...
                   'gui_OutputFcn',  @RemoteClient_OutputFcn, ...
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


% --- Executes just before RemoteClient is made visible.
function RemoteClient_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to RemoteClient (see VARARGIN)

% Choose default command line output for RemoteClient
handles.output = hObject;


X = zeros(120,160,3);
hImage = image(X,'parent',handles.axes1);
setappdata(handles.figure1,'hImage',hImage);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes RemoteClient wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = RemoteClient_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in hParadigmsListBox.
function hParadigmsListBox_Callback(hObject, eventdata, handles)
% hObject    handle to hParadigmsListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns hParadigmsListBox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hParadigmsListBox


% --- Executes during object creation, after setting all properties.
function hParadigmsListBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hParadigmsListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in hJuice.
function hJuice_Callback(hObject, eventdata, handles)
% hObject    handle to hJuice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
iSocket = getappdata(handles.figure1,'iSocket');
if ~isempty(iSocket)
 mssend(iSocket, {'JuicePulse'});
end
    
% --- Executes on button press in hStart.
function hStart_Callback(hObject, eventdata, handles)
% hObject    handle to hStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in hPause.
function hPause_Callback(hObject, eventdata, handles)
% hObject    handle to hPause (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in hRealTiemVideo.
function hRealTiemVideo_Callback(hObject, eventdata, handles)
% hObject    handle to hRealTiemVideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hRealTiemVideo


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in hConnect.
function hConnect_Callback(hObject, eventdata, handles)
iConnectionTimeOutSec = 5;
iDataTimeOut = 1;

iSocket = getappdata(handles.figure1,'iSocket');
if ~isempty(iSocket)
    % Disconnect
    msclose(iSocket);
    setappdata(handles.figure1,'iSocket',[]);
    set(handles.hConnect,'String','Connect');
    hVideoTimer = getappdata(handles.figure1,'hVideoTimer');
    hStatisticsTimer = getappdata(handles.figure1,'hStatisticsTimer');
    if ~isempty(hStatisticsTimer)
        stop(hStatisticsTimer);
        setappdata(handles.figure1,'hStatisticsTimer',[]);
    end
    set(handles.hParadigmsListBox,'String','','value',1);
        
    if ~isempty(hVideoTimer)
        stop(hVideoTimer);
        setappdata(handles.figure1,'hVideoTimer',[]);
    end
else
    strAddress = get(handles.hRemoteAddressEdit,'String');
    iPort = str2num(get(handles.hRemotePortEdit,'String'));
    
    iSocket = msconnect(strAddress, iPort, iConnectionTimeOutSec); 
    if iSocket > 0
        
        % Query about which paradigms are available
         mssend(iSocket, {'paradigmsavail'});
        [acParadigms,iCommError]  = msrecv(iSocket, iDataTimeOut);
        setappdata(handles.figure1,'acParadigms',acParadigms);
        set(handles.hParadigmsListBox,'String',char(acParadigms));
        
        setappdata(handles.figure1,'iSocket',iSocket);
        set(handles.hConnect,'String','Disconnect');
        
        hVideoTimer = timer('TimerFcn',{@fnInvalidateVideo,handles}, 'Period', 0.3,'ExecutionMode','fixedDelay');
        hStatisticsTimer = timer('TimerFcn',{@fnInvalidateStat,handles}, 'Period', 10,'ExecutionMode','fixedDelay');
        start(hVideoTimer);
        start(hStatisticsTimer);
        setappdata(handles.figure1,'hVideoTimer',hVideoTimer);
        setappdata(handles.figure1,'hStatisticsTimer',hStatisticsTimer);
    end
end

function fnClearBuffer(handles)
iSocket = getappdata(handles.figure1,'iSocket');
if ~isempty(iSocket)
   % Clear buffer
    while (1)
        [Dummy,iCommError]  = msrecv(iSocket, 0);
        if iCommError < 0
            break;
        end
    end
end
return;


function fnInvalidateStat(a,b,handles)
iDataTimeOut = 1;
iSocket = getappdata(handles.figure1,'iSocket');
if ~isempty(iSocket)
    fnClearBuffer(handles);
         mssend(iSocket, {'currentstate'});
        [strCurrentState,iCommError]  = msrecv(iSocket, iDataTimeOut);
      set(handles.hCurrentParadigmStateText,'String',strCurrentState);
end
return;


function fnInvalidateVideo(a,b,handles)
iDataTimeOut = 1;

iSocket = getappdata(handles.figure1,'iSocket');
if ~isempty(iSocket)
    
    hImage = getappdata(handles.figure1,'hImage');
     mssend(iSocket, {'getvideoframenow'});
     [a3iImage,iCommError]  = msrecv(iSocket, iDataTimeOut);
     set(hImage,'CData',a3iImage);
    
end
return;



function hRemoteAddressEdit_Callback(hObject, eventdata, handles)
iSocket = getappdata(handles.figure1,'iSocket');
iDataTimeOut = 2;
if ~isempty(iSocket)
%   mssend(iSocket, {'GetParadigm'});
% [strctParadigm,iCommError]  = msrecv(iSocket, iDataTimeOut);
  
    mssend(iSocket, {'gettrials'});
    [acTrials,iCommError]  = msrecv(iSocket, iDataTimeOut);
end
%         
%         acTrials
%         
% %%
% acTrials{1} = acTrials{1}(2:end);
% acTrials{2} = acTrials{2}(2:end);
% afTrialsTimestamps = acTrials{1};
% 
% fBinSizeSeconds = 1 * 60;
% iNumBins = 100;
% 
% fTimeElapsed = afTrialsTimestamps(end)-afTrialsTimestamps(2);
% fTimeElapsedRound = ceil(fTimeElapsed / fBinSizeSeconds)*fBinSizeSeconds;
% 
% %fLastTimeStamp = afTrialsTimestamps(end);
% 
% fStartTS = afTrialsTimestamps(2) +fTimeElapsedRound -iNumBins*fBinSizeSeconds;
% 
% a2iStat = zeros(3,iNumBins); % Correct;Incorrect;Timeout
% for iBinIter=1:iNumBins
%     fStartBinTime = fStartTS + (iBinIter-1)*fBinSizeSeconds;
%     fEndBinTime = fStartTS + (iBinIter)*fBinSizeSeconds;
%     aiTrialInd = find(afTrialsTimestamps >= fStartBinTime & afTrialsTimestamps <= fEndBinTime);
%     if ~isempty(aiTrialInd)
%         for k=1:length(aiTrialInd)
%             switch lower(acTrials{2}{k}.m_strResult)
%                 case 'correct'
%                     a2iStat(1,iBinIter) = a2iStat(1,iBinIter) + 1;
%                 case 'incorrect'
%                     a2iStat(2,iBinIter) = a2iStat(2,iBinIter) + 1;
%                 case 'timeout'
%                     a2iStat(3,iBinIter) = a2iStat(3,iBinIter) + 1;
%             end
%         end
%     end
% end
% figure;
% plot(a2iStat')

% a2fNormalizedStat = a2iStat ./ repmat(sum(a2iStat,1),3,1);
% abNonEmptyBins = ~isnan(a2fNormalizedStat(1,:));

% --- Executes during object creation, after setting all properties.
function hRemoteAddressEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hRemoteAddressEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hRemotePortEdit_Callback(hObject, eventdata, handles)
% hObject    handle to hRemotePortEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hRemotePortEdit as text
%        str2double(get(hObject,'String')) returns contents of hRemotePortEdit as a double


% --- Executes during object creation, after setting all properties.
function hRemotePortEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hRemotePortEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in hDrawAttention.
function hDrawAttention_Callback(hObject, eventdata, handles)
% hObject    handle to hDrawAttention (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in listbox3.
function listbox3_Callback(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox3


% --- Executes during object creation, after setting all properties.
function listbox3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
