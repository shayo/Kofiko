function fnAnalyzeCorrectTrials(acDataEntries)

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


for iSessionIter=1:iNumSessions 
    fprintf('Loading %d out of %d : %s...',iSessionIter,iNumSessions, acDataEntries{iSessionIter}.m_strFile);
    strctTmp = load(acDataEntries{iSessionIter}.m_strFile);
    fprintf('Done!\n');
    % Show that the definicency is not in saccade execution.
    iCorrectIndex = find(ismember(strctTmp.strctDesignStat.m_acUniqueOutcomes,'Correct'));
    
       iNumTrials = length(strctTmp.strctDesignStat.m_acTrials);
    acOutcomes = cell(1, iNumTrials);
    for iTrialIter=1:iNumTrials
        if isempty(strctTmp.strctDesignStat.m_acTrials{iTrialIter}.m_strctNewTrialOutcome)
            acOutcomes{iTrialIter}= 'Unknown';
        else
            acOutcomes{iTrialIter} = strctTmp.strctDesignStat.m_acTrials{iTrialIter}.m_strctNewTrialOutcome.m_strOutcome;
        end
    end
    
    abCorrectTrials = ismember(acOutcomes,'Correct');

%     figure(1+iSessionIter);clf;
%     figure(100+iSessionIter);clf; 
    %%
    for iTrialTypeIter=1:size(a2cTrialNames,1)
%         figure(1+iSessionIter);
%         subplot(2,4,iTrialTypeIter);cla; hold on;
%         
        iTrialIndex = find(ismember(lower(strctTmp.strctDesignStat.m_acUniqueTrialNames),lower( a2cTrialNames{iTrialTypeIter,1})));
        iTrialStimIndex = find(ismember(lower(strctTmp.strctDesignStat.m_acUniqueTrialNames),lower( a2cTrialNames{iTrialTypeIter,2})));
        
        aiCorrectGoTrials = find(strctTmp.strctDesignStat.m_aiTrialTypeMappedToUnique == iTrialIndex & abCorrectTrials);%strctTmp.strctDesignStat.m_aiTrialOutcomeMappedToUnique == iCorrectIndex);
        aiCorrectGoStimTrials = find(strctTmp.strctDesignStat.m_aiTrialTypeMappedToUnique == iTrialStimIndex & abCorrectTrials);%strctTmp.strctDesignStat.m_aiTrialOutcomeMappedToUnique == iCorrectIndex);
%         
%         figure(1+iSessionIter);
%         hold on;
%         fnPlotMemorySaccadeScreen();
%     
        clear afReactionTime afReactionTimeStim afAngle afAngleStim afAmp afAmpStim afExitAngleStim afExitAngle
        clear a2fFixationPointsStim a2fFixationPoints
        for k=1:length(aiCorrectGoTrials)
            if ~isempty(strctTmp.strctDesignStat.m_acTrials{aiCorrectGoTrials(k)}.m_strctNewTrialOutcome.m_pt2fFirstFixationAfterSaccade)
%                    plot(strctTmp.strctDesignStat.m_acTrials{aiCorrectGoTrials(k)}.m_strctNewTrialOutcome.m_pt2fFirstFixationAfterSaccade(1),...
%                   strctTmp.strctDesignStat.m_acTrials{aiCorrectGoTrials(k)}.m_strctNewTrialOutcome.m_pt2fFirstFixationAfterSaccade(2),'k.');
                a2fFixationPoints(k,:) = strctTmp.strctDesignStat.m_acTrials{aiCorrectGoTrials(k)}.m_strctNewTrialOutcome.m_pt2fFirstFixationAfterSaccade;
                afReactionTime(k) = strctTmp.strctDesignStat.m_acTrials{aiCorrectGoTrials(k)}.m_strctNewTrialOutcome.m_fReactionTimeSec;
                afAngle(k) = strctTmp.strctDesignStat.m_acTrials{aiCorrectGoTrials(k)}.m_strctNewTrialOutcome.m_fAngularAccuracyDeg;
                afExitAngle(k) = strctTmp.strctDesignStat.m_acTrials{aiCorrectGoTrials(k)}.m_strctNewTrialOutcome.m_fExitAngle;
                afAmp(k) = strctTmp.strctDesignStat.m_acTrials{aiCorrectGoTrials(k)}.m_strctNewTrialOutcome.m_fAmplitudeAccuracy;
            end            
        end
        for k=1:length(aiCorrectGoStimTrials)
            if ~isempty(strctTmp.strctDesignStat.m_acTrials{aiCorrectGoStimTrials(k)}.m_strctNewTrialOutcome.m_pt2fFirstFixationAfterSaccade)
