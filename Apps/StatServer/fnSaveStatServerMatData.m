function fnSaveStatServerMatData() 
global g_strctCycle g_strctConfig g_strctNeuralServer
% Save important stuff to disk....
if ~isempty(g_strctCycle.m_strSessionName)
    strSession = g_strctCycle.m_strSessionName;
else
    strSession = g_strctCycle.m_strTmpSessionName;
end

strOutputInfo = fullfile(g_strctConfig.m_strctDirectories.m_strDataFolder,[strSession,'-StatServerInfo.mat']);
save(strOutputInfo,'g_strctCycle','g_strctNeuralServer','g_strctConfig');
