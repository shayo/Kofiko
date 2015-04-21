function fnDefaultForceChoiceNeuralDisplay(ahPanels, strctUnit)


a2cTrialsOfInterest= ...
    {'SaccadeTaskRight','MicrostimSaccadeTaskRight';...                             %1
    'SaccadeTaskLeft','MicrostimSaccadeTaskLeft';...                                  %2
    'SaccadeTaskUp','MicrostimSaccadeTaskUp';...                                     %3
    'SaccadeTaskDown','MicrostimSaccadeTaskDown';...                            %4
    'SaccadeTaskRightUp','MicrostimSaccadeTaskRightUp';...                      %5
    'SaccadeTaskRightDown','MicrostimSaccadeTaskRightDown';...          %6
    'SaccadeTaskLeftUp','MicrostimSaccadeTaskLeftUp';...                            %7
    'SaccadeTaskLeftDown','MicrostimSaccadeTaskLeftDown'};                      %8

hParent = ahPanels(1);
acTrialsOfInterest = a2cTrialsOfInterest(:,1);
fnDefaultForceChoiceNeuralDisplayAux(strctUnit, acTrialsOfInterest,hParent )
hParent = ahPanels(2);
acTrialsOfInterest = a2cTrialsOfInterest(:,2);
fnDefaultForceChoiceNeuralDisplayAux(strctUnit, acTrialsOfInterest,hParent )
return;

function fnDefaultForceChoiceNeuralDisplayAux(strctUnit, acTrialsOfInterest,hParent )

for iTrialOfInterestIter =1:length(acTrialsOfInterest)
    iTrialTypeIndex = find(ismember(lower(strctUnit.m_acTrialNames), lower(acTrialsOfInterest{iTrialOfInterestIter}))) ;
    iTrialOutcomeIndex = find(ismember(strctUnit.m_acUniqueOutcomes,'Correct'));
    
    iNumTrialsSameType = strctUnit.m_a2iNumTrials(iTrialTypeIndex,iTrialOutcomeIndex);
    if iNumTrialsSameType == 0
        continue;
    end;
    tightsubplot(8,4, (iTrialOfInterestIter-1)*4+1,'Spacing',0.05,'Parent',hParent);
    hold on;
    imagesc(strctUnit.m_a2cTrialStats{iTrialTypeIndex, iTrialOutcomeIndex}.m_strctRasterCue.m_aiRasterTimeMS,...
        1:iNumTrialsSameType,...
        strctUnit.m_a2cTrialStats{iTrialTypeIndex, iTrialOutcomeIndex}.m_strctRasterCue.m_a2fSmoothRaster);
    axis([strctUnit.m_a2cTrialStats{iTrialTypeIndex, iTrialOutcomeIndex}.m_strctRasterCue.m_aiRasterTimeMS([1 end]) 1 iNumTrialsSameType])
    for k=1:iNumTrialsSameType
        plot(1e3*strctUnit.m_a2cTrialStats{iTrialTypeIndex, iTrialOutcomeIndex}.m_strctRasterCue.m_afCueOnset(k)*ones(1,2),[k-0.5 k+0.5],'g','LineWidth',2);
        plot(1e3*strctUnit.m_a2cTrialStats{iTrialTypeIndex, iTrialOutcomeIndex}.m_strctRasterCue.m_afChoicesOnset(k)*ones(1,2),[k-0.5 k+0.5],'r','LineWidth',2);
        plot(1e3*strctUnit.m_a2cTrialStats{iTrialTypeIndex, iTrialOutcomeIndex}.m_strctRasterCue.m_afTrialEnd(k)*ones(1,2),[k-0.5 k+0.5],'m','LineWidth',2);
    end
    title(acTrialsOfInterest{iTrialOfInterestIter});
    tightsubplot(8,4, (iTrialOfInterestIter-1)*4+2,'Spacing',0.05,'Parent',hParent);
    afAvgFiringRateCue = nanmean(strctUnit.m_a2cTrialStats{iTrialTypeIndex, iTrialOutcomeIndex}.m_strctRasterCue.m_a2fSmoothRaster,1);
    afAvgFiringRateSaccade =nanmean(strctUnit.m_a2cTrialStats{iTrialTypeIndex, iTrialOutcomeIndex}.m_strctRasterSaccade.m_a2fSmoothRaster,1);
    
    
    fMaxFiringRate = max([afAvgFiringRateCue,afAvgFiringRateSaccade]);
    
    hold on;
    fMemoryPeriodSec = mean(strctUnit.m_a2cTrialStats{iTrialTypeIndex, iTrialOutcomeIndex}.m_strctRasterCue.m_afChoicesOnset);
    plot(fMemoryPeriodSec*ones(1,2)*1e3,[0 fMaxFiringRate],'r');
    plot(0*ones(1,2)*1e3,[0 fMaxFiringRate],'g');
    
    plot(strctUnit.m_a2cTrialStats{iTrialTypeIndex, iTrialOutcomeIndex}.m_strctRasterCue.m_aiRasterTimeMS, afAvgFiringRateCue);
    axis([strctUnit.m_a2cTrialStats{iTrialTypeIndex, iTrialOutcomeIndex}.m_strctRasterCue.m_aiRasterTimeMS([1,end]), 0 1.1*fMaxFiringRate]);
    title('0 = Cue Onset');
    tightsubplot(8,4, (iTrialOfInterestIter-1)*4+3,'Spacing',0.05,'Parent',hParent);
    hold on;
    imagesc(strctUnit.m_a2cTrialStats{iTrialTypeIndex, iTrialOutcomeIndex}.m_strctRasterSaccade.m_aiRasterTimeMS,...
        1:iNumTrialsSameType,...
        strctUnit.m_a2cTrialStats{iTrialTypeIndex, iTrialOutcomeIndex}.m_strctRasterSaccade.m_a2fSmoothRaster);
    axis([strctUnit.m_a2cTrialStats{iTrialTypeIndex, iTrialOutcomeIndex}.m_strctRasterSaccade.m_aiRasterTimeMS([1 end]) 1 iNumTrialsSameType])
    for k=1:iNumTrialsSameType
        plot(1e3*strctUnit.m_a2cTrialStats{iTrialTypeIndex, iTrialOutcomeIndex}.m_strctRasterSaccade.m_afCueOnset(k)*ones(1,2),[k-0.5 k+0.5],'w','LineWidth',2);
        plot(1e3*strctUnit.m_a2cTrialStats{iTrialTypeIndex, iTrialOutcomeIndex}.m_strctRasterSaccade.m_afChoicesOnset(k)*ones(1,2),[k-0.5 k+0.5],'r','LineWidth',2);
        plot(1e3*strctUnit.m_a2cTrialStats{iTrialTypeIndex, iTrialOutcomeIndex}.m_strctRasterSaccade.m_afTrialEnd(k)*ones(1,2),[k-0.5 k+0.5],'m','LineWidth',2);
    end
    tightsubplot(8,4, (iTrialOfInterestIter-1)*4+4,'Spacing',0.05,'Parent',hParent);
    hold on;
    plot(strctUnit.m_a2cTrialStats{iTrialTypeIndex, iTrialOutcomeIndex}.m_strctRasterSaccade.m_aiRasterTimeMS, afAvgFiringRateSaccade);
    plot(0*ones(1,2)*1e3,[0 fMaxFiringRate],'m');
    
    title('0 = Saccade');
    axis([strctUnit.m_a2cTrialStats{iTrialTypeIndex, iTrialOutcomeIndex}.m_strctRasterCue.m_aiRasterTimeMS([1,end]), 0 1.1*fMaxFiringRate]);%%
end