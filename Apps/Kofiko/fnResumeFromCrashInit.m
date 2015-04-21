function fnResumeFromCrashInit()
global g_iCurrParadigm g_iNextParadigm g_bAppIsRunning g_astrctAllParadigms g_strctParadigm
fnShowPTB();
g_strctParadigm.m_iMachineState = 0;
g_astrctAllParadigms{g_iCurrParadigm} = g_strctParadigm;


while (g_bAppIsRunning)
    fnRunParadigm();
    g_iCurrParadigm = g_iNextParadigm;
end;

fnLog('Exitting Kofiko');
fnShutDown();
return;

