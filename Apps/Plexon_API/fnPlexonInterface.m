function [g_strctPlexon, raw_tsCount, raw_ts] = fnPlexonInterface(g_strctPlexon, command, varargin)


raw_ts = [];
raw_tsCount = [];
%[raw_tsCount, raw_ts] = PL_GetTS(g_strctPlexon.m_iServerID);

%[raw_tsCount, raw_ts] = deal([]);
%switch command
	%case 'GetSpikes'
		g_strctPlexon.m_afCounts = [];
		
        raw_spk = PL_GetSpikeCounts(g_strctPlexon.m_iServerID);
        [raw_tsCount, raw_ts] = PL_GetTS(g_strctPlexon.m_iServerID);
		disp(raw_spk(1:2))
		size(raw_tsCount)
        size(raw_ts)
        g_strctPlexon.m_strctLastCheck.m_afCounts = raw_spk;
        g_strctPlexon.m_strctLastCheck.m_iTS_count = raw_tsCount;
        g_strctPlexon.m_strctLastCheck.m_afTimeStamps = raw_ts;
        
		%[g_strctPlexon.m_strctLastCheck.m_iSpikeAndStrobeEvents, g_strctPlexon.m_strctLastCheck.m_afSpikeAndEvents, g_strctPlexon.m_strctLastCheck.m_afWaveForms] =...
		%	PL_GetWFEvs(g_strctPlexon.m_iServerID);
	
	%case 'Init'
		%g_strctPlexon.m_iServerID = [];
		%serverID = PL_InitClient(0);
		%g_strctPlexon.m_iServerID = serverID;
		
	%case 'Close'
		%PL_Close(g_strctPlexon.m_iServerID);

%end

return;