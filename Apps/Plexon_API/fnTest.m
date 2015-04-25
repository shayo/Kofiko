function [g_strctPlexon] = fnGetSpikes(g_strctPlexon)
[g_strctPlexon.m_strctLastCheck.m_iTSCount, g_strctPlexon.m_strctLastCheck.m_afTimeStamps] = PL_GetTS(g_strctPlexon.m_iServerID);
%g_strctPlexon.m_strctLastCheck.m_afTimeStamps = raw_ts;
%g_strctPlexon.m_strctLastCheck.m_iTSCount = raw_ts;

end