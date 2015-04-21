function [astrctTrainInfo,astrctPulseIntervals] = fnIdentifyStimulationTrains(strctTrigger,afTrainTime)
fThreshold = max(strctTrigger.m_afData(:))/5;
if isempty(strctTrigger.m_afData) || fThreshold < 100 
    % Threshold of analog signal should be above 100.
    % if it is below 100 is means there were no pulses....
    astrctTrainInfo = [];
    astrctPulseIntervals = [];
    return;
end

fMinTrainFreq = 10;

fTrainMS = 1/fMinTrainFreq*1e3;  % every inter-event-interval shorter than this value will be merged.
astrctPulseIntervals = fnGetIntervals(strctTrigger.m_afData > fThreshold);
iNumPulses = length(astrctPulseIntervals);
fSamplingFreq = strctTrigger.m_fSamplingFreq;
% Merge intervals that are shorter than X ms
%%
a2iTrains = zeros(0,2);
a2iTrains(1,1) = 1;

iCurrentInd = astrctPulseIntervals(1).m_iEnd;
aiPulseToTrain = zeros(1, iNumPulses);
aiPulseToTrain(1) = 1;
iTrainCounter = 1;
afInterPulseIntervalMS = ones(1, iNumPulses)*NaN;
for k=2:iNumPulses
    fTimeDiffMS = (astrctPulseIntervals(k).m_iStart - iCurrentInd +1) / fSamplingFreq * 1e3;
    if fTimeDiffMS>fTrainMS
        % New train!
        a2iTrains(iTrainCounter,2) = k-1;
        iTrainCounter = iTrainCounter + 1;
        a2iTrains(iTrainCounter,1) = k;
    else
        % Still in the same train. We can compute inter pulse interval
        afInterPulseIntervalMS(k) = fTimeDiffMS;
    end
    aiPulseToTrain(k) = iTrainCounter;
    iCurrentInd = astrctPulseIntervals(k).m_iEnd;
end
% Update last train
if ~isempty(k)
    a2iTrains(end,2) = k;
else
    a2iTrains(1,2) = 1;
end
%%

iNumTrains = iTrainCounter;

aiStartInd = cat(1,astrctPulseIntervals(a2iTrains(:,1)).m_iStart);
aiEndInd = cat(1,astrctPulseIntervals(a2iTrains(:,2)).m_iEnd);
afTrainLengthMS = (aiEndInd-aiStartInd+1)/ fSamplingFreq * 1e3;
% round to the nearest MS. Round to closest number of pulses
aiNumPulsesPerTrain = a2iTrains(:,2)-a2iTrains(:,1)+1;

[UniqueTrains,~,aiMapTrainToUnique] = unique([round(afTrainLengthMS),aiNumPulsesPerTrain],'rows');
iNumTrainTypes = size(UniqueTrains,1);
fprintf('Detected %d trains and %d unique train types:\n',iNumTrains,iNumTrainTypes );

