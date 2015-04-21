function strctStat = fnAnalyzeViewDirectionTouchTrials(astrctSortedTrials, strctGeneralInfo, strctKofiko,strctDesign)
%%
strctStat = [];
% Find relevant trial types....
acRelevantTrialTypes = {'ViewDirection_Left_Easy_Exp1',...
                                          'ViewDirection_Right_Easy_Exp1',...
                                          'ViewDirection_Left_Intermediate_Exp1',...
                                          'ViewDirection_Right_Intermediate_Exp1',...
                                          'ViewDirection_Left_Hard_Exp1',...
                                          'ViewDirection_Right_Hard_Exp1'...
                                          'ViewDirection_Right_Memory_Short_Exp1' ...
                                          'ViewDirection_Left_Memory_Short_Exp1'...
                                          'ViewDirection_Right_Memory_Long_Exp1'...
                                          'ViewDirection_Left_Memory_Long_Exp1',...
                                          'ViewDirection_Right_Memory_Short_Exp1',...
                                          'ViewDirection_Left_Memory_Short_Exp1',...
                                          'ViewDirection_Left_Memory_Short_ID1',...
                                          'ViewDirection_Right_Memory_Short_ID1',...
                                          'ViewDirection_Left_Memory_Short_ID2',...
                                          'ViewDirection_Right_Memory_Short_ID2',...
                                          'ViewDirection_Left_Memory_Short_ID3',...
                                          'ViewDirection_Right_Memory_Short_ID3',...
                                          'ViewDirection_Left_Memory_Short_ID4',...
                                          'ViewDirection_Right_Memory_Short_ID4',...
                                          'ViewDirection_Left_Memory_Short_Obj1',...
                                          'ViewDirection_Right_Memory_Short_Obj1',...
                                          'ViewDirection_Left_Memory_Short_Obj2',...
                                          'ViewDirection_Right_Memory_Short_Obj2'};

