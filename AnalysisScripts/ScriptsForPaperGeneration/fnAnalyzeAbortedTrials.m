function fnAnalyzeAbortedTrials(acDataEntries)

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
%%
for iSessionIter=1:iNumSessions 
    fprintf('Loading %d out of %d : %s...',iSessionIter,iNumSessions, acDataEntries{iSessionIter}.m_strFile);
    strctTmp = load(acDataEntries{iSessionIter}.m_strFile);
    fprintf('Done!\n');
    % Show that the definicency is not in saccade execution.
    iAbortedIndex = find(ismember(strctTmp.strctDesignStat.m_acUniqueOutcomes,'Aborted'));
%     figure(1+iSessionIter);clf;
%     figure(100+iSessionIter);clf; 
    %%
    acGazes = cell(1,8);
    for iTrialTypeIter=1:size(a2cTrialNames,1)
%         figure(1+iSessionIter);
%         subplot(2,4,iTrialTypeIter);cla; hold on;
%         
        iTrialIndex = find(ismember(lower(strctTmp.strctDesignStat.m_acUniqueTrialNames),lower( a2cTrialNames{iTrialTypeIter,1})));
        iTrialStimIndex = find(ismember(lower(strctTmp.strctDesignStat.m_acUniqueTrialNames),lower( a2cTrialNames{iTrialTypeIter,2})));
        
        aiAbortedGoTrials = find(strctTmp.strctDesignStat.m_aiTrialTypeMappedToUnique == iTrialIndex & strctTmp.strctDesignStat.m_aiTrialOutcomeMappedToUnique == iAbortedIndex);
        aiAbortedGoStimTrials = find(strctTmp.strctDesignStat.m_aiTrialTypeMappedToUnique == iTrialStimIndex & strctTmp.strctDesignStat.m_aiTrialOutcomeMappedToUnique == iAbortedIndex);

        for j=1:length(aiAbortedGoStimTrials)
            
        afGaze = sqrt(strctTmp.strctDesignStat.m_acTrials{aiAbortedGoStimTrials(j)}.m_strctNewTrialOutcome.m_afEyeXpixZero.^2+...
            strctTmp.strctDesignStat.m_acTrials{aiAbortedGoStimTrials(j)}.m_strctNewTrialOutcome.m_afEyeYpixZero.^2);
        acGazes{iTrialTypeIter}(j,:) = afGaze(1:8600);
        end
        
        % Build the chi-square table
        aiSelectedTarget = zeros(1,8);
        aiSelectedTargetSim = zeros(1,8);

        for k=1:length(aiAbortedGoTrials)
            if ~isempty(strctTmp.strctDesignStat.m_acTrials{aiAbortedGoTrials(k)}.m_strctNewTrialOutcome.m_iSelectedTarget)
                aiSelectedTarget(strctTmp.strctDesignStat.m_acTrials{aiAbortedGoTrials(k)}.m_strctNewTrialOutcome.m_iSelectedTarget) = ...
                    aiSelectedTarget(strctTmp.strctDesignStat.m_acTrials{aiAbortedGoTrials(k)}.m_strctNewTrialOutcome.m_iSelectedTarget) + 1;
            end            
        end

        for k=1:length(aiAbortedGoStimTrials)
            if ~isempty(strctTmp.strctDesignStat.m_acTrials{aiAbortedGoStimTrials(k)}.m_strctNewTrialOutcome.m_iSelectedTarget)
                aiSelectedTargetSim(strctTmp.strctDesignStat.m_acTrials{aiAbortedGoStimTrials(k)}.m_strctNewTrialOutcome.m_iSelectedTarget) = ...
                    aiSelectedTargetSim(strctTmp.strctDesignStat.m_acTrials{aiAbortedGoStimTrials(k)}.m_strctNewTrialOutcome.m_iSelectedTarget) + 1;
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
%%
acDirs = {'R','L','U','D','UR','BR','UL','BL'};

fPIX_TO_VISUAL_ANGLE = 28.8/800;
a2fGaze = [acGazes{2};acGazes{7};acGazes{8}]*fPIX_TO_VISUAL_ANGLE;


M=mean(a2fGaze,1);
S = std(a2fGaze,1)/sqrt(size(M,1));
figure(11);
clf;hold on;
plot([0:8599]*0.25, M)
plot([0:8599]*0.25, M+S,'k--')
plot([0:8599]*0.25, M-S,'k--')
set(gca,'xlim',[0 400],'ylim',[-5 10]);
P=get(gcf,'position');P(3:4)=[240,280];
set(gcf,'position',P);


% Find latency
aiLatency = nans(1,  size(a2fGaze,1));
for k=1:size(a2fGaze,1)
    M=mean(a2fGaze(k,400:800));
    S=std(a2fGaze(k,400:800));
    iIndex = find(a2fGaze(k,800:end) > M+5*S,1,'first');
    if ~isempty(iIndex)
        aiLatency(k) = iIndex;
    end
end
(median(aiLatency(~isnan(aiLatency)))+800)*0.25
(mad(aiLatency(~isnan(aiLatency)))+800)*0.25

%