abActive = zeros(1,iNumTrainTypes) > 0;
for iUniqueTrainIter=1:iNumTrainTypes
    NumPulsesForThisTrainType = UniqueTrains(iUniqueTrainIter,2);
    aiRelevantTrains = find(aiMapTrainToUnique == iUniqueTrainIter);
    
    if length(aiRelevantTrains) < 5 
        % Not enough trains to run statistics
        continue;
    end;
    
    abActive(iUniqueTrainIter) = true;
    aiRelevantPulses = aiPulseToTrain(aiRelevantTrains);
    
    afPulseLengthMS = cat(1,astrctPulseIntervals(aiRelevantPulses).m_iLength) / fSamplingFreq * 1e3;
    afInterPulseMS = afInterPulseIntervalMS(aiRelevantPulses);
    fInterPulseMeanMS = nanmean(afInterPulseMS);
    
    if ~isnan(fInterPulseMeanMS)
        fTrainLengthMS = median(afTrainLengthMS(aiRelevantTrains))+fInterPulseMeanMS;
    else
        fTrainLengthMS = median(afTrainLengthMS(aiRelevantTrains));      
    end

       fPulseFreq = round(NumPulsesForThisTrainType/ fTrainLengthMS * 1000);
        
    fprintf('%d Trains found with %d pulses per train (%d Hz). Pulse Length : %.2f +- %.2f ms, IPI = %.2f +- %.2f ms, Train length = %.2f Sec\n',...
        length(aiRelevantTrains) ,NumPulsesForThisTrainType, fPulseFreq,mean(afPulseLengthMS), std(afPulseLengthMS),  mean(afInterPulseMS), std(afInterPulseMS), fTrainLengthMS/1e3);

    astrctTrainInfo(iUniqueTrainIter).m_iNumTrains = length(aiRelevantTrains);
    astrctTrainInfo(iUniqueTrainIter).m_iPulsesPerTrain = NumPulsesForThisTrainType;
    astrctTrainInfo(iUniqueTrainIter).m_afPulseLengthMS = afPulseLengthMS;
    astrctTrainInfo(iUniqueTrainIter).m_afInterPulseMS = afInterPulseMS;
    astrctTrainInfo(iUniqueTrainIter).m_fTrainLengthMS = fTrainLengthMS;
    astrctTrainInfo(iUniqueTrainIter).m_aiTrainOnsetIndices = aiStartInd(aiRelevantTrains);
    astrctTrainInfo(iUniqueTrainIter).m_aiTrainOffsetIndices = aiEndInd(aiRelevantTrains);
    
    astrctTrainInfo(iUniqueTrainIter).m_afTrainOnsetTS_Plexon = afTrainTime(aiStartInd(aiRelevantTrains));
    astrctTrainInfo(iUniqueTrainIter).m_afTrainOffsetTS_Plexon = afTrainTime(aiEndInd(aiRelevantTrains));
    
end
if exist('astrctTrainInfo','var')
astrctTrainInfo=astrctTrainInfo(abActive);
else
    astrctTrainInfo=[];
end;
return;

