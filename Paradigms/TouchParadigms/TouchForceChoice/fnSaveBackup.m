function fnSaveBackup()
global g_strctParadigm g_strctDynamicStimLog g_strctCycle


if  g_strctParadigm.m_bMicroStimThisTrial 
	% append the microstim results
	g_strctParadigm.m_strctCurrentTrial.m_strctTrialOutcome.m_strctMicroStimTimes = ...
	g_strctCycle.m_strctMicroStim.m_astrctTriggeringMachines;
end
g_strctDynamicStimLog(end+1).TrialLog = g_strctParadigm.m_strctCurrentTrial;


g_strctParadigm.m_strctLogVars.m_iLogEntryCounter = g_strctParadigm.m_strctLogVars.m_iLogEntryCounter + 1;
if g_strctParadigm.m_strctLogVars.m_iLogEntryCounter > g_strctParadigm.m_strctLogVars.m_iLogCounterBeforeSave
    
    
    g_strctParadigm.m_strctLogVars.m_iLogEntryCounter = 0;

    g_strctParadigm.m_strctLogVars.m_iLogSaves = g_strctParadigm.m_strctLogVars.m_iLogSaves+1;
    save([g_strctParadigm.m_strLogPath,'\',g_strctParadigm.m_strExperimentName,...
        '\',g_strctParadigm.m_strExperimentName,'-',num2str(g_strctParadigm.m_strctLogVars.m_iLogSaves)],'g_strctDynamicStimLog');
    g_strctDynamicStimLog = [];
end



return;
