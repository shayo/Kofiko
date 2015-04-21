function Kofiko(strXMLConfigFileName, strctRegisterConfig)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)
% Kofiko entry point
clear global
global g_hLogFileID g_bVERBOSE g_bAppIsRunning g_bSIMULATE
global g_bLastLoggedList g_strctStimulusServer g_bRecording 
global g_astrctAllParadigms g_iCurrParadigm g_abParadigmInitialized
global g_strctAppConfig g_strctSystemCodes g_iNextParadigm g_strLogFileName g_strctPTB g_strctAcquisitionServer

g_bSIMULATE = false; % Turn ON if running this on a machine without MCC

% Default XML file and subject name
if ~exist('strXMLConfigFileName','var')
    strXMLConfigFileName = '.\Config\KofikoConfigForDifferentRigs\Default.xml';
end;

% Read from the XML file various config information (DAQ, GUI, paradigms, ...)
[g_strctAppConfig,g_astrctAllParadigms, g_strctSystemCodes] = ...
    fnLoadKofikoConfigXML(strXMLConfigFileName);

g_strctAppConfig.m_strctVersion = fnGetKofikoVersion();

warning off
fnAddPTBFolders(g_strctAppConfig.m_strctDirectories.m_strPTB_Folder);
warning on
try
    GetSecs();
catch
    fprintf('Fatal Error. Could not call GetSecs. PTB Folder is probably misconfigured.\n');
    return;
end

strTestPTB = which('Priority');
if isempty(strTestPTB)
    fprintf('Sorry, PTB is not in the path. Did you ran the 64 bit version? PTB is only compatible with 32 bit matlab.\n');
    fprintf('Check <PTB_Folder> in the XML configuration file\n');
    return;
end;

Priority(2); % "Real-Time"
%IOPort('CloseAll'); % Make sure all ports have been closed...

g_bVERBOSE = false;
g_hLogFileID = [];
g_bLastLoggedList = '';
dbstop if error

if exist('strctRegisterConfig','var')
   g_strctAppConfig.m_strctSubject = strctRegisterConfig.m_strctMonkeyInfo;
   if ~(fnStartLogFileWithKnownFileName(strctRegisterConfig.m_strLogFileName, g_strctAppConfig.m_strctSubject.m_strName))
        fprintf('Failed to open log file');
        return;
    end;
else
    g_strctAppConfig.m_strctSubject.m_strName = 'Unknown';
    if ~(fnStartLogFile(g_strctAppConfig.m_strctDirectories.m_strLogFolder,g_strctAppConfig.m_strctSubject.m_strName))
        fprintf('Failed to open log file');
        return;
    end;
end
g_strctAppConfig.m_strLogFileName = g_strLogFileName;

fnLog('Starting Kofiko...');
if ~fnSetupDAQ()
    fnShutDown();
    return;
end

% Arduino-Intan?

g_strctAcquisitionServer.m_bConnected = false;
if isfield(g_strctAppConfig,'m_strctAcquisitionServer')
    fnConnectToAcquisitionServer()
end

% Setup sound
InitializePsychSound(1);
astrctAudioDevices = PsychPortAudio('GetDevices');
iDeviceIndex = find(ismember({astrctAudioDevices.DeviceName},g_strctAppConfig.m_strctSounds.m_strAudioDeviceName));
if isempty(iDeviceIndex)
    fprintf('Failed to find audio device %s. \n',g_strctAppConfig.m_strctSounds.m_strAudioDeviceName);
    fprintf('Your available devices are:\n');
    for k=1:length(astrctAudioDevices)
        fprintf('* %s\n',astrctAudioDevices(k).DeviceName)
    end
    fprintf('\n\nPlease edit StimulusServer.xml config file with your device!. \nNow Aborting!\n');
    return;
end;
iAgressiveMode = 0; % Should be 4, once we get the soundblaster card...
try
    g_strctPTB.m_hAudioDevice = PsychPortAudio('Open',astrctAudioDevices(iDeviceIndex).DeviceIndex,1,iAgressiveMode, 44100,2);
    
catch
    g_strctPTB.m_hAudioDevice = [];
    
end



%


fnConnectToRealTimeStatServer();

if g_strctAppConfig.m_strctStimulusServer.m_fSingleComputerMode
    fRefreshRate = 75;
    g_strctStimulusServer.m_iSocket = [];
    g_strctStimulusServer.m_strIP = [];%g_strctAppConfig.m_strctStimulusServer.m_strAddress;
    g_strctStimulusServer.m_iPort = [];%g_strctAppConfig.m_strctStimulusServer.m_fPort;
    [fWidth, fHeight] = Screen('WindowSize',g_strctAppConfig.m_strctStimulusServer.m_fPTBScreen);
    g_strctStimulusServer.m_aiScreenSize = [0 0 fWidth, fHeight] + ...
        g_strctAppConfig.m_strctStimulusServer.m_afVisibleOffset;
    g_strctStimulusServer.m_fRefreshRateHz = fRefreshRate;
    g_strctStimulusServer.m_fRefreshRateMS = 1/fRefreshRate*1000;
    g_strctStimulusServer.m_bConnected = true;
    
else
    
    % Establih a connection to the stimulus machine
    fnSetupConnectionToStimulusServer(...
        g_strctAppConfig.m_strctStimulusServer.m_strAddress,...
        g_strctAppConfig.m_strctStimulusServer.m_fPort);
    
    if isempty(g_strctStimulusServer)
         fnShutDown();
        fnLog('CRITICAL ERROR: Could not connect to stimulus server...');
        fprintf('CRITICAL ERROR: Could not connect to stimulus server...\n');
       
        return;
    end;
end

fnSetupRemoteAccess();

% Initialize stuff
fnSetupDefaultParameters();

fnSetupPTB();

fnSetMatlabFigure();

fnLoadSounds();

if isfield(g_strctAppConfig,'m_strctVideoStreaming') && ~isempty(g_strctAppConfig.m_strctVideoStreaming) && ...
        isfield(g_strctAppConfig.m_strctVideoStreaming,'m_strDeviceName') && ~isempty(g_strctAppConfig.m_strctVideoStreaming.m_strDeviceName)
    fnStartVideo(g_strctAppConfig.m_strctVideoStreaming);
end

%fnRegisterAdvancers();

g_bAppIsRunning = true;
g_bRecording = false;
g_iCurrParadigm = 1; % probably the "deafult" paradigm
g_abParadigmInitialized = zeros(1,length(g_astrctAllParadigms));
% drawnow 
% figure(g_handles.figure1);
% drawnow 

while (g_bAppIsRunning)
    fnRunParadigm();
    g_iCurrParadigm = g_iNextParadigm;
end;
if ~g_strctAppConfig.m_strctStimulusServer.m_fSingleComputerMode
    fnParadigmToStimulusServer('CloseConnection');
end

if g_strctAppConfig.m_strctRemoteAccess.m_bClientConnected
    msclose(g_strctAppConfig.m_strctRemoteAccess.m_iCommSocket);
end

msclose(g_strctAppConfig.m_strctRemoteAccess.m_hSocket)

fnStopVideo();

fnLog('Exitting Kofiko');
fnShutDown();
Priority(0);

return;

function fnLoadSounds()
global g_strctAppConfig g_strctSoundMedia

if isfield(g_strctAppConfig,'m_strctSounds')
    fprintf('Attempting to load sounds...\n');
    acFieldNames = fieldnames(g_strctAppConfig.m_strctSounds);
    iNumFiles = length(acFieldNames);
    abExist = zeros(1,iNumFiles)>0;
    acSoundFileNames = cell(1,iNumFiles );
    acSoundNames = cell(1,iNumFiles );
    for iFileIter=1:iNumFiles
        acSoundFileNames{iFileIter} = getfield(g_strctAppConfig.m_strctSounds, acFieldNames{iFileIter});
        acSoundNames{iFileIter} = acFieldNames{iFileIter}(6:end);
        if exist(acSoundFileNames{iFileIter},'file')
            abExist(iFileIter)= true;
        else
            fprintf('*** Warning, sound file %s is missing\n',acSoundFileNames{iFileIter});
        end
    end
    acSoundFileNames = acSoundFileNames(abExist);
    acSoundNames = acSoundNames(abExist);
  
    if fnParadigmToKofikoComm('IsTouchMode')
        % Load sounds locally
        g_strctSoundMedia.m_acSounds = fnLoadSoundsAux(acSoundFileNames,acSoundNames);
    else
        % Instruct stimulus server to load sounds!
        fnParadigmToStimulusServer('LoadSounds', acSoundFileNames,acSoundNames);
    end

  fprintf('Load sounds Done.\n');
      
else
    g_strctSoundMedia.m_acSounds = [];
end



% <Sounds
%     TrialOnsetSoundFile = "beep-6.wav"
%     TrialTimeoutSoundFile = "beep-10.wav"
%     CorrectTrialSoundFile = "beep-8.wav"
%     IncorrectTrialSoundFile = "beep-7.wav"
% > </Sounds>




function fnRegisterAdvancers()
global g_strctDAQParams 
iNumAdvancers = length(g_strctDAQParams.m_a2iAdvancerMappingToChamberHole);
%if iNumAdvancers > 0
    fndllMiceHook('Init');
