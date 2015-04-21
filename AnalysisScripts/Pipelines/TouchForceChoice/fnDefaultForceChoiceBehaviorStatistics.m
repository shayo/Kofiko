function fnDefaultForceChoiceBehaviorStatistics(ahPanels, strctData)
 %Sort trials....

 
 acReOrder= {'SaccadeTaskRight','MicrostimSaccadeTaskRight',...
    'SaccadeTaskLeft','MicrostimSaccadeTaskLeft',...
    'SaccadeTaskUp','MicrostimSaccadeTaskUp',...
    'SaccadeTaskDown','MicrostimSaccadeTaskDown',...
    'SaccadeTaskRightUp','MicrostimSaccadeTaskRightUp',...
    'SaccadeTaskRightDown','MicrostimSaccadeTaskRightDown',...
    'SaccadeTaskLeftUp','MicrostimSaccadeTaskLeftUp',...
    'SaccadeTaskLeftDown','MicrostimSaccadeTaskLeftDown'};

[abFound, aiIndex]=ismember(lower(acReOrder),lower(strctData.m_acUniqueTrialNames));
aiFound= aiIndex(aiIndex>0);
 aiRemaining = setdiff(1: length(strctData.m_acUniqueTrialNames),aiFound);
aiSortOrder = [aiFound,aiRemaining ];

hAxes2 = axes('parent',ahPanels(2));
iNumUniqueTrialTypes = size(strctData.m_a2fNumTrialsNormalized,1);
barh(1:iNumUniqueTrialTypes,strctData.m_a2fNumTrialsNormalized(aiSortOrder,:),'parent',hAxes2)
legend(strctData.m_acUniqueOutcomes)
set(gca,'ytick', 1:iNumUniqueTrialTypes,'yticklabel',strctData.m_acUniqueTrialNames(aiSortOrder));
xlabel('Percentage of trials');

hAxes1 = axes('parent',ahPanels(1));
bar(strctData.m_a2fNumTrialsNormalized(aiSortOrder,:),'stacked','parent',hAxes1);
legend(strctData.m_acUniqueOutcomes,'location','northoutside')
set(gca,'ylim',[0 1]);
ylabel('Percentage of trials');
set(gca,'xtick', 1: iNumUniqueTrialTypes, 'xticklabel',strctData.m_acUniqueTrialNames(aiSortOrder));
xticklabel_rotate;

%%





strctDesignStat = strctData;
a2cCompareTrials = {'SaccadeTaskRight','MicrostimSaccadeTaskRight';...
    'SaccadeTaskLeft','MicrostimSaccadeTaskLeft';...
    'SaccadeTaskUp','MicrostimSaccadeTaskUp';...
    'SaccadeTaskDown','MicrostimSaccadeTaskDown';...
    'SaccadeTaskRightUp','MicrostimSaccadeTaskRightUp';...
    'SaccadeTaskRightDown','MicrostimSaccadeTaskRightDown';...
    'SaccadeTaskLeftUp','MicrostimSaccadeTaskLeftUp';...
    'SaccadeTaskLeftDown','MicrostimSaccadeTaskLeftDown'};
