function strctNeuralServer = fnInitializeBlackRockNeuralServer()

strctNeuralServer.m_bConnected = false;


try
    strctNeuralServer.m_hSocket = cbmex('open');
    cbmex('trialconfig', 1);
catch
    strctNeuralServer.m_hSocket  = 0;
end
if strctNeuralServer.m_hSocket  == 0
    fprintf('Connection Failed!\n');
    return;
end
% Query number of channels, etc...
strctNeuralServer.m_iNumSpikeChannels = 16;
strctNeuralServer.m_iNumberUnitsPerChannel = 4;
strctNeuralServer.m_iNumChannels = 16;
strctNeuralServer.m_fAD_Freq = 2000;
strctNeuralServer.m_aiEnabledChannels = 1:16;
strctNeuralServer.m_iNumActiveSpikeChannels =  1:16;
strctNeuralServer.m_bConnected = true;
return;