%    fndllMiceHook('Hook',g_strctDAQParams.m_a2iAdvancerMappingToChamberHole(:,1));
%end

return;

%%
function fnSaveDataToDisk(hObject, b)
fnSaveParadigmsToDisk(false);
return;

function fnPauseParadigmCallback(hObject, b)
global g_strctGUIParams g_strctCycle
if ~g_strctCycle.m_bParadigmPaused
    g_strctGUIParams.m_bUserPaused = true;
    fnPauseParadigm();
else
    g_strctGUIParams.m_bUserPaused = false;    
    fnResumeParadigm();
end;
return;


function fnSetupRemoteAccess()
global g_strctAppConfig
g_strctAppConfig.m_strctRemoteAccess.m_hSocket = mslisten(g_strctAppConfig.m_strctRemoteAccess.m_fPort);
g_strctAppConfig.m_strctRemoteAccess.m_bClientConnected = false;
return;


function fnStartParadigmCallback(hObject, b)
fnStartParadigm();
return;

function fnOpenNeuralListenPort(fLocalListenUDP_Port)
global g_strctSpikeServer g_bVERBOSE
g_strctSpikeServer.m_iListenSocket = udp_mslisten(fLocalListenUDP_Port);
return;


  
function fnConnectToAcquisitionServer()
global g_strctAcquisitionServer  g_strctAppConfig
g_strctAcquisitionServer.m_bConnected = false;
if ~isfield(g_strctAppConfig,'m_strctAcquisitionServer')
    return
end
fnLog('Trying to setup a TCP/IP connection with Kofiko-Intan');
if ~isfield(g_strctAppConfig.m_strctAcquisitionServer,'m_strAddress') && ...
        isempty(g_strctAppConfig.m_strctAcquisitionServer.m_strAddress)
   
g_strctAcquisitionServer.m_bConnected = false;
g_strctAcquisitionServer.m_iSocket = [];
return;
end;

[strPath,strSession,strExt]=fileparts(g_strctAppConfig.m_strLogFileName);

g_strctAcquisitionServer.m_iSocket = fndllZeroMQ_Wrapper('StartConnectThread',g_strctAppConfig.m_strctAcquisitionServer.m_strAddress);
fndllZeroMQ_Wrapper('Send',g_strctAcquisitionServer.m_iSocket,['SetSessionName ',strSession]);
g_strctAcquisitionServer.m_bConnected = true;
return

  
function fnConnectToRealTimeStatServer()
global g_strctRealTimeStatServer g_bVERBOSE g_strctAppConfig
if ~isfield(g_strctAppConfig,'m_strctRealTimeStatisticsServer')
    g_strctRealTimeStatServer.m_bConnected = false;
    return
end
bBefore = g_bVERBOSE;
g_bVERBOSE = true;
iTimeOutSec  = 1;
fnLog('Trying to setup a TCP/IP connection with the real time statistics server');
if ~isfield(g_strctAppConfig.m_strctRealTimeStatisticsServer,'m_strAddress') && ...
        isempty(g_strctAppConfig.m_strctRealTimeStatisticsServer.m_strAddress) || ...
    ~isfield(g_strctAppConfig.m_strctRealTimeStatisticsServer,'m_fPort')
    
g_strctRealTimeStatServer.m_bConnected = false;
g_strctRealTimeStatServer.m_iSocket = [];
return;
end;

g_strctRealTimeStatServer.m_iSocket = msconnect(g_strctAppConfig.m_strctRealTimeStatisticsServer.m_strAddress,g_strctAppConfig.m_strctRealTimeStatisticsServer.m_fPort,iTimeOutSec);
g_strctRealTimeStatServer.m_bConnected = false;

if g_strctRealTimeStatServer.m_iSocket < 0
    g_bVERBOSE = bBefore;
    return;
end;
fnLog('Connection to real time server established');
mssend(g_strctRealTimeStatServer.m_iSocket, {'StartNewSession',g_strctAppConfig.m_strLogFileName});
g_strctRealTimeStatServer.m_bConnected = true;
g_bVERBOSE = bBefore;
return;


function bSuccessful = fnSetupConnectionToStimulusServer(strStimulusServerIP, iStimulusServerPort)
global g_strctStimulusServer g_bVERBOSE 
% Connect to Stimulus Server
bSuccessful = false;
bBefore = g_bVERBOSE ;
g_bVERBOSE = true;

fnLog('Trying to setup a connection with the stimulus server');

iTimeOutSec  = 5;
g_strctStimulusServer.m_iSocket = msconnect(strStimulusServerIP, iStimulusServerPort, iTimeOutSec); 
if g_strctStimulusServer.m_iSocket < 0
    g_strctStimulusServer = [];
    return;
end;

fnLog('Connection established');

fnLog('Starting PTB on stimulus server');

fnParadigmToStimulusServer('StartPTB');
   
iTimeOutSec = 15;

acResponse1 = msrecv(g_strctStimulusServer.m_iSocket,iTimeOutSec);
if isempty(acResponse1)
    g_strctStimulusServer = [];
    return;
end;

acResponse2 = msrecv(g_strctStimulusServer.m_iSocket,iTimeOutSec);
if isempty(acResponse2)
        g_strctStimulusServer = [];
    return;
end;

if ~strcmpi(acResponse1{1},'ScreenSize') || ~strcmpi(acResponse2{1},'RefreshRate')
      g_strctStimulusServer = [];
    return;
end;


aiStimulusServerScreenSize = acResponse1{2};
fRefreshRate = acResponse2{2};

if isempty(aiStimulusServerScreenSize)
    g_strctStimulusServer = [];
    return;
end;

g_strctStimulusServer.m_strIP = strStimulusServerIP;
g_strctStimulusServer.m_iPort = iStimulusServerPort;
g_strctStimulusServer.m_aiScreenSize = aiStimulusServerScreenSize;
g_strctStimulusServer.m_fRefreshRateHz = fRefreshRate;
g_strctStimulusServer.m_fRefreshRateMS = 1/fRefreshRate*1000;
g_strctStimulusServer.m_bConnected = true;
bSuccessful = true;
g_bVERBOSE = bBefore;
return;

function fnParadigmSwitch(hObject,b)
% Now, switch to a new paradigm
iSelectedParadigm = get(hObject,'Value');
fnSwitchKofikoParadigm(iSelectedParadigm);

return;

function fnSetMatlabFigure()
global g_handles   g_strctGUIParams
if ishandle(1)
    close(1)
end;
g_handles.figure1 = figure(1);
%aiFigurePos =  get(g_handles.figure1,'Position');
fnMaximizeWindow(g_handles.figure1);
set(g_handles.figure1,'Units','Pixels',...
    'Name','Kofiko','Visible','on','Menubar','none','Toolbar','none','DockControls','off',...
    'NumberTitle','off','CloseRequestFcn',@fnCloseKofiko,'Renderer','OpenGL','KeyPressFcn',@fnKeyDown,'KeyReleaseFcn',@fnKeyUp); % 'WindowScrollWheelFcn',@fnMouseWheel,
drawnow
fnSetButtons();
drawnow
return;


function fnKeyDown(a,b)


return;

function fnKeyUp(a,b)
return;


function fnSetButtons()
global g_strctStimulusServer g_strLogFileName g_astrctAllParadigms g_handles g_strctEyeCalib g_strctGUIParams  g_strctAppConfig g_strctDAQParams
aiFigPos = get(g_handles.figure1,'Position');

iPanelHeight = 200;
iPanelWidth = 320;

g_strctGUIParams.m_iPanelHeight = iPanelHeight;
g_strctGUIParams.m_iPanelWidth = iPanelWidth;


fOffsetX = aiFigPos(3)-g_strctGUIParams.m_iPanelWidth-20;
fOffsetY = aiFigPos(4);


g_handles.hControlPanel = uipanel('Units','Pixels','Position',...
    [fOffsetX+20 aiFigPos(4)-iPanelHeight iPanelWidth iPanelHeight]);

iNumButtonsInRow = 3;
iButtonWidth = iPanelWidth / iNumButtonsInRow - 40;
iButtonHeight = 35;

g_handles.hRecordButton = uicontrol('Style', 'pushbutton', 'String', 'Record',...
    'Position', [5 iPanelHeight-iButtonHeight-5 iButtonWidth iButtonHeight], 'parent',g_handles.hControlPanel,'Callback', @fnStartRecordingCallback);

g_handles.hEyeCalibButton = uicontrol('Style', 'pushbutton', 'String', 'Recenter',...
    'Position', [iButtonWidth+20 iPanelHeight-iButtonHeight-5 iButtonWidth iButtonHeight], 'parent',g_handles.hControlPanel, 'Callback', @fnRecenterGazeCallback);

g_handles.hJuiceRewardButton = uicontrol('Style', 'pushbutton', 'String', 'Juice',...
    'Position', [2*iButtonWidth+35 iPanelHeight-iButtonHeight-5 iButtonWidth iButtonHeight], 'parent',g_handles.hControlPanel, 'Callback', @fnJuiceReward);

