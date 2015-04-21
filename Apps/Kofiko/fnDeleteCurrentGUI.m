function fnDeleteCurrentGUI()
global g_strctParadigm g_handles

% if ishandle(g_handles.m_strctStatisticsPanel.m_hPanel) && strcmp(get(g_handles.m_strctStatisticsPanel.m_hPanel,'visible'),'on')
%     set(g_handles.m_strctStatisticsPanel.m_hPanel,'visible','off');
% end

if ishandle(g_handles.m_strctSettingsPanel.m_hPanel) && strcmp(get(g_handles.m_strctSettingsPanel.m_hPanel,'visible'),'on')
    set(g_handles.m_strctSettingsPanel.m_hPanel,'visible','off');
end

if isfield(g_strctParadigm,'m_strctControllers') && isfield(g_strctParadigm.m_strctControllers,'m_hPanel') && ...
        ishandle(g_strctParadigm.m_strctControllers.m_hPanel)
    set(g_strctParadigm.m_strctControllers.m_hPanel,'visible','off');
end;
return;
