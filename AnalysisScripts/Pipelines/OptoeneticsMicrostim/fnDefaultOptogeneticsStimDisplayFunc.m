function fnDefaultOptogeneticsStimDisplayFunc(ahPanels, strctData)
dbg = 1;
% set(gcf,'renderer','zbuffer');%painters')

iNumUniqueTrains = length(strctData.m_astrctTrain);

for iTrainIter=1:iNumUniqueTrains
    if isfield( strctData.m_astrctTrain(iTrainIter),'m_a2fXEyePix')
    h=tightsubplot(4,2,8,'Spacing',0.15,'Parent',ahPanels(iTrainIter));
    iNumTrainsWithSteadyEye = size(strctData.m_astrctTrain(iTrainIter).m_a2fXEyePix,1);
    hold on;
    for k=1:iNumTrainsWithSteadyEye
        iCenter=find(strctData.m_astrctTrain(iTrainIter).m_aiPeriStimulusRangeMS == 0);
        afX=strctData.m_astrctTrain(iTrainIter).m_a2fXEyePix(k,iCenter-200:iCenter+400);
        afY=strctData.m_astrctTrain(iTrainIter).m_a2fYEyePix(k,iCenter-200:iCenter+400);
        plot(afX-afX(1),afY-afY(1),'k');
    end
    axis(h,'equal');
    axis([-500 500 -500 500]);
    end
    if sum(strctData.m_astrctTrain(iTrainIter).m_a2fSmoothRaster(:)) < 10
        continue;
    end;
    fTimeScaleFactor = 1e3;
    afX = strctData.m_astrctTrain(iTrainIter).m_aiPeriStimulusRangeMS/fTimeScaleFactor;
    tightsubplot(1,2,1,'Spacing',0.15,'Parent',ahPanels(iTrainIter));
    
    afFiringRateSmooth = mean(strctData.m_astrctTrain(iTrainIter).m_a2fSmoothRaster,1)*1e3;

    plot(afX,afFiringRateSmooth);
    
    fTrainHeight = 0.1*max(ceil(afFiringRateSmooth));
    fSpikesOffset = 1.2*max(ceil(afFiringRateSmooth));
    
    aiInd=find(strctData.m_astrctTrain(iTrainIter).m_a2bRaster);
    [aiTrial,aiSpike]=ind2sub(size(strctData.m_astrctTrain(iTrainIter).m_a2bRaster), aiInd);
    % raster will occupy same space as the the average...
    iNumTrials = size(strctData.m_astrctTrain(iTrainIter).m_a2bRaster,1);
    hold on;
    iRasterLine = 1/iNumTrials*max(ceil(afFiringRateSmooth));
    for iSpikeIter=1:length(aiSpike)
        rectangle('Position',[afX(aiSpike(iSpikeIter)) fSpikesOffset+aiTrial(iSpikeIter)*iRasterLine 1/fTimeScaleFactor iRasterLine ],'facecolor','k');
    end
    
    % Draw the stimulation train.
    fTrainLengthMS = strctData.m_astrctTrain(iTrainIter).m_strctTrain.m_fTrainLengthMS;
    fPulseLengthMS = median(strctData.m_astrctTrain(iTrainIter).m_strctTrain.m_afPulseLengthMS(1,:));
    iPulsesPerTrain = strctData.m_astrctTrain(iTrainIter).m_strctTrain.m_iPulsesPerTrain;
    
    if isfield(strctData.m_astrctTrain(iTrainIter).m_strctTrain,'m_afInterPulseMS')
        fInterPulseInterval = nanmean(strctData.m_astrctTrain(iTrainIter).m_strctTrain.m_afInterPulseMS);
        if isnan(fInterPulseInterval)
            fInterPulseInterval = 0;
        end;
    else
            fInterPulseInterval = 0;
    end
    
    % Build the train for display purposes.
    for k=1:iPulsesPerTrain
          fTimeStart = (k-1)*(fInterPulseInterval+fPulseLengthMS)/fTimeScaleFactor;
          rectangle('Position',[fTimeStart fSpikesOffset-fTrainHeight fPulseLengthMS/fTimeScaleFactor  fTrainHeight ],'facecolor','g','edgecolor','none');
    end
        set(gca,'xlim', [afX(1), afX(end)]);

    set(gca,'ytick',unique(ceil(linspace(0,fSpikesOffset,4))))
    % Significance
    tightsubplot(4,2,2,'Spacing',0.15,'Parent',ahPanels(iTrainIter));
    hold on;
    bar(1:3,[    mean(strctData.m_astrctTrain(iTrainIter).m_afAvgSpikesBefore),    mean(strctData.m_astrctTrain(iTrainIter).m_afAvgSpikesDuring),    mean(strctData.m_astrctTrain(iTrainIter).m_afAvgSpikesAfter)],'facecolor',[74,126,187]/255)
    fMax = max( [mean(strctData.m_astrctTrain(iTrainIter).m_afAvgSpikesBefore)+std(strctData.m_astrctTrain(iTrainIter).m_afAvgSpikesBefore),...
                           mean(strctData.m_astrctTrain(iTrainIter).m_afAvgSpikesDuring)+std(strctData.m_astrctTrain(iTrainIter).m_afAvgSpikesDuring),...
                           mean(strctData.m_astrctTrain(iTrainIter).m_afAvgSpikesAfter)+std(strctData.m_astrctTrain(iTrainIter).m_afAvgSpikesAfter)]);
    
    plot([1 1],mean(strctData.m_astrctTrain(iTrainIter).m_afAvgSpikesBefore)+[-1 1]*std(strctData.m_astrctTrain(iTrainIter).m_afAvgSpikesBefore),'k','linewidth',2)
    plot([2 2],mean(strctData.m_astrctTrain(iTrainIter).m_afAvgSpikesDuring)+[-1 1]*std(strctData.m_astrctTrain(iTrainIter).m_afAvgSpikesDuring),'k','linewidth',2)
    plot([3 3],mean(strctData.m_astrctTrain(iTrainIter).m_afAvgSpikesAfter)+[-1 1]*std(strctData.m_astrctTrain(iTrainIter).m_afAvgSpikesAfter),'k','linewidth',2)
    set(gca,'xtick',1:3,'xticklabel',{'Before','During','After'});
    set(gca,'ylim',[0 1.2*fMax]);
    if log10(strctData.m_astrctTrain(iTrainIter).m_afStatisticalTests(1)) < -4
        text(2,1.1*fMax,'***','color','r','horizontalalignment','center');
    elseif log10(strctData.m_astrctTrain(iTrainIter).m_afStatisticalTests(1)) < -3
        text(2,1.1*fMax,'**','color','r','horizontalalignment','center');
    elseif log10(strctData.m_astrctTrain(iTrainIter).m_afStatisticalTests(1)) < -2
        text(2,1.1*fMax,'*','color','r','horizontalalignment','center');
    end
    
    % SUA/MUA ?  - Waveform
    tightsubplot(4,2,4,'Spacing',0.15,'Parent',ahPanels(iTrainIter));
    hold on;
    iNumSamplesInWaveForm = length(strctData.m_astrctTrain(iTrainIter).m_afAvgWaveFormBefore);
    afWaveFormTimeMicrosec = round(1e3*linspace(0,1,iNumSamplesInWaveForm));
    afBlue =  [74,126,187]/255;
    afRed = [190,75,72]/255;
    
    fnFancyPlot2(afWaveFormTimeMicrosec, strctData.m_astrctTrain(iTrainIter).m_afAvgWaveFormBefore, strctData.m_astrctTrain(iTrainIter).m_afStdWaveFormBefore, afBlue,0.9*afBlue);
    fnFancyPlot2(afWaveFormTimeMicrosec, strctData.m_astrctTrain(iTrainIter).m_afAvgWaveFormDuring, strctData.m_astrctTrain(iTrainIter).m_afStdWaveFormDuring, afRed,0.9*afRed);
    set(gca,'ytick',[]);
    
    % LFP
    
    tightsubplot(4,2,6,'Spacing',0.15,'Parent',ahPanels(iTrainIter));
    hold on;
    N = size(strctData.m_astrctTrain(iTrainIter).m_strctLFP.m_afData,1);
    fnFancyPlot2(  afX,  mean(strctData.m_astrctTrain(iTrainIter).m_strctLFP.m_afData),    std(strctData.m_astrctTrain(iTrainIter).m_strctLFP.m_afData)/sqrt(N),  0.9*afBlue,afBlue);
    set(gca,'ytick',[]);
    set(gca,'xlim', [afX(1), afX(end)]);
    %set(gca,'xtick',linspace(afX(1),afX(end),5));
    