% g_handles.hJuiceCounter = uicontrol('Style', 'edit', 'String', '0',...
%     'Position', [3*iButtonWidth+60 iPanelHeight-25 35 18], 'parent',g_handles.hControlPanel, 'Callback', @fnJuiceCounterEdit,'HorizontalAlignment','left');

g_handles.hStartButton= uicontrol('Style', 'pushbutton',  'String', 'Start',...
    'Position', [3*iButtonWidth+50 iPanelHeight-iButtonHeight-5 iButtonWidth iButtonHeight], 'Callback', @fnStartParadigmCallback,...
    'parent',g_handles.hControlPanel);

g_handles.hCommentEdit = fnMyUIControlEdit('Style', 'edit', 'String', 'Enter a comment to be logged... ',...
     'Position',[5 iPanelHeight-iButtonHeight-30 iPanelWidth-15 18], 'parent',g_handles.hControlPanel, 'Callback', @fnCommentEdit,'HorizontalAlignment','left');

g_handles.hLastComment = uicontrol('Style', 'text', 'String', 'Last comment:',...
     'Position',[5 iPanelHeight-iButtonHeight-55 iPanelWidth-25 18], 'parent',g_handles.hControlPanel);%, 'Callback', @fnCommentEdit,'HorizontalAlignment','left');
 
 g_handles.hText4 = uicontrol('Style', 'text', 'String', ['Log file: ',g_strLogFileName],...
     'Position',[5 iPanelHeight-iButtonHeight-70  iPanelWidth-25 18], 'parent',g_handles.hControlPanel,'HorizontalAlignment','left');

 g_handles.hLogLine = uicontrol('Style', 'text', 'String', '123','Position',...
     [10 aiFigPos(4)-fOffsetY-aiFigPos(2)-30 fOffsetX 18],...
     'BackgroundColor','r','ForegroundColor','y','parent',g_handles.figure1);
 
iNumParadigms = length(g_astrctAllParadigms);

strOptions='';
for k=1:iNumParadigms
    strOptions =[strOptions,'|',g_astrctAllParadigms{k}.m_strName];
end;

g_handles.hText1 = uicontrol('Style', 'text', 'String', 'Paradigm:',...
    'Position', [5 iPanelHeight-iButtonHeight-90 50 18], 'parent',g_handles.hControlPanel);

g_handles.hText2 = uicontrol('Style', 'text', 'String', 'was loaded at:',...
    'position',[5+200 iPanelHeight-iButtonHeight-90 iPanelWidth-215 18],'HorizontalAlignment','left', 'parent',g_handles.hControlPanel);

g_handles.hRuntimeStatus = uicontrol('Style', 'text', 'String', 'Cycle Time Info',...
    'Position', [5 iPanelHeight-iButtonHeight-110 iPanelWidth-25 18], 'parent',g_handles.hControlPanel,'HorizontalAlignment','left');

% g_handles.hAnnotationButton = uicontrol('Style', 'pushbutton',  'String', 'Annotation',...
%     'Position', [5 iPanelHeight-2*iButtonHeight-110 iButtonWidth iButtonHeight], 'Callback', {@fnAnnotationCallback,'Visible'},'Parent',g_handles.hControlPanel);

g_handles.hSettingsButton = uicontrol('Style', 'pushbutton',  'String', 'Settings',...
    'Position', [iButtonWidth+20 iPanelHeight-2*iButtonHeight-110 iButtonWidth iButtonHeight], 'Callback', {@fnSettingsCallback,'Visible'},'Parent',g_handles.hControlPanel);


g_handles.hPauseButton = uicontrol('Style', 'pushbutton',  'String', 'Pause',...
     'Position', [2*iButtonWidth+30 iPanelHeight-2*iButtonHeight-110 10+iButtonWidth iButtonHeight], 'Callback', @fnPauseParadigmCallback,...
     'parent',g_handles.hControlPanel,'enable','off');

g_handles.hUserTSButton = uicontrol('Style', 'pushbutton',  'String', 'User TS',...
     'Position', [3*iButtonWidth+50 iPanelHeight-2*iButtonHeight-110 10+iButtonWidth-15 iButtonHeight], 'Callback', @fnUserTSCallback,...
     'parent',g_handles.hControlPanel);

 
if g_strctGUIParams.m_fExperimental
    g_handles.m_hProfileButton= uicontrol('Style', 'pushbutton', 'String', 'Profile',...
        'Position',[3*iButtonWidth+60 iPanelHeight-2*iButtonHeight-110  iButtonWidth-10 20], 'Callback', @fnProfileCycle,'HorizontalAlignment','left','parent',g_handles.hControlPanel);
end;

aiPos = [80 iPanelHeight-120 100 18];

g_handles.hParadigmShift = uicontrol('Style', 'popup',...
       'String', strOptions(2:end),...
       'Position',aiPos,...
       'Callback', @fnParadigmSwitch,'parent',g_handles.hControlPanel);

%%

iLowerPanelHeight =  aiFigPos(4) - iPanelHeight-5;
g_strctGUIParams.m_iLowerPanelHeight = iLowerPanelHeight;
aiLowerPanelRect = [fOffsetX+20 aiFigPos(4)-iLowerPanelHeight-iPanelHeight iPanelWidth iLowerPanelHeight];
g_strctGUIParams.m_aiLowerPanelRect = aiLowerPanelRect;

g_handles.m_strctSettingsPanel.m_hPanel = uipanel('Units','Pixels','Position',...
    aiLowerPanelRect);

g_handles.m_strctSettingsPanel.m_hGainXText = uicontrol('Style', 'text', 'String', 'Eye Gain X',...
     'Position',[5 iLowerPanelHeight-30-5 60 20], 'HorizontalAlignment','left','parent',g_handles.m_strctSettingsPanel.m_hPanel);
g_handles.m_strctSettingsPanel.m_hGainX = uicontrol('Style', 'edit', 'String', num2str(fnTsGetVar(g_strctEyeCalib,'GainX')),...
     'Position',[70 iLowerPanelHeight-30 60 20], 'Callback', {@fnSettingsCallback,'GainX'},'HorizontalAlignment','left','parent',g_handles.m_strctSettingsPanel.m_hPanel);

g_handles.m_strctSettingsPanel.m_hGainYText = uicontrol('Style', 'text', 'String', 'Eye Gain Y',...
     'Position',[5 iLowerPanelHeight-60-5 60 20], 'HorizontalAlignment','left','parent',g_handles.m_strctSettingsPanel.m_hPanel);
g_handles.m_strctSettingsPanel.m_hGainY = uicontrol('Style', 'edit', 'String', num2str(fnTsGetVar(g_strctEyeCalib,'GainY')),...
     'Position',[70 iLowerPanelHeight-60 60 20], 'Callback', {@fnSettingsCallback,'GainY'},'HorizontalAlignment','left','parent',g_handles.m_strctSettingsPanel.m_hPanel);
 

 g_handles.m_strctSettingsPanel.hJuiceRewardText = uicontrol('Style', 'text', 'String', 'Juice Time (ms)',...
     'Position',[5 iLowerPanelHeight-95 80 20],'HorizontalAlignment','left','parent',g_handles.m_strctSettingsPanel.m_hPanel);

 g_handles.m_strctSettingsPanel.hJuiceRewardEdit = uicontrol('Style', 'edit', 'String', num2str(g_strctGUIParams.m_fJuiceTimeMS),...
     'Position', [90 iLowerPanelHeight-90 60 20], 'parent',g_handles.m_strctSettingsPanel.m_hPanel, 'Callback', @fnJuiceRewardEdit,'HorizontalAlignment','left');

g_handles.m_strctSettingsPanel.m_hMotionThresholdText = uicontrol('Style', 'text', 'String', 'Motion Threshold',...
     'Position',[5 iLowerPanelHeight-120 100 20], 'HorizontalAlignment','left','parent',g_handles.m_strctSettingsPanel.m_hPanel);
g_handles.m_strctSettingsPanel.m_hMotionThresholdEdit= uicontrol('Style', 'edit', 'String', num2str(g_strctGUIParams.m_fMotionThreshold),...
     'Position',[100+10 iLowerPanelHeight-115 60 20], 'Callback', {@fnSettingsCallback,'MotionThreshold'},'HorizontalAlignment','left','parent',g_handles.m_strctSettingsPanel.m_hPanel);

g_handles.m_strctSettingsPanel.m_hMotionPauseAfterText = uicontrol('Style', 'text', 'String', 'Motion Pause Paradigm After X Sec of motion',...
     'Position',[5 iLowerPanelHeight-145 250 20], 'HorizontalAlignment','left','parent',g_handles.m_strctSettingsPanel.m_hPanel);
g_handles.m_strctSettingsPanel.hMotionPauseAfterEdit= uicontrol('Style', 'edit', 'String', num2str(g_strctGUIParams.m_fPauseTaskAfterMotionSec),...
     'Position',[240+10 iLowerPanelHeight-140 60 20], 'Callback', {@fnSettingsCallback,'MotionPauseAfterSec'},'HorizontalAlignment','left','parent',g_handles.m_strctSettingsPanel.m_hPanel);

