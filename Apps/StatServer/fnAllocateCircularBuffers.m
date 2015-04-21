function fnAllocateCircularBuffers(iTrialHistoryLength, fMaxTrialLengthSec )
global g_strctNeuralServer

fprintf('Allocating buffers for trials...');
    

% Keep N Trials in time.
fMaxFiringRateHz=300;
g_strctNeuralServer.m_strctBuffer.m_iTrialHistoryLength = iTrialHistoryLength;
g_strctNeuralServer.m_fLastSampleTS = 0;
g_strctNeuralServer.m_strctBuffer.m_iTrialCounter = 1;
g_strctNeuralServer.m_strctBuffer.m_aiTrialType = zeros(1,iTrialHistoryLength);
g_strctNeuralServer.m_strctBuffer.m_afTrialStartTS = NaN*ones(1,iTrialHistoryLength);

g_strctNeuralServer.m_strctBuffer.m_a4fSpikeTS_Buffer = NaN*ones(iTrialHistoryLength, ...
                                                g_strctNeuralServer.m_iNumActiveSpikeChannels,...
                                                g_strctNeuralServer.m_iNumberUnitsPerChannel, ...
                                                fMaxTrialLengthSec * fMaxFiringRateHz);
                                            
g_strctNeuralServer.m_strctBuffer.m_a2iSpikes_NumValidSamples = zeros(g_strctNeuralServer.m_iNumActiveSpikeChannels,g_strctNeuralServer.m_iNumberUnitsPerChannel);


g_strctNeuralServer.m_strctBuffer.m_a2fLFP_TS = NaN*ones(iTrialHistoryLength, g_strctNeuralServer.m_iNumActiveSpikeChannels);
g_strctNeuralServer.m_strctBuffer.m_aiLFP_NumValidSamples  = zeros(1,g_strctNeuralServer.m_iNumActiveSpikeChannels);
  
g_strctNeuralServer.m_strctBuffer.m_a3fLFP_Buffer = NaN*ones(iTrialHistoryLength, ...
                                            g_strctNeuralServer.m_iNumActiveSpikeChannels,...
                                             g_strctNeuralServer.m_fAD_Freq * fMaxTrialLengthSec,'single');

X=whos('g_strctNeuralServer');
fprintf('%d MB were allocated for %d trials and %d channels\n',round(X.bytes/1e6),iTrialHistoryLength,g_strctNeuralServer.m_iNumActiveSpikeChannels);

return;
