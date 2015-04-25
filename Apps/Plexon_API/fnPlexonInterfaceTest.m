function [raw_tsCount, raw_ts, x] = fnPlexonInterfaceTest(g_strctPlexon)

bleh = 1

[raw_tsCount, raw_ts] = PL_GetTS(g_strctPlexon.m_iServerID);
switch bleh
	case 1
		x.raw_tsCount = raw_tsCount;
		x.raw_ts = raw_ts;
end