function fnAnalyzeIncorrectTrials(acDataEntries)

iNumSessions  = length(acDataEntries);
 a2cTrialNames = {'SaccadeTaskRight','MicrostimSaccadeTaskRight';...
    'SaccadeTaskLeft','MicrostimSaccadeTaskLeft';...
    'SaccadeTaskUp','MicrostimSaccadeTaskUp';...
    'SaccadeTaskDown','MicrostimSaccadeTaskDown';...
    'SaccadeTaskRightUp','MicrostimSaccadeTaskRightUp';...
    'SaccadeTaskRightDown','MicrostimSaccadeTaskRightDown';...
    'SaccadeTaskLeftUp','MicrostimSaccadeTaskLeftUp';...
    'SaccadeTaskLeftDown','MicrostimSaccadeTaskLeftDown'};
aiNumCorrect = zeros(1,iNumSessions );
aiNumIncorrect = zeros(1,iNumSessions );

abMonkeyJ=zeros(1,length(acDataEntries))>0;
for i=1:length(acDataEntries)
   if ~isempty(strfind(acDataEntries{i}.m_strFile,'Julien'))
        abMonkeyJ(i) = true;
   end;
end
%% Chi-sqr 2x2
 for iSessionIter=1:iNumSessions 
      fprintf('Loading %d out of %d : %s...',iSessionIter,iNumSessions, acDataEntries{iSessionIter}.m_strFile);
     strctTmp = load(acDataEntries{iSessionIter}.m_strFile);
     fprintf('Done!\n');

        iNumTrials = length(strctTmp.strctDesignStat.m_acTrials);
        acOutcomes = cell(1, iNumTrials);
        for iTrialIter=1:iNumTrials
            if isempty(strctTmp.strctDesignStat.m_acTrials{iTrialIter}.m_strctNewTrialOutcome)
                acOutcomes{iTrialIter}= 'Unknown';
            else
                acOutcomes{iTrialIter} = strctTmp.strctDesignStat.m_acTrials{iTrialIter}.m_strctNewTrialOutcome.m_strOutcome;
            end
        end
            abIncorrectTrials = ismember(acOutcomes,'Incorrect');
            abCorrectTrials = ismember(acOutcomes,'Correct');

      
      for iTrialTypeIter=1:size(a2cTrialNames,1)
            iTrialIndex = find(ismember(lower(strctTmp.strctDesignStat.m_acUniqueTrialNames),lower( a2cTrialNames{iTrialTypeIter,1})));
            iTrialStimIndex = find(ismember(lower(strctTmp.strctDesignStat.m_acUniqueTrialNames),lower( a2cTrialNames{iTrialTypeIter,2})));
            
            iIncorrectGoTrials = sum(strctTmp.strctDesignStat.m_aiTrialTypeMappedToUnique == iTrialIndex & abIncorrectTrials);
            iIncorrectGoStimTrials = sum(strctTmp.strctDesignStat.m_aiTrialTypeMappedToUnique == iTrialStimIndex & abIncorrectTrials);
            iCorrectGoTrials = sum(strctTmp.strctDesignStat.m_aiTrialTypeMappedToUnique == iTrialIndex & abCorrectTrials);
            iICorrectGoStimTrials = sum(strctTmp.strctDesignStat.m_aiTrialTypeMappedToUnique == iTrialStimIndex & abCorrectTrials);
            
        a2iObservedTable = [iCorrectGoTrials,iIncorrectGoTrials;iICorrectGoStimTrials,iIncorrectGoStimTrials];
        Tmp=a2iObservedTable./[sum(a2iObservedTable,2),sum(a2iObservedTable,2)]*1e2;
        a2fIncorrectIncreasePerc(iSessionIter, iTrialTypeIter) = Tmp(2,2)-Tmp(1,2);
        
        a2fExpectedTable = sum(a2iObservedTable,2) * sum(a2iObservedTable,1) / sum(a2iObservedTable(:));
         a2fChiElements = (a2fExpectedTable - a2iObservedTable ) .^2 ./ a2fExpectedTable;
        a2fChiSquare(iSessionIter,iTrialTypeIter) = sum(a2fChiElements(~isinf(a2fChiElements) & ~isnan(a2fChiElements)));
       end
  end     
     a2fPvalue = 1 - chi2cdf(a2fChiSquare, 1); 

       
%    if strcmpi(strctTmp.strctDesignStat.m_acTrials{iTrialIter}.m_strctNewTrialOutcome.m_strOutcome,'Incorrect')
%        strctTmp.strctDesignStat.m_acTrials{iTrialIter}.m_strctNewTrialOutcome.m_iSelectedTarget
%    end
% end