for iIter=1:size(a2cCompareTrials,1)
    
    iNoStim=find(ismember( lower(strctDesignStat.m_acUniqueTrialNames), lower(a2cCompareTrials{iIter,1})));
    iStim=find(ismember( lower(strctDesignStat.m_acUniqueTrialNames), lower(a2cCompareTrials{iIter,2})));
    iOutcome = find(ismember(strctDesignStat.m_acUniqueOutcomes,'Correct'));
    % look only at correct trials.
    aiStimTrials = strctDesignStat.m_a2cTrialsIndicesSorted{iStim,iOutcome};
    aiNoStimTrials = strctDesignStat.m_a2cTrialsIndicesSorted{iNoStim,iOutcome};
        tightsubplot(2,4,iIter,'Spacing',0.05,'Parent',ahPanels(3));
    hold on;
    a2fDirectionsStim = zeros(length(aiStimTrials), 2);
    for k=1:length(aiStimTrials)
        iStart = find(strctDesignStat.m_astrctTrialsPostProc(aiStimTrials(k)).m_afEyeTS_PLX >= strctDesignStat.m_astrctTrialsPostProc(aiStimTrials(k)).m_fChoiceOnsetTSPlexon,1,'first');
        iEnd = find(strctDesignStat.m_astrctTrialsPostProc(aiStimTrials(k)).m_afEyeTS_PLX <= strctDesignStat.m_astrctTrialsPostProc(aiStimTrials(k)).m_fSaccadeTSPlexon,1,'last');
        
        afX = strctDesignStat.m_astrctTrialsPostProc(aiStimTrials(k)).m_afEyeXpixSmooth(iStart:iEnd);
        afY = strctDesignStat.m_astrctTrialsPostProc(aiStimTrials(k)).m_afEyeYpixSmooth(iStart:iEnd);
        afDist = (afX-afX(1)).^2+(afY-afY(1)).^2;
               if all(isnan(afDist))
            continue;
        end;
  
        iIndexStart = find(afDist < 80,1,'last');
        afDirection = [afX(end)-afX(iIndexStart),afY(end)-afY(iIndexStart)];
        afDirection=afDirection/norm(afDirection);
        a2fDirectionsStim(k,:) = afDirection;
                plot(afX-afX(1),afY-afY(1),'r'); 
              plot([0  afDirection(1)*100],[0 afDirection(2)*100],'g');

        dbg =1;
    end
     a2fDirectionsNoStim = zeros(length(aiNoStimTrials), 2);
    for k=1:length(aiNoStimTrials)
      iStart = find(strctDesignStat.m_astrctTrialsPostProc(aiNoStimTrials(k)).m_afEyeTS_PLX >= strctDesignStat.m_astrctTrialsPostProc(aiNoStimTrials(k)).m_fChoiceOnsetTSPlexon,1,'first');
        iEnd = find(strctDesignStat.m_astrctTrialsPostProc(aiNoStimTrials(k)).m_afEyeTS_PLX <= strctDesignStat.m_astrctTrialsPostProc(aiNoStimTrials(k)).m_fSaccadeTSPlexon,1,'last');
           
        afX = strctDesignStat.m_astrctTrialsPostProc(aiNoStimTrials(k)).m_afEyeXpixSmooth(iStart:iEnd);
        afY = strctDesignStat.m_astrctTrialsPostProc(aiNoStimTrials(k)).m_afEyeYpixSmooth(iStart:iEnd);
        
      afDist = (afX-afX(1)).^2+(afY-afY(1)).^2;
        if all(isnan(afDist))
            continue;
        end;
        iIndexStart = find(afDist < 80,1,'last');
        afDirection = [afX(end)-afX(iIndexStart),afY(end)-afY(iIndexStart)];
        afDirection=afDirection/norm(afDirection);
        a2fDirectionsNoStim(k,:) = afDirection;
         
        plot(afX-afX(1),afY-afY(1),'k'); 
    end    
    box on
    axis equal
    axis([-300 300 -300 300]);
    iMin = min( length(aiNoStimTrials), length(aiStimTrials));
    afAnglesStim = atan2(a2fDirectionsStim(:,2),a2fDirectionsStim(:,1));
    afAnglesNoStim = atan2(a2fDirectionsNoStim(:,2),a2fDirectionsNoStim(:,1));
    
    afDiff = afAnglesStim(1:iMin)-afAnglesNoStim(1:iMin);
    
    [h mu ul ll] = circ_mtest(afDiff, 0);
    h
     
%     figure(4);clf;hold on;
%     circ_plot(afAnglesStim,'pretty','ro',true,'linewidth',2,'color','r'),
%     hold on;
%     circ_plot(afAnglesNoStim,'pretty','b.',true,'linewidth',2,'color','b'),
  
end
    
return;
