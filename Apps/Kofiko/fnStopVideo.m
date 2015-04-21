function fnStopVideo()
global g_strctAppConfig
if ~isempty(g_strctAppConfig.m_hVideoGrabber)
    stop(g_strctAppConfig.m_hVideoGrabber);
    g_strctAppConfig.m_hVideoGrabber = [];
end