g_handles.m_strctSettingsPanel.m_hMotionResumeAfterText = uicontrol('Style', 'text', 'String', 'Motion Resume Paradigm After X Sec of no motion',...
     'Position',[5 iLowerPanelHeight-170 250 20], 'HorizontalAlignment','left','parent',g_handles.m_strctSettingsPanel.m_hPanel);
g_handles.m_strctSettingsPanel.m_hMotionResumeAfterEdit= uicontrol('Style', 'edit', 'String', num2str(g_strctGUIParams.m_fMotionResumeTaskSec),...
     'Position',[240+10 iLowerPanelHeight-165 60 20], 'Callback', {@fnSettingsCallback,'MotionResumeAfterSec'},'HorizontalAlignment','left','parent',g_handles.m_strctSettingsPanel.m_hPanel);

g_handles.m_strctSettingsPanel.m_hMotionValue = uicontrol('Style', 'text', 'String', 'Motion Value:',...
     'Position',[5 iLowerPanelHeight-205 350 20], 'HorizontalAlignment','left','parent',g_handles.m_strctSettingsPanel.m_hPanel);

 
% 
% g_handles.m_strctSettingsPanel.m_hAvgStartMSText = uicontrol('Style', 'text', 'String', 'PSTH Average Window Start (ms):',...
%      'Position',[5 iLowerPanelHeight-500 175 20], 'HorizontalAlignment','left','parent',g_handles.m_strctSettingsPanel.m_hPanel);
% 
% g_handles.m_strctSettingsPanel.m_hAvgStartMSEdit= uicontrol('Style', 'edit', 'String', num2str(g_strctGUIParams.m_fPSTHStartAvgAfterOnsetMS),...
%      'Position',[240+10 iLowerPanelHeight-500 60 20], 'Callback', {@fnSettingsCallback,'PSTH_StartMS'},'HorizontalAlignment','left','parent',g_handles.m_strctSettingsPanel.m_hPanel);
% 
% g_handles.m_strctSettingsPanel.m_hAvgEndMSText = uicontrol('Style', 'text', 'String', 'PSTH Average Window End (ms):',...
%      'Position',[5 iLowerPanelHeight-525 175 20], 'HorizontalAlignment','left','parent',g_handles.m_strctSettingsPanel.m_hPanel);
%  
% g_handles.m_strctSettingsPanel.m_hAvgEndMSEdit= uicontrol('Style', 'edit', 'String', num2str(g_strctGUIParams.m_fPSTHEndAvgAfterOnsetMS),...
%      'Position',[240+10 iLowerPanelHeight-525 60 20], 'Callback', {@fnSettingsCallback,'PSTH_EndMS'},'HorizontalAlignment','left','parent',g_handles.m_strctSettingsPanel.m_hPanel);
 
 
g_handles.m_strctSettingsPanel.m_hConnectToRealTimeStatServer = uicontrol('Style', 'pushbutton', 'String', 'Connect To Real-Time Statistics Server',...
     'Position',[10 iLowerPanelHeight-455 200 30], 'Callback', {@fnSettingsCallback,'ConnectToRealTimeStatServer'},'HorizontalAlignment','left','parent',g_handles.m_strctSettingsPanel.m_hPanel);

 g_handles.m_strctSettingsPanel.m_hConnectToRealTimeStatServer = uicontrol('Style', 'pushbutton', 'String', 'Reconnect To Stimulus Server Server',...
     'Position',[10 iLowerPanelHeight-500 200 30], 'Callback', {@fnSettingsCallback,'ReconnectToStimulusServer'},'HorizontalAlignment','left','parent',g_handles.m_strctSettingsPanel.m_hPanel);

 
 g_handles.m_strctSettingsPanel.m_hTogglePTBScreen = uicontrol('Style', 'pushbutton', 'String', 'Toggle PTB Screen',...
     'Position',[10 iLowerPanelHeight-400 150 30], 'Callback', {@fnSettingsCallback,'TogglePTBScreen'},'HorizontalAlignment','left','parent',g_handles.m_strctSettingsPanel.m_hPanel);

 g_handles.m_strctSettingsPanel.m_hStatPrint= uicontrol('Style', 'pushbutton', 'String', 'StatPrint',...
     'Position',[10 iLowerPanelHeight-300 100 30], 'Callback', {@fnSettingsCallback,'StatPrint'},'HorizontalAlignment','left','parent',g_handles.m_strctSettingsPanel.m_hPanel);

  g_handles.m_strctSettingsPanel.m_hStatPrint= uicontrol('Style', 'pushbutton', 'String', 'StatClear',...
     'Position',[120 iLowerPanelHeight-300 100 30], 'Callback', {@fnSettingsCallback,'StatClear'},'HorizontalAlignment','left','parent',g_handles.m_strctSettingsPanel.m_hPanel);

g_handles.m_strctSettingsPanel.m_hStatPrint= uicontrol('Style', 'pushbutton', 'String', 'FlipThreadUsage',...
     'Position',[0 iLowerPanelHeight-250 100 30], 'Callback', {@fnSettingsCallback,'FlipThreadUsage'},'HorizontalAlignment','left','parent',g_handles.m_strctSettingsPanel.m_hPanel);
 
 
 
  g_handles.m_strctSettingsPanel.m_hMouseEmulator = uicontrol('Style','checkbox','String','Mouse Gaze Emulator',...
     'Position',[10 iLowerPanelHeight-550 200 30],'HorizontalAlignment','Left','Parent',...
    g_handles.m_strctSettingsPanel.m_hPanel,'Callback',{@fnSettingsCallback,'EmulateGaze'},'value',false);
 
g_handles.m_strctSettingsPanel.m_hDisableSpecialKeys = uicontrol('Style','checkbox','String','Disable Special Keys',...
     'Position',[10 iLowerPanelHeight-580 200 30],'HorizontalAlignment','Left','Parent',...
    g_handles.m_strctSettingsPanel.m_hPanel,'Callback',{@fnSettingsCallback,'ToggleSpecialKeys'},'value',false);
 

g_handles.m_strctSettingsPanel.m_hMicroStimCh1 = uicontrol('Style','pushbutton','String','Microstim Pulse (Ch1)',...
     'Position',[10 iLowerPanelHeight-620 150 30],'HorizontalAlignment','Left','Parent',...
    g_handles.m_strctSettingsPanel.m_hPanel,'Callback',{@fnSettingsCallback,'MicroStimPulse',1});

g_handles.m_strctSettingsPanel.m_ahMicroStimAmpEdit(1) = uicontrol('Style', 'edit', 'String', '',...
     'Position',[10 iLowerPanelHeight-660 60 20], 'Callback', {@fnSettingsCallback,'MicrostimAmplitude',1},'HorizontalAlignment','left','parent',g_handles.m_strctSettingsPanel.m_hPanel);

 
g_handles.m_strctSettingsPanel.m_ahMicroStimSrcEdit(1) = uicontrol('Style', 'edit', 'String', '',...
     'Position',[10 iLowerPanelHeight-690 60 20], 'Callback', {@fnSettingsCallback,'MicrostimSource',1},'HorizontalAlignment','left','parent',g_handles.m_strctSettingsPanel.m_hPanel);
 
 g_handles.m_strctSettingsPanel.m_ahMicroStimSrcEdit(2) = uicontrol('Style', 'edit', 'String', '',...
     'Position',[170 iLowerPanelHeight-690 60 20], 'Callback', {@fnSettingsCallback,'MicrostimSource',2},'HorizontalAlignment','left','parent',g_handles.m_strctSettingsPanel.m_hPanel);

g_handles.m_strctSettingsPanel.m_hMicroStimCh2 = uicontrol('Style','pushbutton','String','Microstim Pulse (Ch2)',...
     'Position',[170 iLowerPanelHeight-620 150 30],'HorizontalAlignment','Left','Parent',...
    g_handles.m_strctSettingsPanel.m_hPanel,'Callback',{@fnSettingsCallback,'MicroStimPulse',2});

g_handles.m_strctSettingsPanel.m_ahMicroStimAmpEdit(2) = uicontrol('Style', 'edit', 'String', '',...
     'Position',[170 iLowerPanelHeight-660 60 20], 'Callback', {@fnSettingsCallback,'MicrostimAmplitude',2},'HorizontalAlignment','left','parent',g_handles.m_strctSettingsPanel.m_hPanel);


g_handles.m_strctSettingsPanel.m_hMicroStimChAll = uicontrol('Style','pushbutton','String','Microstim Pulse (All)',...
     'Position',[60 iLowerPanelHeight-730 150 30],'HorizontalAlignment','Left','Parent',...
    g_handles.m_strctSettingsPanel.m_hPanel,'Callback',{@fnSettingsCallback,'MicroStimPulse',1:2});


g_handles.m_strctSettingsPanel.m_hMicroStimGUI = uicontrol('Style','pushbutton','String','Microstim GUI',...
     'Position',[60 iLowerPanelHeight-770 150 30],'HorizontalAlignment','Left','Parent',...
    g_handles.m_strctSettingsPanel.m_hPanel,'Callback',{@fnSettingsCallback,'MicroStimGUI',1:2});


