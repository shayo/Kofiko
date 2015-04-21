function afKofiko_TS = fnPlexonTimeToKofikoTime(strctSession, afPlexon_TS)
if isfield(strctSession,'m_afKofikoSyncTS')
    if length(strctSession.m_afKofikoSyncTS) == 1
        afTimeRelative = (afPlexon_TS - strctSession.m_fPlexonStartTS );
        afKofiko_TS  = strctSession.m_fKofikoStartTS + afTimeRelative;    
    else
        afKofiko_TS = interp1(strctSession.m_afPlexonSyncTS,strctSession.m_afKofikoSyncTS,afPlexon_TS,'linear','extrap');
    end
else
    assert(false);
    afTimeRelative = (afPlexon_TS - strctSession.m_fPlexonStartTS - strctSession.m_afKofikoTStoPlexonTS(1))/(1+ strctSession.m_afKofikoTStoPlexonTS(2));
    afKofiko_TS  = strctSession.m_fKofikoStartTS + afTimeRelative;
end
return;