%                 plot(strctTmp.strctDesignStat.m_acTrials{aiCorrectGoStimTrials(k)}.m_strctNewTrialOutcome.m_pt2fFirstFixationAfterSaccade(1),...
%                     strctTmp.strctDesignStat.m_acTrials{aiCorrectGoStimTrials(k)}.m_strctNewTrialOutcome.m_pt2fFirstFixationAfterSaccade(2),'r.');
                a2fFixationPointsStim(k,:) = strctTmp.strctDesignStat.m_acTrials{aiCorrectGoStimTrials(k)}.m_strctNewTrialOutcome.m_pt2fFirstFixationAfterSaccade;
                 afReactionTimeStim(k) = strctTmp.strctDesignStat.m_acTrials{aiCorrectGoStimTrials(k)}.m_strctNewTrialOutcome.m_fReactionTimeSec;
                afAngleStim(k) = strctTmp.strctDesignStat.m_acTrials{aiCorrectGoStimTrials(k)}.m_strctNewTrialOutcome.m_fAngularAccuracyDeg;
                afAmpStim(k) = strctTmp.strctDesignStat.m_acTrials{aiCorrectGoStimTrials(k)}.m_strctNewTrialOutcome.m_fAmplitudeAccuracy;
                afExitAngleStim(k) = strctTmp.strctDesignStat.m_acTrials{aiCorrectGoStimTrials(k)}.m_strctNewTrialOutcome.m_fExitAngle;
            end
        end
        a2cExitAngles{iSessionIter,iTrialTypeIter} = afExitAngle;
        a2cExitAnglesStim{iSessionIter,iTrialTypeIter} = afExitAngleStim;
        a2cFixation{iSessionIter,iTrialTypeIter} = a2fFixationPoints;
        a2cFixationSim{iSessionIter,iTrialTypeIter} = a2fFixationPointsStim;
        a2cReactionTimes{iSessionIter,iTrialTypeIter} = afReactionTime;
        a2cReactionTimesStim{iSessionIter,iTrialTypeIter} = afReactionTimeStim;
%         axis equal
%         axis([-400 400 -400 400]);
        a2fP_Angle(iSessionIter,iTrialTypeIter)=circ_cmtest(afAngle/180*pi,afAngleStim/180*pi);
        a2fP_ExitAngle(iSessionIter,iTrialTypeIter)=circ_cmtest(afExitAngle,afExitAngleStim);
        a2fP_Amp(iSessionIter,iTrialTypeIter) = ranksum(afAmp,afAmpStim);
        a2fP_ReactionTime(iSessionIter,iTrialTypeIter)=ranksum(afReactionTime,afReactionTimeStim);
%     [afHist,afCent]=hist(afReactionTime,0:0.1:1.5);
%     [afHistStim,afCent]=hist(afReactionTimeStim,0:0.1:1.5);
%     afHist=afHist/sum(afHist);
%     afHistStim=afHistStim/sum(afHistStim);
%     figure(100+iSessionIter);
%     subplot(2,4,iTrialTypeIter);hold on;
%     plot(afCent,afHist,'b');
%     plot(afCent,afHistStim,'r');
    end

    
%    [a1,b1]=rose(afAngle/180*pi, 100);
%    [a2,b2]=rose(afAngleStim/180*pi, 100);
%     figure(13);clf;hold off;
%     fnMyPolarFilled(a1,b1,'b'); hold on;
%     fnMyPolarFilled(gca,a2,b2,'r')
    
end
%%
[aiSessions, aiTrials]=find(a2fP_ReactionTime<0.05)
[aiSessions,aiTmp]=sort(aiSessions)
aiTrials = aiTrials(aiTmp);
iNumSig = length(aiSessions);
figure(15);clf;
for iIter=1:iNumSig
   iSession =  aiSessions(iIter);
   iTrialType = aiTrials(iIter);
   
   
   afCent = 0:0.1:1;
   afHist=histc(a2cReactionTimes{iSession,iTrialType},afCent);
   afHistStim=histc(a2cReactionTimesStim{iSession,iTrialType},afCent);
   subplot(1,3,iIter);hold on;
   bar(afCent,afHist/sum(afHist),'facecolor','b','edgecolor','none');
   bar(afCent,-afHistStim/sum(afHistStim),'facecolor','r','edgecolor','none');
   set(gca,'xlim',[-0.1 1],'ylim',[-0.6 0.6]);
 
 if abMonkeyJ(iSession)
       strMonkey = 'J';
       iSessionIndex = iSession;
   else
       strMonkey = 'B';
       iSessionIndex = iSession-4;
   end
   if (a2fP_ReactionTime(iSession,iTrialType)) < 0.001
    title(sprintf('Monkey %s, Session %d, p<0.001',strMonkey,iSessionIndex));
   elseif (a2fP_ReactionTime(iSession,iTrialType)) < 0.01
        title(sprintf('Monkey %s, Session %d, p<0.01',strMonkey,iSessionIndex));       
   else
       title(sprintf('Monkey %s, Session %d, p<0.05',strMonkey,iSessionIndex));       
   end   
   xlabel('Time (sec)');
   
end

%%
[aiSessions, aiTrials]=find(a2fP_ExitAngle<0.05)
[aiSessions,aiTmp]=sort(aiSessions)
aiTrials = aiTrials(aiTmp);
iNumSig = length(aiSessions);
   figure(11);
   clf;
for iIter=1:iNumSig
   iSession =  aiSessions(iIter);
   iTrialType = aiTrials(iIter);5
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
a2fP_Amp(a2fP_ExitAngle<0.05)

for iIter=1:6
figure(10001+iIter);clf;set(gcf,'color',[1 1 1]);
   iSession =  aiSessions(iIter);
   iTrialType = aiTrials(iIter);
   [a1,b1]=rose(a2cExitAngles{iSession,iTrialType},100);
   [a2,b2]=rose(a2cExitAnglesStim{iSession,iTrialType},100);
    hold off;
   fnMyPolarFilled(a2,b2,'r')
   hold on;
   fnMyPolarFilled(a1,b1,'b')
   
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

%