% g_handles.m_strctSettingsPanel.m_hMotionAxes = ...
%     axes('units','pixels','position',[40 iLowerPanelHeight-300-30 iPanelWidth-70 100],'Parent',g_handles.m_strctSettingsPanel.m_hPanel);
 
set(g_handles.m_strctSettingsPanel.m_hPanel,'visible','off');
 

%% TS Panel

g_handles.m_strctTSPanel.m_hPanel = uipanel('Units','Pixels','Position',aiLowerPanelRect);


g_handles.hTimeStampList = uicontrol('Style', 'listbox', 'String', 'Empty',...
    'Position', [10 iLowerPanelHeight-400 iPanelWidth-20 300], 'parent',g_handles.m_strctTSPanel.m_hPanel,'Fontsize',16,'callback',@SetTSName);

g_handles.hStartTS = uicontrol('Style', 'pushbutton', 'String', 'Start',...
    'Position', [5 iLowerPanelHeight-iButtonHeight-10 iButtonWidth iButtonHeight], 'parent',g_handles.m_strctTSPanel.m_hPanel,'Callback', @fnStartTS);

g_handles.hStopTS = uicontrol('Style', 'pushbutton', 'String', 'Stop',...
    'Position', [iButtonWidth+15 iLowerPanelHeight-iButtonHeight-10 iButtonWidth iButtonHeight], 'parent',g_handles.m_strctTSPanel.m_hPanel,'Callback', @fnStopTS,'enable','off');

g_handles.hDeleteTS = uicontrol('Style', 'pushbutton', 'String', 'Delete',...
    'Position', [2*iButtonWidth+30 iLowerPanelHeight-iButtonHeight-10 iButtonWidth iButtonHeight], 'parent',g_handles.m_strctTSPanel.m_hPanel,'Callback', @fnDeleteTS,'enable','off');

g_handles.hRenameTS = uicontrol('Style', 'pushbutton', 'String', 'Rename',...
    'Position', [3*iButtonWidth+45 iLowerPanelHeight-iButtonHeight-10 iButtonWidth iButtonHeight], 'parent',g_handles.m_strctTSPanel.m_hPanel,'Callback', @fnRenameTS);

 g_handles.hTSNameEdit= uicontrol('Style', 'edit', 'String', 'Unknown TS',...
     'Position', [10 iLowerPanelHeight-iButtonHeight-50 iPanelWidth-20 30], 'parent',g_handles.m_strctTSPanel.m_hPanel,...
     'HorizontalAlignment','left','FontSize',16,'backgroundcolor','w');

set(g_handles.m_strctTSPanel.m_hPanel,'visible','off');

%%

g_handles.hDummyController = uicontrol('style','pushbutton','parent',g_handles.figure1);
set(g_handles.hDummyController,'visible','off');

return


function fnConnectToSpikeServer(a,b)
global g_strctSpikeServer g_strctAppConfig

if g_strctSpikeServer.m_bConnected
    % Nothing to do here.
    return;
end;

fnSetupConnectionToSpikeServer(g_strctAppConfig.m_strctSpikeServer.m_strAddress, g_strctAppConfig.m_strctSpikeServer.m_fPort);

if g_strctSpikeServer.m_bConnected
    % ?
end;

return;


function fnInvalidateUserTS()
global g_handles g_strctAppConfig
iNumEntries = length(g_strctAppConfig.m_astrctUserTS);
acList = cell(1,iNumEntries);
for k=1:iNumEntries
    if isnan(g_strctAppConfig.m_astrctUserTS(k).m_fEndTS)
        acList{k} = ['*** ',g_strctAppConfig.m_astrctUserTS(k).m_strName];
    else
        acList{k} = g_strctAppConfig.m_astrctUserTS(k).m_strName;
    end
end
if iNumEntries == 0
    set(g_handles.hTimeStampList,'string','','visible','off');
    return;
end
set(g_handles.hTimeStampList,'string',char(acList),'value',iNumEntries,'visible','on');
return;


function fnStartTS(a,b)
global g_strctAppConfig g_handles
strDesc = get( g_handles.hTSNameEdit,'string');
strctTS.m_strName = strDesc;
strctTS.m_fStartTS = GetSecs();
strctTS.m_fEndTS = NaN;
if isempty(g_strctAppConfig.m_astrctUserTS)
    g_strctAppConfig.m_astrctUserTS = strctTS;
else
    iNumEntries = length(g_strctAppConfig.m_astrctUserTS);
    g_strctAppConfig.m_astrctUserTS(iNumEntries+1) = strctTS;
end
fnInvalidateUserTS();

set(g_handles.hStartTS,'enable','off');
set(g_handles.hStopTS,'enable','on');
set(g_handles.hDeleteTS,'enable','on');
return;

function fnStopTS(a,b)
global g_strctAppConfig g_handles
iNumEntries = length(g_strctAppConfig.m_astrctUserTS);
if iNumEntries == 0
    return;
end;
g_strctAppConfig.m_astrctUserTS(iNumEntries).m_fEndTS = GetSecs();
set(g_handles.hStopTS,'enable','off');
set(g_handles.hStartTS,'enable','on');
fnInvalidateUserTS();
return;

function fnDeleteTS(a,b)
global g_strctAppConfig g_handles
iSelected = get(g_handles.hTimeStampList,'value');
g_strctAppConfig.m_astrctUserTS(iSelected) = [];

fnInvalidateUserTS();
if length(g_strctAppConfig.m_astrctUserTS) > 0
    set(g_handles.hDeleteTS,'enable','on');
else
    set(g_handles.hDeleteTS,'enable','off');
end

set(g_handles.hStartTS,'enable','on');
return;

function fnRenameTS(a,b)
global g_strctAppConfig g_handles
strDesc = get( g_handles.hTSNameEdit,'string');
iSelected = get(g_handles.hTimeStampList,'value');
g_strctAppConfig.m_astrctUserTS(iSelected).m_strName = strDesc;
fnInvalidateUserTS();
return;

function SetTSName(a,b)
global g_strctAppConfig g_handles
iSelected = get(g_handles.hTimeStampList,'value');
set( g_handles.hTSNameEdit,'string',g_strctAppConfig.m_astrctUserTS(iSelected).m_strName);

return;

 
 
function fnResetStatForSelectedUnits()
return;

function fnRecenterGazeCallback(hObject, eventdata)
fnRecenterGaze();
return;

function fnSetSelectedCat(hObject, b)
global g_strctCycle g_handles g_strctGUIParams


aiSelectedCat = get(g_handles.hCategoriesList,'value');
iNumSelected = length(aiSelectedCat);
if iNumSelected >  g_strctGUIParams.m_iMaxCatDisplayed
    aiSelectedCat = aiSelectedCat(1:g_strctGUIParams.m_iMaxCatDisplayed);
    set(g_handles.hCategoriesList,'value',aiSelectedCat);
end

g_strctCycle.m_aiSelectedCat = aiSelectedCat;
return;




function fnSendStat(hObject, b)
% Non functioning at the moment!
return;
if 0
    global g_astrctAllParadigms g_strctAppConfig g_strctSystemCodes g_strctEyeCalib
    global g_strctDAQParams g_strctLog g_strctStimulusServer g_strctParadigm g_iCurrParadigm
    global g_strctCycle
    bPaused = false;
    if isempty(g_strctStimulusServer)
        return;
    end;
    
    if ~g_strctCycle.m_bParadigmPaused
        fnPauseParadigm();
        bPaused = true;
    end
    
    iPlexonSocket = msconnect(g_strctAppConfig.m_strctPlexonServer.m_strAddress, g_strctAppConfig.m_strctPlexonServer.m_fPort);
    if iPlexonSocket < 0
        fnLog('Could not connect to plexon computer');
    else
        
        if ~isempty(g_iCurrParadigm ) && g_iCurrParadigm > 0
            g_astrctAllParadigms{g_iCurrParadigm} = g_strctParadigm;
        end;
        
        strctKofiko.g_astrctAllParadigms = g_astrctAllParadigms;
        strctKofiko.g_strctAppConfig = g_strctAppConfig;
        strctKofiko.g_strctSystemCodes = g_strctSystemCodes;
        strctKofiko.g_strctEyeCalib = g_strctEyeCalib;
        strctKofiko.g_strctDAQParams = g_strctDAQParams;
        strctKofiko.g_strctLog = g_strctLog;
        strctKofiko.g_strctStimulusServer = g_strctStimulusServer;
        strctKofiko2 = fnCropBuffer(strctKofiko);
        mssend(iPlexonSocket,strctKofiko2);
        fnLog('Information was sent to Plexon');
    end
    if bPaused
        fnResumeParadigm();
    end
end
return


function fnJuiceReward(hObject,b)
global g_strctGUIParams
%global g_iRewardMachineState
%g_iRewardMachineState = 1;
fnParadigmToKofikoComm('Juice', g_strctGUIParams.m_fJuiceTimeMS, true)
return;

function fnJuiceRewardEdit(hObject,b)
global g_strctGUIParams
fJuice = str2num(get(hObject,'String'));
if isreal(fJuice) && fJuice > 0
    g_strctGUIParams.m_fJuiceTimeMS = fJuice;
