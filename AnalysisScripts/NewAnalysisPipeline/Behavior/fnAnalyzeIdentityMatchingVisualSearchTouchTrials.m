function strctStat = fnAnalyzeIdentityMatchingVisualSearchTouchTrials(astrctSortedTrials, strctGeneralInfo, strctKofiko,strctDesign)
strctStat = [];
% Find relevant trial types....
acRelevantTrialTypes = {...
'IdentityMatching_Training_Exp1',...
'IdentityMatching_Easy2_Exp1',... 
'IdentityMatching_Easy2_ShortMemory_Exp1'};%,...'IdentityMatching_4Option_Exp1'};

a2fSummary = zeros(0,4); % ID, Yaw, Pitch, Outcome(0=timeout,1=success,-1=fail), ReactionTime, Memory
for iTrialTypeIter=1:length(astrctSortedTrials)
    if  ismember( astrctSortedTrials(iTrialTypeIter).m_strctTrialType.TrialParams.Name,acRelevantTrialTypes)
        iNumTrials = length(astrctSortedTrials(iTrialTypeIter).m_acTrials);
        for iTrialIter=1:iNumTrials
            % Parse file name to identify angle....
            iMediaIndex = astrctSortedTrials(iTrialTypeIter).m_acTrials{iTrialIter}.m_strctCueMedia.m_iMediaIndex;
            acAttributes = setdiff(strctDesign.m_acAttributes(            strctDesign.m_a2bMediaAttributes(iMediaIndex,:)),'IdentityMatching_Exp1');
            iIdentity = str2num(acAttributes{1}(9:end));
               
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
            a2fSummary = [a2fSummary; iIdentity,iOutcome, fReactionTime,fMemory];
        end
    end
end
if isempty(a2fSummary)
    return;
end;
% Build performance curve as a function of identity
% Overall performance:
abTimeout = a2fSummary(:,2) == 0;
abCorrect = a2fSummary(:,2) == 1;
iNumValid = length(abTimeout)-sum(abTimeout);
fprintf('%d trials\n', length(abTimeout));
fprintf('Of which, %d timeout, remaining %d valid trials. \n', sum(abTimeout), iNumValid);
fprintf('%d Correct (%.2f%%)\n', sum(abCorrect), sum(abCorrect)/iNumValid*1e2);

aiIdentities = unique(a2fSummary(:,1));
iNumID = length(aiIdentities);
afPerformance = zeros(1,iNumID);
for k=1:iNumID
    aiRelevantTrials = find(a2fSummary(:,1) == k & ~abTimeout);
    iNumCorrect = sum(a2fSummary(aiRelevantTrials,2) == 1);
    afPerformance(k) = iNumCorrect/length(aiRelevantTrials)*1e2;
    fprintf('ID %d: %d Trials, %.2f%% Correct\n',k, length(aiRelevantTrials),  afPerformance(k));
end
figure;
clf;
plot(1:iNumID, afPerformance);
xlabel('Identity');
ylabel('Performance (%)');
axis([1 iNumID  0 100]);
set(gcf,'Name',sprintf('%s, %s',strctGeneralInfo.m_strSubjectName,strctGeneralInfo.m_strTimeDate));



return;
