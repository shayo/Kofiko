function a2fMissedSpikeEvents = fnSyncSpikeServerHardwareSoftware(N)
global g_strctServerCycle
afSoftwareTime = zeros(1,N);
afHardwareTime = zeros(1,N);
fStart = GetSecs();
iPlexonSpecialSyncStrobeWord = 32754;

a2fMissedSpikeEvents = [];
for iTrial=1:N
    [n, t] = PL_GetTS(g_strctServerCycle.m_strctPlexonServer.m_hPlexonServer); % Clear buffer
    afSoftwareTime(iTrial) = GetSecs();
    PL_SendUserEventWord(g_strctServerCycle.m_strctPlexonServer.m_hPlexonServer, iPlexonSpecialSyncStrobeWord);

    a2fMissedSpikeEvents = [a2fMissedSpikeEvents;t];

    while (1)
        [n, t] = PL_GetTS(g_strctServerCycle.m_strctPlexonServer.m_hPlexonServer);
        a2fMissedSpikeEvents = [a2fMissedSpikeEvents;t];
        iIndex=find(t(:,1) == 4 & t(:,2) == 257  & t(:,3) == iPlexonSpecialSyncStrobeWord,1,'last');
        if ~isempty(iIndex)
            break;
        end;
    end
    afHardwareTime(iTrial) = t(iIndex,4);
end
fEnd = GetSecs();

afTimeDiff = afHardwareTime-afSoftwareTime;
fMeanTimeDifference = median(afTimeDiff);
afTimeDiff0 = afTimeDiff-fMeanTimeDifference;
fJitterMS = std(afTimeDiff0)*1e3;

g_strctServerCycle.m_strctPlexonServer.m_strctSync.m_fSyncTS_PTB = (fEnd-fStart)/2+fStart;
g_strctServerCycle.m_strctPlexonServer.m_strctSync.m_fTimerOffset = fMeanTimeDifference; 
g_strctServerCycle.m_strctPlexonServer.m_strctSync.m_fJitterMS = fJitterMS;
% i.e.
% PTB Time = TimeOffset + Hardware Time

return;
