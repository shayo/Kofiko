function [afPlexonTime] = fnStimulusServerTimeToPlexonTime(SyncTime, strctSession, afStimulusServer_TS)
[afKofikoTime] = fnStimulusServerTimeToKofikoTime(SyncTime, afStimulusServer_TS);
afPlexonTime = fnKofikoTimeToPlexonTime(strctSession,afKofikoTime);


if 0
    % Convert stimulus server timing to plexon timing using the Sync
    % communication method
    if SyncTime.Buffer(1,3) == 0
        afLocalTime = SyncTime.Buffer(2:end,1); % Local time is Kofiko
        afRemoteTime = SyncTime.Buffer(2:end,2); % Remote time is Plexon
        fJitterMS = mean(1e3*SyncTime.Buffer(2:end,3));
    else
        afLocalTime = SyncTime.Buffer(:,1); % Local time is Kofiko
        afRemoteTime = SyncTime.Buffer(:,2); % Remote time is Plexon
        fJitterMS = mean(1e3*SyncTime.Buffer(:,3));
    end
    
    if max(fJitterMS) == 0
        fnWorkerLog('Cannot do this time alignment? It seems like this was run on a touch screen configuration without a stimulus server?!?!?');
        assert(false);
    end
    %afTimeTrans = [afRemoteTime ones(size(afRemoteTime))] \ afLocalTime;
    %afKofikoTime =  afTimeTrans(1)*afStimulusServer_TS + afTimeTrans(2);
    if length(afRemoteTime) == 1
        fOffset = afLocalTime(1)-afRemoteTime(1);
        afKofikoTime =  afStimulusServer_TS+fOffset;%
    else
        afKofikoTime =  interp1(afRemoteTime, afLocalTime, afStimulusServer_TS,'linear','extrap');
    end
end

% %
% % % afTimeRelative = afKofikoTime - strctSession.m_fKofikoStartTS;
% % %
% % % afPlexonTime = afTimeRelative + strctSession.m_fPlexonStartTS + ...
% % %     afTimeRelative * strctSession.m_afKofikoTStoPlexonTS(2) + ...
% % %     strctSession.m_afKofikoTStoPlexonTS(1);

return
