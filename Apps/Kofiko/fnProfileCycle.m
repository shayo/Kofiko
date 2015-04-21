function fnProfileCycle
global g_strctCycle g_strctGUIParams
fnShowPTB();
g_strctCycle.m_bRefreshScreen = true;
A = g_strctGUIParams.m_fRefreshRateMS ;
%g_strctGUIParams.m_fRefreshRateMS = 0;
profile on -timer real

iNumCycles = 10000;
for k=1:iNumCycles
    fnKofikoCycleClean();
end;
g_strctCycle.m_bRefreshScreen = true;
g_strctGUIParams.m_fRefreshRateMS = A;
profile off
profile viewer
fnHidePTB();
return;    