end
return;

function fnCommentEdit(hObject,b)
global g_strctSystemCodes g_handles g_strctAppConfig
strComment = get(hObject,'String');
fnDAQWrapper('StrobeWord', g_strctSystemCodes.m_iComment);
strCurrentDateTime = datestr(now,'dd-mmm-yyyy HH:MM:SS:FFF');
set(g_handles.hLastComment,'String',[strCurrentDateTime,' ',strComment],'fontweight','bold');
set(hObject,'String','');
g_strctAppConfig = fnTsSetVar(g_strctAppConfig,'Comments', [strCurrentDateTime,' ',strComment]);

return;

function fnSettingsCallback(hObject,a,strEventType,varargin)
global g_strctParadigm g_handles g_strctEyeCalib g_strctGUIParams g_strctAppConfig  g_strctCycle g_strctDAQParams g_strctAcquisitionServer

bUpdateDepth = strncmpi(strEventType,'SetDepth',8);
if bUpdateDepth
    iSelctedElectrode = str2num(strEventType(9:end));
    strTemp = get(hObject,'string');
    fNewDepthMM = str2num(strTemp);
    if ~isempty(fNewDepthMM)
        g_strctAppConfig.m_strctElectrophysiology.m_astrctElectrodes(iSelctedElectrode) = ...
            fnTsSetVar(g_strctAppConfig.m_strctElectrophysiology.m_astrctElectrodes(iSelctedElectrode), 'Depth', fNewDepthMM);
        fnLog('Updating depth of electrode %d to %.2f ', iSelctedElectrode,fNewDepthMM );
    end;
end;

switch strEventType
    case 'Visible'
        bVisible = strcmpi(get(g_handles.m_strctSettingsPanel.m_hPanel,'visible'),'on');
        if ~bVisible
            set(g_handles.m_strctSettingsPanel.m_hPanel,'visible','on')
%            set(g_handles.m_strctStatisticsPanel.m_hPanel,'visible','off')
             if isfield(g_strctParadigm,'m_strctControllers') && isfield(g_strctParadigm.m_strctControllers,'m_hPanel')
                set(g_strctParadigm.m_strctControllers.m_hPanel,'visible','off')
            end;
            
            fGainX = fnTsGetVar(g_strctEyeCalib,'GainX');
            fGainY = fnTsGetVar(g_strctEyeCalib,'GainY');
            set(g_handles.m_strctSettingsPanel.m_hGainX,'string',num2str(fGainX));
            set(g_handles.m_strctSettingsPanel.m_hGainY,'string',num2str(fGainY));


%             set(g_handles.m_strctSettingsPanel.m_hAvgStartMSEdit, 'String', num2str(g_strctGUIParams.m_fPSTHStartAvgAfterOnsetMS));
%             set(g_handles.m_strctSettingsPanel.m_hAvgEndMSEdit ,'String',  num2str(g_strctGUIParams.m_fPSTHEndAvgAfterOnsetMS));
%             
%             iNumElectrodes = length(g_strctAppConfig.m_strctElectrophysiology.m_astrctElectrodes);
%             for k=1:iNumElectrodes
%                 fCurrDepthMM = g_strctAppConfig.m_strctElectrophysiology.m_astrctElectrodes(k).Depth.Buffer(...
%                     g_strctAppConfig.m_strctElectrophysiology.m_astrctElectrodes(k).Depth.BufferIdx);
%                 set(g_handles.m_strctSettingsPanel.m_hCurrentDepthEdit(k),'string',num2str(fCurrDepthMM));
%             end;
%             
            g_strctGUIParams.m_bSettingsPanelOn = true;
        else
            set(g_handles.m_strctSettingsPanel.m_hPanel,'visible','off')
             if isfield(g_strctParadigm,'m_strctControllers') && isfield(g_strctParadigm.m_strctControllers,'m_hPanel')
                set(g_strctParadigm.m_strctControllers.m_hPanel,'visible','on')
            end;
            g_strctGUIParams.m_bSettingsPanelOn = false;
        end
        
%     case 'PSTH_StartMS'
%         strTemp = get(g_handles.m_strctSettingsPanel.m_hAvgStartMSEdit,'string');
%         fStartMS = str2num(strTemp);
%         if ~isempty(fStartMS) && fStartMS < g_strctGUIParams.m_fPSTHEndAvgAfterOnsetMS
%             g_strctGUIParams.m_fPSTHStartAvgAfterOnsetMS = fStartMS;
%         else
%             set(g_handles.m_strctSettingsPanel.m_hAvgStartMSEdit,'string',num2str(g_strctGUIParams.m_fPSTHStartAvgAfterOnsetMS));
%         end;
%     case 'PSTH_EndMS'
%         strTemp = get(g_handles.m_strctSettingsPanel.m_hAvgEndMSEdit,'string');
%         fEndMS = str2num(strTemp);
%         if ~isempty(fEndMS) && fEndMS > g_strctGUIParams.m_fPSTHStartAvgAfterOnsetMS
%             g_strctGUIParams.m_fPSTHEndAvgAfterOnsetMS = fEndMS;
%         else
%             set(g_handles.m_strctSettingsPanel.m_hAvgEndMSEdit,'string',num2str(g_strctGUIParams.m_fPSTHEndAvgAfterOnsetMS));
%         end;
        
    case 'GainX'
        strTemp = get(g_handles.m_strctSettingsPanel.m_hGainX,'string');
        fGainX = str2num(strTemp);
        if ~isempty(fGainX)
            if fGainX == 0
                fGainX = 0.05;
            end;
            g_strctEyeCalib = fnTsSetVar(g_strctEyeCalib,'GainX', fGainX);
            fnLog('Setting new eye X gain %.2f', fGainX);
        end;
    case 'GainY'
        strTemp = get(g_handles.m_strctSettingsPanel.m_hGainY,'string');
        fGainY = str2num(strTemp);
        if ~isempty(fGainY)
            if fGainY == 0
                fGainY = 0.05;
            end;
            g_strctEyeCalib = fnTsSetVar(g_strctEyeCalib,'GainY', fGainY);
            fnLog('Setting new eye Y gain %.2f', fGainY);
        end;
    case 'StatPrint'
        if g_strctAcquisitionServer.m_bConnected
            fndllZeroMQ_Wrapper('Send',g_strctAcquisitionServer.m_iSocket,['tictoc_print']);
        end
    case 'StatClear'
        if g_strctAcquisitionServer.m_bConnected
            fndllZeroMQ_Wrapper('Send',g_strctAcquisitionServer.m_iSocket,['tictoc_clear']);
        end
    case 'FlipThreadUsage'
        if g_strctAcquisitionServer.m_bConnected
            fndllZeroMQ_Wrapper('Send',g_strctAcquisitionServer.m_iSocket,['flip_thread_usage']);
        end
  
    case 'MotionThreshold'
        strTemp = get(g_handles.m_strctSettingsPanel.m_hMotionThresholdEdit,'string');
        fMotionThreshold = str2num(strTemp);
        if ~isempty(fMotionThreshold)
            g_strctGUIParams.m_fMotionThreshold = fMotionThreshold;
            fnLog('Setting new motion threshold to %.2f', fMotionThreshold);
        end;
        
    case 'MotionPauseAfterSec'
        strTemp = get(g_handles.m_strctSettingsPanel.hMotionPauseAfterEdit,'string');
        fPauseSec = str2num(strTemp);
        if ~isempty(fPauseSec)
            g_strctGUIParams.m_fPauseTaskAfterMotionSec = fPauseSec;
            fnLog('Paradigm will pause after monkey moves for at least %.2f sec', fPauseSec);
        end;
        
    case 'MotionResumeAfterSec'
        strTemp = get(g_handles.m_strctSettingsPanel.m_hMotionResumeAfterEdit,'string');
        fResumeSec = str2num(strTemp);
        if ~isempty(fResumeSec)
            g_strctGUIParams.m_fMotionResumeTaskSec = fResumeSec;
            fnLog('Paradigm will resume after monkey keep still for at least %.2f sec', fResumeSec);
        end;
    case 'ConnectToRealTimeStatServer'
        fnConnectToRealTimeStatServer();
    case 'ReconnectToStimulusServer'
        fnReconnectToStimulusServer();
    case 'EmulateGaze'
          bEmulatorMode = get(g_handles.m_strctSettingsPanel.m_hMouseEmulator,'value');
           fnParadigmToKofikoComm('MouseEmulator',bEmulatorMode);
    case 'ToggleSpecialKeys'
      g_strctGUIParams.m_bUseSpecialKeys = ~get(g_handles.m_strctSettingsPanel.m_hDisableSpecialKeys,'value');
    case 'TogglePTBScreen'
          fnTogglePTB();
    case 'MicrostimAmplitude'
        iHandle = varargin{1};
        fAmplitude = str2num(get(g_handles.m_strctSettingsPanel.m_ahMicroStimAmpEdit(iHandle),'String'));
        if length(fAmplitude) == 1 && ~isempty(fAmplitude)
            afAmplitudes = fnTsGetVar(g_strctDAQParams,'MicroStimAmplitude');
            afAmplitudes(iHandle) = fAmplitude;
            g_strctDAQParams = fnTsSetVar(g_strctDAQParams,'MicroStimAmplitude',afAmplitudes);
        end
        
    case 'MicrostimSource'
        iHandle = varargin{1};
        
            acSources = fnTsGetVar(g_strctDAQParams,'MicroStimSource');
            acSources{iHandle} = get(g_handles.m_strctSettingsPanel.m_ahMicroStimSrcEdit(iHandle),'String');
            g_strctDAQParams = fnTsSetVar(g_strctDAQParams,'MicroStimSource',acSources);
        
    case 'MicroStimPulse'
        aiChannels = varargin{1};
        
       afAmplitudes = fnTsGetVar(g_strctDAQParams,'MicroStimAmplitude');
        
        for k=1:length(aiChannels)
            fnParadigmToKofikoComm('StimulationTTL',aiChannels(k),afAmplitudes(aiChannels(k)));
        end
    case 'MicroStimGUI'
        %NanoStimulatorGUI();
        ChipKitStimGUI_Serial();