for iSessionIter=1:iNumSessions 
    fprintf('Loading %d out of %d : %s...',iSessionIter,iNumSessions, acDataEntries{iSessionIter}.m_strFile);
    strctTmp = load(acDataEntries{iSessionIter}.m_strFile);
    fprintf('Done!\n');

    iNumTrials = length(strctTmp.strctDesignStat.m_acTrials);
    acOutcomes = cell(1, iNumTrials);
    for iTrialIter=1:iNumTrials
        if isempty(strctTmp.strctDesignStat.m_acTrials{iTrialIter}.m_strctNewTrialOutcome)
            acOutcomes{iTrialIter}= 'Unknown';
        else
            acOutcomes{iTrialIter} = strctTmp.strctDesignStat.m_acTrials{iTrialIter}.m_strctNewTrialOutcome.m_strOutcome;
        end
    end
    
    abIncorrectTrials = ismember(acOutcomes,'Incorrect');
    
    % Show that the definicency is not in saccade execution.
    iIncorrectIndex = find(ismember(strctTmp.strctDesignStat.m_acUniqueOutcomes,'Incorrect'));
%     figure(1+iSessionIter);clf;
%     figure(100+iSessionIter);clf; 
    %%
    for iTrialTypeIter=1:size(a2cTrialNames,1)
%         figure(1+iSessionIter);
%         subplot(2,4,iTrialTypeIter);cla; hold on;
%         
        iTrialIndex = find(ismember(lower(strctTmp.strctDesignStat.m_acUniqueTrialNames),lower( a2cTrialNames{iTrialTypeIter,1})));
        iTrialStimIndex = find(ismember(lower(strctTmp.strctDesignStat.m_acUniqueTrialNames),lower( a2cTrialNames{iTrialTypeIter,2})));
        
        aiIncorrectGoTrials = find(strctTmp.strctDesignStat.m_aiTrialTypeMappedToUnique == iTrialIndex & abIncorrectTrials);
        aiIncorrectGoStimTrials = find(strctTmp.strctDesignStat.m_aiTrialTypeMappedToUnique == iTrialStimIndex & abIncorrectTrials);
        

%         a2fFractionIncorrect(10,:)*1e2
%         a2fFractionIncorrectStim(10,:)*1e2
        % Build the chi-square table
        aiSelectedTarget = zeros(1,8);
        aiSelectedTargetSim = zeros(1,8);

        aiSelectedTargetOLD = zeros(1,8);
        aiSelectedTargetSimOLD = zeros(1,8);
        
        for k=1:length(aiIncorrectGoTrials)
            if ~isempty(strctTmp.strctDesignStat.m_acTrials{aiIncorrectGoTrials(k)}.m_strctNewTrialOutcome.m_iSelectedTarget)
                if strctTmp.strctDesignStat.m_acTrials{aiIncorrectGoTrials(k)}.m_strctNewTrialOutcome.m_iSelectedTarget == iTrialTypeIter
                    dbg = 1;
                end;
                
                aiSelectedTarget(strctTmp.strctDesignStat.m_acTrials{aiIncorrectGoTrials(k)}.m_strctNewTrialOutcome.m_iSelectedTarget) = ...
                    aiSelectedTarget(strctTmp.strctDesignStat.m_acTrials{aiIncorrectGoTrials(k)}.m_strctNewTrialOutcome.m_iSelectedTarget) + 1;
            end            
        end

        for k=1:length(aiIncorrectGoStimTrials)
            if ~isempty(strctTmp.strctDesignStat.m_acTrials{aiIncorrectGoStimTrials(k)}.m_strctNewTrialOutcome.m_iSelectedTarget)
                aiSelectedTargetSim(strctTmp.strctDesignStat.m_acTrials{aiIncorrectGoStimTrials(k)}.m_strctNewTrialOutcome.m_iSelectedTarget) = ...
                    aiSelectedTargetSim(strctTmp.strctDesignStat.m_acTrials{aiIncorrectGoStimTrials(k)}.m_strctNewTrialOutcome.m_iSelectedTarget) + 1;
            end            
        end
        a3iSelectedTargets(iSessionIter,iTrialTypeIter,:) =aiSelectedTarget;
        a3iSelectedTargetsStim(iSessionIter,iTrialTypeIter,:) =aiSelectedTargetSim;
        a2iObservedTable = [aiSelectedTarget;aiSelectedTargetSim];
        a2fExpectedTable = sum(a2iObservedTable,2) * sum(a2iObservedTable,1) / sum(a2iObservedTable(:));
         a2fChiElements = (a2fExpectedTable - a2iObservedTable ) .^2 ./ a2fExpectedTable;
        a2fChiSquare(iSessionIter,iTrialTypeIter) = sum(a2fChiElements(~isinf(a2fChiElements) & ~isnan(a2fChiElements)));
    end
end

a2fPvalue = 1 - chi2cdf(a2fChiSquare, 6); % 6 dof because there are 8 bins and one is always empty
[aiSessions,aiTrials]=find(a2fPvalue<0.05);
[aiSessions,aiTmp]=sort(aiSessions);
aiTrials = aiTrials(aiTmp);

aiSessions = [1];
aiTrials = [1];
iNumSig = length(aiSessions);
figure(15);clf;
acDirs = {'Right','Left','Up','Down','Upper right','Bottom right','Upper left','Bottom left'};
aiNumCorrect = zeros(1,iNumSessions );
for iIter=1:iNumSig
   iSession =  aiSessions(iIter);
   iTrialType = aiTrials(iIter);
