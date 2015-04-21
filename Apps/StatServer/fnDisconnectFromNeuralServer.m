function fnDisconnectFromNeuralServer
global g_strctNeuralServer g_strctConfig
fprintf('Disconnecting from neural server...\n');
if ~isempty(g_strctNeuralServer) && g_strctNeuralServer.m_bConnected
    switch g_strctConfig.m_strctNeuralServer.m_strType
        case 'PLEXON'
            PL_Close(g_strctNeuralServer.m_hSocket);
        case 'BLACKROCK'
            cbmex('close');
        otherwise
            assert(false);
    end
end
g_strctNeuralServer.m_bConnected = false;
g_strctNeuralServer.m_hSocket = 0;

return;