end


return;

% 
% function fnAnnotationCallback(hObject, a, strEventType)
% global g_strctParadigm g_handles  g_strctGUIParams
% 
% switch strEventType
%     case 'Visible'
%         bVisible = strcmpi(get(g_handles.m_strctStatisticsPanel.m_hPanel,'visible'),'on');
%         if ~bVisible
%             set(g_handles.m_strctStatisticsPanel.m_hPanel,'visible','on')
%             set(g_handles.m_strctSettingsPanel.m_hPanel,'visible','off')
%             set(g_handles.m_strctTSPanel.m_hPanel,'visible','off');
%             if isfield(g_strctParadigm,'m_strctControllers') && isfield(g_strctParadigm.m_strctControllers,'m_hPanel')
%                 set(g_strctParadigm.m_strctControllers.m_hPanel,'visible','off')
%             end;
%             g_strctGUIParams.m_bStatisticsPanelOn = true;
%         else
%             set(g_handles.m_strctStatisticsPanel.m_hPanel,'visible','off')
%              if isfield(g_strctParadigm,'m_strctControllers') && isfield(g_strctParadigm.m_strctControllers,'m_hPanel')
%                 set(g_strctParadigm.m_strctControllers.m_hPanel,'visible','on')
%             end;
%             g_strctGUIParams.m_bStatisticsPanelOn = false;
%         end
% end
% 
% return;




function fnUserTSCallback(hObject, a)
global g_strctParadigm g_handles  g_strctGUIParams

bVisible = strcmpi(get(g_handles.m_strctTSPanel.m_hPanel,'visible'),'on');
if ~bVisible
    %set(g_handles.m_strctStatisticsPanel.m_hPanel,'visible','off')
    set(g_handles.m_strctSettingsPanel.m_hPanel,'visible','off')
    set(g_handles.m_strctTSPanel.m_hPanel,'visible','on');
    if isfield(g_strctParadigm,'m_strctControllers') && isfield(g_strctParadigm.m_strctControllers,'m_hPanel')
        set(g_strctParadigm.m_strctControllers.m_hPanel,'visible','off')
    end;
else
        set(g_handles.m_strctTSPanel.m_hPanel,'visible','off');

        if isfield(g_strctParadigm,'m_strctControllers') && isfield(g_strctParadigm.m_strctControllers,'m_hPanel')
        set(g_strctParadigm.m_strctControllers.m_hPanel,'visible','on')
    end;
end

return;


function fnCloseKofiko(a,b)
global g_bParadigmRunning g_bAppIsRunning 
if g_bAppIsRunning
    g_bParadigmRunning = false;
    g_bAppIsRunning = false;
    fnLog('Stopping Paradigm');
    fnLog('Shutting down');
else
    fnShutDown();
end;
return

function fnSetupDefaultParameters()
global g_strctEyeCalib g_strctGUIParams g_strctAppConfig g_handles g_strctRecordingInfo g_strctDAQParams

if isfield(g_strctAppConfig,'m_strctElectrophysiology')
    iNumChambers = length(g_strctAppConfig.m_strctElectrophysiology);
    for iChamberIter=1:iNumChambers
        if isfield(g_strctAppConfig.m_strctElectrophysiology(iChamberIter),'m_astrctGrids')
            aiActiveElectrodes = find(g_strctAppConfig.m_strctElectrophysiology(iChamberIter).m_astrctGrids.m_abSelected);
            iNumActiveElectrodes = sum(g_strctAppConfig.m_strctElectrophysiology(iChamberIter).m_astrctGrids.m_abSelected);
            if isfield(g_strctAppConfig.m_strctElectrophysiology(iChamberIter).m_astrctGrids(1),'m_astrctDepth')
                g_strctAppConfig.m_strctElectrophysiology(iChamberIter).m_astrctGrids(1) = rmfield(...
                    g_strctAppConfig.m_strctElectrophysiology(iChamberIter).m_astrctGrids(1),'m_astrctDepth');
            end
            
        else
            aiActiveElectrodes = [];
            iNumActiveElectrodes  = 0;
        end
           
        for k=1:iNumActiveElectrodes
            strctTmp = ...
                fnTsAddVar([], 'Depth', ...
                g_strctAppConfig.m_strctElectrophysiology(iChamberIter).m_astrctGrids(1).m_afGuideTubeLengthMM(aiActiveElectrodes(k))+...
                g_strctAppConfig.m_strctElectrophysiology(iChamberIter).m_astrctGrids(1).m_afElectrodeLengthMM(aiActiveElectrodes(k)),20000);
            g_strctAppConfig.m_strctElectrophysiology(iChamberIter).m_astrctGrids(1).m_astrctDepth(k) = strctTmp.Depth;
        end;
    end
else
    g_strctAppConfig.m_strctElectrophysiology = [];
end

g_strctAppConfig.m_astrctUserTS = [];

g_strctAppConfig.m_hVideoGrabber = [];

g_strctAppConfig = fnTsAddVar(g_strctAppConfig,'Comments', 'Initialzing Kofiko', 100);

g_strctAppConfig = fnTsAddVar(g_strctAppConfig,'ParadigmSwitch', '', 100);


g_strctGUIParams = g_strctAppConfig.m_strctGUIParams;
g_strctGUIParams.m_iJuiceCounter = 0;
g_strctGUIParams.m_fJuiceTimeOpenTotalMS = 0;
g_strctGUIParams.m_bStatisticsPanelOn = false;
g_strctGUIParams.m_bSettingsPanelOn = false;
g_strctGUIParams.m_bUserPaused = false;    
g_strctGUIParams.m_bDisplayPTB = true;

g_strctGUIParams.m_iActiveElectrode = 1;
g_strctGUIParams.m_iActiveChamber = 1;

g_strctGUIParams.m_iMaxCatDisplayed = 10; % Do not show more than 10 categories...

g_strctGUIParams.m_bShowStat = true;

g_strctGUIParams.m_iSelectedChannel = 1;
g_strctGUIParams.m_iSelectedUnit = 1;

g_strctGUIParams.m_iActiveLFPChannel = 1;

g_strctGUIParams.m_bUseSpecialKeys = true;

iPanelHeight = 200;
iPanelWidth = 320;

g_strctGUIParams.m_iPanelHeight = iPanelHeight;
g_strctGUIParams.m_iPanelWidth = iPanelWidth;



iInitBufferLength = 100;
g_strctEyeCalib = fnTsAddVar([], 'CenterX', g_strctAppConfig.m_strctEyeCalib.m_fCenterX, iInitBufferLength);
g_strctEyeCalib = fnTsAddVar(g_strctEyeCalib, 'CenterY', g_strctAppConfig.m_strctEyeCalib.m_fCenterY, iInitBufferLength);
g_strctEyeCalib = fnTsAddVar(g_strctEyeCalib, 'GainX', g_strctAppConfig.m_strctEyeCalib.m_fScaleX, iInitBufferLength);
g_strctEyeCalib = fnTsAddVar(g_strctEyeCalib, 'GainY', g_strctAppConfig.m_strctEyeCalib.m_fScaleY, iInitBufferLength);

if g_strctAppConfig.m_strctVarSave.m_fEyePos
    iEstimatedNumberOfRecordingHours = 5;
    iInitBufferLength = g_strctAppConfig.m_strctVarSave.m_fEyePosSampleRateHz * 3600 * iEstimatedNumberOfRecordingHours;
    g_strctEyeCalib = fnTsAddVar(g_strctEyeCalib, 'EyeRaw', [0 0 0], iInitBufferLength);
end;

return;
    

function bOK = fnSetupDAQ()
bOK  = false;
global g_strctDAQParams  g_strctAppConfig   g_strctRecordingInfo 
strLogLine = fnLog('Initializing Data Acqusition Card...');
%set(g_handles.hLogLine,'String',strLogLine);
drawnow
g_strctDAQParams = g_strctAppConfig.m_strctDAQ;
g_strctDAQParams.m_bMouseGazeEmulator = false;