%    subplot(2,3,iIter);
   aiSelectedTarget = squeeze(a3iSelectedTargets(iSession,iTrialType,:))';
   aiSelectedTargetStim = squeeze(a3iSelectedTargetsStim(iSession,iTrialType,:))';
    
   
    if abMonkeyJ(iSession)
       strMonkey = 'J';
       iSessionIndex = iSession;
   else
       strMonkey = 'B';
       iSessionIndex = iSession-4;
    end
   strGoDirection = acDirs{iTrialType};
%     strTitle = sprintf('Monkey %s, Session %d, Go %s',strMonkey,iSessionIndex,strGoDirection);
   fnDoubleBar(1:8, aiSelectedTarget/sum(aiSelectedTarget), aiSelectedTargetStim/sum(aiSelectedTargetStim),'',[-0.5 -0.25 0 0.25 0.5]);
   set(gca,'xticklabel',acDirs);
xticklabel_rotate
end


%%
if 0
[aiSessions, aiTrials]=find(a2fP_ExitAngle<0.05)
[aiSessions,aiTmp]=sort(aiSessions)
aiTrials = aiTrials(aiTmp);
iNumSig = length(aiSessions);
   figure(11);
   clf;
for iIter=1:iNumSig
   iSession =  aiSessions(iIter);
   iTrialType = aiTrials(iIter);
   afDifferenceInAngles(iIter)=abs(circ_median(a2cExitAngles{iSession,iTrialType}')-circ_median(a2cExitAnglesStim{iSession,iTrialType}'))/pi*180;
   
   [a1,b1]=rose(a2cExitAngles{iSession,iTrialType},100);
   [a2,b2]=rose(a2cExitAnglesStim{iSession,iTrialType},100);
   tightsubplot(2,3,iIter,'Spacing',0.1);
    hold off;
   fnMyPolarFilled(a2,b2,'r')
   hold on;
   fnMyPolarFilled(a1,b1,'b')
   if abMonkeyJ(iSession)
       strMonkey = 'J';
       iSessionIndex = iSession;
   else
       strMonkey = 'B';
       iSessionIndex = iSession-4;
   end
   if (a2fP_ExitAngle(iSession,iTrialType)) < 0.001
    title(sprintf('Monkey %s, Session %d, p<0.001',strMonkey,iSessionIndex));
   elseif (a2fP_ExitAngle(iSession,iTrialType)) < 0.01
        title(sprintf('Monkey %s, Session %d, p<0.01',strMonkey,iSessionIndex));       
   else
       title(sprintf('Monkey %s, Session %d, p<0.05',strMonkey,iSessionIndex));       
   end
end
%%
fPIX_TO_VISUAL_ANGLE = 28.8/800;
[aiSessions, aiTrials]=find(a2fP_Amp<0.05)
[aiSessions,aiTmp]=sort(aiSessions)
aiTrials = aiTrials(aiTmp);
iNumSig = length(aiSessions);
   figure(12);
   clf;
for iIter=1:iNumSig
   iSession =  aiSessions(iIter);
   iTrialType = aiTrials(iIter);
   tightsubplot(2,4,iIter,'Spacing',0.1);
%    hold on;
%     fnPlotMemorySaccadeScreen();
%     plot(a2cFixation{iSession,iTrialType}(:,1),a2cFixation{iSession,iTrialType}(:,2),'k.');
%     plot(a2cFixationSim{iSession,iTrialType}(:,1),a2cFixationSim{iSession,iTrialType}(:,2),'r.');
     afCent = 80:20:400;
     afAmp = sqrt(a2cFixation{iSession,iTrialType}(:,1).^2+a2cFixation{iSession,iTrialType}(:,2).^2);
     afAmpStim = sqrt(a2cFixationSim{iSession,iTrialType}(:,1).^2+a2cFixationSim{iSession,iTrialType}(:,2).^2);
    afMedianDiff(iIter)=median(afAmp)-median(afAmpStim)
     afHist = histc(afAmp,afCent);
    afHistStim = histc(afAmpStim,afCent);
    hold on;
    bar(afCent*fPIX_TO_VISUAL_ANGLE,afHist/sum(afHist),'facecolor','b','Edgecolor','none');
    bar(afCent*fPIX_TO_VISUAL_ANGLE,-afHistStim/sum(afHistStim),'facecolor','r','Edgecolor','none');
    set(gca,'ylim',[-0.4 0.4],'xlim',[80 400]*fPIX_TO_VISUAL_ANGLE);
     if abMonkeyJ(iSession)
       strMonkey = 'J';
       iSessionIndex = iSession;
   else
       strMonkey = 'B';
       iSessionIndex = iSession-4;
   end
   if (a2fP_Amp(iSession,iTrialType)) < 0.001
    title(sprintf('Monkey %s, Session %d, p<0.001',strMonkey,iSessionIndex));
   elseif (a2fP_Amp(iSession,iTrialType)) < 0.01
        title(sprintf('Monkey %s, Session %d, p<0.01',strMonkey,iSessionIndex));       
   else
       title(sprintf('Monkey %s, Session %d, p<0.05',strMonkey,iSessionIndex));       
   end
end
%%

end