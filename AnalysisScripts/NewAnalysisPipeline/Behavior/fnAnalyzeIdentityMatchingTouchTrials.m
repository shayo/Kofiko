function strctStat = fnAnalyzeIdentityMatchingTouchTrials(astrctSortedTrials, strctGeneralInfo, strctKofiko,strctDesign)
strctStat = [];
% Find relevant trial types....
acRelevantTrialTypes = {...
'IdentityMatching_Same_Exp1',...
'IdentityMatching_Different_Exp1',... 
'IdentityMatching_Same_Exp2',...
'IdentityMatching_Different_Exp2'};

a2fSummary = zeros(0,6); % Identity1, Identity2,  FaceGen, bObject, Outcome(0=timeout,1=success,-1=fail), ReactionTime 
for iTrialTypeIter=1:length(astrctSortedTrials)
    if  ismember( astrctSortedTrials(iTrialTypeIter).m_strctTrialType.TrialParams.Name,acRelevantTrialTypes)
        iNumTrials = length(astrctSortedTrials(iTrialTypeIter).m_acTrials);
        for iTrialIter=1:iNumTrials
            % Parse file name to identify angle....
            iMediaIndex1 = astrctSortedTrials(iTrialTypeIter).m_acTrials{iTrialIter}.m_astrctCueMedia(1).m_iMediaIndex;
            iMediaIndex2 = astrctSortedTrials(iTrialTypeIter).m_acTrials{iTrialIter}.m_astrctCueMedia(2).m_iMediaIndex;
            
            acAttributes1 = setdiff(strctDesign.m_acAttributes(strctDesign.m_a2bMediaAttributes(iMediaIndex1,:)),{'IdentityMatching_Exp1','IdentityMatching_Exp2'});
            acAttributes2 = setdiff(strctDesign.m_acAttributes(strctDesign.m_a2bMediaAttributes(iMediaIndex2,:)),{'IdentityMatching_Exp1','IdentityMatching_Exp2'});
            
            bObject = false;
            bFaceGen = false;
             
            if strncmpi(acAttributes1{1},'Identity',8)
                iIdentity1 = str2num(acAttributes1{1}(9:end));
            else
                 % Face gen
                 bFaceGen = true;
                 iIdentity1 = str2num(acAttributes1{1}(13:end));
            end
            
           if strncmpi(acAttributes2{1},'Identity',8)
                iIdentity2 = str2num(acAttributes2{1}(9:end));
            else
                 % Face gen
                 bFaceGen = true;
                 iIdentity2 = str2num(acAttributes2{1}(13:end));
            end            
                 
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
            a2fSummary = [a2fSummary; iIdentity1,iIdentity2, bFaceGen, bObject, iOutcome, fReactionTime];
        end
    end
end

if isempty(a2fSummary)
    return;
end;
% Build performance curve as a function of identity
% Overall performance:
abTimeout = a2fSummary(:,5) == 0;
abCorrect = a2fSummary(:,5) == 1;
abFaceGenTrials = a2fSummary(:,3) == 1;
iNumValid = length(abTimeout)-sum(abTimeout);
fprintf('%d trials\n', length(abTimeout));
fprintf('Of which, %d timeout, remaining %d valid trials. \n', sum(abTimeout), iNumValid);
fprintf('%d Correct (%.2f%%)\n', sum(abCorrect), sum(abCorrect)/iNumValid*1e2);

fprintf('Performance with face gen faces\n');
fprintf('%d Correct (%.2f%%)\n', sum(abCorrect &abFaceGenTrials ), sum(abCorrect&abFaceGenTrials )/sum(abFaceGenTrials)*1e2);

fprintf('Performance with real faces\n');
fprintf('%d Correct (%.2f%%)\n', sum(abCorrect &~abFaceGenTrials ), sum(abCorrect&~abFaceGenTrials )/sum(~abFaceGenTrials)*1e2);


% Generate confusion matrices....
%  a2fPercentCorrect = ones(iNumIDs,iNumIDs)*NaN;
%  a2iNumTrials = zeros(iNumIDs,iNumIDs);
% for iID1=1:iNumIDs
%     for iID2=iID1:iNumIDs
%         aiRelevantTrials = find(  ( (a2fSummary(:,1) == iID1 & a2fSummary(:,2)) == iID2 | (a2fSummary(:,1) == iID2 & a2fSummary(:,2) == iID1))  & a2fSummary(:,3) == 0);
%         a2iNumTrials(iID1,iID2) = length(aiRelevantTrials);
%         a2fPercentCorrect(iID1,iID2) = sum(a2fSummary(aiRelevantTrials,5) == 1) / length(aiRelevantTrials) * 1e2;
%     end
% end

abNotFaceGen = a2fSummary(:,3) == 0;

iNumIDs= max(a2fSummary(abNotFaceGen,1));


a2iTemp = a2fSummary(abNotFaceGen,1:2);
aiOutCome = a2fSummary(abNotFaceGen,5);
a2iNumTrials = zeros(iNumIDs,iNumIDs);
a2iNumCorrect = zeros(iNumIDs,iNumIDs);
for k=1:size(a2iTemp,1)
    a2iNumTrials( a2iTemp(k,1),a2iTemp(k,2)) = a2iNumTrials( a2iTemp(k,1),a2iTemp(k,2))+1;
    if aiOutCome(k) == 1
        a2iNumCorrect(a2iTemp(k,1),a2iTemp(k,2)) =a2iNumCorrect(a2iTemp(k,1),a2iTemp(k,2))+1;
        a2iNumCorrect(a2iTemp(k,2),a2iTemp(k,1)) =a2iNumCorrect(a2iTemp(k,2),a2iTemp(k,1))+1;
    end
    
    a2iNumTrials( a2iTemp(k,2),a2iTemp(k,1)) = a2iNumTrials( a2iTemp(k,2),a2iTemp(k,1))+1;
end
a2fConfusion = a2iNumCorrect./a2iNumTrials;
a2bDiag = eye(size(a2fConfusion))>0;
a2fConfusion(~a2bDiag) = 1-a2fConfusion(~a2bDiag);
strctStat.m_a2fConfusion = a2fConfusion;
strctStat.m_a2iNumTrials= a2iNumTrials;

% Siginifance using binomial distribution and 0.5 chance level...
strctStat.m_a2fPValue = zeros(iNumIDs,iNumIDs);
for i=1:iNumIDs
    for j=1:iNumIDs
             strctStat.m_a2fPValue(i,j) = 2*sum(binopdf(a2iNumCorrect(i,j):a2iNumTrials(i,j),a2iNumTrials(i,j),0.5));
      end
end


return;
