
strctDesignStat = strctData
a2cCompareTrials = {'SaccadeTaskRight','MicrostimSaccadeTaskRight';...
    'SaccadeTaskLeft','MicrostimSaccadeTaskLeft';...
    'SaccadeTaskUp','MicrostimSaccadeTaskUp';...
    'SaccadeTaskDown','MicrostimSaccadeTaskDown';...
    'SaccadeTaskRightUp','MicrostimSaccadeTaskRightUp';...
    'SaccadeTaskRightDown','MicrostimSaccadeTaskRightDown';...
    'SaccadeTaskLeftUp','MicrostimSaccadeTaskLeftUp';...
    'SaccadeTaskLeftDown','MicrostimSaccadeTaskLeftDown'};
figure(14);
clf;
figure(15);
clf;
for iIter=1:size(a2cCompareTrials,1)
    
    iNoStim=find(ismember( lower(strctDesignStat.m_acUniqueTrialNames), lower(a2cCompareTrials{iIter,1})));
    iStim=find(ismember( lower(strctDesignStat.m_acUniqueTrialNames), lower(a2cCompareTrials{iIter,2})));
    iOutcome = find(ismember(strctDesignStat.m_acUniqueOutcomes,'Correct'));
    % look only at correct trials.
    aiStimTrials = strctDesignStat.m_a2cTrialsIndicesSorted{iStim,iOutcome};
    aiNoStimTrials = strctDesignStat.m_a2cTrialsIndicesSorted{iNoStim,iOutcome};
    if iIter>=5
        figure(15);
        tightsubplot(1,4,iIter-4,'Spacing',0.05);
    else
        figure(14);
        tightsubplot(1,4,iIter,'Spacing',0.05);
    end
    hold on;
    for k=1:length(aiStimTrials)
        iStart = find(strctDesignStat.m_astrctTrialsPostProc(aiStimTrials(k)).m_afEyeTS_PLX >= strctDesignStat.m_astrctTrialsPostProc(aiStimTrials(k)).m_fChoiceOnsetTSPlexon,1,'first');
        iEnd = find(strctDesignStat.m_astrctTrialsPostProc(aiStimTrials(k)).m_afEyeTS_PLX <= strctDesignStat.m_astrctTrialsPostProc(aiStimTrials(k)).m_fSaccadeTSPlexon,1,'last');
        
        afX = strctDesignStat.m_astrctTrialsPostProc(aiStimTrials(k)).m_afEyeXpixSmooth(iStart:iEnd);
        afY = strctDesignStat.m_astrctTrialsPostProc(aiStimTrials(k)).m_afEyeYpixSmooth(iStart:iEnd);
        plot(afX-afX(1),afY-afY(1),'r'); 
    end
    for k=1:length(aiNoStimTrials)
      iStart = find(strctDesignStat.m_astrctTrialsPostProc(aiNoStimTrials(k)).m_afEyeTS_PLX >= strctDesignStat.m_astrctTrialsPostProc(aiNoStimTrials(k)).m_fChoiceOnsetTSPlexon,1,'first');
        iEnd = find(strctDesignStat.m_astrctTrialsPostProc(aiNoStimTrials(k)).m_afEyeTS_PLX <= strctDesignStat.m_astrctTrialsPostProc(aiNoStimTrials(k)).m_fSaccadeTSPlexon,1,'last');
           
        afX = strctDesignStat.m_astrctTrialsPostProc(aiNoStimTrials(k)).m_afEyeXpixSmooth(iStart:iEnd);
        afY = strctDesignStat.m_astrctTrialsPostProc(aiNoStimTrials(k)).m_afEyeYpixSmooth(iStart:iEnd);
        plot(afX-afX(1),afY-afY(1),'k'); 
    end    
    box on
    axis equal
    axis([-300 300 -300 300]);
end
    
