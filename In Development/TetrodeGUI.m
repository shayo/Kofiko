g_strctNeuralServer= fnInitializePlexonNeuralServer();

%%
 iNumChannels = 16;
  a2iTetrodeChannelTable = [1,2,3,4;5,6,7,8];
 iNumTetrodes = size(a2iTetrodeChannelTable,1);
abTetrodeChannels = zeros(1,1+iNumChannels )>0;
abSingleChannels = zeros(1,1+iNumChannels )>0;
abTetrodeChannels(1+a2iTetrodeChannelTable(:)) = true;
abSingleChannels(1+ setdiff(1:iNumChannels, a2iTetrodeChannelTable(:))) = true;

 %% Allocate circular buffer
 iNumSpikesPerSingleChannel = 1000;
 iNumSpikesPerTetrodeChannel = 1000;
 iWaveFormPoints = 40;
 
 a3iSingleCircularBuffer = zeros(iNumChannels, iNumSpikesPerSingleChannel,iWaveFormPoints+1,'int16'); % Last wave form point will be ID assignment
 a3iTetrodeCircularBuffer = zeros(iNumTetrodes, iNumSpikesPerTetrodeChannel,4*iWaveFormPoints+1,'int16'); % Last wave form point will be ID assignment
 aiSingleBufferPos = ones(1, iNumChannels);
 aiTetrodeBufferPos = ones(1, iNumChannels);

 aiSingleBufferNumSamples = ones(1, iNumChannels);
 aiTetrodeBufferNumSamples = ones(1, iNumChannels);
 
%%
 res = PL_WaitForServer(g_strctNeuralServer.m_hSocket, 100);
[NumSpikeAndStrobeEvents, a2fSpikeAndEvents, a2fWaveForms] =PL_GetWFEvs(g_strctNeuralServer.m_hSocket); 
%%

aiChRaw = a2fSpikeAndEvents(:,2);
abTetrodeEvent = abTetrodeChannels(aiChRaw+1);
abSingleElectrodeEvent = abSingleChannels(aiChRaw+1);
%% Handle Single spike data
aiSingleCh = aiChRaw(abSingleElectrodeEvent);
afSingleTS = a2fSpikeAndEvents(abSingleElectrodeEvent,4);

%% Handle tetrode data
aiCh = aiChRaw(abTetrodeEvent);
afTS = a2fSpikeAndEvents(abTetrodeEvent,4);
[afSortedTetrode_TS, aiInd]=sort(afTS);
aiSortedTetrodeCh = aiCh(aiInd);
a2fTetrodeWaves = a2fWaveForms(abTetrodeEvent,:);
a2fSortedWaveForms =a2fTetrodeWaves(aiInd,:);

[a2iTetrodeEventToTetrodeNumber, a2fGrouppedWaves] = GroupChannelsToTetrode(afSortedTetrode_TS,aiSortedTetrodeCh, a2fSortedWaveForms,a2iTetrodeChannelTable);
afTetrodeEventTS = afSortedTetrode_TS(a2iTetrodeEventToTetrodeNumber(1,:));
 
%% Update Buffers


%% Spike sorting....


%% Update circular buffer


%%

f=figure(1);
clf
h=tightsubplot(1,1,1);

%%
    abStrobes = a2fSpikeAndEvents(:,1) == 4;
    a2fSpikeAndEvents(abStrobes,3) = a2fSpikeAndEvents(abStrobes,3) + 32768;

    
    
%%    
    
[NumAnalog, afAnalogTime, a2fLFP] = PL_GetADVEx(g_strctNeuralServer.m_hSocket);
NumActiveChannels = g_strctNeuralServer.m_iNumActiveSpikeChannels;


if NumAnalog(1) == 0
    a2fLFP = zeros(0, NumActiveChannels);
else
    a2fLFP = a2fLFP(:,g_strctNeuralServer.m_aiSpikeToAnalogMapping);
    afAnalogTime =afAnalogTime(1);%g_strctNeuralServer.m_aiSpikeToAnalogMapping);
    
end;
