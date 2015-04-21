function fnSpikeServerCycle()
global g_strctServerCycle g_strctNet

fCurrTime = GetSecs;
% 
% % Sync hardware - software... Expect a jitter of ~ 0.3-1 ms
% if fCurrTime - g_strctServerCycle.m_fSyncTimer > g_strctServerCycle.m_fSyncHardwareSoftwareSec
%     a2fMissedSpikeEvents = fnSyncSpikeServerHardwareSoftware(1);
%     g_strctServerCycle.m_fSyncTimer = fCurrTime;
% else
%     a2fMissedSpikeEvents = [];
% end

% Check for keyboard...
if fCurrTime-g_strctServerCycle.m_fKBCheckTimer > g_strctServerCycle.m_fKBCheckTimerRateMS/1e3
    g_strctServerCycle.m_fKBCheckTimer = fCurrTime;
    [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
    if keyIsDown && keyCode(27)
        fnLog('Stopping server');
        g_strctServerCycle.m_fbClientConnected = false;
        return;
    end;
end


%% Handle incoming commands...
acInputFromKofiko = msrecv(g_strctNet.m_iCommSocket,0);
if ~isempty(acInputFromKofiko)
    strCommand = acInputFromKofiko{1};
    
    switch strCommand
        case 'Ping'
            % Send Pong
            fRandomNumber = acInputFromKofiko{2};
            mssend(g_strctNet.m_iCommSocket,{'Pong',fRandomNumber});
        case 'Echo'
            % Send Pong
            mssend(g_strctNet.m_iCommSocket, acInputFromKofiko{2:end});
        case 'PingGetSecs'
            % Used to sync clocks between stimulus server and kofiko
            iNumPings = acInputFromKofiko{2};
            fTimeoutSec = 20;
            for k=1:iNumPings
                acInputFromKofiko = msrecv(g_strctNet.m_iCommSocket,fTimeoutSec);
                mssend(g_strctNet.m_iCommSocket,{'PongGetSecs',GetSecs()});
            end
        case 'CloseConnection'
            g_strctServerCycle.m_fbClientConnected = false;
    end
end;


return;


