function afPlexon_TS = fnKofikoTimeToPlexonTime(strctSession, afKofiko_TS)
if isempty(afKofiko_TS) || isempty(strctSession.m_afPlexonSyncTS) || isempty(strctSession.m_afKofikoSyncTS)
    afPlexon_TS = [];
    return;
end;

if isfield(strctSession,'m_afKofikoSyncTS')
    if length(strctSession.m_afPlexonSyncTS) == 1 % Degenerate case....
        afTimeRelative = afKofiko_TS - strctSession.m_fKofikoStartTS;
        afPlexon_TS = strctSession.m_fPlexonStartTS + afTimeRelative;
    else
        afPlexon_TS = interp1(strctSession.m_afKofikoSyncTS,strctSession.m_afPlexonSyncTS,afKofiko_TS,'linear','extrap');
    end
else
    assert(false);
    afTimeRelative = afKofiko_TS - strctSession.m_fKofikoStartTS;
    afPlexon_TS = afTimeRelative + strctSession.m_fPlexonStartTS + ...
        afTimeRelative * strctSession.m_afKofikoTStoPlexonTS(2) + ...
        strctSession.m_afKofikoTStoPlexonTS(1);
end
return;