a2fSummary = zeros(0,8); % ID, Yaw, Pitch, Outcome(0=timeout,1=success,-1=fail), ReactionTime, Memory, Object(1), TrialType,
for iTrialTypeIter=1:length(astrctSortedTrials)
    if  ismember( astrctSortedTrials(iTrialTypeIter).m_strctTrialType.TrialParams.Name,acRelevantTrialTypes)
        iNumTrials = length(astrctSortedTrials(iTrialTypeIter).m_acTrials);
        for iTrialIter=1:iNumTrials
            % Parse file name to identify angle....
            if ~isfield(astrctSortedTrials(iTrialTypeIter).m_acTrials{iTrialIter},'m_strctCueMedia')
                strctCue = astrctSortedTrials(iTrialTypeIter).m_acTrials{iTrialIter}.m_astrctCueMedia;
            else
                strctCue = astrctSortedTrials(iTrialTypeIter).m_acTrials{iTrialIter}.m_astrctCueMedia;
            end
            
                aiUnderscore = find(.m_strFileName == '_');
                aiSlash = find(strctCue.m_strFileName == '\');
            
            if strncmpi(strctCue.m_strFileName(aiSlash(end)+1:end),'ID',2)
                % Face trial
                iIdentity = str2num(strctCue.m_strFileName(aiSlash(end)+3:aiUnderscore(1)-1));
                bObject = false;
            else
                % Object trial
                iIdentity = str2num(strctCue.m_strFileName(aiSlash(end)+4:aiUnderscore(1)-1));
                bObject = true;
            end
            
            fYaw = str2num(strctCue.m_strFileName(aiUnderscore(2)+1:aiUnderscore(3)-1));
            fPitch = str2num(strctCue.m_strFileName(aiUnderscore(end)+1:end-4));
            
            switch astrctSortedTrials(iTrialTypeIter).m_acTrials{iTrialIter}.m_strctTrialOutcome.m_strResult
                case 'Incorrect'
                    iOutcome = -1;
                    fReactionTime = astrctSortedTrials(iTrialTypeIter).m_acTrials{iTrialIter}.m_strctTrialOutcome.m_afTouchChoiceTS-astrctSortedTrials(iTrialTypeIter).m_acTrials{iTrialIter}.m_strctTrialOutcome.m_fChoicesOnsetTS_Kofiko;
                case 'Correct'
                    iOutcome = 1;
                    fReactionTime = astrctSortedTrials(iTrialTypeIter).m_acTrials{iTrialIter}.m_strctTrialOutcome.m_afTouchChoiceTS-astrctSortedTrials(iTrialTypeIter).m_acTrials{iTrialIter}.m_strctTrialOutcome.m_fChoicesOnsetTS_Kofiko;
                otherwise
                    iOutcome = 0;
                    fReactionTime = NaN;
            end
            
            if isempty(astrctSortedTrials(iTrialTypeIter).m_acTrials{iTrialIter}.m_strctMemoryPeriod)
                fMemory = 0;
            else
                 fMemory = astrctSortedTrials(iTrialTypeIter).m_acTrials{iTrialIter}.m_strctMemoryPeriod.m_fMemoryPeriodMS;
            end
            a2fSummary = [a2fSummary; iIdentity,fYaw,fPitch,iOutcome, fReactionTime,fMemory,bObject,iTrialTypeIter];
        end
    else
        fprintf('Trial Type %s not analyzed. Not in relevant set\n', astrctSortedTrials(iTrialTypeIter).m_strctTrialType.TrialParams.Name);
    end
end
%%
if isempty(a2fSummary)
    return;
end;
% Build psychometric curve?

afTestedAngles = unique(a2fSummary(:,2));
iNumAngles = length(afTestedAngles);
afPercentCorrect = zeros(1,iNumAngles);
aiNumTrials = zeros(1,iNumAngles);
aiNumTimeouts = zeros(1,iNumAngles);
for iAngleIter=1:iNumAngles
    abRelevantEntries = a2fSummary(:,2) == afTestedAngles(iAngleIter) ;
    aiNumTrials(iAngleIter) = sum(abRelevantEntries);
    afPercentCorrect(iAngleIter) = sum(a2fSummary(abRelevantEntries,4) == 1)  / (sum(a2fSummary(abRelevantEntries,4) == 1) +sum(a2fSummary(abRelevantEntries,4) == -1) );
    aiNumTimeouts(iAngleIter) = sum(a2fSummary(abRelevantEntries,4) == 0);
end

[afUniqueAngles, Dummy, aiMapping]=unique(abs(afTestedAngles));
iNumUniqueAngles = length(afUniqueAngles);
afPercentCorrectAbs = zeros(1, iNumUniqueAngles);
aiNumTrialsAbs = zeros(1,iNumUniqueAngles);
for iAngleIter=1:length(afUniqueAngles)
    abRelevantEntries = abs(a2fSummary(:,2)) == afUniqueAngles(iAngleIter);
    aiNumTrials(iAngleIter) = sum(abRelevantEntries);
    afPercentCorrectAbs(iAngleIter) = sum(a2fSummary(abRelevantEntries,4) == 1)  / (sum(a2fSummary(abRelevantEntries,4) == 1) +sum(a2fSummary(abRelevantEntries,4) == -1) );
    aiNumTrialsAbs(iAngleIter) = sum(a2fSummary(abRelevantEntries,4) == 0);
end

figure;
clf;
subplot(2,2,1);
plot(afTestedAngles, afPercentCorrect,'b.');hold on;
plot(afTestedAngles, afPercentCorrect,'r');
xlabel('Yaw Angle (deg)');
ylabel('Percent correct');
subplot(2,2,2);
% Show absolute graph...
plot(afUniqueAngles,afPercentCorrectAbs,'b.');hold on;
plot(afUniqueAngles,afPercentCorrectAbs,'r');
xlabel('Abs Yaw Angle (deg)');
ylabel('Percent correct');
set(gca,'ylim',[0.2 1]');
subplot(2,2,3);
bar(afTestedAngles, aiNumTrials+aiNumTimeouts,'r'); hold on;
bar(afTestedAngles, aiNumTrials,'b');
legend({'All Trials','Timeout'},'Location','SouthOutside');
xlabel('Yaw Angle (deg)');
ylabel('Num Trials');
set(gcf,'Name',sprintf('%s, %s',strctGeneralInfo.m_strSubjectName,strctGeneralInfo.m_strTimeDate));

strctStat.m_afUniqueAngles = afUniqueAngles;
strctStat.m_afPercentCorrectAbs = afPercentCorrectAbs;
return;
