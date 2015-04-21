function strctStat = fnAnalyzeIdentityMatchingTrinity(astrctSortedTrials, strctGeneralInfo, strctKofiko,strctDesign)
LookupTable = [NaN, NaN;
                            NaN, NaN; 
                             1,0
                             1,1
                             1,2
                             1,3
                             1,4
                             2,0
                             2,1
                             2,2
                             2,3
                             2,4
                             3,0
                             3,1
                             3,2
                             3,3
                             3,4
                             4,0
                             4,1
                             4,2
                             4,3
                             4,4
                             5,0
                             5,1
                             5,2
                             5,3
                             5,4
                             1,0
                             1,1
                             1,2
                             1,3
                             1,4
                             2,0
                             2,1
                             2,2
                             2,3
                             2,4
                             3,0
                             3,1
                             3,2
                             3,3
                             3,4
                             4,0
                             4,1
                             4,2
                             4,3
                             4,4
                             5,0
                             5,1
                             5,2
                             5,3
                             5,4];                             

SummaryAll = [];
for iTrialTypeIndex = [1,3]
    fprintf('Looking into trial type %s\n',astrctSortedTrials(iTrialTypeIndex).m_strctTrialType.TrialParams.Name)

    iNumTrials = length(astrctSortedTrials(iTrialTypeIndex).m_acTrials);
    SummaryTable = zeros(iNumTrials, 3);
     for iTrialIter=1:iNumTrials
            iIdentity = LookupTable(astrctSortedTrials(iTrialTypeIndex).m_acTrials{iTrialIter}.m_astrctCueMedia(1).m_iMediaIndex, 1);
            iViewDirectionIndex = LookupTable(astrctSortedTrials(iTrialTypeIndex).m_acTrials{iTrialIter}.m_astrctCueMedia(1).m_iMediaIndex, 2);
            
            switch astrctSortedTrials(iTrialTypeIndex).m_acTrials{iTrialIter}.m_strctTrialOutcome.m_strResult
                case 'Correct'
                    iResult = 1;
                case 'Incorrect'
                    iResult = 0;
                otherwise
                    iResult = 2;
            end
            SummaryTable(iTrialIter,1) = iIdentity;
            SummaryTable(iTrialIter,2) = iViewDirectionIndex;
            SummaryTable(iTrialIter,3) = iResult;
     end
     SummaryAll = [SummaryAll;SummaryTable];
end

abSubset = SummaryAll(:,3)==1 | SummaryAll(:,3)==0;
iNumSubset = sum(abSubset);
iNumCorrectOnSubset = sum(SummaryAll(abSubset, 3) == 1);
fprintf('Correct performance: %.2f\n', iNumCorrectOnSubset/iNumSubset*1e2)

for iID=1:5
    abSubset = (SummaryAll(:,3)==1 | SummaryAll(:,3)==0) & SummaryAll(:,1) == iID;
    iNumSubset = sum(abSubset);
    iNumCorrectOnSubset = sum(SummaryAll(abSubset, 3) == 1);
    fprintf('%d Trials, Correct performance: %.2f\n', iNumSubset, iNumCorrectOnSubset/iNumSubset*1e2)
    strctStat.m_afPerformanceAcrossIdentities(iID) = iNumCorrectOnSubset/iNumSubset*1e2;
end

return;

