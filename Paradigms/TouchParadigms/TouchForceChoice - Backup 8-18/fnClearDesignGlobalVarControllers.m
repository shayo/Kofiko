function fnClearDesignGlobalVarControllers()
global g_strctParadigm


g_strctParadigm.m_strctRewardControllers.m_iNumElements = 0;
g_strctParadigm.m_strctStimuliControllers.m_iNumElements = 0;
g_strctParadigm.m_strctTimingControllers.m_iNumElements = 0;
g_strctParadigm.m_strctMicroStimControllers.m_iNumElements = 0;

if isfield(g_strctParadigm,'m_strctDesignRunTimeControllers') && ~isempty(g_strctParadigm.m_strctDesignRunTimeControllers)
acControllers = fieldnames(g_strctParadigm.m_strctDesignRunTimeControllers);
for iIter=1:length(acControllers)
    try
        hHandle = getfield(g_strctParadigm.m_strctDesignRunTimeControllers, acControllers{iIter});
        delete(hHandle);
    catch
    end
end
end

g_strctParadigm.m_strctDesignRunTimeControllers = [];

return;
