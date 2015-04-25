function [ErrorB] = fnCheckStrobeConnectivity()
global g_strctPlexon g_strctParadigm

for i = 1:15
    strobeCheck(i) = (2^i)-1;
    fnDAQNI('StrobeWord',	strobeCheck(i));
    delay(.050);
end


[g_strctPlexon.m_strctLastCheck.m_iWFCount, g_strctPlexon.m_strctLastCheck.m_afTimeStamps, g_strctPlexon.m_strctLastCheck.m_afWaveForms] = PL_GetWFEvs(g_strctPlexon.m_iServerID);

if g_strctPlexon.m_strctLastCheck.m_afTimeStamps(g_strctPlexon.m_strctLastCheck.m_afTimeStamps(1,:) == 4,3) ~= strobeCheck'
	error('StrobeWord check failed; strobewords are not being sent to plexon correctly. Abort this experiment and fix this');
	ErrorB =1 ;
	
end
return;



function delay(seconds)
% function pause the program
% seconds = delay time in seconds
tic;
while toc < seconds
end
return;
