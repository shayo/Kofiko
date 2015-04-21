function fnUpdateConditionList()
global g_strctCycle g_strctWindows
NumConditions = length(g_strctCycle.m_strctTrialBufferOpt.ConditionNames);
a2cData = cell(NumConditions,4);
for k=1:NumConditions
    a2cData{k,1} = g_strctCycle.m_strctTrialBufferOpt.ConditionNames{k};
    a2cData{k,2} = g_strctCycle.m_abDisplayConditions(k)>0;
    a2cData{k,3} = g_strctCycle.m_abDisplayConditionsRaster(k) > 0;
    R=(round(255*g_strctCycle.m_a2fConditionColors(k,1)));
    G=(round(255*g_strctCycle.m_a2fConditionColors(k,2)));
    B=(round(255*g_strctCycle.m_a2fConditionColors(k,3)));
    a2cData{k,4} = sprintf('<html><span style="background-color: #%02X%02X%02X;"> _________  </span></html>',R,G,B);
end
set(g_strctWindows.m_strctSettingsPanel.m_hConditionTable,'Data',a2cData);
