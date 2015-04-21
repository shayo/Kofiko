function fnToggleShowStatistics(a,b)
global g_strctGUIParams g_handles
g_strctGUIParams.m_bShowStat = ~g_strctGUIParams.m_bShowStat;
% if g_strctGUIParams.m_bShowStat
%     set(g_handles.hDrawStatsButton,'fontweight','bold');
% else
%     set(g_handles.hDrawStatsButton,'fontweight','normal');    
% end;

return;