g_strctDAQParams = fnTsAddVar(g_strctDAQParams,'MicroStimAmplitude',[NaN NaN],100);
g_strctDAQParams = fnTsAddVar(g_strctDAQParams,'MicroStimSource',{'Manual','Manual'},100);


if ~isfield(g_strctDAQParams,'m_strEyeSignalInput')
    g_strctDAQParams.m_strEyeSignalInput = 'Analog';
end
if strcmpi(g_strctDAQParams.m_strEyeSignalInput,'Serial') 
    if ~isfield(g_strctDAQParams,'m_strEyeSignalSerialCOM')
        fprintf('Missing Entry in XML (EyeSignalSerialCOM) under the DAQ block to specify COM port for ISCAN\n');
        return;
    end

    bOK = fnInitializeSerialPortforISCAN();
    if ~bOK
        fprintf('Error initializing serial port with IOPort\n');
        return;
    end;
    % Turn on saving of eye signal... 
    g_strctAppConfig.m_strctVarSave.m_fEyePos  = 1;
    g_strctDAQParams.m_bUseEyePosSerial = true;
end

if isfield(g_strctAppConfig.m_strctDAQ,'m_fAcqusitionCardBoard')
    bErrorInitializingDAQ = fnDAQWrapper('Init',g_strctAppConfig.m_strctDAQ.m_fAcqusitionCardBoard);
else
    bErrorInitializingDAQ = fnDAQWrapper('Init',g_strctAppConfig.m_strctDAQ.m_strAcqusitionCardBoard);
end

if bErrorInitializingDAQ
    return;
end


% [AdvancerPort, ChamberIndex, Hole Index]
 
iNumExternalTriggers = length(g_strctDAQParams.m_afExternalTriggers);
iExternalTriggerBufferSize = 5000;
for k=1:iNumExternalTriggers
    if k==1
        g_strctDAQParams.m_astrctExternalTriggers = fnTsAddVar([],'Trigger',0,iExternalTriggerBufferSize);
    else
        g_strctDAQParams.m_astrctExternalTriggers(k) = fnTsAddVar([],'Trigger',0,iExternalTriggerBufferSize);
    end;
end
g_strctDAQParams.m_aiExternalTriggerFSM_State = zeros(1,iNumExternalTriggers);

g_strctDAQParams = fnTsAddVar(g_strctDAQParams,'NanoStimulatorParams',{},  10000);
g_strctDAQParams = fnTsAddVar(g_strctDAQParams,'MicroStimTriggers',{},  10000);

iEstimatedNumberOfRecordingHours = 5;
iInitBufferLength = g_strctAppConfig.m_strctVarSave.m_fMotionSampleRateHz * 3600 * iEstimatedNumberOfRecordingHours;
g_strctDAQParams.m_strctMotionSensor = fnTsAddVar([],'MotionSensor',0,iInitBufferLength);

[fLocalTime, fServerTime, fJitter] = fnSyncClockWithStimulusServer(100);
g_strctDAQParams= fnTsAddVar(g_strctDAQParams,'StimulusServerSync',[fLocalTime,fServerTime,fJitter],10000);

g_strctDAQParams = fnTsAddVar(g_strctDAQParams,'RecordSync',0,360000);

g_strctDAQParams=fnTsAddVar(g_strctDAQParams,'JuiceRewards',{},10000);
g_strctRecordingInfo.m_iSession = 0;
bOK  = true;
return;

function fnSetupPTB()
global g_strctPTB g_strctStimulusServer g_handles g_strctGUIParams g_strctAppConfig
A=PsychtoolboxVersion;
fnLog('Using PTB toolbox version: %s',A(1:min(length(A),6)));

g_handles.figure1 = figure(1);
set(g_handles.figure1,'Menubar','none','Toolbar','none')
drawnow
fnMaximizeWindow(g_handles.figure1);
drawnow
aiMatlabFigRect = get(g_handles.figure1,'Position');
close(g_handles.figure1);




a2iRects = get(0,'MonitorPosition');
[fDummy, iIndex] = min(a2iRects(:,1));
aiMatlabFigRectFull  =a2iRects(iIndex,:);
%strLogLine = fnLog('Opening PTB Screen');

%set(g_handles.hLogLine,'String',strLogLine);
%drawnow

iPTBOffsetX = 5;
iPTBOffsetY =  aiMatlabFigRectFull(4)-aiMatlabFigRect(4)+10;

g_strctPTB.m_iScreenIndex = g_strctGUIParams.m_fPTBScreen;
%Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference', 'TextRenderer', 0);

% fAvailWidth = aiMatlabFigRect(3)-g_strctGUIParams.m_iPanelWidth-20-iPTBOffsetX;
% fAvailHeight = aiMatlabFigRect(4)-aiMatlabFigRect(2)-20; % For status line

fAvailWidth = aiMatlabFigRect(3)-g_strctGUIParams.m_iPanelWidth-20-iPTBOffsetX;
fAvailHeight = aiMatlabFigRect(4)-aiMatlabFigRect(2)-50; % For status line

if fAvailWidth > g_strctStimulusServer.m_aiScreenSize(3) && ...
   fAvailHeight > g_strctStimulusServer.m_aiScreenSize(4)

  fScaledWidth = g_strctStimulusServer.m_aiScreenSize(3);
  fScaledHeight = g_strctStimulusServer.m_aiScreenSize(4);
  fScale = 1;
else
    fXScale = fAvailWidth /  g_strctStimulusServer.m_aiScreenSize(3);
    fYScale = fAvailHeight / g_strctStimulusServer.m_aiScreenSize(4);
    
    fScale = min(fXScale,fYScale);
    
    fScaledHeight = floor(g_strctStimulusServer.m_aiScreenSize(4) * fScale);
    fScaledWidth =  floor(g_strctStimulusServer.m_aiScreenSize(3) * fScale);
 end

    
  g_strctPTB.m_fScale = fScale;
  g_strctPTB.m_fScaledHeight = fScaledHeight;
  g_strctPTB.m_fScaledWidth = fScaledWidth;
 g_strctPTB.m_aiScreenRect = [aiMatlabFigRect(1)+iPTBOffsetX,...
     aiMatlabFigRect(2)+iPTBOffsetY,...
     aiMatlabFigRect(1)+fAvailWidth,...
     aiMatlabFigRect(2)+fAvailHeight];
 
fnLog('Starting PTB Screen');
drawnow
if isfield(g_strctGUIParams,'m_fDebug') && g_strctGUIParams.m_fDebug == 1
    g_strctPTB.m_aiScreenRect = [aiMatlabFigRect(1)+iPTBOffsetX+500,... % Give enough space for the stimulus server PTB screen
        aiMatlabFigRect(2)+iPTBOffsetY,...
        aiMatlabFigRect(1)+fAvailWidth,...
        aiMatlabFigRect(2)+fAvailHeight];
    
    [g_strctPTB.m_hWindow, g_strctPTB.m_aiRect] = Screen(    'OpenWindow',g_strctPTB.m_iScreenIndex,[0 0 0],g_strctPTB.m_aiScreenRect);
else
          [g_strctPTB.m_hWindow, g_strctPTB.m_aiRect] = Screen(    'OpenWindow',g_strctPTB.m_iScreenIndex,[0 0 0],g_strctPTB.m_aiScreenRect);
end
Screen('Flip',g_strctPTB.m_hWindow);
if g_strctAppConfig.m_strctStimulusServer.m_fSingleComputerMode
    Screen('Preference', 'SkipSyncTests', 1);
    g_strctPTB.m_iRefreshRate=Screen('FrameRate', 0);
    [g_strctStimulusServer.m_hWindow, g_strctStimulusServer.m_aiRect] = Screen(    'OpenWindow',g_strctAppConfig.m_strctStimulusServer.m_fPTBScreen,[0 0 0],[]);
    Screen('Flip',g_strctStimulusServer.m_hWindow);
    Screen(g_strctStimulusServer.m_hWindow,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

end
Screen(g_strctPTB.m_hWindow,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
g_strctPTB.m_bNonRectMakeTexture = true;
g_strctPTB.m_bRunningOnStimulusServer = false;
Screen(g_strctPTB.m_hWindow,'FillRect',[250 255 255]);
Screen('TextSize', g_strctPTB.m_hWindow,  20);
Screen('Flip', g_strctPTB.m_hWindow);
return;


function fnStartRecordingCallback(hObject,b)
global  g_bRecording        
if ~g_bRecording
    fnStartRecording(0.2);
else
    fnStopRecording(0.2);
end;
return;


function fnReconnectToStimulusServer()
global g_strctAppConfig g_iCurrParadigm g_handles
bOK = fnSetupConnectionToStimulusServer(...
        g_strctAppConfig.m_strctStimulusServer.m_strAddress,...
        g_strctAppConfig.m_strctStimulusServer.m_fPort);
    
if bOK
    % Emulate a switch into the paradigm. This should initialize things on
    % the other end....
    fnSwitchKofikoParadigm(g_iCurrParadigm);
    set(g_handles.hPauseButton, 'String','Resume','enable','on');
    set(g_handles.hStartButton,'enable','on');
    return
end

return;
