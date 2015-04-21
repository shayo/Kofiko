function StimulusServer(strXMLConfigFile)
clear global
dbstop if error

global g_strctPTB g_strctServerCycle g_strctConfig g_strctNet g_bVERBOSE g_bSIMULATE g_strctSoundMedia

g_bVERBOSE = true; % this will display logged messages on screen
if ~exist('.\Config\StimServerConfigForDifferentRigs','dir')
    fprintf('Critical Error. Cannot find config folder for stimulus server!. Generate .\\Config\\StimServerConfigForDifferentRigs\n');
    return;
end

strConfigFolder = '.\Config\StimServerConfigForDifferentRigs\';
astrctConfigFiles = dir([strConfigFolder,'*.xml']);
if isempty(astrctConfigFiles)
    fprintf('Critical Error. No config files found!\n');
    return;
end
if length(astrctConfigFiles) == 1
    % Just load this one
    strXMLConfigFile = astrctConfigFiles(1).name;
else
    % Ask user which one to select...
    strCacheFile = [strConfigFolder,'StimServerCache.mat'];
    acOptions = {astrctConfigFiles.name};
    if exist(strCacheFile,'file')
        try
            strctTmp = load(strCacheFile);
        iIndex = find(ismember(acOptions,strctTmp.strXMLConfigFile));
        if ~isempty(iIndex) && exist([strConfigFolder,acOptions{iIndex}],'file')
            iInitialValue = iIndex;
        else
            iInitialValue = 1;
        end
        catch
            iInitialValue = 1;
        end
    else
        iInitialValue = 1;
    end
        
      [v,s] = listdlg('PromptString','Select a rig config:',...
                      'SelectionMode','single',...
                      'ListString',acOptions,'initialvalue',iInitialValue,'ListSize',[400 200]);
        if isempty(s) || (~isempty(s) && s==0)
            return;
        end;
        % Save cache
        strXMLConfigFile = acOptions{v};

try
    save(strCacheFile,'strXMLConfigFile');
catch
end
        drawnow
end

g_strctConfig = fnLoadConfigXML([strConfigFolder,strXMLConfigFile]);


g_strctSoundMedia.m_acSounds = [];

if ~isempty(g_strctConfig.m_strctDirectories.m_strPTB_Folder)
    
    if g_strctConfig.m_strctDirectories.m_strPTB_Folder(end) ~= '\'
        g_strctConfig.m_strctDirectories.m_strPTB_Folder(end+1) = '\';
    end
    addpath(genpath(g_strctConfig.m_strctDirectories.m_strPTB_Folder));
    addpath([g_strctConfig.m_strctDirectories.m_strPTB_Folder,'PsychBasic']);
    addpath([g_strctConfig.m_strctDirectories.m_strPTB_Folder,'PsychBasic\MatlabWindowsFilesR2007a']);
    addpath([g_strctConfig.m_strctDirectories.m_strPTB_Folder,'PsychOneliners']);
    addpath([g_strctConfig.m_strctDirectories.m_strPTB_Folder,'PsychRects']);
    addpath([g_strctConfig.m_strctDirectories.m_strPTB_Folder,'PsychTests']);
    addpath([g_strctConfig.m_strctDirectories.m_strPTB_Folder,'PsychPriority']);
    addpath([g_strctConfig.m_strctDirectories.m_strPTB_Folder,'PsychAlphaBlending']);
    addpath([g_strctConfig.m_strctDirectories.m_strPTB_Folder,'PsychOpenGL\MOGL\core']);
    addpath([g_strctConfig.m_strctDirectories.m_strPTB_Folder,'PsychOpenGL\MOGL\wrap']);
    addpath([g_strctConfig.m_strctDirectories.m_strPTB_Folder,'PsychGLImageProcessing']);
    addpath([g_strctConfig.m_strctDirectories.m_strPTB_Folder,'PsychOpenGL']);
    addpath([g_strctConfig.m_strctDirectories.m_strPTB_Folder,'PsychSound']);
end

try
    GetSecs();
catch
    fprintf('Fatal Error. Could not call GetSecs. PTB Folder is probably misconfigured.\n');
    return;
end

bSuccessful  = fnStartLogFile(g_strctConfig.m_strctDirectories.m_strLogFolder,'');
if ~bSuccessful
    error('Could not start log file');
end;

% Config
bServerRunning = true;
fnLog('Starting Stimulus Server...');