%     tightsubplot(2,2,2,'Spacing',0.05,'Parent',ahPanels(iTrainIter));
%         
%     
%     % Smooth Raster
%     plot(strctData.m_astrctTrain(iTrainIter).m_aiPeriStimulusRangeMS,10+afFiringRateSmooth,'k');
%     
%     xlabel('Time (ms)');
%     ylabel('Firing rate (Hz)');
%     hold on;
%     rectangle('Position',[0 0 strctData.m_astrctTrain(iTrainIter).m_strctTrain.m_fTrainLengthMS 10],'facecolor','g');
%     axis([aiPeriStimulusRangeMS(1) aiPeriStimulusRangeMS(end) 0 1.1*max(mean(a2fSmoothRaster,1)*1e3)]);
%     subplot(1,2,2);
%     imagesc(aiPeriStimulusRangeMS, 1:size(a2fSmoothRaster,1),a2fSmoothRaster);
%     xlabel('Time (ms)');
%     ylabel('Trial');
%     colormap jet
%     hold on;
%     plot([0 0],[0 size(a2fSmoothRaster,1)],'w','LineWidth',2);
%     plot([astrctUniqueTrains(iTrainIter).m_fTrainLengthMS astrctUniqueTrains(iTrainIter).m_fTrainLengthMS],[0 size(a2fSmoothRaster,1)],'w','LineWidth',2);
%     dbg = 1;
%     
    
end
