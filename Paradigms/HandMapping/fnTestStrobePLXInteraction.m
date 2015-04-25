function g_strctPlexon = fnTestStrobePLXInteraction()
global g_strctPlexon
fnDAQNI('Init',0);
[g_strctPlexon.m_iServerID] = PL_InitClient(0);

for i = 1:100
fnDAQNI('StrobeWord',i);
WaitSecs(.01);
end
fnGetSpikesFromPlexon();








return;