% Attempt to create audio device using ASIO interface
InitializePsychSound(1);
astrctAudioDevices = PsychPortAudio('GetDevices');
iDeviceIndex = find(ismember({astrctAudioDevices.DeviceName},g_strctConfig.m_strctStimulusServer.m_strAudioDeviceName));
if isempty(iDeviceIndex)
    fprintf('Failed to find audio device %s. \n',g_strctConfig.m_strctStimulusServer.m_strAudioDeviceName);
    fprintf('Your available devices are:\n');
    for k=1:length(astrctAudioDevices)
        fprintf('* %s\n',astrctAudioDevices(k).DeviceName)
    end
    fprintf('\n\nPlease edit StimulusServer.xml config file with your device!. \nNow Aborting!\n');
    return;
end;




iAgressiveMode = 3; % Should be 4, once we get the soundblaster card...
try
    g_strctPTB.m_hAudioDevice = PsychPortAudio('Open',astrctAudioDevices(iDeviceIndex).DeviceIndex,1,iAgressiveMode, 44100,2);
catch
    g_strctPTB.m_hAudioDevice = [];
end

%PsychPortAudio('Verbosity',0); % Do this after you made sure everything
%runs smooth

Priority(2); % "Real-Time"

g_strctNet.m_iServerSocket = mslisten(g_strctConfig.m_strctStimulusServer.m_fPort);
while (bServerRunning)
    fnLog('Listening on port %d',g_strctConfig.m_strctStimulusServer.m_fPort);
    [g_strctNet.m_iCommSocket,g_strctNet.m_strIP] = msaccept(g_strctNet.m_iServerSocket,g_strctConfig.m_strctStimulusServer.m_fListenTimeoutSec);  % Block
    drawnow
    if g_strctNet.m_iCommSocket == -1 % Timeout
        [keyIsDown, secs, keyCode, deltaSecs] =KbCheck;
        if keyIsDown && keyCode(27)
            fprintf('Stopping server\n');
            break;
        end;
        continue;
    end;
    fnLog('Client connected %s',g_strctNet.m_strIP);
    g_strctServerCycle.m_fbClientConnected = true;
    
     fnInitStimulusServer();
%    try
fnShowPTB();

        while (g_strctServerCycle.m_fbClientConnected)
            fnStimulusServerCycle();
        end;
        fnStopPTB();
%     catch
%         fnLog('Crashed');
%         strctError = lasterror
%         fnLog('%s',strctError.message);
%         astrctStack = strctError.stack;
%         for k=1:size(astrctStack,1)
%             fnLog('File %s, at line %d', astrctStack(k).file, astrctStack(k).line);
%         end;
%          if  g_strctPTB.m_bRunning
%              fnStopPTB();
%          end;
%         drawnow
%     end
    msclose(g_strctNet.m_iCommSocket);
end;

msclose(g_strctNet.m_iServerSocket);
 PsychPortAudio('Close', g_strctPTB.m_hAudioDevice);
fnStopPTB();
return;

function fnInitStimulusServer()
global g_strctServerCycle
g_strctServerCycle.m_fbClientConnected = true;
g_strctServerCycle.m_fKBCheckTimer = GetSecs();
g_strctServerCycle.m_fKBCheckTimerRateMS = 1000;
g_strctServerCycle.m_iNumCycles = 0;
g_strctServerCycle.m_fCycleTimer = GetSecs();
g_strctServerCycle.m_fCycleTimerRateMS = 1000;
%g_strctServerCycle.m_afCycleTime = zeros(1,10000);
g_strctServerCycle.m_fCurrTime = GetSecs();
g_strctServerCycle.m_bPaused = false;
g_strctServerCycle.m_strDrawFunc = [];
g_strctServerCycle.m_strctDrawParams = [];
g_strctServerCycle.m_iMachineState = 0;

return;


function fnStopPTB()
global g_strctPTB g_bSIMULATE
if g_bSIMULATE
    g_strctPTB.m_bRunning = false;
    return;
end;
try
    Screen('CloseAll');
    ShowCursor;
catch
    fnLog('Crashed while stopping PTB');

    strctError = lasterror
    fnLog('%s',strctError.message);
    astrctStack = strctError.stack;
    for k=1:size(astrctStack,1)
        fnLog('File %s, at line %d \n', astrctStack(k).file, astrctStack(k).line);
    end;
    drawnow
end;
g_strctPTB.m_bRunning = false;
return;