%{

% Align spikes to trains

% Build raster in 1ms percision.
aiStartTrainInd = cat(1,astrctPulseIntervals(a2iTrains(aiRelevantTrains,1)).m_iStart);
afStartTrainTimestamp = (aiStartTrainInd-1) / fSamplingFreq;
if length(afStartTrainTimestamp) == 1
    % Skip this
    continue;
end;


iBeforeMS = -1000;
iAfterMS  = fTrainLengthMS + 1000;


% Align LFP
iNumTr = length(aiStartTrainInd);

aiPeriStimulusRangeMS = iBeforeMS:iAfterMS;

% Sample LFPs
a2fSampleTimes = zeros(iNumTr, length(aiPeriStimulusRangeMS));
for iTrialIter = 1:iNumTr
    a2fSampleTimes(iTrialIter,:) = afStartTrainTimestamp(iTrialIter)+ aiPeriStimulusRangeMS/1e3;
end;

iSelectedFrame = find( strctPlexon.AD01.m_afTimeStamp0 < afStartTrainTimestamp(1),1,'last');
fSamplingFreq = strctPlexon.AD01.m_fFreq;
afPlexonTime = single(strctPlexon.AD01.m_afTimeStamp0(iSelectedFrame):...
    1/fSamplingFreq:strctPlexon.AD01.m_afTimeStamp0(iSelectedFrame)+...
    (strctPlexon.AD01.m_aiNumSamplesInFragment(iSelectedFrame)-1)*1/fSamplingFreq);

a2fLFPs = single(reshape(interp1(afPlexonTime, strctPlexon.AD01.m_afData(...
    strctPlexon.AD01.m_aiStart(iSelectedFrame):strctPlexon.AD01.m_aiEnd(iSelectedFrame)),a2fSampleTimes(:)),size(a2fSampleTimes)));

afMeanLFP = nanmean(a2fLFPs,1);
afStdLFP =nanstd(a2fLFPs,1);


params.tapers=[3 5];
params.Fs = 1000;

[S,f] = mtspectrumc( a2fLFPs', params );
S=abs(S);
afAvgFreqRes = nanmean(log10(S),2)';
afStdFreqRes = nanstd(log10(S),[],2)';

fGaussianSmoothKernelMS = 15;
afKernel = fspecial('gaussian',[1 7*fGaussianSmoothKernelMS],fGaussianSmoothKernelMS);
for iUnitIter=1:iNumUnits
    [a2bRaster,aiPeriStimulusRangeMS, a2fAvgSpikeForm] = fnRaster(strctPlexon.m_astrctUnits(iUnitIter), afStartTrainTimestamp, iBeforeMS, iAfterMS);
    
    
    [afSpikeAvgBefore, afSpikeAvgDuring, afSpikeAvgAfter , afSpikeStdBefore, afSpikeStdDuring,afSpikeStdAfter] = fnAvgWaveForm(strctPlexon.m_astrctUnits(iUnitIter), afStartTrainTimestamp, fTrainLengthMS, iBeforeMS, iAfterMS);
    
    
    a2bRaster = a2bRaster > 0;
    if sum(a2bRaster(:)) == 0
        % Skip this unit
        continue;
    end;
    
    % smooth raster
    a2fSmoothRaster = conv2(double(a2bRaster), afKernel,'same');
    %
    afPSTH_NotSmooth = mean(double(a2bRaster),1);
    
    afPSTH = mean(a2fSmoothRaster,1);
    afPSTH_Std = std(a2fSmoothRaster,1);
    % Statistics
    afAvgBefore = mean(a2fSmoothRaster(:, aiPeriStimulusRangeMS < 0),2);
    afAvgDuring = mean(a2fSmoothRaster(:, aiPeriStimulusRangeMS > 0 & aiPeriStimulusRangeMS < fTrainLengthMS),2);
    afAvgAfter = mean(a2fSmoothRaster(:,  aiPeriStimulusRangeMS > fTrainLengthMS),2);
    
    [h,p_d_b]=ttest(afAvgBefore,afAvgDuring);
    [h,p_d_a]=ttest(afAvgAfter,afAvgDuring);
    [h,p_b_a]=ttest(afAvgAfter,afAvgBefore);
    
    % Draw
    %             if iFigureIter ~= 15
    %                 iFigureIter = iFigureIter+ 1;
    %                 continue;
    %             end
    figure(iFigureIter);
    %             if iFigureIter ~= 4
    %                 continue;
    %             else
    %                   iFigureIter = iFigureIter + 1;
    %             end;
    drawnow
    clf;
    fnMaximizeWindow(iFigureIter);
    %             drawnow
    %             fnMaximizeWind(iFigureIter);
    %
    
    strDesc = sprintf('Unit %d, %d PPT, %d ms pulse  [Exp : %s]', iUnitIter,aiTrainsUniqueNumPulses(iUniqueTrainIter), round( mean(afPulseLengthMS)),strInputFile);
    set(iFigureIter,'Name', strDesc);
    subplot(3,3,1); hold on;
    imagesc(aiPeriStimulusRangeMS,1:size(a2fSmoothRaster,1), fnDup3(1-a2bRaster));
    axis xy
    xlabel('Time (ms)'); ylabel('Trials ');
    plot([0 0],[1 size(a2fSmoothRaster,1)],'b');
    plot(fTrainLengthMS* [1 1],[1 size(a2fSmoothRaster,1)],'b');
    axis([aiPeriStimulusRangeMS(1) aiPeriStimulusRangeMS(end) 1 size(a2fSmoothRaster,1)])
    box on
    
    subplot(3,3,2);hold on;
    
    imagesc(aiPeriStimulusRangeMS,1:size(a2fSmoothRaster,1), 1e3*a2fSmoothRaster); colormap jet;
    colorbar
    xlabel('Time (ms)'); ylabel('Trials ');
    plot([0 0],[1 size(a2fSmoothRaster,1)],'w');
    plot(fTrainLengthMS* [1 1],[1 size(a2fSmoothRaster,1)],'w');
    axis([aiPeriStimulusRangeMS(1) aiPeriStimulusRangeMS(end) 1 size(a2fSmoothRaster,1)])
    box on
    subplot(3,3,3);hold on;
    fnFancyPlot2(aiPeriStimulusRangeMS, afPSTH*1e3, afPSTH_Std*1e3, [79,129,189]/255,0.5*[79,129,189]/255);
    fMin = min( (afPSTH-afPSTH_Std)*1e3);
    fMax = max( (afPSTH+afPSTH_Std)*1e3);
    box on; grid on;xlabel('Time (ms)'); ylabel('Avg. Firing rate (Hz)');
    axis([aiPeriStimulusRangeMS(1) aiPeriStimulusRangeMS(end) fMin-10 fMax+10])
    % plot train
    fPulseLengthMS = round(mean(afPulseLengthMS));
    fInterPulseIntervalMS = round(mean(afInterPulseMS));
    iNumPulses = aiTrainsUniqueNumPulses(iUniqueTrainIter);
    fHeight =5;
    for iPulseIter=1:iNumPulses                fPulseStartTimeMS = (iPulseIter-1) * (fPulseLengthMS+fInterPulseIntervalMS);
        fPulseEndTimeMS = fPulseStartTimeMS+fPulseLengthMS;
        
        afX = [fPulseStartTimeMS, fPulseEndTimeMS, fPulseEndTimeMS, fPulseStartTimeMS];
        afY = [fMax             , fMax,    fMax+fHeight,             fMax+fHeight];
        fill(afX,afY,'b','edgecolor','none');
    end
    
    
    subplot(3,3,4);hold on;
    plot(aiPeriStimulusRangeMS,1e3*afPSTH_NotSmooth)
    xlabel('Time (ms)');
    ylabel('Firing rate (Hz)');
    
    
    subplot(3,3,5);hold on;
    fMax = max(1e3*[mean(afAvgBefore), mean(afAvgDuring), mean(afAvgAfter)]);
    bar([1:3], 1e3*[mean(afAvgBefore), mean(afAvgDuring), mean(afAvgAfter)]);
    set(gca,'xtick',[1:3],'xticklabel',{'Before','During','After'});
    ylabel('Avg. Firing Rate (Hz)');
    plot([1 2],[fMax*1.1 fMax*1.1],'k','LineWidth',2);
    plot([2 3],[fMax*1.3 fMax*1.3],'k','LineWidth',2);
    plot([1 3],[fMax*1.5 fMax*1.5],'k','LineWidth',2);
    
    text(1.5,fMax*1.25, sprintf('P = %.2f', p_d_b),'fontsize',8);
    text(2.5,fMax*1.35, sprintf('P = %.2f', p_d_a),'fontsize',8);
    text(2.0,fMax*1.55, sprintf('P = %.2f', p_b_a),'fontsize',8);
    axis([0.5 3.5 0 fMax*1.8]);
    box on
    drawnow
    title('Firing Rate');
    
    subplot(3,3,6);hold on;
    fMin = min(afMeanLFP-afStdLFP);
    fMax = max(afMeanLFP+afStdLFP);
    fill([0 fTrainLengthMS fTrainLengthMS 0 ],[fMin fMin fMax fMax],[0.7 0.7 0.7]);
    fnFancyPlot2(aiPeriStimulusRangeMS, afMeanLFP, afStdLFP, [79,129,189]/255,0.5*[79,129,189]/255);
    xlabel('Time (ms)');
    ylabel('LFP Value');
    box on
    grid on
    title('LFP');
    
    
    %
    
    subplot(3,3,7);hold on;
    % power spectrum analysis of LFP and spike?
    fnFancyPlot2(f,afAvgFreqRes ,afStdFreqRes, [79,129,189]/255,0.5*[79,129,189]/255);
    axis([0 200 min(afAvgFreqRes+afStdFreqRes) max(afAvgFreqRes+afStdFreqRes)]);
    
    xlabel('LFP Frequency');
    ylabel('log10 amplitude');
    grid on
    box on
    
    %The ?rst argument is the data matrix in the form of times * trials or
    subplot(3,3,8);hold on;
    afX = [1:length(afSpikeAvgDuring)]/length(afSpikeAvgDuring) * 1000;
    plot(afX, afSpikeAvgBefore, afX, afSpikeAvgDuring,afX, afSpikeAvgAfter,'LineWidth',2);
    legend({'Before','During','After'},'Location','NorthEastOutside');
    xlabel('Time (microsec)');
    ylabel('Amplitude');
    title('Spike Wave Form');
    grid on
    box on
    
    h=tightsubplot(10,1,1);
    set(h,'visible','off');
    strFile = astrctPLXFiles(iFileIter).name;
    strFile(strFile == '_') = ' ';
    strDesc = sprintf('%d) Unit %d, %d PPT, %d ms pulse  [Exp : %s]',iFigureIter, iUnitIter,aiTrainsUniqueNumPulses(iUniqueTrainIter), round( mean(afPulseLengthMS)),strFile);
    text(0.1,0.8,strDesc,'parent',h,'FontSize',19)
    
    set(gcf,'color',[1 1 1]);
    orient(iFigureIter,'portrait');
    drawnow
    drawnow expose
    drawnow update
    print(iFigureIter,'-dpsc','-r100','-painter','-append',OUT_FILE);
    
    iFigureIter = iFigureIter + 1;
    
end
% Display stuff on screen / dump to file



%    % Sample LFPs
%     iNumTrials = length(abValidTrials);
%     a2fSampleTimes = zeros(iNumTrials, length(aiPeriStimulusRangeMS));
%     for iTrialIter = 1:iNumTrials
%         a2fSampleTimes(iTrialIter,:) = afModifiedStimulusON_TS_Plexon(iTrialIter)+ aiPeriStimulusRangeMS/1e3;
%     end;
%
%
%     iSelectedFrame = find(strctPlexon.m_astrctLFP(strctPlexon.m_astrctUnits(iSelectedUnit).m_iChannel).m_afTimeStamp0 < strctSession.m_fPlexonStartTS,1,'last');
%     fSamplingFreq = strctPlexon.m_astrctLFP(strctPlexon.m_astrctUnits(iSelectedUnit).m_iChannel).m_fFreq;
%     afPlexonTime = single(strctPlexon.m_astrctLFP(strctPlexon.m_astrctUnits(iSelectedUnit).m_iChannel).m_afTimeStamp0(iSelectedFrame):...
%         1/fSamplingFreq:strctPlexon.m_astrctLFP(strctPlexon.m_astrctUnits(iSelectedUnit).m_iChannel).m_afTimeStamp0(iSelectedFrame)+...
%         (strctPlexon.m_astrctLFP(strctPlexon.m_astrctUnits(iSelectedUnit).m_iChannel).m_aiNumSamplesInFragment(iSelectedFrame)-1)*1/fSamplingFreq);
%
%     a2fLFPs = single(reshape(interp1(afPlexonTime, strctPlexon.m_astrctLFP(strctPlexon.m_astrctUnits(iSelectedUnit).m_iChannel).m_afData(...
%         strctPlexon.m_astrctLFP(strctPlexon.m_astrctUnits(iSelectedUnit).m_iChannel).m_aiStart(iSelectedFrame):...
%         strctPlexon.m_astrctLFP(strctPlexon.m_astrctUnits(iSelectedUnit).m_iChannel).m_aiEnd(iSelectedFrame)),...
%         a2fSampleTimes(:)),size(a2fSampleTimes)));




end
%%


%}