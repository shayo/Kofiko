function bSuccess = fnConnectToNeuralServer()
global g_strctNeuralServer g_strctConfig g_strctWindows
bSuccess = false;
fnStatLog('Attempting to connect to neural server...');
drawnow
switch g_strctConfig.m_strctNeuralServer.m_strType
    case 'PLEXON'
        g_strctNeuralServer = fnInitializePlexonNeuralServer();
    case 'BLACKROCK'
        g_strctNeuralServer = fnInitializeBlackRockNeuralServer();
    otherwise
        assert(false);
end
if isempty(g_strctNeuralServer)
    return;
end;

if g_strctNeuralServer.m_bConnected == true
    fnStatLog('Successful!');
    
    g_strctNeuralServer.m_a2iCurrentActiveUnits = zeros(g_strctNeuralServer.m_iNumActiveSpikeChannels,g_strctNeuralServer.m_iNumberUnitsPerChannel);
    
    g_strctNeuralServer.m_a2cActiveUnitsHistory = cell(g_strctNeuralServer.m_iNumActiveSpikeChannels,g_strctNeuralServer.m_iNumberUnitsPerChannel);
    g_strctNeuralServer.m_a2bLostWarning = zeros(g_strctNeuralServer.m_iNumActiveSpikeChannels,g_strctNeuralServer.m_iNumberUnitsPerChannel) > 0;
    g_strctNeuralServer.m_abChannelsDisplayed = true(1,g_strctNeuralServer.m_iNumActiveSpikeChannels) > 0;
    % Map spike channels to analog channels
else
    fnStatLog('Unsuccessful!!!!!');
    bSuccess = false;
    return;
end
bSuccess = true;
return;