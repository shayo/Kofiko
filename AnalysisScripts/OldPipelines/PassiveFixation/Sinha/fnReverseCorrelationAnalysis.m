

aiNoiseInd = strctStimulusParams.m_aiNoiseIndex;

afStimulusOnsets = afModifiedStimulusON_TS_Plexon(abValidTrials);
iNumValidStimuli = length(afStimulusOnsets);
avgNoise = mean(strctTmp.a2fRand(:,:,aiNoiseInd),3);

iUnitIter = 2;

aiSpikeInd = find(strctPlexon.m_astrctUnits(iUnitIter).m_afTimestamps >=  afStimulusOnsets(1) & ...
                  strctPlexon.m_astrctUnits(iUnitIter).m_afTimestamps <=  afStimulusOnsets(end));
afSpiketimes = strctPlexon.m_astrctUnits(iUnitIter).m_afTimestamps(aiSpikeInd);
iNumSpikes = length(aiSpikeInd);

% Reverse correlation parameters
fBinQuantizerMS = 5;
afTimeMS = 0:fBinQuantizerMS:500; % 100 bins, 5ms
iNumBins = length(afTimeMS);

a3fAvgStimulus = zeros( size(avgNoise,1),size(avgNoise,2),iNumBins,'single');
aiNumSamplesInBin = zeros(1,iNumBins);
% We can do this either by looping spikes or images...
for k=1:iNumValidStimuli
    aiSpikesIndLocal = find(afSpiketimes  >= afStimulusOnsets(k) & afSpiketimes <= afStimulusOnsets(k)+ afTimeMS(end)/1e3);
    aiBins = 1+round((afSpiketimes(aiSpikesIndLocal) - afStimulusOnsets(k)) / (fBinQuantizerMS/1e3));
    a2fNoise = strctTmp.a2fRand(:,:, aiNoiseInd(k));
    a3fAvgStimulus(:,:,aiBins) = a3fAvgStimulus(:,:,aiBins) + repmat(a2fNoise,[1,1,length(aiBins)]);
    aiNumSamplesInBin(aiBins) = aiNumSamplesInBin(aiBins) + 1;
end

for k=1:iNumBins
    a3fAvgStimulus(:,:,k) = a3fAvgStimulus(:,:,k) / aiNumSamplesInBin(k);
end

figure(10);clf;
for k=1:100
    tightsubplot(10,10,k)
    imagesc(a3fAvgStimulus(:,:,k));
end
colormap gray

%%

aiVec = 1:6000;
NumPos = 1800;
aiRandInd = aiVec(randperm(NumPos));
a2fPpos = zeros(100,100);
a2fM = zeros(100,100);
a2fS = zeros(100,100);
for i=1:100
    for j=1:100
        A = squeeze(strctTmp.a2fRand(i,j,:));
        a2fM(i,j) = mean(A(:));
        a2fS(i,j) = std(A(:));
        
      [h1,a2fPpos(i,j)]=ztest(squeeze(strctTmp.a2fRand(i,j,aiRandInd)),  a2fM(i,j), a2fS(i,j));
    end;
end;

figure(10);
clf;


%%

