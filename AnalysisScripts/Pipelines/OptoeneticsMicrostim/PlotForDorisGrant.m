strctChR2 = load('D:\Data\Doris\Electrophys\Bert\Optogenetics\111216\RAW\..\Processed\Optogenetic_Analysis\Bert_111216_161304_Ch_001_Interval_004_Standard_Train_Analysis.mat');    
strctHalo= load('D:\Data\Doris\Electrophys\Bert\Optogenetics\111212\RAW\..\Processed\Optogenetic_Analysis\Bert_111212_144722_Ch_001_Interval_012_Standard_Train_Analysis.mat');    

figure(11);
clf;
subplot(2,2,1);
imagesc(strctChR2.strctUnitInterval.m_astrctTrain(1).m_aiPeriStimulusRangeMS, 1:size(strctChR2.strctUnitInterval.m_astrctTrain(1).m_a2fSmoothRaster,1), 1e3*strctChR2.strctUnitInterval.m_astrctTrain(1).m_a2fSmoothRaster);
xlabel('Time (ms)');
ylabel('Trial');
colorbar
title('Single unit recorded from ChR2 site');
set(gca,'xlim',[-1000 2000]);
subplot(2,2,2);
imagesc(strctHalo.strctUnitInterval.m_astrctTrain(1).m_aiPeriStimulusRangeMS,1:size(strctHalo.strctUnitInterval.m_astrctTrain(1).m_a2fSmoothRaster,1),1e3*strctHalo.strctUnitInterval.m_astrctTrain(1).m_a2fSmoothRaster);
xlabel('Time (ms)');
ylabel('Trial');    
colorbar
title('Single unit recorded from eNpHR 3.0 site');
set(gca,'xlim',[-1000 2000]);
subplot(2,2,3);
plot(strctChR2.strctUnitInterval.m_astrctTrain(1).m_aiPeriStimulusRangeMS,  1e3*mean(strctChR2.strctUnitInterval.m_astrctTrain(1).m_a2fSmoothRaster,1),'k');
xlabel('Time (ms)');
ylabel('Firing rate (Hz)');    
set(gca,'xlim',[-1000 2000]);
subplot(2,2,4);
plot(strctHalo.strctUnitInterval.m_astrctTrain(1).m_aiPeriStimulusRangeMS,  1e3*mean(strctHalo.strctUnitInterval.m_astrctTrain(1).m_a2fSmoothRaster,1),'k');
xlabel('Time (ms)');
ylabel('Firing rate (Hz)');    
set(gca,'xlim',[-1000 2000]);

%%

astrctChR2 = dir('D:\Data\Doris\Electrophys\Bert\Optogenetics\111216\Processed\Optogenetic_Analysis\*.mat');
clear acUnits
for iIter=1:length(astrctChR2)
    strctTmp = load(['D:\Data\Doris\Electrophys\Bert\Optogenetics\111216\Processed\Optogenetic_Analysis\', astrctChR2(iIter).name]);
    acUnits{iIter} = strctTmp.strctUnitInterval;
end

astrctHalo = dir('D:\Data\Doris\Electrophys\Bert\Optogenetics\111212\Processed\Optogenetic_Analysis\*.mat');
clear acUnits2
for iIter=1:length(astrctHalo)
    strctTmp = load(['D:\Data\Doris\Electrophys\Bert\Optogenetics\111212\Processed\Optogenetic_Analysis\', astrctHalo(iIter).name]);
    acUnits2{iIter} = strctTmp.strctUnitInterval;
end

figure(12);
clf;
subplot(1,2,1);hold on;
iCounter = 1;
for k=1:length(acUnits)
    for j=1:length(acUnits{k}.m_astrctTrain)
        fBeforeMean = mean(acUnits{k}.m_astrctTrain(j).m_afAvgSpikesBefore);
        fBeforeStd = std(acUnits{k}.m_astrctTrain(j).m_afAvgSpikesBefore);
        
        fDuringMean = mean(acUnits{k}.m_astrctTrain(j).m_afAvgSpikesDuring);
        fDuringStd= std(acUnits{k}.m_astrctTrain(j).m_afAvgSpikesDuring);

        fAfterMean = mean(acUnits{k}.m_astrctTrain(j).m_afAvgSpikesAfter);
        fAfterStd= std(acUnits{k}.m_astrctTrain(j).m_afAvgSpikesAfter);
        
        [h,pValue] = ttest(acUnits{k}.m_astrctTrain(j).m_afAvgSpikesBefore, acUnits{k}.m_astrctTrain(j).m_afAvgSpikesDuring);
        afPValueBefDur(iCounter) = pValue;
        if pValue < 0.01
            plot([0 1],[fBeforeMean fDuringMean],'b');
        else
            plot([0 1],[fBeforeMean fDuringMean],'k');
        end
        
[h,pValue] = ttest(acUnits{k}.m_astrctTrain(j).m_afAvgSpikesDuring, acUnits{k}.m_astrctTrain(j).m_afAvgSpikesAfter);
        afPValueDurAfter(iCounter) = pValue;
        
        if pValue < 0.01
            plot([1 2],[ fDuringMean fAfterMean],'b');
        else
            plot([1 2],[ fDuringMean fAfterMean],'k');
        end
        
        iCounter=iCounter+1;
    end
end
box on
set(gca,'xtick',[0 1 2],'xticklabel',{'Before','During','After'});
ylabel('Firing rate (Hz)');
title('Population from ChR2 Site');

sum(afPValueBefDur<0.01)

sum(afPValueDurAfter<0.01)

length(afPValueBefDur)

subplot(1,2,2);hold on;
iCounter=1;
for k=1:length(acUnits2)
    for j=1:length(acUnits2{k}.m_astrctTrain)
        fBeforeMean = mean(acUnits2{k}.m_astrctTrain(j).m_afAvgSpikesBefore);
        fBeforeStd = std(acUnits2{k}.m_astrctTrain(j).m_afAvgSpikesBefore);
        
        fDuringMean = mean(acUnits2{k}.m_astrctTrain(j).m_afAvgSpikesDuring);
        fDuringStd= std(acUnits2{k}.m_astrctTrain(j).m_afAvgSpikesDuring);

        fAfterMean = mean(acUnits2{k}.m_astrctTrain(j).m_afAvgSpikesAfter);
        fAfterStd= std(acUnits2{k}.m_astrctTrain(j).m_afAvgSpikesAfter);
        
        [h,pValue] = ttest(acUnits2{k}.m_astrctTrain(j).m_afAvgSpikesBefore, acUnits2{k}.m_astrctTrain(j).m_afAvgSpikesDuring);
             afPValueBefDur(iCounter) = pValue;
   
        if pValue < 0.01
            plot([0 1],[fBeforeMean fDuringMean],'b');
        else
            plot([0 1],[fBeforeMean fDuringMean],'k');
        end
        
[h,pValue] = ttest(acUnits2{k}.m_astrctTrain(j).m_afAvgSpikesDuring, acUnits2{k}.m_astrctTrain(j).m_afAvgSpikesAfter);
        
        if pValue < 0.01
            plot([1 2],[ fDuringMean fAfterMean],'b');
        else
            plot([1 2],[ fDuringMean fAfterMean],'k');
        end
        iCounter=iCounter+1;
    end
end
box on
set(gca,'xtick',[0 1 2],'xticklabel',{'Before','During','After'});
ylabel('Firing rate (Hz)');
title('Population from eNpHR 3.0 Site');