a2fPvalue = 1 - chi2cdf(a2fChiSquare, 6); % 6 dof because there are 8 bins and one is always empty
[aiSessions,aiTrials]=find(a2fPvalue<0.05);
[aiSessions,aiTmp]=sort(aiSessions);
aiTrials = aiTrials(aiTmp);
iNumSig = length(aiSessions);
figure(15);clf;
aiSessions = [1 1 1];
aiTrials = [2,7,8];
for iIter=1:length(aiTrials)
   iSession =  aiSessions(iIter);
   iTrialType = aiTrials(iIter);
   subplot(1,3,iIter);
   aiSelectedTarget = squeeze(a3iSelectedTargets(iSession,iTrialType,:))';
   aiSelectedTargetStim = squeeze(a3iSelectedTargetsStim(iSession,iTrialType,:))';
    strTitle = sprintf('Go %s',acDirs{iTrialType});
   fnDoubleBar(1:8, aiSelectedTarget/sum(aiSelectedTarget), aiSelectedTargetStim/sum(aiSelectedTargetStim),strTitle,-1:0.4:1);
   set(gca,'xticklabel',acDirs);
end

%% Show raw eye trace


%%
% % [aiSessions, aiTrials]=find(a2fP_ExitAngle<0.05)
% % [aiSessions,aiTmp]=sort(aiSessions)
% % aiTrials = aiTrials(aiTmp);
% % iNumSig = length(aiSessions);
% %    figure(11);
% %    clf;
% % for iIter=1:iNumSig
% %    iSession =  aiSessions(iIter);
% %    iTrialType = aiTrials(iIter);
% %    afDifferenceInAngles(iIter)=abs(circ_median(a2cExitAngles{iSession,iTrialType}')-circ_median(a2cExitAnglesStim{iSession,iTrialType}'))/pi*180;
% %    
% %    [a1,b1]=rose(a2cExitAngles{iSession,iTrialType},100);
% %    [a2,b2]=rose(a2cExitAnglesStim{iSession,iTrialType},100);
% %    tightsubplot(2,3,iIter,'Spacing',0.1);
% %     hold off;
% %    fnMyPolarFilled(a2,b2,'r')
% %    hold on;
% %    fnMyPolarFilled(a1,b1,'b')
% %    if abMonkeyJ(iSession)
% %        strMonkey = 'J';
% %        iSessionIndex = iSession;
% %    else
% %        strMonkey = 'B';
% %        iSessionIndex = iSession-4;
% %    end
% %    if (a2fP_ExitAngle(iSession,iTrialType)) < 0.001
% %     title(sprintf('Monkey %s, Session %d, p<0.001',strMonkey,iSessionIndex));
% %    elseif (a2fP_ExitAngle(iSession,iTrialType)) < 0.01
% %         title(sprintf('Monkey %s, Session %d, p<0.01',strMonkey,iSessionIndex));       
% %    else
% %        title(sprintf('Monkey %s, Session %d, p<0.05',strMonkey,iSessionIndex));       
% %    end
% % end
% % %%
% % fPIX_TO_VISUAL_ANGLE = 28.8/800;
% % [aiSessions, aiTrials]=find(a2fP_Amp<0.05)
% % [aiSessions,aiTmp]=sort(aiSessions)
% % aiTrials = aiTrials(aiTmp);
% % iNumSig = length(aiSessions);
% %    figure(12);
% %    clf;
% % for iIter=1:iNumSig
% %    iSession =  aiSessions(iIter);
% %    iTrialType = aiTrials(iIter);
% %    tightsubplot(2,4,iIter,'Spacing',0.1);
% % %    hold on;
% % %     fnPlotMemorySaccadeScreen();
% % %     plot(a2cFixation{iSession,iTrialType}(:,1),a2cFixation{iSession,iTrialType}(:,2),'k.');
% % %     plot(a2cFixationSim{iSession,iTrialType}(:,1),a2cFixationSim{iSession,iTrialType}(:,2),'r.');
% %      afCent = 80:20:400;
% %      afAmp = sqrt(a2cFixation{iSession,iTrialType}(:,1).^2+a2cFixation{iSession,iTrialType}(:,2).^2);
% %      afAmpStim = sqrt(a2cFixationSim{iSession,iTrialType}(:,1).^2+a2cFixationSim{iSession,iTrialType}(:,2).^2);
% %     afMedianDiff(iIter)=median(afAmp)-median(afAmpStim)
% %      afHist = histc(afAmp,afCent);
% %     afHistStim = histc(afAmpStim,afCent);
% %     hold on;
% %     bar(afCent*fPIX_TO_VISUAL_ANGLE,afHist/sum(afHist),'facecolor','b','Edgecolor','none');
% %     bar(afCent*fPIX_TO_VISUAL_ANGLE,-afHistStim/sum(afHistStim),'facecolor','r','Edgecolor','none');
% %     set(gca,'ylim',[-0.4 0.4],'xlim',[80 400]*fPIX_TO_VISUAL_ANGLE);
% %      if abMonkeyJ(iSession)
% %        strMonkey = 'J';
% %        iSessionIndex = iSession;
% %    else
% %        strMonkey = 'B';
% %        iSessionIndex = iSession-4;
% %    end
% %    if (a2fP_Amp(iSession,iTrialType)) < 0.001
% %     title(sprintf('Monkey %s, Session %d, p<0.001',strMonkey,iSessionIndex));
% %    elseif (a2fP_Amp(iSession,iTrialType)) < 0.01
% %         title(sprintf('Monkey %s, Session %d, p<0.01',strMonkey,iSessionIndex));       
% %    else
% %        title(sprintf('Monkey %s, Session %d, p<0.05',strMonkey,iSessionIndex));       
% %    end
% % end
% % %%
% % 
% % %