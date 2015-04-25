function DAQServer()
clear global
dbstop if error


global g_strctPTB g_strctDAQCycle g_strctConfig g_strctNet g_bVERBOSE g_bSIMULATE g_strctSoundMedia

g_strctNet.m_fPort = 1503;
try
    GetSecs();
catch
    fprintf('Fatal Error. Could not call GetSecs. PTB Folder is probably misconfigured.\n');
    return;
end






Priority(2); % "Real-Time"

g_strctNet.m_iServerSocket = mslisten(g_strctNet.m_fPort);
while (bServerRunning)

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
    
    g_strctDAQCycle.m_fbClientConnected = true;
    
     fnInitDAQServer();



        while (g_strctDAQCycle.m_fbClientConnected)
            fnDAQServerCycle();
        end;
     

    msclose(g_strctNet.m_iCommSocket);
end;

msclose(g_strctNet.m_iServerSocket);
 PsychPortAudio('Close', g_strctPTB.m_hAudioDevice);
fnStopPTB();
return;

function fnInitStimulusServer()
global g_strctDAQCycle
g_strctDAQCycle.m_fbClientConnected = true;
g_strctDAQCycle.m_fKBCheckTimer = GetSecs();
g_strctDAQCycle.m_fKBCheckTimerRateMS = 1000;
g_strctDAQCycle.m_iNumCycles = 0;
g_strctDAQCycle.m_fCycleTimer = GetSecs();
g_strctDAQCycle.m_fCycleTimerRateMS = 1000;
%g_strctDAQCycle.m_afCycleTime = zeros(1,10000);
g_strctDAQCycle.m_fCurrTime = GetSecs();
g_strctDAQCycle.m_bPaused = false;
g_strctDAQCycle.m_strDrawFunc = [];
g_strctDAQCycle.m_strctDrawParams = [];
g_strctDAQCycle.m_iMachineState = 0;

return;

