function fnCloseListeningSocket()
global g_strctNet
fprintf('Closing network ports...\n');
if ~isempty(g_strctNet) && g_strctNet.m_iCommSocket > 0
       msclose(g_strctNet.m_iCommSocket);
       g_strctNet.m_iCommSocket = 0;
end
if ~isempty(g_strctNet) &&  g_strctNet.m_iServerSocket > 0
    msclose(g_strctNet.m_iServerSocket );
    g_strctNet.m_iServerSocket = 0;
end;
    
return;