
[b, strTargetA]=fnFindAttribute(acData{1}.strctUnit.m_a2cAttributes,'Target');
[b, strTargetB]=fnFindAttribute(acData{2}.strctUnit.m_a2cAttributes,'Target');
%%
afSpikesA = acData{1}.strctUnit.m_afSpikeTimes;
afSpikesB = acData{2}.strctUnit.m_afSpikeTimes;

fBinSizeMS = 1;

fBlockLengthMS = 1000;
iNumSurrogate =500;
fWindowMS = 500;

a2fSurrogateSpikes = fnGenerateSurrogateShuffleTrains(afSpikesB, fBlockLengthMS, iNumSurrogate) ;
[afCrossCorrelogram, afBinCenter] = CrossCorrelogram(afSpikesA, afSpikesB, fWindowMS, fBinSizeMS);
iNumBins = length(afBinCenter);
a2fCrossCorrelogramShiftPred = zeros(iNumSurrogate, length(afBinCenter));
for k=1:iNumSurrogate
    [a2fCrossCorrelogramShiftPred(k,:), afBinCenter] = CrossCorrelogram(afSpikesA, a2fSurrogateSpikes(k,:), fWindowMS, fBinSizeMS);
end
a2fSortedBootstrap=sort(a2fCrossCorrelogramShiftPred,1);
%%
fSigValue = 0.01;
afDummy = linspace(0,1, iNumSurrogate);
afLowerConfidence = zeros(1, iNumBins);
afUpperConfidence = zeros(1, iNumBins);
for k=1:iNumBins
    afTmp= interp1(afDummy,a2fSortedBootstrap(:,k), [fSigValue, 1-fSigValue]);
    afLowerConfidence(k) = afTmp(1);
    afUpperConfidence(k) = afTmp(2);
end

fNormFactor = 1/length(afSpikesA)/ (fBinSizeMS/1e3);
figure(2);clf;hold on;
plot(afBinCenter,afCrossCorrelogram*fNormFactor);

plot(afBinCenter,afLowerConfidence*fNormFactor,'r--');
plot(afBinCenter,afUpperConfidence*fNormFactor,'r--');
%plot(afBinCenter,a2fCrossCorrelogramShiftPred(1,:),'k');
%legend(sprintf('0 = spike at %s',strTargetA),'Location','NorthEastOutside');

xlabel('Time (ms), 0 = Spike at ML');
ylabel('Firing rate (Hz)');
plot([0 0 ],[min((afCrossCorrelogram)*fNormFactor) max((afCrossCorrelogram)*fNormFactor)],'k--');
axis([-fWindowMS+5 fWindowMS-5 min((afCrossCorrelogram-afLowerConfidence)*fNormFactor) max((afCrossCorrelogram+afUpperConfidence)*fNormFactor)])

set(gcf,'color',[1 1 1]);
box on